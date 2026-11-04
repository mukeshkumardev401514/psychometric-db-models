CREATE TABLE consents (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL, patient_id UUID NOT NULL,
 consent_type consent_type NOT NULL, consent_version VARCHAR(50) NOT NULL, granted BOOLEAN NOT NULL,
 consent_text TEXT NOT NULL, granted_at TIMESTAMPTZ, revoked_at TIMESTAMPTZ, ip_address INET,
 user_agent TEXT, assignment_id UUID, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 CHECK(granted=FALSE OR granted_at IS NOT NULL),
 CHECK(revoked_at IS NULL OR granted_at IS NOT NULL)
);
CREATE INDEX idx_consents_user_id ON consents(user_id);
CREATE INDEX idx_consents_patient_id ON consents(patient_id);
CREATE INDEX idx_consents_type ON consents(consent_type);
CREATE INDEX idx_consents_assignment_id ON consents(assignment_id);
CREATE INDEX idx_consents_patient_type ON consents(patient_id,consent_type);
CREATE INDEX idx_consents_granted_at ON consents(granted_at);
