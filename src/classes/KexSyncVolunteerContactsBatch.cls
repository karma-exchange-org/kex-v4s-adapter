global without sharing class KexSyncVolunteerContactsBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
        	'SELECT Id FROM Contact where GW_Volunteers__Volunteer_Last_Web_Signup_Date__c != null');
    }

    global void execute(Database.BatchableContext BC, List<Contact> volunteerContacts){
        List<KexSyncTracker__c> shiftList = new List<KexSyncTracker__c>();
        for (Contact volunteerContact : volunteerContacts) {
            KexSyncTracker__c sync = new KexSyncTracker__c();
            sync.Volunteer_Contact__c = volunteerContact.Id;
            shiftList.add(sync);
        }
        insert shiftList;
    }

    global void finish(Database.BatchableContext BC) {
        database.executebatch(
            new KexCompactAndSyncPendingContactsBatch());
    }

}