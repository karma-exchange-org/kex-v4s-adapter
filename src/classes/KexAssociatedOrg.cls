public with sharing class KexAssociatedOrg {
    public enum AssociatedOrgType {
        EVENT_SPONSOR
    }

    public String name;
    public String type;

    public KexAssociatedOrg(String name, AssociatedOrgType type) {
        this.name = name;
        this.type = type.name();
    }
}