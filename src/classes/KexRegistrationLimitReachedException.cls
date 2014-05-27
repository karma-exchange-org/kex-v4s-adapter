public with sharing class KexRegistrationLimitReachedException extends KexTypedException {

    public override KexErrorInfo.ErrorType getErrorType() {
        return KexErrorInfo.ErrorType.REGISTRATION_LIMIT_REACHED;
    }
}