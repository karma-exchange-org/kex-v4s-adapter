public with sharing class KexObjectNotFoundException extends KexTypedException {
    public KexObjectNotFoundException(Id objectId) {
        super('Object with id=\'' + objectId +'\' not found');
    }

    public override KexErrorInfo.ErrorType getErrorType() {
        return KexErrorInfo.ErrorType.OBJECT_NOT_FOUND;
    }
}