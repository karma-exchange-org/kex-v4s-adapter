@RestResource(urlMapping='/registration/*')
global with sharing class KexRegistrationController {

    private static final String ORG_SECRET = Karma_Exchange_Admin_Settings__c.getInstance().SecretKey__c;

    @HttpPost
    global static KexRestServiceResponse doPost(String action, String eventId,
           String firstName, String lastName, String email, String secretKey) {

        try {
            KexInvalidParamException.notNull('eventId', eventId);
            KexInvalidParamException.notNull('action', action);
            KexInvalidParamException.notNull('firstName', firstName);
            KexInvalidParamException.notNull('lastName', lastName);
            KexInvalidParamException.notNull('email', email);
            KexInvalidParamException.notNull('secretKey', secretKey);
            if (!ORG_SECRET.equals(secretKey)) {
                throw new KexAuthFailureException();
            }
        } catch (KexTypedException e) {
            return new KexRestServiceResponse(
                new KexErrorInfo(e));
        }

        Id shiftId = eventId;
        try {
            execute(action, shiftId, firstName, lastName, email);
            // Return the updated shift information.
            return new KexRestServiceResponse(KexSourceEvent.toEvent(shiftId));
        } catch (KexTypedException e) {
            return new KexRestServiceResponse(KexSourceEvent.toEvent(shiftId), new KexErrorInfo(e));
        } catch (Exception e) {
            return new KexRestServiceResponse(KexSourceEvent.toEvent(shiftId), new KexErrorInfo(e));
        }
    }

    private static void execute(String action, Id shiftId,
           String firstName, String lastName, String email) {
        System.debug('Processing signup request:' +
          'action=' + action + ', ' +
          'shiftId=' + shiftId + ', ' +
          'firstName=' + firstName + ', ' +
          'lastName=' + lastName + ', ' +
          'email=' + email);

        Contact contact = lookupOrCreateContact(firstName, lastName, email);

        // TODO(avaliani): Do we need a select for update here? Triggers is going to update this.
        //   Is the trigger updating it as part of the same txn or only post-commit?
        List<GW_Volunteers__Volunteer_Shift__c> shiftQuery =
            [Select GW_Volunteers__Number_of_Volunteers_Still_Needed__c,
                GW_Volunteers__Start_Date_Time__c,
                GW_Volunteers__Volunteer_Job__c
             from GW_Volunteers__Volunteer_Shift__c
             where Id = :shiftId];
        if (shiftQuery.isEmpty()) {
            throw new KexObjectNotFoundException(shiftId);
        }
        GW_Volunteers__Volunteer_Shift__c shift = shiftQuery[0];

        List<GW_Volunteers__Volunteer_Hours__c> hoursQuery =
            [Select GW_Volunteers__Status__c
             from GW_Volunteers__Volunteer_Hours__c
             where GW_Volunteers__Contact__c = :contact.Id and
                GW_Volunteers__Volunteer_Shift__c = :shiftId
             for update];

        System.debug('Num volunteers needed: ' +
            shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c);

        // Prevent duplicate signups
        if ( action.equals(RegistrationAction.REGISTER.name()) ) {
            if (hoursQuery.isEmpty() || (hoursQuery[0].GW_Volunteers__Status__c != 'Confirmed')) {
                if ( (shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c == null) ||
                     (shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c.intValue() == 0) ) {
                    throw new KexRegistrationLimitReachedException();
                }

                GW_Volunteers__Volunteer_Hours__c hours;
                if (hoursQuery.isEmpty()) {
                    DateTime shiftDate = shift.GW_Volunteers__Start_Date_Time__c;
                    hours = new GW_Volunteers__Volunteer_Hours__c(
                        GW_Volunteers__Contact__c = contact.ID,
                        GW_Volunteers__Volunteer_Shift__c = shiftId,
                        GW_Volunteers__Volunteer_Job__c = shift.GW_Volunteers__Volunteer_Job__c,
                        GW_Volunteers__Start_Date__c =
                            Date.newInstance(shiftDate.year(), shiftDate.month(), shiftDate.day()),
                        GW_Volunteers__Status__c = 'Web Sign Up',
                        GW_Volunteers__Number_of_Volunteers__c = 1);

                    insert hours;
                    // We need to do this to ensure the new web signup email workflow is processed.
                    hours.GW_Volunteers__Status__c = 'Confirmed';
                    update hours;
                } else {
                    hours = hoursQuery[0];
                    hours.GW_Volunteers__Status__c = 'Confirmed';
                    update hours;
                }
            }
        } else if (!hoursQuery.isEmpty()) {
            GW_Volunteers__Volunteer_Hours__c hours = hoursQuery[0];
            hours.GW_Volunteers__Status__c = 'Canceled';
            update hours;
        }
    }

    private static Contact lookupOrCreateContact(String firstName, String lastName, String email) {
        // TODO(avaliani): close out timing window for duplicate contacts.
        Contact[] contactQueryResult =
          [Select c.ID from Contact c where
              c.FirstName = :firstName and
              c.LastName = :lastName and
              c.Email = :email];
        Contact contact;
        if (contactQueryResult.isEmpty()) {
            contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                GW_Volunteers__Volunteer_Last_Web_Signup_Date__c = Date.today());
            insert contact;
        } else {
            contact = contactQueryResult[0];
        }
        return contact;
    }

    private enum RegistrationAction {
        REGISTER,
        UNREGISTER
    }

 }