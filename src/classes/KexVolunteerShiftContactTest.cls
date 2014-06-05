@IsTest
private class KexVolunteerShiftContactTest {

    static testMethod void testUpdatePrimaryTrigger() {
        KexTestDataFactory testDataFactory = new KexTestDataFactory();
        GW_Volunteers__Volunteer_Shift__c shift = testDataFactory.createShift();
        Contact contact1 = testDataFactory.createContact();
        Contact contact2 = testDataFactory.createContact();
        Contact contact3 = testDataFactory.createContact();

        List<Volunteer_Shift_Contact__c> shiftContacts =
            getShiftContacts(shift.id);
        System.assert(shiftContacts.size() == 0);

        Volunteer_Shift_Contact__c shiftContact1 =
            testDataFactory.createShiftContact(shift, contact1, true);
        shiftContacts = getShiftContacts(shift.id);
        System.assert(shiftContacts.size() == 1);
        System.assert(checkAndGetPrimaryContactId(shiftContacts) == contact1.id,
            'primary contact is not correct: ' + shiftContacts);

        Volunteer_Shift_Contact__c shiftContact2 =
            testDataFactory.createShiftContact(shift, contact2, true);
        shiftContacts = getShiftContacts(shift.id);
        System.assert(shiftContacts.size() == 2);
        System.assert(checkAndGetPrimaryContactId(shiftContacts) == contact2.id,
            'primary contact is not correct: ' + shiftContacts);

        Volunteer_Shift_Contact__c shiftContact3 =
            testDataFactory.createShiftContact(shift, contact3, false);
        shiftContacts = getShiftContacts(shift.id);
        System.assert(shiftContacts.size() == 3);
        System.assert(checkAndGetPrimaryContactId(shiftContacts) == contact2.id,
            'primary contact is not correct: ' + shiftContacts);

        shiftContact1.Is_Primary__c = true;
        update shiftContact1;
        shiftContacts = getShiftContacts(shift.id);
        System.assert(checkAndGetPrimaryContactId(shiftContacts) == contact1.id,
            'primary contact is not correct: ' + shiftContacts);

        shiftContact3.Is_Primary__c = true;
        update shiftContact3;
        shiftContacts = getShiftContacts(shift.id);
        System.assert(checkAndGetPrimaryContactId(shiftContacts) == contact3.id,
            'primary contact is not correct: ' + shiftContacts);
    }

    private static List<Volunteer_Shift_Contact__c> getShiftContacts(Id shiftId) {
        return [SELECT Id, Is_Primary__c, Volunteer_Shift__c, Contact__c
            FROM Volunteer_Shift_Contact__c
            where Volunteer_Shift__c = :shiftId];
    }

    private static Id checkAndGetPrimaryContactId(List<Volunteer_Shift_Contact__c> shiftContacts) {
        Id primaryContact = null;
        for (Volunteer_Shift_Contact__c shiftContact : shiftContacts) {
            if (shiftContact.Is_Primary__c) {
                System.assert(primaryContact == null,
                    'more than one primary contact:' + shiftContacts);
                primaryContact = shiftContact.Contact__c;
            }
        }
        return primaryContact;
    }
}