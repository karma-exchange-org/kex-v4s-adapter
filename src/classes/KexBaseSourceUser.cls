public with sharing virtual class KexBaseSourceUser {

    public String firstName;
    public String lastName;
    public String email;

    public KexBaseSourceUser(Contact c) {
        firstName = c.FirstName;
        lastName = c.LastName;
        email = c.Email;
    }

    // @VisibleForTesting
    public KexBaseSourceUser() {
    }

    public virtual void validate() {
        KexInvalidParamException.notNull('firstName', firstName);
        KexInvalidParamException.notNull('lastName', lastName);
        KexInvalidParamException.notNull('email', email);
    }
}