public with sharing class KexSyncShift {

    public static final String ACTION_UPSERT = 'UPSERT';
    public static final String ACTION_DELETE = 'DELETE';

    private static final String VH_STATUS_CONFIRMED = 'Confirmed';
    private static final String VH_STATUS_WEB_SIGN_UP = 'Web Sign Up';
    private static final String VH_STATUS_COMPLETED = 'Completed';
    private static final String VH_STATUS_NO_SHOW = 'No-Show';

    // demo
    // private static final String KEX_SERVER = 'kex-latest.appspot.com';
    // private static final String KEX_SERVER_PROTOCOL = 'https';
    // private static final String ORG_KEY = 'agxzfmtleC1sYXRlc3RyGwsSDE9yZ2FuaXphdGlvbiIJdW5pdGVkd2F5DA';

    // debug
    private static final String KEX_SERVER = 'karmademo.dyndns.dk:8080';
    private static final String KEX_SERVER_PROTOCOL = 'http';
    private static final String ORG_KEY = 'agprZXgtbGF0ZXN0chsLEgxPcmdhbml6YXRpb24iCXVuaXRlZHdheQw';

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
            KexEvent event = toEvent(shiftId);
            if (event == null) {
                System.debug('KexSyncShift: record for upsert no longer exists');
            } else {
                sendUpsertReq(event);
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

    private static KexEvent toEvent(ID shiftId) {
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
            return null;
        }

        GW_Volunteers__Volunteer_Shift__c shift = shiftQuery[0];
        GW_Volunteers__Volunteer_Job__c job = shift.GW_Volunteers__Volunteer_Job__r;

        KexEvent event = new KexEvent();
        event.sourceKey = shift.Id;

        event.title = job.Name;
        event.description = job.GW_Volunteers__Description__c;

        // event.location.title =
        //    job.GW_Volunteers__Location_Information__c;
        if ((job.GW_Volunteers__Location_Information__c != null) ||
            (job.GW_Volunteers__Location_Street__c != null) ||
            (job.GW_Volunteers__Location_City__c != null) ||
            (job.GW_Volunteers__Location__c != null) ||
            (job.GW_Volunteers__Location_Zip_Postal_Code__c != null)) {

            event.location = new KexEvent.Location();
            event.location.description =
                job.GW_Volunteers__Location_Information__c;
            event.location.address.street =
                job.GW_Volunteers__Location_Street__c;
            event.location.address.city =
                job.GW_Volunteers__Location_City__c;
            event.location.address.state =
                job.GW_Volunteers__Location__c;
            event.location.address.zip =
                job.GW_Volunteers__Location_Zip_Postal_Code__c;
            event.location.address.country = 'USA';
        }

        event.startTime = shift.GW_Volunteers__Start_Date_Time__c.getTime();
        DateTime endTime = DateTime.newInstance(shift.GW_Volunteers__Start_Date_Time__c.getTime());
        Double durationHours = shift.GW_Volunteers__Duration__c.doubleValue();
        endTime = endTime.addMinutes((durationHours * 60).intValue());
        event.endTime = endTime.getTime();

        event.maxRegistrations = shift.GW_Volunteers__Desired_Number_of_Volunteers__c.intValue();

        event.organization = new KexEvent.KeyWrapper(ORG_KEY);
        event.sourceParticipants = getParticipants(shift);

        // Skipping shift description for now.
        // TODO(avaliani): add this once there is shift support

        return event;
    }


    private static List<KexSourceParticipant> getParticipants(GW_Volunteers__Volunteer_Shift__c shift) {
        List<KexSourceParticipant> sourceParticipants = new List<KexSourceParticipant>();

        List<GW_Volunteers__Volunteer_Hours__c> shiftVolunteers =
            [Select
                GW_Volunteers__Status__c,
                GW_Volunteers__Contact__r.FirstName,
                GW_Volunteers__Contact__r.LastName,
                GW_Volunteers__Contact__r.Email
             from GW_Volunteers__Volunteer_Hours__c
             where GW_Volunteers__Volunteer_Shift__c = :shift.Id];

        // Prospect - ignored
        // Confirmed / Web Sign Up => REGISTERED
        // Completed  => REGISTERED
        // No-show => REGISTERED_NO_SHOW
        // Canceled - ignored. The volunteer can no longer do this job or shift. This status
        //            prevents the system scheduler from re-assigning a recurring volunteer to this shift.
        for (GW_Volunteers__Volunteer_Hours__c shiftVolunteer : shiftVolunteers) {
            String participantType = null;
            if (  shiftVolunteer.GW_Volunteers__Status__c.equals(VH_STATUS_CONFIRMED) ||
                  shiftVolunteer.GW_Volunteers__Status__c.equals(VH_STATUS_WEB_SIGN_UP) ||
                  shiftVolunteer.GW_Volunteers__Status__c.equals(VH_STATUS_COMPLETED)  ) {
                participantType = KexSourceParticipant.TYPE_REGISTERED;
            } else if ( shiftVolunteer.GW_Volunteers__Status__c.equals(VH_STATUS_NO_SHOW) ) {
                participantType = KexSourceParticipant.TYPE_REGISTERED_NO_SHOW;
            }
            if (participantType != null) {
                KexSourceParticipant participant = new KexSourceParticipant();
                participant.type = participantType;
                KexSourceUser sourceUser = new KexSourceUser();
                sourceUser.firstName = shiftVolunteer.GW_Volunteers__Contact__r.FirstName;
                sourceUser.lastName = shiftVolunteer.GW_Volunteers__Contact__r.LastName;
                sourceUser.email = shiftVolunteer.GW_Volunteers__Contact__r.Email;
                participant.user = sourceUser;
                sourceParticipants.add(participant);
            }
        }

        sourceParticipants.add(getDefaultOrganizer());

        return sourceParticipants;
    }

    public static KexSourceParticipant getDefaultOrganizer() {
        KexSourceParticipant participant = new KexSourceParticipant();
        participant.type = KexSourceParticipant.TYPE_ORGANIZER;
        KexSourceUser sourceUser = new KexSourceUser();
        // Hard coding this in for now for testing.
        sourceUser.firstName = 'Katie(2)';
        sourceUser.lastName = 'Hilary(2)';
        sourceUser.email = 'katie.hilary@karmaexchange.org';
        participant.user = sourceUser;
        return participant;
    }
}