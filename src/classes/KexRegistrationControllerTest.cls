@IsTest
private class KexRegistrationControllerTest {

    private static Integer volCount = 0;

    static testmethod void testRegister() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId =
            testDataFactory.createShift().id;
        Id shift2Id =
            testDataFactory.createShift().id;

        // Initially start with 1 volunteer.
        KexSourceUser newVol =
            createNewVolunteer();
        KexRegistrationReq regReq =
            createRegistrationReq(shiftId);

        KexRestServiceResponse regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error == null,
            'registration should be successful: ' + JSON.serialize(regResult.error));

        Contact newVolContact =
            lookupVolunteer(newVol, shiftId);
        System.assert(newVolContact != null, 'volunteer should have been persisted');
        System.assert(newVolContact.HasOptedOutOfEmail == false, 'emailOptOut should be initialized to false');
        List<GW_Volunteers__Volunteer_Hours__c> volHrs =
            newVolContact.GW_Volunteers__Volunteer_Hours__r;
        System.assert(volHrs.size() == 1, 'volunteer hours size incorrect: ' + volHrs);
        GW_Volunteers__Volunteer_Hours__c volHr =
            volHrs[0];
        System.assert(volHr.GW_Volunteers__Status__c.equals('Confirmed') &&
            (volHr.GW_Volunteers__Number_of_Volunteers__c == 1), 'volunteer hour incorrectly initialized: ' + volHr);

        // Register the same volunteer with another shift. Make sure one shift does not influence the other.
        regReq =
            createRegistrationReq(shift2Id, 4);
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error == null,
            'registration should be successful: ' + JSON.serialize(regResult.error));

        newVolContact =
            lookupVolunteer(newVol, shift2Id);
        volHrs =
            newVolContact.GW_Volunteers__Volunteer_Hours__r;
        System.assert(volHrs.size() == 1, 'volunteer hours size incorrect: ' + volHrs);
        volHr =
            volHrs[0];
        System.assert(volHr.GW_Volunteers__Status__c.equals('Confirmed') &&
            (volHr.GW_Volunteers__Number_of_Volunteers__c == 4), 'volunteer hour incorrectly initialized: ' + volHr);

        newVolContact =
            lookupVolunteer(newVol, shiftId);
        volHrs =
            newVolContact.GW_Volunteers__Volunteer_Hours__r;
        System.assert(volHrs.size() == 1, 'volunteer hours size incorrect: ' + volHrs);
        volHr =
            volHrs[0];
        System.assert(volHr.GW_Volunteers__Status__c.equals('Confirmed') &&
            (volHr.GW_Volunteers__Number_of_Volunteers__c == 1), 'volunteer hour incorrectly initialized: ' + volHr);


        // Next update the registration to add a volunteer.
        regReq =
            createRegistrationReq(shiftId, 2);
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error == null,
            '2nd registration should be successful: ' + JSON.serialize(regResult.error));

        newVolContact =
            lookupVolunteer(newVol, shiftId);
        volHrs =
            newVolContact.GW_Volunteers__Volunteer_Hours__r;
        System.assert(volHrs.size() == 1, '2nd volunteer hours size incorrect: ' + volHrs);
        volHr =
            volHrs[0];
        System.assert(volHr.GW_Volunteers__Status__c.equals('Confirmed') &&
            (volHr.GW_Volunteers__Number_of_Volunteers__c == 2), '2nd volunteer hour incorrectly initialized: ' + volHr);

        // Now only update the volunteer prefs.
        newVol.emailOptOut = true;
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                null,
                newVol);
        System.assert(regResult.error == null,
            '3rd req should be successful: ' + JSON.serialize(regResult.error));
        newVolContact =
            lookupVolunteer(newVol, shiftId);
        System.assert(newVolContact.HasOptedOutOfEmail == true, 'emailOptOut should be initialized to false');

        // Cancel the registration
        regReq =
            createUnregisterReq(shiftId);
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error == null,
            '4th req should be successful: ' + JSON.serialize(regResult.error));

        newVolContact =
            lookupVolunteer(newVol, shiftId);
        volHrs =
            newVolContact.GW_Volunteers__Volunteer_Hours__r;
        System.assert(volHrs.size() == 1, '4th volunteer hours size incorrect: ' + volHrs);
        volHr =
            volHrs[0];
        System.assert(volHr.GW_Volunteers__Status__c.equals('Canceled'),
            '4th volunteer hour incorrectly initialized: ' + volHr);

        // Update prefs when unregistered.
        newVol.emailOptOut = false;
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                null,
                newVol);
        System.assert(regResult.error == null,
            'req should be successful: ' + JSON.serialize(regResult.error));
        newVolContact =
            lookupVolunteer(newVol, shiftId);
        System.assert(newVolContact.HasOptedOutOfEmail == false, 'emailOptOut should be initialized to false');

        // Now re-register.
        regReq =
            createRegistrationReq(shiftId, 3);
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error == null,
            'req should be successful: ' + JSON.serialize(regResult.error));

        newVolContact =
            lookupVolunteer(newVol, shiftId);
        volHrs =
            newVolContact.GW_Volunteers__Volunteer_Hours__r;
        System.assert(volHrs.size() == 1, 'volunteer hours size incorrect: ' + volHrs);
        volHr =
            volHrs[0];
        System.assert(volHr.GW_Volunteers__Status__c.equals('Confirmed') &&
            (volHr.GW_Volunteers__Number_of_Volunteers__c == 3), 'volunteer hour incorrectly initialized: ' + volHr);
    }

    static testmethod void testUpdatePrefs() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        KexSourceUser newVol =
            createNewVolunteer();
        Account org1 = new Account();
        org1.name = 'test-org1';
        insert org1;
        Account org2 = new Account();
        org2.name = 'test-org2';
        insert org2;

        // First insert a new user with two prefs and and make sure the prefs are copied.
        newVol.orgPrefs = new List<KexOrgPrefs> {
            createOrgPrefs(org1, true),
            createOrgPrefs(org2, false) };

        KexRestServiceResponse reqResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                null,
                newVol);
        System.assert(reqResult.error == null,
            'req should be successful: ' + JSON.serialize(reqResult.error));

        Contact newVolContact =
            lookupVolunteer(newVol);
        System.assert(newVolContact != null, 'volunteer should have been persisted');
        System.assert(newVolContact.HasOptedOutOfEmail == false, 'emailOptOut should be initialized to false');
        Map<Id, Volunteer_Preferences_Per_Org__c> volPrefsMap =
            createOrgPrefsMap(newVolContact);
        System.assert(volPrefsMap.size() == 2, 'volunteer prefs map size incorrect: ' + volPrefsMap);
        Volunteer_Preferences_Per_Org__c volPref =
            volPrefsMap.get(org1.id);
        System.assert( (volPref != null) && (volPref.Has_Opted_Out_Of_Email__c == true),
            'volPref mismatch: ' + volPref);
        volPref =
            volPrefsMap.get(org2.id);
        System.assert( (volPref != null) && (volPref.Has_Opted_Out_Of_Email__c == false),
            'volPref mismatch: ' + volPref);

        // Then remove a pref and change the other pref.
        newVol.orgPrefs = new List<KexOrgPrefs> {
            createOrgPrefs(org1, false) };

        reqResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                null,
                newVol);
        System.assert(reqResult.error == null,
            'req should be successful: ' + JSON.serialize(reqResult.error));

        newVolContact =
            lookupVolunteer(newVol);
        System.assert(newVolContact != null, 'volunteer should have been persisted');
        volPrefsMap =
            createOrgPrefsMap(newVolContact);
        System.assert(volPrefsMap.size() == 1, 'volunteer prefs map size incorrect: ' + volPrefsMap);
        volPref =
            volPrefsMap.get(org1.id);
        System.assert( (volPref != null) && (volPref.Has_Opted_Out_Of_Email__c == false),
            'volPref mismatch: ' + volPref);

        // Then add a new pref.
        Account org3 = new Account();
        org3.name = 'test-org3';
        insert org3;
        newVol.orgPrefs = new List<KexOrgPrefs> {
            createOrgPrefs(org1, false),
            createOrgPrefs(org3, true) };

        reqResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                null,
                newVol);
        System.assert(reqResult.error == null,
            'req should be successful: ' + JSON.serialize(reqResult.error));

        newVolContact =
            lookupVolunteer(newVol);
        System.assert(newVolContact != null, 'volunteer should have been persisted');
        volPrefsMap =
            createOrgPrefsMap(newVolContact);
        System.assert(volPrefsMap.size() == 2, 'volunteer prefs map size incorrect: ' + volPrefsMap);
        volPref =
            volPrefsMap.get(org1.id);
        System.assert( (volPref != null) && (volPref.Has_Opted_Out_Of_Email__c == false),
            'volPref mismatch: ' + volPref);
        volPref =
            volPrefsMap.get(org3.id);
        System.assert( (volPref != null) && (volPref.Has_Opted_Out_Of_Email__c == true),
            'volPref mismatch: ' + volPref);

    }

    static testmethod void testAuthFailureException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        KexSourceUser newVol =
            createNewVolunteer();

        KexRestServiceResponse reqResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.INVALID_SECRET_KEY,
                null,
                newVol);
        System.assert(reqResult.error != null, 'doPost should not have succeeded');
        System.assert(reqResult.error.type.equals(KexErrorInfo.ErrorType.AUTHENTICATION_FAILURE.name()),
            'error type should be auth failure: '  + reqResult.error.type);
    }

    static testmethod void testInvalidParamException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();

        KexRestServiceResponse reqResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                null,
                null);
        System.assert(reqResult.error != null, 'doPost should not have succeeded');
        System.assert(reqResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            'null user param is invalid: '  + reqResult.error.type);
    }

    static testmethod void testObjectNotFoundException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift =
            testDataFactory.createShift();
        KexSourceUser newVol =
            createNewVolunteer();
        KexRegistrationReq regReq =
            createRegistrationReq(shift.id);
        delete shift;

        KexRestServiceResponse regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.OBJECT_NOT_FOUND.name()),
            'deleted shift should not be found: '  + regResult.error.type);
    }

    static testmethod void testRegistrationLimitReachedException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexSourceUser newVol;
        KexRegistrationReq regReq;
        KexRestServiceResponse regResult;
        for (Integer i=0; i < KexTestDataFactory.MAX_SHIFT_VOLUNTEERS; i++) {
            newVol =
                createNewVolunteer();
            regReq =
                createRegistrationReq(shiftId);
            regResult =
                KexRegistrationController.doPost(
                    KexTestDataFactory.SECRET_KEY,
                    regReq,
                    newVol);
            System.assert(regResult.error == null, 'doPost should succeed');
        }
        // The next registration should fail.
        newVol =
            createNewVolunteer();
        regReq =
            createRegistrationReq(shiftId);
        regResult =
            KexRegistrationController.doPost(
                KexTestDataFactory.SECRET_KEY,
                regReq,
                newVol);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.REGISTRATION_LIMIT_REACHED.name()),
            'expected registration limit error: '  + regResult.error.type);
    }

    private static KexSourceUser createNewVolunteer() {
         KexSourceUser volunteer =
            new KexSourceUser();
        volCount++;
        volunteer.firstName = 'KexTestVol' + volCount;
        volunteer.lastName =  'KexTestVol' + volCount;
        volunteer.email = 'KexTesVol' + volCount + '@x.y';
        volunteer.emailOptOut = false;
        return volunteer;
    }

    private static KexOrgPrefs createOrgPrefs(Account orgAcc, boolean emailOptOut) {
        return new KexOrgPrefs(
           new KexOrg(orgAcc),
           emailOptOut);
    }

    private static Contact lookupVolunteer(KexSourceUser sourceUser) {
        Contact[] contactQueryResult =
          [Select
                ID,
                FirstName,
                LastName,
                Email,
                HasOptedOutOfEmail,
                (SELECT
                    prefs.Org__c,
                    prefs.Has_Opted_Out_Of_Email__c
                 FROM c.Volunteer_Preferences_Per_Org__r prefs)
           FROM Contact c
           WHERE
                  c.FirstName = :sourceUser.firstName and
                  c.LastName = :sourceUser.lastName and
                  c.Email = :sourceUser.email];
        if (contactQueryResult.isEmpty()) {
            return null;
        } else {
            System.assert(contactQueryResult.size() == 1, 'multiple contacts found');
            return contactQueryResult[0];
        }
    }

    private static Contact lookupVolunteer(KexSourceUser sourceUser, Id shiftId) {
        Contact[] contactQueryResult =
          [Select
                ID,
                FirstName,
                LastName,
                Email,
                HasOptedOutOfEmail,
                (SELECT
                    prefs.Org__c,
                    prefs.Has_Opted_Out_Of_Email__c
                 FROM c.Volunteer_Preferences_Per_Org__r prefs),
                (SELECT
                    vh.GW_Volunteers__Status__c,
                    vh.GW_Volunteers__Number_of_Volunteers__c
                 FROM c.GW_Volunteers__Volunteer_Hours__r vh
                 WHERE vh.GW_Volunteers__Volunteer_Shift__c = :shiftId)
           FROM Contact c
           WHERE
                  c.FirstName = :sourceUser.firstName and
                  c.LastName = :sourceUser.lastName and
                  c.Email = :sourceUser.email];
        if (contactQueryResult.isEmpty()) {
            return null;
        } else {
            System.assert(contactQueryResult.size() == 1, 'multiple contacts found');
            return contactQueryResult[0];
        }
    }

    private static KexRegistrationReq createRegistrationReq(Id shiftId) {
        return createRegistrationReq(shiftId, 1);
    }

    private static KexRegistrationReq createRegistrationReq(Id shiftId, Integer numVolunteers) {
        KexRegistrationReq req =
            new KexRegistrationReq();
        req.action = KexRegistrationReq.RegistrationAction.REGISTER.name();
        req.eventId = shiftId;
        req.numVolunteers = numVolunteers;
        return req;
    }

    private static KexRegistrationReq createUnregisterReq(Id shiftId) {
        KexRegistrationReq req =
            new KexRegistrationReq();
        req.action = KexRegistrationReq.RegistrationAction.UNREGISTER.name();
        req.eventId = shiftId;
        return req;
    }

    private static Map<Id, Volunteer_Preferences_Per_Org__c> createOrgPrefsMap(Contact contact) {
        Map<Id, Volunteer_Preferences_Per_Org__c> orgPrefMap =
            new Map<Id, Volunteer_Preferences_Per_Org__c>();
        for (Volunteer_Preferences_Per_Org__c orgPref : contact.Volunteer_Preferences_Per_Org__r) {
            orgPrefMap.put(orgPref.Org__c, orgPref);
        }
        return orgPrefMap;
    }

}