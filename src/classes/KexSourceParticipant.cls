public with sharing class KexSourceParticipant {
    public static final String TYPE_ORGANIZER = 'ORGANIZER';
    public static final String TYPE_REGISTERED = 'REGISTERED';
    public static final String TYPE_REGISTERED_NO_SHOW = 'REGISTERED_NO_SHOW';

    public String type;
    public KexBaseSourceUser user;
    public Integer numVolunteers;
    public Double hoursWorked;

    public KexSourceParticipant(String type, KexBaseSourceUser user) {
        this(type, user, 0, 0);
    }

    public KexSourceParticipant(String type, KexBaseSourceUser user, Integer numVolunteers,
            Double hoursWorked) {
        this.type = type;
        this.user = user;
        this.numVolunteers = numVolunteers;
        this.hoursWorked = hoursWorked;
    }
}