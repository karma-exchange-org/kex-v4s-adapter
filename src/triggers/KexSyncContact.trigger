trigger KexSyncContact on Contact (after update) {

    // Check if automatic sync is enabled.
    if (!Karma_Exchange_Settings__c.getInstance().Auto_Sync__c) {
        return;
    }

    // Check if any volunteer contacts have been updated. If so,
    // create a sync request entry for them.
    List<KexSyncTracker__c> pendingSyncReqs =
        new List<KexSyncTracker__c>();
    for (Contact updatedContact : Trigger.new) {
        Contact oldContact =
            Trigger.oldMap.get(updatedContact.id);
        if ( (updatedContact.GW_Volunteers__Volunteer_Last_Web_Signup_Date__c != null)
             && ( (updatedContact.FirstName != oldContact.FirstName) ||
                  (updatedContact.LastName != oldContact.LastName) ||
                  (updatedContact.Email != oldContact.Email) ||
                  (updatedContact.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail) ) ) {
            KexSyncTracker__c sync = new KexSyncTracker__c();
            sync.Volunteer_Contact__c = updatedContact.id;
            pendingSyncReqs.add(sync);
        }
    }
    insert pendingSyncReqs;

}