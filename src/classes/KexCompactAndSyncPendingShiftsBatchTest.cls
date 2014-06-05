@IsTest
private class KexCompactAndSyncPendingShiftsBatchTest {

    static testmethod void testCompaction() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift1 =
            testDataFactory.createShift();
        GW_Volunteers__Volunteer_Shift__c shift2 =
            testDataFactory.createShift();
        GW_Volunteers__Volunteer_Shift__c shift3 =
            testDataFactory.createShift();

        Integer BATCH_SIZE = 2;
        Integer numShiftPendingTrackerEntries = 3;

        // Create BATCH_SIZE*3 + 1 (initial) sync entries for shift1.
        for (Integer i = 0; i < (BATCH_SIZE*3); i++) {
            shift1.GW_Volunteers__Desired_Number_of_Volunteers__c++;
            update shift1;
            numShiftPendingTrackerEntries++;
        }

        // Create BATCH_SIZE sync entries for shift2.
        for (Integer i = 0; i < (BATCH_SIZE - 1); i++) {
            shift2.GW_Volunteers__Desired_Number_of_Volunteers__c++;
            update shift2;
            numShiftPendingTrackerEntries++;
        }

        // Create BATCH_SIZE*2 sync entries for shift3.
        for (Integer i = 0; i < ((BATCH_SIZE*2) - 1); i++) {
            shift3.GW_Volunteers__Desired_Number_of_Volunteers__c++;
            update shift3;
            numShiftPendingTrackerEntries++;
        }

        List<KexSyncTracker__c> pendingShiftTrackers =
            [SELECT Id,Volunteer_Shift__c FROM KexSyncTracker__c  where Volunteer_Shift__c!=null];
        System.assert(pendingShiftTrackers.size() == numShiftPendingTrackerEntries,
            'Pending shifts size mismatch: ' + pendingShiftTrackers.size());

        Test.startTest();

        KexCompactAndSyncPendingShiftsBatch compactAndSyncBatch =
            new KexCompactAndSyncPendingShiftsBatch();
        Database.QueryLocatorIterator queryLocIter =
            compactAndSyncBatch.start(null).iterator();
        while (queryLocIter.hasNext()) {
            List<KexSyncTracker__c> batchPendingShiftTrackers =
                new List<KexSyncTracker__c>();
            while  ((batchPendingShiftTrackers.size() < BATCH_SIZE) && queryLocIter.hasNext()) {
                batchPendingShiftTrackers.add(
                    (KexSyncTracker__c) queryLocIter.next());
            }
            compactAndSyncBatch.execute(null, batchPendingShiftTrackers);
        }

        Test.stopTest();

        Set<id> expectedPendingShifts =
            new Set<Id>();
        expectedPendingShifts.add(shift1.id);
        expectedPendingShifts.add(shift2.id);
        expectedPendingShifts.add(shift3.id);

        pendingShiftTrackers =
            [SELECT Id,Volunteer_Shift__c FROM KexSyncTracker__c  where Volunteer_Shift__c!=null];
        System.assert(pendingShiftTrackers.size() == expectedPendingShifts.size(),
            'End test pending shifts size mismatch: ' + pendingShiftTrackers.size());
        for (KexSyncTracker__c pendingShiftTracker : pendingShiftTrackers) {
            expectedPendingShifts.remove(pendingShiftTracker.Volunteer_Shift__c);
        }
        System.assert(0 == expectedPendingShifts.size(),
            'End test pending shifts has duplicates: ' + pendingShiftTrackers + ' expected: ' + expectedPendingShifts);
    }
}