@isTest
public class KexTestDataFactory {

    public static final String SECRET_KEY = 'x';
    public static final String INVALID_SECRET_KEY = 'y';
    public static final String KEX_ORG_ID = 'KexTestOrgId';
    public static final String KEX_SERVER_URL = 'https://kex.server.org';

    public static final Integer MAX_SHIFT_VOLUNTEERS = 4;

    private final Id accountId;
    private final Id campaignId;
    private Integer contactCount = 0;
    private Integer jobCount = 0;

    public KexTestDataFactory() {
        Karma_Exchange_Admin_Settings__c adminSettings = new Karma_Exchange_Admin_Settings__c();
        adminSettings.SecretKey__c = SECRET_KEY;
        adminSettings.OrganizationId__c = 'KexTestOrgId';
        adminSettings.ServerUrl__c = KEX_SERVER_URL;
        insert adminSettings;

        Account acc = new Account(name='Individual Test Account');
        insert acc;
        accountId = acc.id;

        Campaign cmp = new Campaign(
            recordtypeid=getVolunteersCampaignRecordTypeId(),
            name='Test Campaign',
            IsActive=true);
        insert cmp;
        campaignId = cmp.Id;
    }

    private static Id getVolunteersCampaignRecordTypeId() {
        list<RecordType> listRT = [SELECT Id FROM RecordType WHERE DeveloperName='Volunteers_Campaign'];
        System.assert(listRT.size() != 0);
        return listRT[0].Id;
    }

    public Contact createContact() {
        contactCount++;
        Contact con = new Contact(
            Firstname=('KexTestFirst' + contactCount),
            Lastname=('KexTestLast' + contactCount),
            email=('KexTestEmail' + contactCount + '@x.y'),
            AccountId=accountId,
            GW_Volunteers__Volunteer_Status__c='inactive');
        insert con;
        return con;
    }

    public GW_Volunteers__Volunteer_Shift__c createShift() {
        jobCount++;
        GW_Volunteers__Volunteer_Job__c job = new GW_Volunteers__Volunteer_Job__c(
            name='TestJob' + jobCount,
            GW_Volunteers__Campaign__c = campaignId,
            GW_Volunteers__Location_Street__c = '1931 Center Street ',
            GW_Volunteers__Location_City__c = 'Berkeley',
            GW_Volunteers__Location__c = 'CA',
            GW_Volunteers__Location_Zip_Postal_Code__c = '94704');
        insert job;
        GW_Volunteers__Volunteer_Shift__c shift = new GW_Volunteers__Volunteer_Shift__c(
            GW_Volunteers__Volunteer_Job__c = job.Id,
            GW_Volunteers__Duration__c = 1,
            GW_Volunteers__Desired_Number_of_Volunteers__c = MAX_SHIFT_VOLUNTEERS,
            GW_Volunteers__Start_Date_Time__c = System.now().addDays(1));
        insert shift;
        return shift;
    }

    public Volunteer_Shift_Contact__c createShiftContact(
            GW_Volunteers__Volunteer_Shift__c shift,
            Contact contact,
            boolean isPrimary) {
        Volunteer_Shift_Contact__c shiftContact =
            new Volunteer_Shift_Contact__c(
                Contact__c = contact.id,
                Volunteer_Shift__c = shift.id,
                Is_Primary__c = isPrimary);
        insert shiftContact;
        return shiftContact;
    }

}