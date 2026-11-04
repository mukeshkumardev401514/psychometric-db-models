CREATE TABLE organization_profile (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), organization_name VARCHAR(255) NOT NULL,
 organization_code VARCHAR(100) NOT NULL UNIQUE, organization_type VARCHAR(100) NOT NULL DEFAULT 'HOSPITAL',
 registration_number VARCHAR(150), email VARCHAR(255), mobile VARCHAR(20), phone VARCHAR(20),
 website VARCHAR(500), address_line1 VARCHAR(255), address_line2 VARCHAR(255), city VARCHAR(100),
 state VARCHAR(100), postal_code VARCHAR(20), country VARCHAR(100) NOT NULL DEFAULT 'India',
 logo_storage_key TEXT, description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX uq_organization_registration_number ON organization_profile(registration_number) WHERE registration_number IS NOT NULL;
CREATE INDEX idx_organization_profile_name ON organization_profile(organization_name);
CREATE INDEX idx_organization_profile_status ON organization_profile(is_active);
