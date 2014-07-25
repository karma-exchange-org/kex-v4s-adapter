global without sharing class KexSyncPendingContactsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    // This number was chosen as a safe number of shifts to process in the app engine
    // timeout of 60 seconds. We can probably bump this number up at some point.
    public static final Integer BATCH_SIZE = 40;

    private Database.Batchable<sObject> nextBatchJob;

    public KexSyncPendingContactsBatch(Database.Batchable<sObject> nextBatchJob) {
        this.nextBatchJob = nextBatchJob;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Volunteer_Contact__c' +
            '  FROM KexSyncTracker__c' +
            '  WHERE Volunteer_Contact__c != null' +
            '  ORDER BY Volunteer_Contact__c asc ');
    }

    global void execute(Database.BatchableContext BC, List<KexSyncTracker__c> contactsPendingSync){
        Set<Id> contacts =
            new Set<Id>();
        for (KexSyncTracker__c contactPendingSync : contactsPendingSync) {
            contacts.add(contactPendingSync.Volunteer_Contact__c);
        }

        List<KexSyncRequest> syncReqs =
            createSyncRequests(contacts);
        KexSyncRequest.send(syncReqs);

        delete contactsPendingSync;
    }

    global void finish(Database.BatchableContext BC) {
        if (nextBatchJob != null) {
            database.executebatch(nextBatchJob);
        }
    }

    public static List<KexSyncRequest> createSyncRequests(Set<Id> contacts) {
        List<Contact> results = [SELECT
            FirstName,
            LastName,
            Email,
            HasOptedOutOfEmail,
            LastModifiedDate,
            (SELECT
                Org__r.Name,
                Org__r.Karma_Exchange_Org_Id__c,
                Org__r.Karma_Exchange_Org_Secret_Key__c,
                Has_Opted_Out_Of_Email__c,
                LastModifiedDate
                FROM Volunteer_Preferences_Per_Org__r)
            FROM Contact
            WHERE Contact.id in :contacts];

        List<KexSyncRequest> syncReqs =
            new List<KexSyncRequest>();
        for (Contact c : results) {
            syncReqs.add(createSyncRequest(c));
        }

        return syncReqs;
    }

    private static KexSyncRequest createSyncRequest(Contact contactResult) {
        List<Volunteer_Preferences_Per_Org__c> orgPrefsResult =
            contactResult.Volunteer_Preferences_Per_Org__r;
        List<KexOrgPrefs> orgPrefs =
            new List<KexOrgPrefs>();
        for (Volunteer_Preferences_Per_Org__c orgPref : orgPrefsResult) {
            orgPrefs.add(
                new KexOrgPrefs(
                    new KexOrg(orgPref.Org__r),
                    orgPref.Has_Opted_Out_Of_Email__c));
        }
        KexSourceUser sourceUser = new KexSourceUser(
                contactResult,
                orgPrefs);

        return new KexSyncRequest(sourceUser);
    }
}