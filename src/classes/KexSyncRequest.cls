public without sharing class KexSyncRequest {

    // Required to workaround the inability to invoke callouts from batch jobs in tests:
    //   https://developer.salesforce.com/forums/ForumsMain?id=906F00000009mDbIAI
    public static KexSyncHttpCalloutMock calloutMock;

    public static final String ACTION_UPSERT = 'UPSERT';
    public static final String ACTION_DELETE = 'DELETE';

    private static final String KEX_SERVER_URL = Karma_Exchange_Admin_Settings__c.getInstance().ServerUrl__c;
    private static final String ORG_ID = Karma_Exchange_Admin_Settings__c.getInstance().OrganizationId__c;
    private static final String ORG_SECRET = Karma_Exchange_Admin_Settings__c.getInstance().SecretKey__c;

    public static final String PATH_DERIVED_EVENT_SYNC = '/api/derived/event';
    public static final String PARAM_ORG_ID = 'org_id';
    public static final String PARAM_ORG_SECRET = 'org_secret';

    public String action;
    public String sourceEventId;
    public KexSourceEvent sourceEvent;

    public KexSyncRequest(String action, String sourceEventId) {
        this(action, sourceEventId, null);
    }

    public KexSyncRequest(String action, KexSourceEvent sourceEvent) {
        this(action, null, sourceEvent);
    }

    private KexSyncRequest(String action, String sourceEventId, KexSourceEvent sourceEvent) {
        this.action = action;
        this.sourceEventId = sourceEventId;
        this.sourceEvent = sourceEvent;
    }

    public static void send(List<KexSyncRequest> syncReqs) {
        sendHttpReq(JSON.serialize(syncReqs), PATH_DERIVED_EVENT_SYNC);
    }

    private static void sendHttpReq(String body, String apiPath) {
        HttpRequest req = new HttpRequest();
        req.setHeader('accept', 'application/json');
        req.setHeader('content-type', 'application/json');
        req.setHeader('Host', getHostHeader(KEX_SERVER_URL));
        req.setHeader('Connection','keep-alive');
        req.setEndpoint(KEX_SERVER_URL + apiPath +
            '?' +
            PARAM_ORG_ID + '=' + ORG_ID + '&' +
            PARAM_ORG_SECRET + '=' + ORG_SECRET);
        req.setMethod('POST');
        if (body != null) {
            req.setBody(body);
        }
        req.setTimeout(120000);
        System.debug('KexSyncRequest: req:' + req);
        System.debug('KexSyncRequest: body:' + body);

        // Make callout
        Http http = new Http();

        HTTPResponse res;
        if (calloutMock == null) {
            res = http.send(req);
        } else {
            res = calloutMock.respond(req);
        }

        System.debug('KexSyncRequest: response:' + res);
        System.debug('KexSyncRequest: response body:' + res.getBody());

        // Note: in addition to the SyncFailureException a CalloutException can be thrown by Apex.
        if (!reqSuccessful(res)) {
            throw new KexSyncFailureException(
            'Http request to Karma Exchange failed: status=\'' + res.getStatusCode() + '\'' +
            ' response=\'' + res.getBody() + '\'');
        }
    }

    private static String getHostHeader(String url) {
        return url.replaceFirst('^https?://', '');
    }

    private static boolean reqSuccessful(HttpResponse res) {
        return (200 <= res.getStatusCode()) && (res.getStatusCode() <= 299);
    }
}