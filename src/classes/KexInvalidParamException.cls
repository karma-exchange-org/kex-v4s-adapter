public with sharing class KexInvalidParamException extends Exception{
    public static void notNull(String paramName, Object paramValue) {
        if (paramValue == null) {
            throw new KexInvalidParamException('parameter \'' + paramName + '\' is required');
        }
    }
}