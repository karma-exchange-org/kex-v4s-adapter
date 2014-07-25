public with sharing class KexOrgPrefs {

    public KexOrg org;
    public boolean emailOptOut;

    public KexOrgPrefs(KexOrg org, boolean emailOptOut) {
        this.org = org;
        this.emailOptOut = emailOptOut;
    }

}