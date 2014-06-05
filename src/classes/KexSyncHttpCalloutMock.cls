@IsTest
global class KexSyncHttpCalloutMock implements HttpCalloutMock {

    public List<KexSyncRequest> syncReqs;
    public Integer numTimesInvoked = 0;

    public KexSyncHttpCalloutMock(Id shiftId) {
        List<Id> shiftIds = new List<Id>();
        shiftIds.add(shiftId);
        init(shiftIds, false);
    }

    public KexSyncHttpCalloutMock(List<Id> shiftIds, boolean calloutFromBatchJob) {
        init(shiftIds, calloutFromBatchJob);
    }

    private void init(List<Id> shiftIds, boolean calloutFromBatchJob) {
        List<KexSourceEvent> eventsToUpsert =
            KexSourceEvent.toEvents(shiftIds);
        Map<Id, KexSourceEvent> eventsToUpsertMap = new Map<Id, KexSourceEvent>();
        for (KexSourceEvent eventToUpsert : eventsToUpsert) {
            eventsToUpsertMap.put(eventToUpsert.sourceEventId, eventToUpsert);
        }
        syncReqs = new List<KexSyncRequest>();
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
        if (calloutFromBatchJob) {
            KexSyncRequest.calloutMock = this;
        }
    }

    global HTTPResponse respond(HTTPRequest req) {
        numTimesInvoked++;
        System.assertEquals(
            KexTestDataFactory.KEX_SERVER_URL + KexSyncRequest.PATH_DERIVED_EVENT_SYNC +
                '?' +
                KexSyncRequest.PARAM_ORG_ID + '=' + KexTestDataFactory.KEX_ORG_ID + '&' +
                KexSyncRequest.PARAM_ORG_SECRET + '=' + KexTestDataFactory.SECRET_KEY,
            req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        System.assertEquals(JSON.serialize(syncReqs), req.getBody());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('');
        return res;
    }
}