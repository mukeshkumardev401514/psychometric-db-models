CREATE TABLE payout_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    batch_date DATE NOT NULL UNIQUE,

    payout_mode payout_mode NOT NULL DEFAULT 'DAILY_BATCH',

    status payout_status NOT NULL DEFAULT 'PENDING',

    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_doctor_count INTEGER NOT NULL DEFAULT 0,

    processed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_payout_batch_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_payout_batch_doctor_count
        CHECK (total_doctor_count >= 0)
);