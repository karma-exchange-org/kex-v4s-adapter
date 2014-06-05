@IsTest
private class KexInvalidParamExceptionTest {

    static testmethod void testNotNull() {
        try {
            KexInvalidParamException.notNull('Name', null);
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('parameter \'Name\' is required'));
        }
    }
}