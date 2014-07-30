global with sharing class KexSourceUser extends KexBaseSourceUser {

    // If a user is registered with multiple organizations, then copying over the email opt out field each
    // time an organization syncs can cause problems. Therefore this field is only copied if the user
    // does not already exist in the Karma Exchange db.
    public boolean emailOptOut;

    public List<KexOrgPrefs> orgPrefs = new List<KexOrgPrefs>();

    public KexSourceUser(Contact c, List<KexOrgPrefs> orgPrefs) {
        super(c);
        this.emailOptOut = c.hasOptedOutOfEmail;
        this.orgPrefs = orgPrefs;
    }

    // @VisibleForTesting
    public KexSourceUser() {
    }

    public override void validate() {
        super.validate();
        KexInvalidParamException.notNull('emailOptOut', emailOptOut);
    }

    public Contact createOrUpdate() {
        // TODO(avaliani): close out timing window for duplicate contacts.
        Contact[] contactQueryResult =
          [Select
                ID,
                FirstName,
                LastName,
                Email,
                HasOptedOutOfEmail,
                (SELECT
                    Org__c,
                    Has_Opted_Out_Of_Email__c,
                    LastModifiedDate
                 FROM Volunteer_Preferences_Per_Org__r)
           FROM Contact c
           WHERE
                  c.FirstName = :firstName and
                  c.LastName = :lastName and
                  c.Email = :email];
        Contact contact;
        if (contactQueryResult.isEmpty()) {

            contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                HasOptedOutOfEmail = emailOptOut);
            insert contact;

            List<Volunteer_Preferences_Per_Org__c> convPrefs =
                createOrgPrefsMap(contact).values();
            insert convPrefs;

        } else {
            contact = contactQueryResult[0];
            if (contact.HasOptedOutOfEmail != emailOptOut) {
                contact.HasOptedOutOfEmail = emailOptOut;
                update contact;
            }

            List<Volunteer_Preferences_Per_Org__c> existingOrgPrefs =
                contact.Volunteer_Preferences_Per_Org__r;

            Map<Id, Volunteer_Preferences_Per_Org__c> reqPrefsMap =
                createOrgPrefsMap(contact);

            List<Volunteer_Preferences_Per_Org__c> prefsToUpsert =
                new List<Volunteer_Preferences_Per_Org__c>();
            List<Volunteer_Preferences_Per_Org__c> prefsToDelete =
                new List<Volunteer_Preferences_Per_Org__c>();

            for (Volunteer_Preferences_Per_Org__c existingOrgPref : existingOrgPrefs) {
                Volunteer_Preferences_Per_Org__c mappedReqPref =
                    reqPrefsMap.get(existingOrgPref.Org__c);
                if (mappedReqPref == null) {
                    prefsToDelete.add(existingOrgPref);
                } else {
                    reqPrefsMap.remove(existingOrgPref.Org__c);
                    if (existingOrgPref.Has_Opted_Out_Of_Email__c != mappedReqPref.Has_Opted_Out_Of_Email__c) {
                        existingOrgPref.Has_Opted_Out_Of_Email__c = mappedReqPref.Has_Opted_Out_Of_Email__c;
                        prefsToUpsert.add(existingOrgPref);
                    }
                }
            }

            // Add anything left in the reqPrefs map to prefsToUpsert.
            prefsToUpsert.addAll(reqPrefsMap.values());

            upsert prefsToUpsert;
            delete prefsToDelete;
        }
        return contact;
    }

    private Map<Id, Volunteer_Preferences_Per_Org__c> createOrgPrefsMap(Contact contact) {
        Map<Id, Volunteer_Preferences_Per_Org__c> orgPrefMap =
            new Map<Id, Volunteer_Preferences_Per_Org__c>();
        for (KexOrgPrefs orgPref : orgPrefs) {
            Volunteer_Preferences_Per_Org__c convPref =
                orgPref.toVolunteerPreferencesPerOrg(contact);
            orgPrefMap.put(convPref.Org__c, convPref);
        }
        return orgPrefMap;
    }
}