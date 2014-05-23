public with sharing class KexAdminController {

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