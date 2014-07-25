public with sharing class KexAssociatedOrg {
    public enum OrgAssociation {
        EVENT_SPONSOR
    }

    public KexOrg org;

    public String association;

    public KexAssociatedOrg(Account acc, OrgAssociation association) {
        org = new KexOrg(acc);
        this.association = association.name();
    }
}