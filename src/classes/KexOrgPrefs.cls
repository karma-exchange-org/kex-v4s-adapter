public with sharing class KexOrgPrefs {

    public KexOrg org;
    public boolean emailOptOut;

    public KexOrgPrefs(KexOrg org, boolean emailOptOut) {
        this.org = org;
        this.emailOptOut = emailOptOut;
    }

    public Volunteer_Preferences_Per_Org__c toVolunteerPreferencesPerOrg(Contact contact) {
        Volunteer_Preferences_Per_Org__c prefs =
            new Volunteer_Preferences_Per_Org__c();
        prefs.Contact__c = contact.id;
        prefs.Org__c = org.id;
        prefs.Has_Opted_Out_Of_Email__c = emailOptOut;
        return prefs;
    }
}