@IsTest
private class KexSyncVolunteerContactsBatchTest {

    static testmethod void testExecute() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift =
            testDataFactory.createShift();
        Contact volunteer =
        	testDataFactory.createContact();
        testDataFactory.registerVolunteer(shift, volunteer);
		Account acc2 =
	    	new Account(Name='Test Account 2');
	    insert acc2;
	    Karma__Volunteer_Preferences_Per_Org__c volunteerPrefs =
	    	new Karma__Volunteer_Preferences_Per_Org__c(
	    		Contact__c = volunteer.Id,
	    		Has_Opted_Out_Of_Email__c = true,
	    		Org__c = acc2.Id);
	    insert volunteerPrefs;

        Set<Id> volunteersToSync = new Set<Id>();
        volunteersToSync.add(volunteer.Id);
        List<KexSyncRequest> syncReqs =
        	KexSyncHttpCalloutMock.createContactSyncReqs(volunteersToSync);

        Test.startTest();

        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(syncReqs, true);
        database.executebatch(
            new KexSyncVolunteerContactsBatch());

        Test.stopTest();

        System.assert(syncMock.numTimesInvoked == 1,
        	'Contacts must be synced: ' + syncMock.numTimesInvoked);
    }

}