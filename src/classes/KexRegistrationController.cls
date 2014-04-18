@RestResource(urlMapping='/registration/*')
global with sharing class KexRegistrationController {

    private enum RegistrationAction {
    	REGISTER,
    	UNREGISTER
    }

    // TODO(avaliani): handle unregister. Rename controller from signup to 'register'. See if
    //   different methods can have different rest resource paths
    // TODO(avaliani): integration. Handle new exception mechanism

    @HttpPost
    global static void doPost(String action, String sourceKey,
           String firstName, String lastName, String email) {

        KexInvalidParamException.notNull('action', action);
        KexInvalidParamException.notNull('sourceKey', sourceKey);
        KexInvalidParamException.notNull('firstName', firstName);
        KexInvalidParamException.notNull('lastName', lastName);
        KexInvalidParamException.notNull('email', email);

        String shiftId = sourceKey;

        System.debug('Processing signup request:' +
          'action=' + action + ', ' +
          'shiftId=' + shiftId + ', ' +
          'firstName=' + firstName + ', ' +
          'lastName=' + lastName + ', ' +
          'email=' + email);

        Contact[] contactQueryResult =
          [Select c.ID from Contact c where
              c.FirstName = :firstName and
              c.LastName = :lastName and
              c.Email = :email
              for update];
        Contact contact;
        if (contactQueryResult.isEmpty()) {
            contact = new Contact(FirstName = firstName, LastName = lastName, Email = email);
            insert contact;
            System.debug('Creating new contact: ' + contact);
        } else {
            contact = contactQueryResult[0];
            System.debug('Found contact: ' + contact);
        }

        // TODO(avaliani): Do we need a select for update here? Triggers is going to update this.
        //   Is the trigger updating it as part of the same txn or only post-commit?
        GW_Volunteers__Volunteer_Shift__c shift =
            [Select GW_Volunteers__Number_of_Volunteers_Still_Needed__c,
                GW_Volunteers__Start_Date_Time__c,
                GW_Volunteers__Volunteer_Job__c
             from GW_Volunteers__Volunteer_Shift__c
             where Id = :shiftId
             for update];
        System.debug('Num volunteers needed: ' +
            shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c);

        GW_Volunteers__Volunteer_Hours__c[] hoursQuery =
            [Select GW_Volunteers__Status__c
             from GW_Volunteers__Volunteer_Hours__c
             where GW_Volunteers__Contact__c = :contact.Id and
                GW_Volunteers__Volunteer_Shift__c = :shiftId
             for update];
         
         System.debug('duplicate ' + action);
         System.debug('duplicate2 ' + RegistrationAction.REGISTER.name());

        // Prevent duplicate signups
        if ( action.equals(RegistrationAction.REGISTER.name()) ) {
	        if (hoursQuery.isEmpty() || (hoursQuery[0].GW_Volunteers__Status__c != 'Confirmed')) {
	            if (shift.GW_Volunteers__Number_of_Volunteers_Still_Needed__c == 0) {
	                throw new KexLimitReachedException('volunteer limit reached');
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
	                    GW_Volunteers__Status__c = 'Confirmed',
	                    GW_Volunteers__Number_of_Volunteers__c = 1);

	                System.debug('[register] creating new hours entry: ' + hours);

	                insert hours;

	            } else {
	                System.debug('[register] updating existing hours entry - old: ' + hours);

	                hours = hoursQuery[0];
	                hours.GW_Volunteers__Status__c = 'Confirmed';
	                update hours;
	            }
	        }
        } else if (!hoursQuery.isEmpty()) {
            GW_Volunteers__Volunteer_Hours__c hours = hoursQuery[0];

            System.debug('[unregister] old: ' + hours);

            hours.GW_Volunteers__Status__c = 'Canceled';
            update hours;
        }
    }
 }