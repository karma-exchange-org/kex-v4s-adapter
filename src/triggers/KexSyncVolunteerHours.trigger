trigger KexSyncVolunteerHours on GW_Volunteers__Volunteer_Hours__c (
        after delete, after insert, after undelete, after update) {

    List<GW_Volunteers__Volunteer_Hours__c> vhToSync;
    if(Trigger.isDelete) {
        vhToSync = Trigger.old;
    } else {
        vhToSync = Trigger.new;
    }

    List<Id> vhIdsToSync = new List<Id>();
    for (GW_Volunteers__Volunteer_Hours__c vh : vhToSync) {
        vhIdsToSync.add(vh.Id);
    }

    List<GW_Volunteers__Volunteer_Hours__c> vhShifts =
        [Select
            GW_Volunteers__Volunteer_Shift__c
         from GW_Volunteers__Volunteer_Hours__c
         where Id in :vhIdsToSync];
    Set<Id> shiftsToSync = new Set<Id>();
    for (GW_Volunteers__Volunteer_Hours__c vhShift : vhShifts) {
        shiftsToSync.add(vhShift.GW_Volunteers__Volunteer_Shift__c);
    }

    List<KexSyncTracker__c> pendingSyncReqs = new List<KexSyncTracker__c>();
    for(Id shiftId : shiftsToSync) {
        KexSyncTracker__c sync = new KexSyncTracker__c();
        sync.Volunteer_Shift__c = shiftId;
        pendingSyncReqs.add(sync);
    }
    insert pendingSyncReqs;

    // debug temporary
    System.debug('KexSyncVolunteerHours: shift ids:' + shiftsToSync);
}