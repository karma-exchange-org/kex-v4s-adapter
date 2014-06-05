trigger KexUpdatePrimaryVolunteerShiftContact on Volunteer_Shift_Contact__c (
        before insert, before update) {

    Map<Id, Volunteer_Shift_Contact__c> primaryShiftContactMap =
        new Map<Id, Volunteer_Shift_Contact__c>();

    for(Volunteer_Shift_Contact__c shiftContact : Trigger.new) {
        if (shiftContact.Is_Primary__c) {
            primaryShiftContactMap.put(
                shiftContact.Volunteer_Shift__c,
                shiftContact);
        }
    }

    List<Volunteer_Shift_Contact__c> affectedShiftContacts =
        [select Id, Volunteer_Shift__c, Is_Primary__c from Volunteer_Shift_Contact__c
            where Volunteer_Shift__c in :primaryShiftContactMap.keySet() limit 10000];
    List<Volunteer_Shift_Contact__c> shiftContactsToUpdate =
        new List<Volunteer_Shift_Contact__c>();
    for (Volunteer_Shift_Contact__c shiftContact : affectedShiftContacts) {
        Volunteer_Shift_Contact__c primaryContact =
            primaryShiftContactMap.get(shiftContact.Volunteer_Shift__c);
        // If shift contact is no longer the primary contact then we need to
        // update the is_primary field.
        if ((primaryContact.id != shiftContact.id) && shiftContact.Is_Primary__c) {
            shiftContact.Is_Primary__c = false;
            shiftContactsToUpdate.add(shiftContact);
        }
    }
    update shiftContactsToUpdate;
}