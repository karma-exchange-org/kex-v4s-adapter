@RestResource(urlMapping='/kex-debug/*')
global with sharing class KexDebugController {

    private static final String ORG_SECRET = Karma_Exchange_Admin_Settings__c.getInstance().SecretKey__c;

    @HttpPost
    global static RegistrationResponse doPost(String secretKey, String action, Id shiftId) {

        try {
            KexInvalidParamException.notNull('action', action);
            KexInvalidParamException.notNull('secretKey', secretKey);
            if (!ORG_SECRET.equals(secretKey)) {
                throw new KexAuthFailureException();
            }

            if (DebugAction.SYNC.name().equals(action)) {
                KexInvalidParamException.notNull('shiftId', shiftId);
                KexAdminController.syncShiftFuture(shiftId);
            } else {
                throw KexInvalidParamException.create('action');
            }

        } catch (KexTypedException e) {
            return new RegistrationResponse(
                new KexErrorInfo(e));
        }

        return new RegistrationResponse();
    }

    private enum DebugAction {
        SYNC
    }

    global class RegistrationResponse {
        public KexErrorInfo error;

        public RegistrationResponse() {
            this(null);
        }

        public RegistrationResponse(KexErrorInfo error) {
            this.error = error;
        }
    }

}