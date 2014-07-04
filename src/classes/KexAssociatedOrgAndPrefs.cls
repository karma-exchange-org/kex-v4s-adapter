public with sharing class KexAssociatedOrgAndPrefs {

	public KexAssociatedOrg org;
	public boolean emailOptOut;

	public KexAssociatedOrgAndPrefs(KexAssociatedOrg org, boolean emailOptOut) {
		this.org = org;
		this.emailOptOut = emailOptOut;
	}
}