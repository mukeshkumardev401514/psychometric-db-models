CREATE TABLE platform_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    tenant_id UUID NOT NULL,

    assessment_id UUID NOT NULL,

    assessment_version_id UUID NOT NULL,

    assignment_id UUID,

    doctor_id UUID,

    patient_id UUID,

    amount NUMERIC(12,2) NOT NULL,

    currency VARCHAR(3) NOT NULL DEFAULT 'INR',

    doctor_percentage NUMERIC(5,2) NOT NULL,

    platform_percentage NUMERIC(5,2) NOT NULL,

    doctor_amount NUMERIC(12,2) NOT NULL,

    platform_amount NUMERIC(12,2) NOT NULL,

    status payment_status NOT NULL DEFAULT 'CREATED',

    razorpay_order_id VARCHAR(255),

    razorpay_payment_id VARCHAR(255),

    razorpay_signature TEXT,

    paid_at TIMESTAMPTZ,

    failure_reason TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_platform_payments_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0),

    CONSTRAINT chk_payment_doctor_percentage
        CHECK (
            doctor_percentage >= 0
            AND doctor_percentage <= 100
        ),

    CONSTRAINT chk_payment_platform_percentage
        CHECK (
            platform_percentage >= 0
            AND platform_percentage <= 100
        ),

    CONSTRAINT chk_payment_percentage_total
        CHECK (
            doctor_percentage + platform_percentage = 100
        ),

    CONSTRAINT chk_payment_doctor_amount
        CHECK (doctor_amount >= 0),

    CONSTRAINT chk_payment_platform_amount
        CHECK (platform_amount >= 0),

    CONSTRAINT chk_payment_split
        CHECK (
            doctor_amount + platform_amount = amount
        )
);

CREATE INDEX idx_platform_payments_tenant
    ON platform_payments(tenant_id);

CREATE INDEX idx_platform_payments_status
    ON platform_payments(status);

CREATE INDEX idx_platform_payments_doctor
    ON platform_payments(doctor_id);

CREATE INDEX idx_platform_payments_assignment
    ON platform_payments(assignment_id);

CREATE UNIQUE INDEX uq_platform_payments_razorpay_order
    ON platform_payments(razorpay_order_id)
    WHERE razorpay_order_id IS NOT NULL;

CREATE UNIQUE INDEX uq_platform_payments_razorpay_payment
    ON platform_payments(razorpay_payment_id)
    WHERE razorpay_payment_id IS NOT NULL;