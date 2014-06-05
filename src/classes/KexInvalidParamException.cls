public with sharing class KexInvalidParamException extends KexTypedException {

    public static void notNull(String paramName, Object paramValue) {
        if (paramValue == null) {
            throw new KexInvalidParamException('parameter \'' + paramName + '\' is required');
        }
    }

    public static KexInvalidParamException create(String paramName) {
        return new KexInvalidParamException('parameter \'' + paramName + '\' has an invalid value');
    }

    public override KexErrorInfo.ErrorType getErrorType() {
        return KexErrorInfo.ErrorType.INVALID_PARAM;
    }
}