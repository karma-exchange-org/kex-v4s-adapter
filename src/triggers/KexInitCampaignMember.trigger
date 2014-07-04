trigger KexInitCampaignMember on CampaignMember (before insert) {

	Id rootOrgId = Karma_Exchange_Admin_Settings__c.getInstance().Organization__c;

	// First lookup the sponsoring orgs for each of the campaigns.

	Set<Id> assocCampaigns =
		new Set<Id>();
	for (CampaignMember campaignMemberEntry : Trigger.new) {
		assocCampaigns.add(campaignMemberEntry.CampaignId);
	}

	Map<Id, Id> campaignToSponsoringOrgMap =
		new Map<Id, Id>();
	List<Campaign> campaignQueryResults =
		[Select
        	Volunteer_Job_Sponsor__c
         from Campaign
         where Id in :assocCampaigns];
    for (Campaign campaignEntry : campaignQueryResults) {
    	Id sponsoringOrg =
    		campaignEntry.Volunteer_Job_Sponsor__c;
    	if (sponsoringOrg == null) {
    		sponsoringOrg = rootOrgId;
    	}
    	if (sponsoringOrg != null) {
	    	campaignToSponsoringOrgMap.put(
	    		campaignEntry.Id,
	    		sponsoringOrg);
    	}
    }

	// Second, check and update the campaign member entries that have associated
	// volunteer preferences.

	Set<Id> assocContacts =
		new Set<Id>();
    Map<String, CampaignMember> campaignMemberMap =
    	new Map<String, CampaignMember>();
	for (CampaignMember campaignMemberEntry : Trigger.new) {
		Id sponsoringOrg =
			campaignToSponsoringOrgMap.get(campaignMemberEntry.CampaignId);
		if (sponsoringOrg != null) {
			campaignMemberMap.put(
				campaignMemberEntry.ContactId + '|' + sponsoringOrg,
				campaignMemberEntry);
			assocContacts.add(campaignMemberEntry.ContactId);
		}
	}

    List<Karma__Volunteer_Preferences_Per_Org__c> volunterPrefsResult =
		[Select
			Contact__c,
			Org__c,
        	Has_Opted_Out_Of_Email__c
         from Karma__Volunteer_Preferences_Per_Org__c
         where Contact__c in :assocContacts];
    for (Karma__Volunteer_Preferences_Per_Org__c volunteerPref : volunterPrefsResult) {
    	CampaignMember assocCampaignMember =
    		campaignMemberMap.get(volunteerPref.Contact__c + '|' + volunteerPref.Org__c);
    	if (assocCampaignMember != null) {
    		assocCampaignMember.Sponsoring_Org_Email_Opt_Out__c =
    			volunteerPref.Has_Opted_Out_Of_Email__c;
    	}
    }
}