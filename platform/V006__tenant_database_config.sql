CREATE TABLE tenant_database_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    tenant_id UUID NOT NULL UNIQUE,

    database_name VARCHAR(255) NOT NULL,

    host VARCHAR(255) NOT NULL,

    port INTEGER NOT NULL DEFAULT 5432,

    username VARCHAR(255) NOT NULL,

    secret_reference VARCHAR(500),

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_tenant_database_config_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(id)
        ON DELETE CASCADE
);