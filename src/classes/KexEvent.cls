public with sharing class KexEvent {
	  public String sourceKey;
	  public String title;
	  public String description;
	  public Location location = new Location();
	  public long startTime;
	  public long endTime;
	  public Integer maxRegistrations;
	  public KeyObject organization = new KeyObject();
	  public List<Participant> participants = new List<Participant>();

	 public class Location{
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

	public class GeoPoint
	{
		public Decimal latitude;
		public Decimal longitude;
	}
	public class Participant
	{
		public String type;
		public KeyObject user = new KeyObject();
	}
	public class KeyObject
	{
		public String key;
	}

}