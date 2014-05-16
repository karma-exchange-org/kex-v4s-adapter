trigger KexSyncShiftTrigger on GW_Volunteers__Volunteer_Shift__c (after delete, after insert, after update) {

	// TODO(avaliani): what are the governer limits for future methods
    if (Trigger.isDelete) {
        for (GW_Volunteers__Volunteer_Shift__c shift : Trigger.old) {
        	System.debug('KexSyncShiftTrigger: deleting shift ' + shift.Id);

            KexSyncShift.sync(shift.GW_Volunteers__Volunteer_Job__c,
              shift.Id, KexSyncShift.ACTION_DELETE);
        }
    } else {
        // TODO(avaliani): Handle visibility change
        for (GW_Volunteers__Volunteer_Shift__c shift : Trigger.new) {
        	System.debug('KexSyncShiftTrigger: upserting shift ' + shift.Id);

            KexSyncShift.sync(shift.GW_Volunteers__Volunteer_Job__c,
              shift.Id, KexSyncShift.ACTION_UPSERT);
        }
    }

}