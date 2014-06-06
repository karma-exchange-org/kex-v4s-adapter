@RestResource(urlMapping='/kex-debug/*')
global with sharing class KexDebugController {

    private static final String ORG_SECRET = Karma_Exchange_Admin_Settings__c.getInstance().SecretKey__c;

    @HttpPost
    global static KexRestServiceResponse doPost(String secretKey, String action, Id shiftId) {

        try {
            KexInvalidParamException.notNull('action', action);
            KexInvalidParamException.notNull('secretKey', secretKey);
            if (!ORG_SECRET.equals(secretKey)) {
                throw new KexAuthFailureException();
            }

            if (DebugAction.SYNC.name().equals(action)) {
                KexInvalidParamException.notNull('shiftId', shiftId);
                KexAdminController.syncShiftFuture(shiftId);
                return new KexRestServiceResponse(KexSourceEvent.toEvent(shiftId));
            } else {
                throw KexInvalidParamException.create('action');
            }

        } catch (KexTypedException e) {
            return new KexRestServiceResponse(new KexErrorInfo(e));
        } catch (Exception e) {
            return new KexRestServiceResponse(new KexErrorInfo(e));
        }
    }

    private enum DebugAction {
        SYNC
    }

}