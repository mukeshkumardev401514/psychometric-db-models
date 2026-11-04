CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    tenant_code VARCHAR(50) NOT NULL UNIQUE,

    tenant_name VARCHAR(255) NOT NULL,

    tenant_type tenant_type NOT NULL,

    status tenant_status NOT NULL DEFAULT 'PROVISIONING',

    database_name VARCHAR(255) NOT NULL UNIQUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);