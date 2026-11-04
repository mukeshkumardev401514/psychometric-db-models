CREATE TABLE doctor_payout_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    doctor_payout_id UUID NOT NULL,

    payment_id UUID NOT NULL,

    doctor_amount NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_payout_items_payout
        FOREIGN KEY (doctor_payout_id)
        REFERENCES doctor_payouts(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_payout_items_payment
        FOREIGN KEY (payment_id)
        REFERENCES platform_payments(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_payout_item_amount
        CHECK (doctor_amount > 0),

    CONSTRAINT uq_doctor_payout_payment
        UNIQUE (payment_id)
);

CREATE INDEX idx_payout_items_payout
    ON doctor_payout_items(doctor_payout_id);