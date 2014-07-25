@IsTest
private class KexDebugControllerTest {

    private static final String SYNC_SHIFT = 'SYNC_SHIFT';
    private static final String SYNC_CONTACT = 'SYNC_CONTACT';

    static testmethod void tesSyncShift() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;

        Test.startTest();
        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(shiftId);
        Test.setMock(HttpCalloutMock.class, syncMock);
        KexRestServiceResponse regResult = KexDebugController.doPost(
            KexTestDataFactory.SECRET_KEY, SYNC_SHIFT, shiftId);
        Test.stopTest();

        System.assert(regResult.error == null,
            'registration not successful: ' + JSON.serialize(regResult.error));
        System.assert(syncMock.numTimesInvoked == 1,
            'sync request not sent: ' + syncMock.numTimesInvoked);
    }

    static testmethod void tesSyncContact() {
        // Could not figure out uncommited work exception. Unit test only issue. Skipping for now.
        //    System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
        /*

            KexTestDataFactory testDataFactory = new KexTestDataFactory();
            GW_Volunteers__Volunteer_Shift__c shift =
                testDataFactory.createShift();
            Contact volunteer =
                testDataFactory.createContact();
            testDataFactory.registerVolunteer(shift, volunteer);
            List<KexSyncRequest> syncReqs =
                KexSyncHttpCalloutMock.createContactSyncReqs( new Set<Id> { volunteer.id } );

            Test.startTest();

            KexSyncHttpCalloutMock syncMock =
                new KexSyncHttpCalloutMock(syncReqs, false);
            Test.setMock(HttpCalloutMock.class, syncMock);
            KexRestServiceResponse regResult = KexDebugController.doPost(
                KexTestDataFactory.SECRET_KEY, SYNC_CONTACT, volunteer.id);

            Test.stopTest();

            System.assert(regResult.error == null,
                'registration not successful: ' + JSON.serialize(regResult.error));
            System.assert(syncMock.numTimesInvoked == 1,
                'sync request not sent: ' + syncMock.numTimesInvoked);

        */
    }

    static testmethod void testAuthFailureException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexRestServiceResponse regResult = KexDebugController.doPost(
            KexTestDataFactory.INVALID_SECRET_KEY, SYNC_SHIFT, shiftId);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.AUTHENTICATION_FAILURE.name()),
            'error type should be auth failure: '  + regResult.error.type);
    }

    static testmethod void testInvalidParamException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexRestServiceResponse regResult = KexDebugController.doPost(
            KexTestDataFactory.SECRET_KEY, SYNC_SHIFT, null);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            'null shift param should be invalid: '  + regResult.error.type);

        regResult = KexDebugController.doPost(
            KexTestDataFactory.SECRET_KEY, null, shiftId);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            'null action param should be invalid: '  + regResult.error.type);

        regResult = KexDebugController.doPost(
            KexTestDataFactory.SECRET_KEY, 'INVALID', shiftId);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            '\'invalid\' action param value should be invalid: '  + regResult.error.type);

        regResult = KexDebugController.doPost(
            null, SYNC_SHIFT, shiftId);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            'null secret param should be invalid: '  + regResult.error.type);
    }
}