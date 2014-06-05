@IsTest
private class KexSyncPendingShiftsBatchTest {

    static testmethod void testExecute() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId1 = testDataFactory.createShift().id;
        GW_Volunteers__Volunteer_Shift__c shift2 =
            testDataFactory.createShift();
        delete shift2;
        List<Id> shiftsToSync = new List<Id>();
        shiftsToSync.add(shiftId1);
        shiftsToSync.add(shift2.id);

        List<KexSyncTracker__c> pendingShifts =
            [SELECT Id,Volunteer_Shift__c FROM KexSyncTracker__c  where Volunteer_Shift__c!=null];
        System.assert(pendingShifts.size() == 3, 'Pending shifts size mismatch: ' + pendingShifts);

        Test.startTest();

        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(shiftsToSync, true);
        database.executebatch(
            new KexSyncPendingShiftsBatch(),
            KexSyncPendingShiftsBatch.BATCH_SIZE);

        Test.stopTest();

        pendingShifts =
            [SELECT Id,Volunteer_Shift__c FROM KexSyncTracker__c  where Volunteer_Shift__c!=null];
        System.assert(pendingShifts.isEmpty(), 'Shifts still require sync: ' + pendingShifts);
    }

}