public with sharing class KexSourceUser extends KexBaseSourceUser {

    // If a user is registered with multiple organizations, then copying over the email opt out field each
    // time an organization syncs can cause problems. Therefore this field is only copied if the user
    // does not already exist in the Karma Exchange db.
    public boolean emailOptOut;

    public List<KexOrgPrefs> orgPrefs;

    public KexSourceUser(Contact c, List<KexOrgPrefs> orgPrefs) {
        super(c);
        this.emailOptOut = c.hasOptedOutOfEmail;
        this.orgPrefs = orgPrefs;
    }
}