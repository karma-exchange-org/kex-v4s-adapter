global without sharing class KexAdminController {

    webservice static void syncShift(Id shiftId) {
        syncShiftFuture(shiftId);
    }

    // Was getting a 502 when making a callout from the webservice method.
    //   https://developer.salesforce.com/forums/ForumsMain?id=906F00000008jyVIAQ
    @future (callout=true)
    public static void syncShiftFuture(Id shiftId) {
        List<KexSyncRequest> syncReqs = new List<KexSyncRequest>();
        KexSourceEvent event =
            KexSourceEvent.toEvent(shiftId);
        if (event == null) {
            throw new KexObjectNotFoundException(shiftId);
        }
        syncReqs.add(
            new KexSyncRequest(KexSyncRequest.ACTION_UPSERT, event));
        KexSyncRequest.send(syncReqs);
    }

    public static void syncUpcomingShifts() {
        database.executebatch(
            new KexSyncUpcomingShiftsBatch());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,
        	'Sync initiated. Please monitor apex jobs for completion.'));
    }

	public Karma_Exchange_Admin_Settings__c customSettings {
        get {
            if (customSettings == null) {
            	customSettings = Karma_Exchange_Admin_Settings__c.getInstance();
            }
            return customSettings;
        }
		set;
	}

	public KarmaExchangeSetting__c settings {
        get {
            if (settings == null) {
            	List<KarmaExchangeSetting__c> persistedSettings =
            		[select id, Default_Shift_Contact__c from KarmaExchangeSetting__c limit 1];
            	if (persistedSettings.size() > 0) {
            		settings = persistedSettings[0];
            	} else {
            		settings = new KarmaExchangeSetting__c();
            	}
            }
            return settings;
        }
		set;
	}

	public PageReference saveSettings() {
		try {
			updateAutoSync();
			upsert customSettings;
			upsert settings;
		} catch (exception ex) {
			// ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
			ApexPages.addMessages(ex);
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Settings updated'));
		return null;
	}

	private void updateAutoSync() {
		Karma_Exchange_Admin_Settings__c oldSettings =
			Karma_Exchange_Admin_Settings__c.getInstance();
		if ((oldSettings != null) && (oldSettings.Auto_Sync__c != customSettings.Auto_Sync__c)) {
			if (customSettings.Auto_Sync__c == true) {
				Id jobID = null;
				try {
			        jobId = System.schedule('Karma Exchange Volunteer Shift Sync',
			            '0 0 * * * ?',
			            new KexSyncPendingJobsBatch());
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

}