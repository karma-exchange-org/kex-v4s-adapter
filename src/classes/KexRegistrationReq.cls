global with sharing class KexRegistrationReq {

    public enum RegistrationAction {
        REGISTER,
        UNREGISTER
    }

    public String action;
    public String eventId;
    public Integer numVolunteers;

    public void validate() {
        KexInvalidParamException.notNull('registrationReq.action', action);
        KexInvalidParamException.notNull('registrationReq.eventId', eventId);
        if ( action.equals(RegistrationAction.REGISTER.name()) ) {
            KexInvalidParamException.notNull('registrationReq.numVolunteers', numVolunteers);
        }
        if (  !action.equals(RegistrationAction.REGISTER.name()) &&
              !action.equals(RegistrationAction.UNREGISTER.name()) ) {
            KexInvalidParamException.notNull('Unkown registrationReq.action', action);
        }
    }

    public void execute(Contact volunteer) {
        Id shiftId = eventId;

        System.debug('Processing signup request:' +
          'action=' + action + ', ' +
          'shiftId=' + shiftId + ', ' +
          'firstName=' + volunteer.firstName + ', ' +
          'lastName=' + volunteer.lastName + ', ' +
          'email=' + volunteer.email);

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
            [Select
                GW_Volunteers__Status__c,
                GW_Volunteers__Number_of_Volunteers__c
             from GW_Volunteers__Volunteer_Hours__c
             where
                GW_Volunteers__Contact__c = :volunteer.Id and
                GW_Volunteers__Volunteer_Shift__c = :shiftId
             for update];

        System.debug('Num volunteers needed: ' +
            shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c);

        // Prevent duplicate signups
        if ( action.equals(RegistrationAction.REGISTER.name()) ) {

            // If the hours query is empty
            //   - check count against num needed
            // If the hours query is non empty
            //  - if the state is confirmed, compute the num volunteers difference
            //  - if the state is not confirmed compute the difference and see if there is room.

            GW_Volunteers__Volunteer_Hours__c hours;
            Integer numVolsStillNeeded =
                shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c.intValue();
            if (numVolsStillNeeded == null) {
                numVolsStillNeeded = 0;
            }

            if (hoursQuery.isEmpty() || (!hoursQuery[0].GW_Volunteers__Status__c.equals('Confirmed'))) {

                if ( numVolunteers > numVolsStillNeeded ) {
                    throw new KexRegistrationLimitReachedException();
                   }

                if (hoursQuery.isEmpty()) {
                    DateTime shiftDate = shift.GW_Volunteers__Start_Date_Time__c;
                    hours = new GW_Volunteers__Volunteer_Hours__c(
                        GW_Volunteers__Contact__c = volunteer.ID,
                        GW_Volunteers__Volunteer_Shift__c = shiftId,
                        GW_Volunteers__Volunteer_Job__c = shift.GW_Volunteers__Volunteer_Job__c,
                        GW_Volunteers__Start_Date__c =
                            Date.newInstance(shiftDate.year(), shiftDate.month(), shiftDate.day()),
                        GW_Volunteers__Status__c = 'Web Sign Up',
                        GW_Volunteers__Number_of_Volunteers__c = numVolunteers);

                    insert hours;
                    // We need to do this to ensure the new web signup email workflow is processed.
                    hours.GW_Volunteers__Status__c = 'Confirmed';
                    update hours;
                } else {
                    hours = hoursQuery[0];
                    hours.GW_Volunteers__Status__c = 'Confirmed';
                    hours.GW_Volunteers__Number_of_Volunteers__c = numVolunteers;
                    update hours;
                }

                // Also update the last web sign up date.
                volunteer.GW_Volunteers__Volunteer_Last_Web_Signup_Date__c = Date.today();
                update volunteer;

            } else { // (hoursQuery[0].GW_Volunteers__Status__c.equals('Confirmed'))

                hours = hoursQuery[0];

                Integer volsNeededDiff =
                    numVolunteers - hours.GW_Volunteers__Number_of_Volunteers__c.intValue();

                if (volsNeededDiff != 0) {
                    if ( volsNeededDiff > numVolsStillNeeded ) {
                        throw new KexRegistrationLimitReachedException();
                    }

                    hours.GW_Volunteers__Number_of_Volunteers__c = numVolunteers;
                    update hours;
                }

            }

        } else if (!hoursQuery.isEmpty()) {
            GW_Volunteers__Volunteer_Hours__c hours = hoursQuery[0];
            hours.GW_Volunteers__Status__c = 'Canceled';
            update hours;
        }
    }

}