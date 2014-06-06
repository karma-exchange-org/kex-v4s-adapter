@IsTest
private class KexRegistrationControllerTest {

    static testmethod void testDoPost() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexRestServiceResponse regResult = KexRegistrationController.doPost('REGISTER',
            shiftId, 'KexTestFirst', 'KexTestLast', 'KexTestEmail@x.y',
            KexTestDataFactory.SECRET_KEY);
        System.assert(regResult.error == null,
            'registration not successful: ' + JSON.serialize(regResult.error));
    }

    static testmethod void testAuthFailureException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexRestServiceResponse regResult = KexRegistrationController.doPost('REGISTER',
            shiftId, 'KexTestFirst', 'KexTestLast', 'KexTestEmail@x.y',
            KexTestDataFactory.INVALID_SECRET_KEY);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.AUTHENTICATION_FAILURE.name()),
            'error type should be auth failure: '  + regResult.error.type);
    }

    static testmethod void testInvalidParamException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        KexRestServiceResponse regResult = KexRegistrationController.doPost('REGISTER',
            null, 'KexTestFirst', 'KexTestLast', 'KexTestEmail@x.y',
            KexTestDataFactory.SECRET_KEY);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.INVALID_PARAM.name()),
            'null shift param is invalid: '  + regResult.error.type);
    }

    static testmethod void testObjectNotFoundException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift =
            testDataFactory.createShift();
        delete shift;

        KexRestServiceResponse regResult = KexRegistrationController.doPost('REGISTER',
            shift.id, 'KexTestFirst', 'KexTestLast', 'KexTestEmail@x.y',
            KexTestDataFactory.SECRET_KEY);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.OBJECT_NOT_FOUND.name()),
            'deleted shift should not be found: '  + regResult.error.type);
    }

    static testmethod void testRegistrationLimitReachedException() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        Contact contact;
        for (Integer i=0; i < KexTestDataFactory.MAX_SHIFT_VOLUNTEERS; i++) {
            contact = testDataFactory.createContact();
            KexRestServiceResponse regResult = KexRegistrationController.doPost('REGISTER',
                shiftId, contact.firstName, contact.lastName, contact.Email,
                KexTestDataFactory.SECRET_KEY);
            System.assert(regResult.error == null, 'doPost should succeed');
        }
        // The next registration should fail.
        contact = testDataFactory.createContact();
        KexRestServiceResponse regResult = KexRegistrationController.doPost('REGISTER',
            shiftId, contact.firstName, contact.lastName, contact.Email,
            KexTestDataFactory.SECRET_KEY);
        System.assert(regResult.error != null, 'doPost should not have succeeded');
        System.assert(regResult.error.type.equals(KexErrorInfo.ErrorType.REGISTRATION_LIMIT_REACHED.name()),
            'expected registration limit error: '  + regResult.error.type);
    }

}