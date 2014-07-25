global without sharing class KexAdminActions {

    webservice static void syncShift(Id shiftId) {
        syncShiftFuture(shiftId);
    }

    webservice static void syncContact(Id contactId) {
        syncContactFuture(contactId);
    }

    // Was getting a 502 when making a callout from the webservice method therefore
    // we use a future method to sync shifts.
    //   https://developer.salesforce.com/forums/ForumsMain?id=906F00000008jyVIAQ
    @future (callout=true)
    public static void syncShiftFuture(Id shiftId) {
        List<KexSyncRequest> syncReqs = new List<KexSyncRequest>();
        KexSourceEvent event =
            KexSourceEvent.toEvent(shiftId);
        if (event == null) {
            throw new KexObjectNotFoundException(shiftId);
        }
        syncReqs.add(
            new KexSyncRequest(KexSyncRequest.ACTION_UPSERT, event));
        KexSyncRequest.send(syncReqs);
    }

    @future (callout=true)
    public static void syncContactFuture(Id contactId) {
        List<KexSyncRequest> syncReqs =
            KexSyncPendingContactsBatch.createSyncRequests( new Set<Id> { contactId } );
        if (syncReqs.isEmpty()) {
            throw new KexObjectNotFoundException(contactId);
        }
        KexSyncRequest.send(syncReqs);
    }

}