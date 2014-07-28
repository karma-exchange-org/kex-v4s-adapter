trigger KexSyncVolunteerHours on GW_Volunteers__Volunteer_Hours__c (
        after delete, after insert, after undelete, after update) {

    // Check if automatic sync is enabled.
    if (!Karma_Exchange_Settings__c.getOrgDefaults().Auto_Sync__c) {
        return;
    }

    // VOL_VolunteerHours_ShiftRollups automatically updates the shift if a 'Confirmed' or 'Completed'
    // volunteer has changed his status. Confirmed / Completed volunteers are the only ones that
    // count towards the total volunteer count. For Karma Exchange we also want to track those
    // that are pending confirmation 'Web Sign Up'. Therefore we could modify the trigger to
    // rely on the VOL_VolunteerHours_ShiftRollups tigger and avoid tracking volunteer hours that
    // we know will be propogated on shift update. But since we have a compaction phase on sync
    // we'll take the trigger hit for now.

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
}