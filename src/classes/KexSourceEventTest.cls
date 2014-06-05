@IsTest
private class KexSourceEventTest {

    static testMethod void testToEvent() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift
            = testDataFactory.createShift();
        Contact contact1 = testDataFactory.createContact();
        Contact contact2 = testDataFactory.createContact();
        testDataFactory.createShiftContact(shift, contact1, true);
        testDataFactory.createShiftContact(shift, contact2, false);

        KexSourceEvent kexEvent = KexSourceEvent.toEvent(shift.id);
        System.assert(kexEvent != null);

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

        // TODO(avaliani): validate conversion
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