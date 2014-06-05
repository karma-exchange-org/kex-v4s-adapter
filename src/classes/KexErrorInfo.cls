public with sharing class KexErrorInfo {
    public enum ErrorType {
        AUTHENTICATION_FAILURE,
        INVALID_PARAM,
        REGISTRATION_LIMIT_REACHED,
        OBJECT_NOT_FOUND,
        DML_EXCEPTION,
        OTHER_EXCEPTION
    }

    public String type { get; private set; }
    public String message { get; private set; }

    public KexErrorInfo(KexTypedException e) {
        type = e.getErrorType().name();
        message = e.getMessage();
    }

    public KexErrorInfo(Exception e) {
        if (e instanceof DmlException) {
            type = ErrorType.DML_EXCEPTION.name();
        } else {
            type = ErrorType.OTHER_EXCEPTION.name();
        }
        message = e.getMessage();
    }
}