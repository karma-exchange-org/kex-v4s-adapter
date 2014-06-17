@IsTest
private class KexSourceEventTest {

    static testMethod void testToEvent() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift
            = testDataFactory.createShift();
        shift.GW_Volunteers__Description__c = 'shift description';
        update shift;

        Contact contact1 = testDataFactory.createContact();
        Contact contact2 = testDataFactory.createContact();
        testDataFactory.createShiftContact(shift, contact1, true);
        testDataFactory.createShiftContact(shift, contact2, false);

        KexSourceEvent kexEvent = KexSourceEvent.toEvent(shift.id);
        System.assert(kexEvent != null);
        System.assert(kexEvent.shiftDescription.equals('shift description'));
        KexSourceEvent.Location loc =
            kexEvent.location;
        System.assert(loc != null);
        KexSourceEvent.Address addr =
            loc.address;
        System.assert(addr != null);
        System.assert(addr.street == KexTestDataFactory.JOB_LOCATION_STREET);
        System.assert(addr.city == KexTestDataFactory.JOB_LOCATION_CITY);
        System.assert(addr.state == KexTestDataFactory.JOB_LOCATION_STATE);
        System.assert(addr.zip == KexTestDataFactory.JOB_ZIP_POSTAL_CODE);
        KexSourceEvent.GeoPoint geoPt =
            addr.geoPt;
        // Geopt is not specified in the default test factory job.
        System.assert(geoPt == null);

        List<KexSourceParticipant> organizers = getOrganizers(kexEvent);
        System.assert(organizers.size() == 2, 'organizers not found: ' + organizers);
        System.assert( (organizers[0].user.firstName.equals(contact1.firstName)) &&
                       (organizers[0].user.lastName.equals(contact1.lastName)) &&
                       (organizers[0].user.email.equalsIgnoreCase(contact1.email)),
                       'organizers[0] != contact1 (): organizers[0]=' + organizers[0] +
                       ' contact1=' + contact1);
        System.assert( (organizers[1].user.firstName.equals(contact2.firstName)) &&
                       (organizers[1].user.lastName.equals(contact2.lastName)) &&
                       (organizers[1].user.email.equalsIgnoreCase(contact2.email)),
                       'organizers[1] != contact2 (): organizers[0]=' + organizers[1] +
                       ' contact2=' + contact2);
        System.assert(null == kexEvent.sourceAssociatedOrg);
        // TODO(avaliani): validate conversion
    }

    static testMethod void testToEventGeoPt() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift
            = testDataFactory.createShift();
        shift.GW_Volunteers__Description__c = 'shift description';
        update shift;
        GW_Volunteers__Volunteer_Job__c job =
            new GW_Volunteers__Volunteer_Job__c(id = shift.GW_Volunteers__Volunteer_Job__c);
        job.Location_Coordinates__Latitude__s = 37.774929;
        job.Location_Coordinates__Longitude__s = -122.419416;
        update job;

        KexSourceEvent kexEvent = KexSourceEvent.toEvent(shift.id);
        System.assert(kexEvent != null);

        KexSourceEvent.GeoPoint geoPt =
            kexEvent.location.address.geoPt;
        System.assert(geoPt != null);
        System.assert( (geoPt.latitude == job.Location_Coordinates__Latitude__s) &&
                       (geoPt.longitude == job.Location_Coordinates__Longitude__s) );
    }

    static testMethod void testToEventDefaultShiftContactJobLevel() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Contact jobLevelContact = testDataFactory.createContact();
        GW_Volunteers__Volunteer_Shift__c shift
            = testDataFactory.createShift();
        GW_Volunteers__Volunteer_Job__c job =
            new GW_Volunteers__Volunteer_Job__c(id = shift.GW_Volunteers__Volunteer_Job__c);
        job.Default_Shift_Contact__c = jobLevelContact.id;
        update job;

        KexSourceEvent kexEvent = KexSourceEvent.toEvent(shift.id);
        System.assert(kexEvent != null);

        List<KexSourceParticipant> organizers = getOrganizers(kexEvent);
        System.assert(organizers.size() == 1, 'organizers not found: ' + organizers);
        System.assert( (organizers[0].user.firstName.equals(jobLevelContact.firstName)) &&
                       (organizers[0].user.lastName.equals(jobLevelContact.lastName)) &&
                       (organizers[0].user.email.equalsIgnoreCase(jobLevelContact.email)),
                       'organizers[0] != jobLevelContact: organizers[0]=' + organizers[0] +
                       ' jobLevelContact=' + jobLevelContact);
    }

    static testMethod void testToEventDefaultShiftContactCampaignLevel() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        Contact cmpLevelContact = testDataFactory.createContact();
        GW_Volunteers__Volunteer_Shift__c shift
            = testDataFactory.createShift();
        Campaign cmp = new Campaign(id=testDataFactory.campaignId);
        cmp.Default_Shift_Contact__c = cmpLevelContact.id;
        update cmp;

        KexSourceEvent kexEvent = KexSourceEvent.toEvent(shift.id);
        System.assert(kexEvent != null);

        List<KexSourceParticipant> organizers = getOrganizers(kexEvent);
        System.assert(organizers.size() == 1, 'organizers not found: ' + organizers);
        System.assert( (organizers[0].user.firstName.equals(cmpLevelContact.firstName)) &&
                       (organizers[0].user.lastName.equals(cmpLevelContact.lastName)) &&
                       (organizers[0].user.email.equalsIgnoreCase(cmpLevelContact.email)),
                       'organizers[0] != cmpLevelContact: organizers[0]=' + organizers[0] +
                       ' cmpLevelContact=' + cmpLevelContact);
    }

    static testMethod void testToEventAssociatedOrg() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift
            = testDataFactory.createShift();

        Account acc = new Account(
            name='Associated Volunteer Org',
            Karma_Exchange_Org_Id__c='StewardshipNetwork',
            Karma_Exchange_Org_Secret_Key__c='FakeKey');
        insert acc;
        Campaign cmp = new Campaign(id=testDataFactory.campaignId);
        cmp.Volunteer_Job_Sponsor__c = acc.id;
        update cmp;

        KexSourceEvent kexEvent = KexSourceEvent.toEvent(shift.id);
        System.assert(kexEvent != null);
        KexAssociatedOrg assocOrg = kexEvent.sourceAssociatedOrg;
        System.assert((assocOrg != null) && assocOrg.name.equals('Associated Volunteer Org') &&
            assocOrg.orgId.equals('StewardshipNetwork') && assocOrg.secretKey.equals('FakeKey'),
            'Associated org does not match: ' + assocOrg);
    }

    private static List<KexSourceParticipant> getOrganizers(KexSourceEvent kexEvent) {
        List<KexSourceParticipant> organizers =
            new List<KexSourceParticipant>();
        for (KexSourceParticipant participant : kexEvent.sourceParticipants) {
            if (KexSourceParticipant.TYPE_ORGANIZER == participant.type) {
                organizers.add(participant);
            }
        }
        return organizers;
    }
}