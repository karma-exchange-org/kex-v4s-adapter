global without sharing class KexCompactAndSyncPendingContactsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Id lastContactProcessed;

    private Database.Batchable<sObject> nextBatchJob;

    public KexCompactAndSyncPendingContactsBatch(Database.Batchable<sObject> nextBatchJob) {
        this.nextBatchJob = nextBatchJob;
    }

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Volunteer_Contact__c' +
            '  FROM KexSyncTracker__c' +
            '  WHERE Volunteer_Contact__c != null' +
            '  ORDER BY Volunteer_Contact__c asc ');
    }

    global void execute(Database.BatchableContext BC, List<KexSyncTracker__c> contactsPendingSync){
        List<KexSyncTracker__c> duplicatePendingContacts = new List<KexSyncTracker__c>();
        for (KexSyncTracker__c contactPendingSync : contactsPendingSync) {
            if (contactPendingSync.Volunteer_Contact__c == lastContactProcessed) {
                duplicatePendingContacts.add(contactPendingSync);
            }
            lastContactProcessed = contactPendingSync.Volunteer_Contact__c;
        }

        delete duplicatePendingContacts;
    }

    global void finish(Database.BatchableContext BC) {
        database.executebatch(
            new KexSyncPendingContactsBatch(nextBatchJob),
            KexSyncPendingContactsBatch.BATCH_SIZE);
    }

}