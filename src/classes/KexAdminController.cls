global without sharing class KexAdminController {

    public Karma_Exchange_Settings__c customSettings { get; set; }

    // This is a hack to get the lookup field icon.
    public Campaign orgLookupField { get; set; }

    // This is a hack to get the lookup field icon.
    public CampaignMember contactLookupField { get; set; }

    public KexAdminController() {
        customSettings = Karma_Exchange_Settings__c.getInstance();
        orgLookupField = new Campaign();
        if (customSettings.Organization__c != null) {
            orgLookupField.Volunteer_Job_Sponsor__c = customSettings.Organization__c;
        }
        contactLookupField = new CampaignMember();
        if (customSettings.Default_Shift_Contact__c != null) {
            contactLookupField.ContactId = customSettings.Default_Shift_Contact__c;
        }
    }

    public PageReference saveSettings() {
        try {
            updateAutoSync();
            customSettings.Organization__c = orgLookupField.Volunteer_Job_Sponsor__c;
            customSettings.Default_Shift_Contact__c = contactLookupField.ContactId;
            upsert customSettings;
        } catch (exception ex) {
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            ApexPages.addMessages(ex);
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Settings updated'));
        return null;
    }

    private void updateAutoSync() {
        Karma_Exchange_Settings__c oldSettings =
            Karma_Exchange_Settings__c.getInstance();
        if ((oldSettings != null) && (oldSettings.Auto_Sync__c != customSettings.Auto_Sync__c)) {
            if (customSettings.Auto_Sync__c == true) {
                Id jobID = null;
                try {
                    jobId = scheduleSyncDbJob();
                } catch (AsyncException e) {
                    if ( !e.getMessage().contains('is already scheduled for execution') ) {
                        throw e;
                    }
                }
                if (jobId != null) {
                    customSettings.Auto_Sync_Job_Id__c = jobId;
                }
            } else {
                if (customSettings.Auto_Sync_Job_Id__c != null) {
                    system.abortJob(customSettings.Auto_Sync_Job_Id__c);
                    customSettings.Auto_Sync_Job_Id__c = null;
                }
            }
        }
    }

    private Id scheduleSyncDbJob() {
        Database.Batchable<sObject> syncShiftsJob =
            new KexSyncPendingJobsBatch();

        // The order of execution doesn't matter in this case. But the sync contacts
        // job supports job chaining so we make that job the schedulable one.
        Schedulable syncDbJob =
            new KexCompactAndSyncPendingContactsBatch(syncShiftsJob);

        return System.schedule('Karma Exchange Db Sync',
                        '0 0 * * * ?',
                        syncDbJob);
    }

    public static void syncUpcomingShifts() {
        database.executebatch(
            new KexSyncUpcomingShiftsBatch());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,
            'Sync initiated. Please monitor apex jobs for completion.'));
    }

}