@IsTest
private class KexAdminControllerTest {

    static testmethod void testSyncUpcomingShifts() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift1 =
            testDataFactory.createShift();
        GW_Volunteers__Volunteer_Shift__c shift2 =
            testDataFactory.createShift();
        List<Id> shiftsToSync = new List<Id>();
        shiftsToSync.add(shift1.id);
        shiftsToSync.add(shift2.id);

        List<KexSyncTracker__c> initailTrackedShifts =
            [SELECT Id FROM KexSyncTracker__c];
        delete initailTrackedShifts;

        Test.startTest();

        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(shiftsToSync, true);
        KexAdminController.syncUpcomingShifts();

        Test.stopTest();

        System.assert(syncMock.numTimesInvoked == 1, 'sync mock must be invoked for upcoming shifts');

        List<KexSyncTracker__c> pendingEntries =
            [SELECT Id FROM KexSyncTracker__c];
        System.assert(pendingEntries.isEmpty(), 'Jobs/shifts still require sync: ' + pendingEntries);
    }

    static testmethod void testEnableAutoSync() {
        // Unfortunately a schedulable job that invokes a batch job in testing
        // does not run the batch job. So we only have this test for coverage.
        Test.startTest();
        KexAdminController.enableAutoSync();
        Test.stopTest();
    }
}