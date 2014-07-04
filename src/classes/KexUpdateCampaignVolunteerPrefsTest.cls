@IsTest
private class KexUpdateCampaignVolunteerPrefsTest {

    static testMethod void testUpdatePref() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift = testDataFactory.createShift();
        Contact volunteer = testDataFactory.createContact();
		testDataFactory.registerVolunteer(shift, volunteer);

		// Verify there is a campaign member entry for the volunteer.

		List<CampaignMember> campaignMemberResult =
	        [Select
	        	ContactId,
	        	Campaign.Volunteer_Job_Sponsor__c,
	        	Sponsoring_Org_Email_Opt_Out__c
	         from CampaignMember
	         where
	         	(ContactId = :volunteer.Id) and
	         	(CampaignId = :testDataFactory.campaignId)];
	    System.assert(campaignMemberResult.size() == 1, 'Campaign member entry not found');

		// Create a preference for an unassociated account and verify that the pref
		// has no effect.

	    Account acc2 =
	    	new Account(Name='Test Account 2');
	    insert acc2;

	    Karma__Volunteer_Preferences_Per_Org__c volunteerPrefs =
	    	new Karma__Volunteer_Preferences_Per_Org__c(
	    		Contact__c = volunteer.Id,
	    		Has_Opted_Out_Of_Email__c = true,
	    		Org__c = acc2.Id);
	    insert volunteerPrefs;

		campaignMemberResult =
	        [Select
	        	ContactId,
	        	Campaign.Volunteer_Job_Sponsor__c,
	        	Sponsoring_Org_Email_Opt_Out__c
	         from CampaignMember
	         where
	         	(ContactId = :volunteer.Id) and
	         	(CampaignId = :testDataFactory.campaignId)];
	    System.assert(!campaignMemberResult[0].Sponsoring_Org_Email_Opt_Out__c,
	    	'Email opt out incorrectly set: ' + campaignMemberResult[0]);

		// Now associated the account with the volunteer and verify that the
		// preference is propogated.

	    Campaign cmp2 = new Campaign(
	            recordtypeid=KexTestDataFactory.getVolunteersCampaignRecordTypeId(),
	            name='Test Campaign 2',
	            IsActive=true,
	            Volunteer_Job_Sponsor__c = acc2.id);
        insert cmp2;
        GW_Volunteers__Volunteer_Shift__c shift2 =
        	testDataFactory.createShift(cmp2);
        testDataFactory.registerVolunteer(
        	shift2, volunteer);

		campaignMemberResult =
	        [Select
	        	ContactId,
	        	Campaign.Volunteer_Job_Sponsor__c,
	        	Sponsoring_Org_Email_Opt_Out__c
	         from CampaignMember
	         where
	         	(ContactId = :volunteer.Id) and
	         	(CampaignId = :cmp2.id)];
	    System.assert(campaignMemberResult[0].Sponsoring_Org_Email_Opt_Out__c,
	    	'Email opt out field should be set: ' + campaignMemberResult[0]);

	    // Finally update the pref and make sure the campaign member field is updated.

	    volunteerPrefs.Has_Opted_Out_Of_Email__c = false;
	    update volunteerPrefs;

		campaignMemberResult =
	        [Select
	        	ContactId,
	        	Campaign.Volunteer_Job_Sponsor__c,
	        	Sponsoring_Org_Email_Opt_Out__c
	         from CampaignMember
	         where
	         	(ContactId = :volunteer.Id) and
	         	(CampaignId = :cmp2.id)];
	    System.assert(!campaignMemberResult[0].Sponsoring_Org_Email_Opt_Out__c,
	    	'Email opt out field should not be set: ' + campaignMemberResult[0]);

    }
}