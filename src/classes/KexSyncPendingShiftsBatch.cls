global with sharing class KexSyncPendingShiftsBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{

    // This number was chosen as a safe number of shifts to process in the app engine
    // timeout of 60 seconds. We can probably bump this number to at least 60 if not
    // more at some point.
    public static final Integer BATCH_SIZE = 20;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,Volunteer_Shift__c FROM KexSyncTracker__c  where Volunteer_Shift__c!=null order by CreatedDate asc ');
    }

    global void execute(Database.BatchableContext BC, List<KexSyncTracker__c> syncList){
        List<KexSyncRequest> syncReqs = createSyncReqs(syncList);
        // TODO(avaliani): handle send failure (fix send failure to throw an exception)
        KexSyncRequest.send(syncReqs);
        delete syncList;
    }

    private List<KexSyncRequest> createSyncReqs(List<KexSyncTracker__c> syncList) {
        List<KexSyncRequest> syncReqs = new List<KexSyncRequest>();

        Set<Id> allShifts = new Set<Id>();
        for(KexSyncTracker__c sync : syncList) {
            allShifts.add(sync.Volunteer_Shift__c);
        }

        // Create upsert requests for shifts that still exist.
        createUpsertReqs(syncReqs, allShifts);

        // Create deletion requests.
        Set<Id> deletionShifts = new Set<Id>(allShifts);
        for(KexSyncRequest ksr : syncReqs) {
            deletionShifts.remove(ksr.sourceEvent.sourceEventId);
        }
        createDeletionReqs(syncReqs, deletionShifts);

        return syncReqs;
    }

    private void createUpsertReqs(List<KexSyncRequest> syncReqs, Set<Id> shifts) {
        List<KexSourceEvent> sourceEvents = KexSourceEvent.toEvents(new List<Id>(shifts));
        for(KexSourceEvent ke : sourceEvents) {
            syncReqs.add(
                new KexSyncRequest(KexSyncRequest.ACTION_UPSERT, ke));
        }
    }

    private void createDeletionReqs(List<KexSyncRequest> syncReqs, Set<Id> shifts) {
        for(Id shiftId : shifts) {
            syncReqs.add(
                new KexSyncRequest(KexSyncRequest.ACTION_DELETE, shiftId) );
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Nothing to do.
    }
}