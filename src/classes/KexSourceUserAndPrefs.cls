public with sharing class KexSourceUserAndPrefs {

	public KexSourceUser user;
	public boolean emailOptOut;
	public List<KexAssociatedOrgAndPrefs> orgPreferences;
	public long sourceLastModifiedDate;

	public KexSourceUserAndPrefs(KexSourceUser user, boolean emailOptOut, List<KexAssociatedOrgAndPrefs> orgPreferences,
			long sourceLastModifiedDate) {
		this.user = user;
		this.emailOptOut = emailOptOut;
		this.orgPreferences = orgPreferences;
		this.sourceLastModifiedDate = sourceLastModifiedDate;
	}
}