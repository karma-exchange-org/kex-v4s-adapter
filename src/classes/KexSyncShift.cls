public with sharing class KexSyncShift {

    public static final String ACTION_UPSERT = 'UPSERT';
    public static final String ACTION_DELETE = 'DELETE';

    private static final String KEX_SERVER = 'kex-latest.appspot.com';
    private static final String KEX_SERVER_PROTOCOL = 'https';
    private static final String ORG_KEY = 'agxzfmtleC1sYXRlc3RyGwsSDE9yZ2FuaXphdGlvbiIJdW5pdGVkd2F5DA';
    private static final String DEFAULT_ORGANIZER_KEY =
        'agxzfmtleC1sYXRlc3RyIQsSBFVzZXIiFzEwMDAwNjA3NDM3Njk1N0ZBQ0VCT09LDA';
    // debug
    // private static final String KEX_SERVER = 'karmademo.dyndns.dk:8080';
    // private static final String KEX_SERVER_PROTOCOL = 'http';
    // private static final String ORG_KEY = 'agprZXgtbGF0ZXN0chsLEgxPcmdhbml6YXRpb24iCXVuaXRlZHdheQw';
    // private static final String DEFAULT_ORGANIZER_KEY =
    //     'agprZXgtbGF0ZXN0ciELEgRVc2VyIhcxMDAwMDYwNzQzNzY5NTdGQUNFQk9PSww';

	private static final String PATH_DERIVED_EVENT = '/api/derived/event';
	private static final String PARAM_ORG_KEY = 'org_key';
	private static final String PARAM_ORG_SECRET = 'org_secret';

    private static final String ORG_SECRET = 'x';

    // TODO(avaliani): Only invoke this if the shift is visible
    // TODO(avaliani): Handle visibility change
    @Future(callout=true)
    public static void sync(ID jobId, ID shiftId, String action) {
    	boolean isUpsert = action.equals(ACTION_UPSERT);
        if (isUpsert) {
	    	GW_Volunteers__Volunteer_Shift__c[] shiftQuery =
	    	   [select GW_Volunteers__Volunteer_Job__c,
	    	       GW_Volunteers__Volunteer_Job__r.Name,
	    	       GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Description__c,
	    	       GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Display_on_Website__c,
	               GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Information__c,
			       GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Street__c,
			       GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_City__c,
	               GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location__c,
	               GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Zip_Postal_Code__c,

			       GW_Volunteers__Start_Date_Time__c,
			       GW_Volunteers__Desired_Number_of_Volunteers__c,
			       GW_Volunteers__Duration__c,
			       GW_Volunteers__Description__c
	    	    from GW_Volunteers__Volunteer_Shift__c
	    	    where Id = :shiftId];

	        if (shiftQuery.isEmpty()) {
	        	System.debug('KexSyncShift: record for upsert no longer exists');
	        } else {
	        	sendUpsertReq(toEvent(shiftQuery[0]));
	        }
        } else {
        	sendDeleteReq(shiftId);
        }
    }

    public static void sendUpsertReq(KexEvent event) {
    	sendHttpReq('POST', null, JSON.serialize(event));
    }

    public static void sendDeleteReq(ID shiftId) {
    	sendHttpReq('DELETE', '/' + shiftId, null);
    }

    private static void sendHttpReq(String method, String pathParam, String body) {
        HttpRequest req = new HttpRequest();
        req.setHeader('accept', 'application/json');
        req.setHeader('content-type', 'application/json');
        req.setHeader('Host', KEX_SERVER);
        req.setHeader('Connection','keep-alive');
        req.setEndpoint(KEX_SERVER_PROTOCOL + '://' + KEX_SERVER + PATH_DERIVED_EVENT +
            ((pathParam == null) ? '' : pathParam) +
            '?' +
            PARAM_ORG_KEY + '=' + ORG_KEY + '&' +
            PARAM_ORG_SECRET + '=' + ORG_SECRET);
        req.setMethod(method);
        if (body != null) {
            req.setBody(body);
        }

        System.debug('KexSyncShift: req:' + req);

        // Make callout
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('KexSyncShift: response:' + res);
        System.debug('KexSyncShift: response body:' + res.getBody());
    }

    private static KexEvent toEvent(GW_Volunteers__Volunteer_Shift__c shift) {
        KexEvent event = new KexEvent();
        event.sourceKey = shift.Id;

        event.title = shift.GW_Volunteers__Volunteer_Job__r.Name;
        event.description = shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Description__c;

        event.location.title =
            shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Information__c;
        event.location.description =
            shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Information__c;
        event.location.address.street =
            shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Street__c;
        event.location.address.city =
            shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_City__c;
        event.location.address.state =
            shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location__c;
        event.location.address.zip =
            shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Location_Zip_Postal_Code__c;
        event.location.address.country = 'USA';

        event.startTime = shift.GW_Volunteers__Start_Date_Time__c.getTime();
        DateTime endTime = DateTime.newInstance(shift.GW_Volunteers__Start_Date_Time__c.getTime());
        Double durationHours = shift.GW_Volunteers__Duration__c.doubleValue();
        endTime = endTime.addMinutes((durationHours * 60).intValue());
        event.endTime = endTime.getTime();

        event.maxRegistrations = shift.GW_Volunteers__Desired_Number_of_Volunteers__c.intValue();

        event.organization.key = ORG_KEY;

        // Skipping shift description for now.
        // TODO(avaliani): add this once there is shift support

        KexEvent.Participant p = new KexEvent.Participant();
        p.user.key = DEFAULT_ORGANIZER_KEY;
        p.type = 'ORGANIZER';
        event.participants.add(p);

        return event;
    }

}