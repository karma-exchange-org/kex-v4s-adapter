public without sharing class KexSourceEvent {

    private static final String VH_STATUS_CONFIRMED = 'Confirmed';
    private static final String VH_STATUS_WEB_SIGN_UP = 'Web Sign Up';
    private static final String VH_STATUS_COMPLETED = 'Completed';
    private static final String VH_STATUS_NO_SHOW = 'No-Show';

    private static final Id DEFAULT_SHIFT_CONTACT = Karma_Exchange_Settings__c.getInstance().Default_Shift_Contact__c;

    public KexSourceEventInfo sourceEventInfo;
    public List<KexSourceParticipant> sourceParticipants = new List<KexSourceParticipant>();
    public KexAssociatedOrg sourceAssociatedOrg;

    public String title;
    public String descriptionHtml;
    public String shiftDescription;

    public Location location;
    public String locationInformationHtml;
    public long startTime;
    public long endTime;
    public Integer maxRegistrations;
    public String externalRegistrationUrl;
    public String externalRegistrationDetailsHtml;

    public class Location {
        public String title;
        public String description;
        public Address address;
    }

    public class Address {
        public String street;
        public String city;
        public String state;
        public String country;
        public String zip;
        public GeoPoint geoPt;
    }

    public class GeoPoint {
        public Decimal latitude;
        public Decimal longitude;

        public GeoPoint(Decimal latitude, Decimal longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }

    public class KexSourceEventInfo {
        public String id;
        public long lastModifiedDate;

        public KexSourceEventInfo(String id, long lastModifiedDate) {
            this.id = id;
            this.lastModifiedDate = lastModifiedDate;
        }
    }

    private KexSourceEvent(Id shiftId, DateTime lastModifiedDate) {
        sourceEventInfo =
            new KexSourceEventInfo(shiftId, lastModifiedDate.getTime());
    }

    public static KexSourceEvent toEvent(Id shiftId) {
        List<KexSourceEvent> eventQueryResult = toEvents(new List<Id> { shiftId });
        return eventQueryResult.isEmpty() ? null : eventQueryResult[0];
    }

    public static List<KexSourceEvent> toEvents(List<Id> shiftIds) {
        List<KexSourceEvent> eventList = new List<KexSourceEvent>();

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
                   GW_Volunteers__Volunteer_Job__r.Location_Coordinates__Latitude__s,
                   GW_Volunteers__Volunteer_Job__r.Location_Coordinates__Longitude__s,
                   GW_Volunteers__Volunteer_Job__r.External_Registration_Url__c,
                   GW_Volunteers__Volunteer_Job__r.External_Registration_Details__c,
                   GW_Volunteers__Start_Date_Time__c,
                   GW_Volunteers__Desired_Number_of_Volunteers__c,
                   GW_Volunteers__Duration__c,
                   GW_Volunteers__Description__c,
                   GW_Volunteers__Volunteer_Job__r.Default_Shift_Contact__r.FirstName,
                   GW_Volunteers__Volunteer_Job__r.Default_Shift_Contact__r.LastName,
                   GW_Volunteers__Volunteer_Job__r.Default_Shift_Contact__r.Email,
                   GW_Volunteers__Volunteer_Job__r.Default_Shift_Contact__r.LastModifiedDate,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Default_Shift_Contact__r.FirstName,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Default_Shift_Contact__r.LastName,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Default_Shift_Contact__r.Email,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Default_Shift_Contact__r.LastModifiedDate,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Volunteer_Job_Sponsor__r.Name,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Volunteer_Job_Sponsor__r.Karma_Exchange_Org_Id__c,
                   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Volunteer_Job_Sponsor__r.Karma_Exchange_Org_Secret_Key__c,
                   LastModifiedDate
                from GW_Volunteers__Volunteer_Shift__c
                where Id in :shiftIds];

        for(GW_Volunteers__Volunteer_Shift__c shift : shiftQuery) {
            GW_Volunteers__Volunteer_Job__c job =
                shift.GW_Volunteers__Volunteer_Job__r;

            KexSourceEvent event = new KexSourceEvent(shift.id, shift.LastModifiedDate);

            event.title = job.Name;
            event.descriptionHtml = job.GW_Volunteers__Description__c;
            event.shiftDescription = shift.GW_Volunteers__Description__c;
            event.locationInformationHtml = job.GW_Volunteers__Location_Information__c;
            event.externalRegistrationUrl = job.External_Registration_Url__c;
            event.externalRegistrationDetailsHtml = job.External_Registration_Details__c;

            // event.location.title =
            //    job.GW_Volunteers__Location_Information__c;
            if ((job.GW_Volunteers__Location_Street__c != null) ||
                (job.GW_Volunteers__Location_City__c != null) ||
                (job.GW_Volunteers__Location__c != null) ||
                (job.GW_Volunteers__Location_Zip_Postal_Code__c != null) ||
                ( (job.Location_Coordinates__Latitude__s != null) &&
                  (job.Location_Coordinates__Longitude__s != null) )  ) {

                event.location = new Location();
                Address addr = event.location.address = new Address();

                addr.street =
                    job.GW_Volunteers__Location_Street__c;
                addr.city =
                    job.GW_Volunteers__Location_City__c;
                addr.state =
                    job.GW_Volunteers__Location__c;
                addr.zip =
                    job.GW_Volunteers__Location_Zip_Postal_Code__c;
                addr.country = 'USA';
                if ( (job.Location_Coordinates__Latitude__s != null) &&
                     (job.Location_Coordinates__Longitude__s != null) ) {
                    addr.geoPt = new GeoPoint(
                        job.Location_Coordinates__Latitude__s,
                        job.Location_Coordinates__Longitude__s);
                }

            }

            event.startTime = shift.GW_Volunteers__Start_Date_Time__c.getTime();
            DateTime endTime = DateTime.newInstance(shift.GW_Volunteers__Start_Date_Time__c.getTime());
            Double durationHours = shift.GW_Volunteers__Duration__c.doubleValue();
            endTime = endTime.addMinutes((durationHours * 60).intValue());
            event.endTime = endTime.getTime();

            event.maxRegistrations =
                (shift.GW_Volunteers__Desired_Number_of_Volunteers__c != null) ?
                shift.GW_Volunteers__Desired_Number_of_Volunteers__c.intValue() :
                0;

            if (job.GW_Volunteers__Campaign__r.Volunteer_Job_Sponsor__r != null) {
                event.sourceAssociatedOrg = new KexAssociatedOrg(
                    job.GW_Volunteers__Campaign__r.Volunteer_Job_Sponsor__r,
                    KexAssociatedOrg.OrgAssociation.EVENT_SPONSOR);
            }

            event.setParticipants(shift);

            // Skipping shift description for now.
            // TODO(avaliani): add this once there is shift support
            eventList.add(event);
        }
        return eventList;
    }

    private void setParticipants(GW_Volunteers__Volunteer_Shift__c shift) {
        sourceParticipants = new List<KexSourceParticipant>();

        // TODO(avaliani): for efficiency we could move this query to the shift query as a nested
        //   query.
        List<GW_Volunteers__Volunteer_Hours__c> shiftVolunteers =
            [Select
                GW_Volunteers__Status__c,
                GW_Volunteers__Contact__r.FirstName,
                GW_Volunteers__Contact__r.LastName,
                GW_Volunteers__Contact__r.Email,
                GW_Volunteers__Contact__r.LastModifiedDate,
                LastModifiedDate
             from GW_Volunteers__Volunteer_Hours__c
             where GW_Volunteers__Volunteer_Shift__c = :shift.Id];

        // Prospect - ignored
        // Confirmed / Web Sign Up => REGISTERED
        // Completed  => REGISTERED
        // No-show => REGISTERED_NO_SHOW
        // Canceled - ignored. The volunteer can no longer do this job or shift. This status
        //            prevents the system scheduler from re-assigning a recurring volunteer to this shift.
        for (GW_Volunteers__Volunteer_Hours__c shiftVolunteer : shiftVolunteers) {
            long lastModifiedDate = shiftVolunteer.LastModifiedDate.getTime();
            if (lastModifiedDate > this.sourceEventInfo.lastModifiedDate) {
                this.sourceEventInfo.lastModifiedDate = lastModifiedDate;
            }

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
                participant.user =
                    new KexBaseSourceUser(shiftVolunteer.GW_Volunteers__Contact__r);
                sourceParticipants.add(participant);
            }
        }

        sourceParticipants.addAll(getOrganizers( shift));
    }

    private static List<KexSourceParticipant> getOrganizers(GW_Volunteers__Volunteer_Shift__c shift) {
        List<KexSourceParticipant> participants = new List<KexSourceParticipant>();
        List<KexSourceParticipant> others = new List<KexSourceParticipant>();
        KexSourceParticipant primary = null;
        List<Volunteer_Shift_Contact__c> shiftContacts =
            [Select
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Email,
                Contact__r.LastModifiedDate,
                Is_Primary__c
             from Volunteer_Shift_Contact__c
             where Volunteer_Shift__c = : shift.Id];
        for (Volunteer_Shift_Contact__c shiftContact : shiftContacts) {
            if (primary==null) {
                primary = toOrganizer(shiftContact.Contact__r);
            } else if (shiftContact.Is_Primary__c) {
                others.add(primary);
                primary = toOrganizer(shiftContact.Contact__r);
            } else {
                others.add(toOrganizer(shiftContact.Contact__r));
            }
        }
        if ( (primary == null) && shift.GW_Volunteers__Volunteer_Job__r.Default_Shift_Contact__c != null) {
            //go to job
            primary = toOrganizer(shift.GW_Volunteers__Volunteer_Job__r.Default_Shift_Contact__r);
        }
        if ( (primary == null) && shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Default_Shift_Contact__c != null) {
            //go to campaign
            primary = toOrganizer(shift.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Default_Shift_Contact__r);
        }
        if (primary == null) {
            //go to Org
            if (DEFAULT_SHIFT_CONTACT != null) {
                List<Contact> defaultShiftContactQueryResult =
                    [select
                        FirstName,
                        LastName,
                        Email,
                        LastModifiedDate
                    from Contact where Id = :DEFAULT_SHIFT_CONTACT];
                if (defaultShiftContactQueryResult.size() > 0) {
                    Contact defaultShiftContact = defaultShiftContactQueryResult[0];
                    primary = toOrganizer(defaultShiftContact);
                }
            }
        }
        participants.add(primary);
        participants.addAll(others);
        return participants;
    }

    private static KexSourceParticipant toOrganizer(Contact organizer) {
        KexSourceParticipant participant = new KexSourceParticipant();
        participant.type = KexSourceParticipant.TYPE_ORGANIZER;
        participant.user =
            new KexBaseSourceUser(organizer);
        return participant;
    }

}