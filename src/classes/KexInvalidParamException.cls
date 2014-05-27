public with sharing class KexInvalidParamException extends KexTypedException {

    public static void notNull(String paramName, Object paramValue) {
        if (paramValue == null) {
            throw new KexInvalidParamException('parameter \'' + paramName + '\' is required');
        }
    }

    public override KexErrorInfo.ErrorType getErrorType() {
        return KexErrorInfo.ErrorType.INVALID_PARAM;
    }
}