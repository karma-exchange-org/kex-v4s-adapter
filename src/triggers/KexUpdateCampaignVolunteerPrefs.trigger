trigger KexUpdateCampaignVolunteerPrefs on Karma__Volunteer_Preferences_Per_Org__c (
		after insert, after undelete, after update) {

	// First update any affected campaign member entries.

	Id rootOrgId = Karma_Exchange_Admin_Settings__c.getInstance().Organization__c;

	Set<Id> affectedContacts =
		new Set<Id>();
	Map<String, Karma__Volunteer_Preferences_Per_Org__c> prefMap =
		new Map<String, Karma__Volunteer_Preferences_Per_Org__c>();
	for (Karma__Volunteer_Preferences_Per_Org__c pref : Trigger.new) {
		affectedContacts.add(pref.Contact__c);
		prefMap.put(
			pref.Contact__c + '|' + pref.Org__c,
			pref);
	}

	List<CampaignMember> fetchedCampaignMembers =
        [Select
        	ContactId,
        	Campaign.Volunteer_Job_Sponsor__c,
        	Sponsoring_Org_Email_Opt_Out__c
         from CampaignMember
         where ContactId in :affectedContacts];
	List<CampaignMember> campaignMembersToUpdate =
		new List<CampaignMember>();
	for (CampaignMember fetchedCampaignMember : fetchedCampaignMembers) {
		// Use the root organization id if the campaign is not associated with a
		// sponsoring org.
		Id orgId = (fetchedCampaignMember.Campaign.Volunteer_Job_Sponsor__c == null) ?
			rootOrgId :
			fetchedCampaignMember.Campaign.Volunteer_Job_Sponsor__c;
		if (orgId != null) {
			Karma__Volunteer_Preferences_Per_Org__c mappedPref =
				prefMap.get(fetchedCampaignMember.ContactId + '|' + orgId);

			// Check if any prefs are updated.
			if (mappedPref.Has_Opted_Out_Of_Email__c != fetchedCampaignMember.Sponsoring_Org_Email_Opt_Out__c) {
				fetchedCampaignMember.Sponsoring_Org_Email_Opt_Out__c =
					mappedPref.Has_Opted_Out_Of_Email__c;
				campaignMembersToUpdate.add(fetchedCampaignMember);
			}
		}
	}

	update campaignMembersToUpdate;

	// Then queue up changes to sync to Karma Exchange.
	if (Karma_Exchange_Admin_Settings__c.getInstance().Auto_Sync__c) {

	    List<KexSyncTracker__c> pendingSyncReqs = new List<KexSyncTracker__c>();
	    for(Id contactId : affectedContacts) {
	        KexSyncTracker__c sync = new KexSyncTracker__c();
	        sync.Volunteer_Contact__c = contactId;
	        pendingSyncReqs.add(sync);
	    }
	    insert pendingSyncReqs;

	}
}