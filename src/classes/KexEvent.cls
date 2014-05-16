public with sharing class KexEvent {
    public String sourceKey;
    public String title;
    public String description;
    public Location location;
    public long startTime;
    public long endTime;
    public Integer maxRegistrations;
    public KeyWrapper organization;
    public List<KexSourceParticipant> sourceParticipants = new List<KexSourceParticipant>();

    public class Location {
        public String title;
        public String description;
        public Address address = new Address();
    }

    public class Address {
        public String street;
        public String city;
        public String state;
        public String country;
        public String zip;
        public GeoPoint geoPt = null;
    }

    public class GeoPoint {
        public Decimal latitude;
        public Decimal longitude;
    }

    public class KeyWrapper {
        public String key;

        public KeyWrapper(String key) {
            this.key = key;
        }
    }

}