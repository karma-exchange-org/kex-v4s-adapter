global with sharing class KexCompactAndSyncPendingShiftsBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id lastShiftProcessed;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id,Volunteer_Shift__c FROM KexSyncTracker__c  where Volunteer_Shift__c != null order by Volunteer_Shift__c asc ');
    }

    global void execute(Database.BatchableContext BC, List<KexSyncTracker__c> shiftsPendingSync){
        List<KexSyncTracker__c> duplicatePendingShifts = new List<KexSyncTracker__c>();
        for (KexSyncTracker__c shiftPendingSync : shiftsPendingSync) {
            if (shiftPendingSync.Volunteer_Shift__c == lastShiftProcessed) {
                duplicatePendingShifts.add(shiftPendingSync);
            }
            lastShiftProcessed = shiftPendingSync.Volunteer_Shift__c;
        }

        delete duplicatePendingShifts;
    }

    global void finish(Database.BatchableContext BC) {
        database.executebatch(
            new KexSyncPendingShiftsBatch(),
            KexSyncPendingShiftsBatch.BATCH_SIZE);
    }
}