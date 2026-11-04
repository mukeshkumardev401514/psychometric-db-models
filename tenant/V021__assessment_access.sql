CREATE TYPE assessment_access_status AS ENUM ('PENDING','ACTIVE','REVOKED','EXPIRED');
CREATE TABLE assessment_access (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), assignment_id UUID NOT NULL UNIQUE, patient_id UUID NOT NULL,
 status assessment_access_status NOT NULL DEFAULT 'PENDING', access_granted_at TIMESTAMPTZ,
 access_expires_at TIMESTAMPTZ, revoked_at TIMESTAMPTZ, payment_verified_at TIMESTAMPTZ,
 consent_verified_at TIMESTAMPTZ, access_token_hash TEXT UNIQUE, last_accessed_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 CHECK(access_expires_at IS NULL OR access_granted_at IS NULL OR access_expires_at>=access_granted_at),
 CHECK(status<>'ACTIVE' OR payment_verified_at IS NOT NULL),
 CHECK(status<>'ACTIVE' OR consent_verified_at IS NOT NULL)
);
CREATE INDEX idx_assessment_access_patient_id ON assessment_access(patient_id);
CREATE INDEX idx_assessment_access_status ON assessment_access(status);
CREATE INDEX idx_assessment_access_expires_at ON assessment_access(access_expires_at);
CREATE INDEX idx_assessment_access_last_accessed ON assessment_access(last_accessed_at);
