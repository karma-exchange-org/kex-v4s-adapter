trigger KexSyncVolunteerJob on GW_Volunteers__Volunteer_Job__c (
        after delete, after insert, after undelete, after update) {

    List<GW_Volunteers__Volunteer_Job__c> jobsToSync;
    if (Trigger.isDelete) {
        jobsToSync = Trigger.old;
    } else {
        jobsToSync = Trigger.new;
    }

    List<KexSyncTracker__c> pendingSyncReqs = new List<KexSyncTracker__c>();
    for(GW_Volunteers__Volunteer_Job__c job : jobsToSync) {
        KexSyncTracker__c sync = new KexSyncTracker__c();
        sync.Volunteer_Job__c = job.Id;
        pendingSyncReqs.add(sync);
    }
    insert pendingSyncReqs;

}