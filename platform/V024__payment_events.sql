CREATE TABLE payment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    payment_id UUID,

    razorpay_event_id VARCHAR(255) NOT NULL UNIQUE,

    event_type VARCHAR(100) NOT NULL,

    payload JSONB NOT NULL,

    status payment_event_status NOT NULL DEFAULT 'RECEIVED',

    processed_at TIMESTAMPTZ,

    error_message TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_payment_events_payment
        FOREIGN KEY (payment_id)
        REFERENCES platform_payments(id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_payment_events_payment
    ON payment_events(payment_id);

CREATE INDEX idx_payment_events_event_type
    ON payment_events(event_type);