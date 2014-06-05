@IsTest
private class KexSyncRequestTest {

    static testmethod void testSend() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Id shiftId = testDataFactory.createShift().id;
        KexSyncHttpCalloutMock syncMock =
            new KexSyncHttpCalloutMock(shiftId);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, syncMock);
        KexSyncRequest.send(syncMock.syncReqs);
        Test.stopTest();
    }

}