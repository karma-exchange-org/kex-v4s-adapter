public with sharing class KexAssociatedOrg {
    public enum OrgAssociation {
        EVENT_SPONSOR
    }

	public String id;
    public String name;
    public String orgId;
    public String secretKey;
    public String association;

	public KexAssociatedOrg(Account acc, OrgAssociation association) {
		id = acc.id;
		name = acc.Name;
		orgId = acc.Karma_Exchange_Org_Id__c;
		secretKey = acc.Karma_Exchange_Org_Secret_Key__c;
		this.association = association.name();
	}
}