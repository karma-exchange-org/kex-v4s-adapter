@IsTest public with sharing class KexRegistrationControllerTest {
@IsTest(SeeAllData=true)
public static void testdoPost() {
	String firstName = getRandomName(9);
	String lastName = getRandomName(4);
	String email = firstName + '.' + lastName + '@' + getRandomName(3) + '.' + getRandomName(2);
	System.debug('*****' + firstName + ' ' + lastName + ' ' + email);
      //Test for creating New User
      KexRegistrationController.doPost('REGISTER', 'a04i000000DMfk8AAD', firstName, lastName, email);
      List<Contact> c = [select Id, Email from Contact where Email = :email];
      System.debug('Created Contact: ' + c);
      System.assert(c[0].Id != null);
      System.assert(c[0].Email == email);
      //Test for existing user
      KexRegistrationController.doPost('REGISTER', 'a04i000000CTk2JAAT', firstName, lastName, email);
      //Test for same user, registering the same event again
      KexRegistrationController.doPost('REGISTER', 'a04i000000CTk2JAAT', firstName, lastName, email);


  }


public static String getRandomName(Integer numberOfLetters){
   String allChars='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   String name='';
   for(integer cnt=0; cnt<=numberOfLetters;cnt++)   {
       Integer i = 1+Math.Round(700.0*Math.random()/26);
       if (i<=26)
       {
          i--;
          String newStr=allChars.substring(i,i+1);
          name=name+newStr;
      }else{
        cnt--;
      }
  }
  return name;
}

}