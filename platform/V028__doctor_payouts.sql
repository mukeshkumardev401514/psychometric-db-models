CREATE TABLE doctor_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    payout_batch_id UUID,

    tenant_id UUID NOT NULL,

    doctor_id UUID NOT NULL,

    payout_account_id UUID NOT NULL,

    payout_mode payout_mode NOT NULL,

    amount NUMERIC(12,2) NOT NULL,

    currency VARCHAR(3) NOT NULL DEFAULT 'INR',

    status payout_status NOT NULL DEFAULT 'PENDING',

    payout_reference VARCHAR(255),

    processed_at TIMESTAMPTZ,

    failure_reason TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_doctor_payout_batch
        FOREIGN KEY (payout_batch_id)
        REFERENCES payout_batches(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_doctor_payout_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_doctor_payout_account
        FOREIGN KEY (payout_account_id)
        REFERENCES doctor_payout_accounts(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_doctor_payout_amount
        CHECK (amount > 0)
);

CREATE INDEX idx_doctor_payouts_doctor
    ON doctor_payouts(doctor_id);

CREATE INDEX idx_doctor_payouts_batch
    ON doctor_payouts(payout_batch_id);

CREATE INDEX idx_doctor_payouts_status
    ON doctor_payouts(status);