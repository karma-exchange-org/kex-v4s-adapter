trigger KexUpdatePrimaryVolunteerShiftContact on Volunteer_Shift_Contact__c (
        before insert, before update) {

    List<Id> shiftIds = new List<Id>();
    List<Id> vsContacts = new List<Id>();
    for(Volunteer_Shift_Contact__c node : Trigger.new)
    {
        if(node.Is_Primary__c)
        {
            shiftIds.add(node.Volunteer_Shift__c);
            vsContacts.add(node.Id);
        }
    }
    List<Volunteer_Shift_Contact__c> toUpdate =
        [select Id from Volunteer_Shift_Contact__c where Volunteer_Shift__c in : shiftIds and  Id not in :vsContacts limit 10000];
    for(Volunteer_Shift_Contact__c node : toUpdate)
    {
        node.Is_Primary__c = false;
    }
    update toUpdate;
}