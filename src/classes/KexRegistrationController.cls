@RestResource(urlMapping='/kex-api/*')
global without sharing class KexRegistrationController {

    private static final String ORG_SECRET = Karma_Exchange_Settings__c.getOrgDefaults().Karma_Exchange_Secret_Key__c;

    @HttpPost
    global static KexRestServiceResponse doPost(String secretKey, KexRegistrationReq registrationReq,
            KexSourceUser sourceUser) {

        Id shiftId = null;
        try {

            KexInvalidParamException.notNull('secretKey', secretKey);
            if (!ORG_SECRET.equals(secretKey)) {
                throw new KexAuthFailureException();
            }

            KexInvalidParamException.notNull('sourceUser', sourceUser);
            sourceUser.validate();
            Contact volunteer =
                sourceUser.createOrUpdate();

            if (registrationReq != null) {
                registrationReq.validate();
                shiftId = registrationReq.eventId;
                registrationReq.execute(volunteer);
                // Return the updated shift information.
                return new KexRestServiceResponse(KexSourceEvent.toEvent(shiftId));
            } else {
                return new KexRestServiceResponse();
            }

        } catch (KexTypedException e) {
            return new KexRestServiceResponse(
                (shiftId != null) ? KexSourceEvent.toEvent(shiftId) : null,
                new KexErrorInfo(e));
        } catch (Exception e) {
            return new KexRestServiceResponse(
                (shiftId != null) ? KexSourceEvent.toEvent(shiftId) : null,
                new KexErrorInfo(e));
        }

    }

 }