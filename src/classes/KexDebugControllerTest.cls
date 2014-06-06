@IsTest
private class KexDebugControllerTest {

    static testmethod void testDoPost() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;

        Test.startTest();
        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(shiftId);
        Test.setMock(HttpCalloutMock.class, syncMock);
        KexRestServiceResponse regResult = KexDebugController.doPost(
            KexTestDataFactory.SECRET_KEY, 'SYNC', shiftId);
        Test.stopTest();

        System.assert(regResult.error == null,
            'registration not successful: ' + JSON.serialize(regResult.error));
        System.assert(syncMock.numTimesInvoked == 1,
            'sync request not sent: ' + syncMock.numTimesInvoked);
    }

    static testmethod void testAuthFailureException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexRestServiceResponse regResult = KexDebugController.doPost(
            KexTestDataFactory.INVALID_SECRET_KEY, 'SYNC', shiftId);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.AUTHENTICATION_FAILURE.name()),
            'error type should be auth failure: '  + regResult.error.type);
    }

    static testmethod void testInvalidParamException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexRestServiceResponse regResult = KexDebugController.doPost(
            KexTestDataFactory.SECRET_KEY, 'SYNC', null);
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
            null, 'SYNC', shiftId);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            'null secret param should be invalid: '  + regResult.error.type);
    }
}