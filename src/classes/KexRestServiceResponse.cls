global class KexRestServiceResponse {

    public KexSourceEvent sourceEvent;
    public KexErrorInfo error;

    public KexRestServiceResponse() {
        this(null, null);
    }

    public KexRestServiceResponse(KexSourceEvent sourceEvent) {
        this(sourceEvent, null);
    }

    public KexRestServiceResponse(KexErrorInfo error) {
        this(null, error);
    }

    public KexRestServiceResponse(KexSourceEvent sourceEvent, KexErrorInfo error) {
        this.sourceEvent = sourceEvent;
        this.error = error;
    }

}