public with sharing class KexAssociatedOrg {
    public enum OrgAssociation {
        EVENT_SPONSOR
    }

    public String orgId;
    public String name;
    public String association;

    public KexAssociatedOrg(String orgId, String name, OrgAssociation association) {
        this.orgId = orgId;
        this.name = name;
        this.association = association.name();
    }
}