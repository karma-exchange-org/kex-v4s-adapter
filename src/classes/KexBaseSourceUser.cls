public with sharing virtual class KexBaseSourceUser {

    public String firstName;
    public String lastName;
    public String email;

    public KexBaseSourceUser(Contact c) {
        firstName = c.FirstName;
        lastName = c.LastName;
        email = c.Email;
    }

}