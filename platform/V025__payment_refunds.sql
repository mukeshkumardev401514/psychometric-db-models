CREATE TABLE payment_refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    payment_id UUID NOT NULL,

    amount NUMERIC(12,2) NOT NULL,

    currency VARCHAR(3) NOT NULL DEFAULT 'INR',

    razorpay_refund_id VARCHAR(255),

    reason TEXT,

    status payment_status NOT NULL DEFAULT 'PENDING',

    refunded_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_payment_refunds_payment
        FOREIGN KEY (payment_id)
        REFERENCES platform_payments(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_refund_amount
        CHECK (amount > 0)
);

CREATE INDEX idx_payment_refunds_payment
    ON payment_refunds(payment_id);

CREATE UNIQUE INDEX uq_payment_refunds_razorpay
    ON payment_refunds(razorpay_refund_id)
    WHERE razorpay_refund_id IS NOT NULL;