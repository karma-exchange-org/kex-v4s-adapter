public with sharing class KexAuthFailureException extends KexTypedException {

    public override KexErrorInfo.ErrorType getErrorType() {
        return KexErrorInfo.ErrorType.AUTHENTICATION_FAILURE;
    }
}