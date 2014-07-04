global without sharing class KexSyncUpcomingShiftsBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
        	'SELECT ID FROM GW_Volunteers__Volunteer_Shift__c WHERE GW_Volunteers__Start_Date_Time__c > TODAY ');
    }

    global void execute(Database.BatchableContext BC, List<GW_Volunteers__Volunteer_Shift__c> jobShifts){
        List<KexSyncTracker__c> shiftList = new List<KexSyncTracker__c>();
        for (GW_Volunteers__Volunteer_Shift__c shift : jobShifts) {
            KexSyncTracker__c sync = new KexSyncTracker__c();
            sync.Volunteer_Shift__c = shift.Id;
            shiftList.add(sync);
        }
        insert shiftList;
    }

    global void finish(Database.BatchableContext BC) {
        database.executebatch(
            new KexCompactAndSyncPendingShiftsBatch());
    	// To make sure we have all the right volunteer preferences we also need to sync volunteer
    	// contacts.
        database.executebatch(
            new KexSyncVolunteerContactsBatch());
    }
}