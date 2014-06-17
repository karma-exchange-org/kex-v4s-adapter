public with sharing class KexAssociatedOrg {
    public enum OrgAssociation {
        EVENT_SPONSOR
    }

    public String name;
    public String orgId;
    public String secretKey;
    public String association;

    public KexAssociatedOrg(String name, String orgId, String secretKey, OrgAssociation association) {
        this.name = name;
        this.orgId = orgId;
        this.secretKey = secretKey;
        this.association = association.name();
    }
}