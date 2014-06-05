global class KexAdminController {

    webservice static void syncShift(Id shiftId) {
        syncShiftFuture(shiftId);
    }

    // Was getting a 502 when making a callout from the webservice method.
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

    public static void syncUpcomingShifts() {
        database.executebatch(
            new KexSyncUpcomingShiftsBatch());
    }

    public static void enableAutoSync() {
        // Schedule every hour (cron expression)
        String jobID = System.schedule('Karma Exchange Auto Sync Job',
            '0 0 * * * ?',
            new KexSyncPendingJobsBatch());
    }

}