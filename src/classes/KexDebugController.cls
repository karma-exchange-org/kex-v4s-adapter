@RestResource(urlMapping='/kex-debug/*')
global without sharing class KexDebugController {

    private static final String ORG_SECRET = Karma_Exchange_Admin_Settings__c.getInstance().SecretKey__c;

    @HttpPost
    global static KexRestServiceResponse doPost(String secretKey, String action, Id objId) {

        try {
            KexInvalidParamException.notNull('action', action);
            KexInvalidParamException.notNull('secretKey', secretKey);
            if (!ORG_SECRET.equals(secretKey)) {
                throw new KexAuthFailureException();
            }

            if (DebugAction.SYNC_SHIFT.name().equals(action)) {

                KexInvalidParamException.notNull('objId', objId);
                KexAdminActions.syncShiftFuture(objId);
                return new KexRestServiceResponse(KexSourceEvent.toEvent(objId));

            } else if (DebugAction.SYNC_CONTACT.name().equals(action)) {

                KexInvalidParamException.notNull('objId', objId);
                KexAdminActions.syncContactFuture(objId);
                return new KexRestServiceResponse();

            } else if (DebugAction.SYNC_UPCOMING_SHIFTS.name().equals(action)) {

                KexAdminController.syncUpcomingShifts();
                return new KexRestServiceResponse();

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
        SYNC_SHIFT,
        SYNC_CONTACT,
        SYNC_UPCOMING_SHIFTS
    }

}