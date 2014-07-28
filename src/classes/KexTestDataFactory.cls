@isTest
public class KexTestDataFactory {

    public static final String SECRET_KEY = 'x';
    public static final String INVALID_SECRET_KEY = 'y';
    public static final String KEX_ORG_ID = 'KexTestOrgId';
    public static final String KEX_SERVER_URL = 'https://kex.server.org';

    public static final String JOB_LOCATION_STREET = '1931 Center Street';
    public static final String JOB_LOCATION_CITY = 'Berkeley';
    public static final String JOB_LOCATION_STATE = 'CA';
    public static final String JOB_ZIP_POSTAL_CODE = '94704';

    public static final Integer MAX_SHIFT_VOLUNTEERS = 4;

    private final Campaign cmp;
    public final Id campaignId;

    private final Id accountId;
    private Integer contactCount = 0;
    private Integer jobCount = 0;

    public KexTestDataFactory() {
        Account acc = new Account(name='Individual Test Account');
        insert acc;
        accountId = acc.id;

        Contact defContact = new Contact(
            Firstname=('DefaultContactFirst'),
            Lastname=('DefaultContactLast'),
            email=('DefaultContactEmail@x.y'));
        insert defContact;

        Karma_Exchange_Settings__c adminSettings = new Karma_Exchange_Settings__c();
        adminSettings.Karma_Exchange_Secret_Key__c = SECRET_KEY;
        adminSettings.Karma_Exchange_Organization_Id__c = 'KexTestOrgId';
        adminSettings.Karma_Exchange_Server_Url__c = KEX_SERVER_URL;
        adminSettings.Organization__c = accountId;
        adminSettings.Auto_Sync__c = true;
        adminSettings.Default_Shift_Contact__c = defContact.id;
        insert adminSettings;

        cmp = new Campaign(
            recordtypeid=getVolunteersCampaignRecordTypeId(),
            name='Test Campaign',
            IsActive=true);
        insert cmp;
        campaignId = cmp.Id;
    }

    public static Id getVolunteersCampaignRecordTypeId() {
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
        return createShift(cmp);
    }

    public GW_Volunteers__Volunteer_Shift__c createShift(Campaign cmp) {
        jobCount++;
        GW_Volunteers__Volunteer_Job__c job = new GW_Volunteers__Volunteer_Job__c(
            name='TestJob' + jobCount,
            GW_Volunteers__Campaign__c = cmp.Id,
            GW_Volunteers__Location_Street__c = JOB_LOCATION_STREET,
            GW_Volunteers__Location_City__c = JOB_LOCATION_CITY,
            GW_Volunteers__Location__c = JOB_LOCATION_STATE,
            GW_Volunteers__Location_Zip_Postal_Code__c = JOB_ZIP_POSTAL_CODE);
        insert job;
        GW_Volunteers__Volunteer_Shift__c shift = new GW_Volunteers__Volunteer_Shift__c(
            GW_Volunteers__Volunteer_Job__c = job.Id,
            GW_Volunteers__Duration__c = 1,
            GW_Volunteers__Desired_Number_of_Volunteers__c = MAX_SHIFT_VOLUNTEERS,
            GW_Volunteers__Start_Date_Time__c = System.now().addDays(1));
        insert shift;
        return shift;
    }

    public GW_Volunteers__Volunteer_Hours__c registerVolunteer(GW_Volunteers__Volunteer_Shift__c shift, Contact volunteer) {
        return registerVolunteer(shift, volunteer, 1);
    }

    public GW_Volunteers__Volunteer_Hours__c registerVolunteer(GW_Volunteers__Volunteer_Shift__c shift, Contact volunteer,
            Integer numVolunteers) {
        volunteer.GW_Volunteers__Volunteer_Last_Web_Signup_Date__c = Date.today();
        update volunteer;
        DateTime shiftDate =
            shift.GW_Volunteers__Start_Date_Time__c;
        GW_Volunteers__Volunteer_Hours__c hoursEntry = new GW_Volunteers__Volunteer_Hours__c(
            GW_Volunteers__Contact__c = volunteer.ID,
            GW_Volunteers__Volunteer_Shift__c = shift.ID,
            GW_Volunteers__Volunteer_Job__c = shift.GW_Volunteers__Volunteer_Job__c,
            GW_Volunteers__Start_Date__c =
                Date.newInstance(shiftDate.year(), shiftDate.month(), shiftDate.day()),
            GW_Volunteers__Status__c = 'Web Sign Up',
            GW_Volunteers__Number_of_Volunteers__c = numVolunteers);
        insert hoursEntry;
        return hoursEntry;
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