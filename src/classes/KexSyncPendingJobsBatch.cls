global without sharing class KexSyncPendingJobsBatch implements Database.Batchable<sObject>, Database.Stateful {

    private List<KexSyncTracker__c> syncList;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Limiting job query to 10,000 ids because in one hour no single
        // volunteer db will have 10,000 job updates.
        syncList = [SELECT CreatedDate,Id,Volunteer_Job__c FROM KexSyncTracker__c
            where Volunteer_Job__c!=null order by CreatedDate asc limit 10000];
        Set<Id> jobs = new Set<Id>();
        for(KexSyncTracker__c sync : syncList) {
            jobs.add(sync.Volunteer_Job__c);
        }

        return Database.getQueryLocator(
            'SELECT ID FROM GW_Volunteers__Volunteer_Shift__c WHERE GW_Volunteers__Volunteer_Job__c in :jobs order by CreatedDate asc');
    }

    global void execute(Database.BatchableContext BC, List<GW_Volunteers__Volunteer_Shift__c> jobShifts){
        List<KexSyncTracker__c> shiftList = new List<KexSyncTracker__c>();
        for(GW_Volunteers__Volunteer_Shift__c shift : jobShifts) {
            KexSyncTracker__c sync = new KexSyncTracker__c();
            sync.Volunteer_Shift__c = shift.Id;
            shiftList.add(sync);
        }
        insert shiftList;
    }

    global void finish(Database.BatchableContext BC) {
        // If the batch job fails mid-way nothing gets deleted. But failures should
        // be rare since all the batch job is doing is converting jobs into shifts.
        delete syncList;
        database.executebatch(
            new KexCompactAndSyncPendingShiftsBatch());
    }
}