@IsTest
private class KexSyncContactTest {

    static testmethod void testSyncContact() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift =
            testDataFactory.createShift();
        Contact volunteer =
            testDataFactory.createContact();
        testDataFactory.registerVolunteer(shift, volunteer);

        // Validate no updates pending
        List<KexSyncTracker__c> pendingContacts =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Contact__c != null];
        System.assert(pendingContacts.size() == 0, 'Pending contacts size mismatch: ' + pendingContacts);

        // Update FirstName
        volunteer.FirstName =
            volunteer.FirstName + '2';
        update volunteer;

        pendingContacts =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Contact__c != null];
        System.assert(pendingContacts.size() == 1, 'Pending contacts size mismatch: ' + pendingContacts);

        // Update LastName
        volunteer.LastName =
            volunteer.LastName + '2';
        update volunteer;

        pendingContacts =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Contact__c != null];
        System.assert(pendingContacts.size() == 2, 'Pending contacts size mismatch: ' + pendingContacts);

        // Update Email
        volunteer.Email =
            'new.' + volunteer.Email;
        update volunteer;

        pendingContacts =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Contact__c != null];
        System.assert(pendingContacts.size() == 3, 'Pending contacts size mismatch: ' + pendingContacts);

        // Update opt out pref
        volunteer.HasOptedOutOfEmail =
            !volunteer.HasOptedOutOfEmail;
        update volunteer;

        pendingContacts =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Contact__c != null];
        System.assert(pendingContacts.size() == 4, 'Pending contacts size mismatch: ' + pendingContacts);

        // Disable auto update and ensure that we don't add rows.
        Karma_Exchange_Settings__c adminSettings =
            Karma_Exchange_Settings__c.getInstance();
        adminSettings.Auto_Sync__c = false;
        upsert adminSettings;

        volunteer.Email =
            'new.' + volunteer.Email;
        update volunteer;

        pendingContacts =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Contact__c != null];
        System.assert(pendingContacts.size() == 4, 'Pending contacts size mismatch: ' + pendingContacts);
    }

}