public with sharing virtual class KexOrg {

    // The salesforce org id.
    public String id;

    // A user readable name for the organization.
    public String name;

    // The karma exchange org id.
    public String orgId;
    public String secretKey;

    public KexOrg(Account acc) {
        id = acc.id;
        name = acc.Name;
        orgId = acc.Karma_Exchange_Org_Id__c;
        secretKey = acc.Karma_Exchange_Org_Secret_Key__c;
    }

}