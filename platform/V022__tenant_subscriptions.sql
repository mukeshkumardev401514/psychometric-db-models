CREATE TABLE tenant_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    tenant_id UUID NOT NULL,

    subscription_plan_id UUID NOT NULL,

    status subscription_status NOT NULL DEFAULT 'TRIAL',

    start_at TIMESTAMPTZ NOT NULL,

    end_at TIMESTAMPTZ,

    razorpay_subscription_id VARCHAR(255),

    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_tenant_subscriptions_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_tenant_subscriptions_plan
        FOREIGN KEY (subscription_plan_id)
        REFERENCES subscription_plans(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_subscription_dates
        CHECK (
            end_at IS NULL
            OR end_at > start_at
        )
);

CREATE INDEX idx_tenant_subscriptions_tenant
    ON tenant_subscriptions(tenant_id);

CREATE INDEX idx_tenant_subscriptions_status
    ON tenant_subscriptions(status);

CREATE UNIQUE INDEX uq_tenant_active_subscription
    ON tenant_subscriptions(tenant_id)
    WHERE status IN ('TRIAL', 'ACTIVE', 'PAST_DUE');