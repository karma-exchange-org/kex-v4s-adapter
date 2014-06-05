@IsTest
private class KexSyncPendingJobsBatchTest {

    static testmethod void testExecute() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift1 =
            testDataFactory.createShift();
        GW_Volunteers__Volunteer_Shift__c shift2 =
            testDataFactory.createShift();
        delete shift2;
        List<Id> shiftsToSync = new List<Id>();
        shiftsToSync.add(shift1.id);
        shiftsToSync.add(shift2.id);

        List<KexSyncTracker__c> pendingJobs =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Job__c!=null];
        System.assert(pendingJobs.size() == 5, 'Pending jobs size mismatch: ' + pendingJobs);

        Test.startTest();

        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(shiftsToSync, true);
        database.executebatch(
            new KexSyncPendingJobsBatch());

        Test.stopTest();

        pendingJobs =
            [SELECT Id,Volunteer_Job__c FROM KexSyncTracker__c  where Volunteer_Job__c!=null];
        System.assert(pendingJobs.isEmpty(), 'Jobs still require sync: ' + pendingJobs);
    }

}