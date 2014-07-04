public with sharing class KexSourceUser {
    public String id;
    public String firstName;
    public String lastName;
    public String email;

    public KexSourceUser(Contact c) {
    	id = c.id;
    	firstName = c.FirstName;
    	lastName = c.LastName;
    	email = c.Email;
    }
}