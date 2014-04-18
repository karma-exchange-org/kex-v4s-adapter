@IsTest public with sharing class KexInvalidParamExceptionTest {
@IsTest(SeeAllData=true)
public static void testKexInvalidParamException() {
   try
    {
      KexInvalidParamException.notNull('Name',null);
    }

   catch(Exception e)
    {
    System.Assert(e.getMessage().contains('parameter \'Name\' is required'));
    }

  }
}