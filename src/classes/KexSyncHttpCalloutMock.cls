@IsTest
global class KexSyncHttpCalloutMock implements HttpCalloutMock {

    public List<KexSyncRequest> syncReqs;
    public Integer numTimesInvoked = 0;

    public KexSyncHttpCalloutMock(Id shiftId) {
        List<Id> shiftIds = new List<Id>();
        shiftIds.add(shiftId);
        init(createShiftSyncReqs(shiftIds), false);
    }

    public KexSyncHttpCalloutMock(List<Id> shiftIds, boolean calloutFromBatchJob) {
        init(createShiftSyncReqs(shiftIds), calloutFromBatchJob);
    }

    public KexSyncHttpCalloutMock(List<KexSyncRequest> syncReqs, boolean calloutFromBatchJob) {
        init(syncReqs, calloutFromBatchJob);
    }

    public static List<KexSyncRequest> createShiftSyncReqs(List<Id> shiftIds) {
        List<KexSourceEvent> eventsToUpsert =
            KexSourceEvent.toEvents(shiftIds);
        Map<Id, KexSourceEvent> eventsToUpsertMap = new Map<Id, KexSourceEvent>();
        for (KexSourceEvent eventToUpsert : eventsToUpsert) {
            eventsToUpsertMap.put(eventToUpsert.sourceEventInfo.id, eventToUpsert);
        }
        List<KexSyncRequest> syncReqs =
            new List<KexSyncRequest>();
        for (Id shiftId : shiftIds) {
            KexSourceEvent eventToUpsert = eventsToUpsertMap.get(shiftId);
            if (eventToUpsert == null) {
                syncReqs.add(
                    new KexSyncRequest(KexSyncRequest.ACTION_DELETE, shiftId));
            } else {
                syncReqs.add(
                    new KexSyncRequest(KexSyncRequest.ACTION_UPSERT, eventToUpsert));
            }
        }
        return syncReqs;
    }

    public static List<KexSyncRequest> createContactSyncReqs(Set<Id> contacts) {
        return KexSyncPendingContactsBatch.createSyncRequests(contacts);
    }

    private void init(List<KexSyncRequest> syncReqs, boolean calloutFromBatchJob) {
        this.syncReqs = syncReqs;
        if (calloutFromBatchJob) {
            KexSyncRequest.calloutMock = this;
        }
    }

    global HTTPResponse respond(HTTPRequest req) {
        List<KexSyncRequest> syncReqsWithConfig =
            KexSyncRequest.addConfigToSyncReqs(syncReqs);

        numTimesInvoked++;
        System.assertEquals(
            KexTestDataFactory.KEX_SERVER_URL + KexSyncRequest.PATH_DERIVED_EVENT_SYNC +
                '?' +
                KexSyncRequest.PARAM_ORG_ID + '=' + KexTestDataFactory.KEX_ORG_ID + '&' +
                KexSyncRequest.PARAM_ORG_SECRET + '=' + KexTestDataFactory.SECRET_KEY,
            req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        System.assertEquals(JSON.serialize(syncReqsWithConfig), req.getBody());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('');
        return res;
    }
}