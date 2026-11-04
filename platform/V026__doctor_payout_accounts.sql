CREATE TABLE doctor_payout_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    tenant_id UUID NOT NULL,

    doctor_id UUID NOT NULL,

    payout_method payout_method NOT NULL DEFAULT 'UPI',

    upi_id VARCHAR(255) NOT NULL,

    account_holder_name VARCHAR(255),

    status payout_account_status NOT NULL DEFAULT 'PENDING_VERIFICATION',

    verified_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_doctor_payout_accounts_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_doctor_payout_accounts_doctor
    ON doctor_payout_accounts(doctor_id);

CREATE INDEX idx_doctor_payout_accounts_tenant
    ON doctor_payout_accounts(tenant_id);