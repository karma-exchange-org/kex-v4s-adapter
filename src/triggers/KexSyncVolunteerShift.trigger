trigger KexSyncVolunteerShift on GW_Volunteers__Volunteer_Shift__c (
        after delete, after insert, after undelete, after update) {

    List<GW_Volunteers__Volunteer_Shift__c> shiftsToSync;
    if(Trigger.isDelete) {
        shiftsToSync = Trigger.old;
    } else {
        shiftsToSync = Trigger.new;
    }

    List<KexSyncTracker__c> pendingSyncReqs = new List<KexSyncTracker__c>();
    for(GW_Volunteers__Volunteer_Shift__c shift : shiftsToSync) {
        KexSyncTracker__c sync = new KexSyncTracker__c();
        sync.Volunteer_Shift__c = shift.Id;
        pendingSyncReqs.add(sync);
    }
    insert pendingSyncReqs;

}