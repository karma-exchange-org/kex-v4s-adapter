public without sharing class KexSyncRequest {

    // Required to workaround the inability to invoke callouts from batch jobs in tests:
    //   https://developer.salesforce.com/forums/ForumsMain?id=906F00000009mDbIAI
    public static KexSyncHttpCalloutMock calloutMock;

    public static final String ACTION_UPSERT = 'UPSERT';
    public static final String ACTION_DELETE = 'DELETE';

    private static final String KEX_SERVER_URL = Karma_Exchange_Settings__c.getOrgDefaults().Karma_Exchange_Server_Url__c;
    private static final String ORG_ID = Karma_Exchange_Settings__c.getOrgDefaults().Karma_Exchange_Organization_Id__c;
    private static final String ORG_SECRET = Karma_Exchange_Settings__c.getOrgDefaults().Karma_Exchange_Secret_Key__c;
    private static final String ORG_ACCOUNT_ID = Karma_Exchange_Settings__c.getOrgDefaults().Organization__c;

    public static final String PATH_DERIVED_EVENT_SYNC = '/api/derived/event';
    public static final String PARAM_ORG_ID = 'org_id';
    public static final String PARAM_ORG_SECRET = 'org_secret';

    public String action;

    public String sourceEventId;
    public KexSourceEvent sourceEvent;
    public KexSourceUser sourceUser;
    public KexSourceConfig sourceConfig;

    public KexSyncRequest(String action, String sourceEventId) {
        this(action, sourceEventId, null);
    }

    public KexSyncRequest(String action, KexSourceEvent sourceEvent) {
        this(action, null, sourceEvent);
    }

    public KexSyncRequest(KexSourceUser sourceUser) {
        this.action = ACTION_UPSERT;
        this.sourceUser = sourceUser;
    }

    public KexSyncRequest(KexSourceConfig sourceConfig) {
        this.action = ACTION_UPSERT;
        this.sourceConfig = sourceConfig;
    }

    private KexSyncRequest(String action, String sourceEventId, KexSourceEvent sourceEvent) {
        this.action = action;
        this.sourceEventId = sourceEventId;
        this.sourceEvent = sourceEvent;
    }

    public static void send(List<KexSyncRequest> syncReqs) {
        List<KexSyncRequest> syncReqsWithConfig =
            addConfigToSyncReqs(syncReqs);
        sendHttpReq(JSON.serialize(syncReqsWithConfig), PATH_DERIVED_EVENT_SYNC);
    }

    // This method was added so we don't have to have an explicit config sync code path. Since the config is
    // small this should have very little overhead.
    //
    // @VisibleForTesting
    public static List<KexSyncRequest> addConfigToSyncReqs(List<KexSyncRequest> syncReqs) {
        List<KexSyncRequest> syncReqsWithConfig =
            new List<KexSyncRequest> { new KexSyncRequest(new KexSourceConfig()) };
        syncReqsWithConfig.addAll(syncReqs);
        return syncReqsWithConfig;
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

    public class KexSourceConfig {
        public String rootOrgId;

        public KexSourceConfig() {
            rootOrgId = ORG_ACCOUNT_ID;
        }
    }
}