public with sharing class KexSourceParticipant {
    public static final String TYPE_ORGANIZER = 'ORGANIZER';
    public static final String TYPE_REGISTERED = 'REGISTERED';
    public static final String TYPE_REGISTERED_NO_SHOW = 'REGISTERED_NO_SHOW';

    public String type;
    public KexBaseSourceUser user;
}