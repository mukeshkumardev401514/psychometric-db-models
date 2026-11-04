CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(100) NOT NULL UNIQUE,

    name VARCHAR(255) NOT NULL,

    description TEXT,

    price NUMERIC(12,2) NOT NULL,

    currency VARCHAR(3) NOT NULL DEFAULT 'INR',

    billing_interval billing_interval NOT NULL,

    status subscription_plan_status NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_subscription_plan_price
        CHECK (price >= 0)
);