CREATE TYPE consent_action AS ENUM ('GRANTED','REVOKED','UPDATED');
CREATE TABLE consent_history (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), consent_id UUID NOT NULL, user_id UUID NOT NULL,
 patient_id UUID NOT NULL, assignment_id UUID, consent_type consent_type NOT NULL,
 consent_version VARCHAR(50) NOT NULL, action consent_action NOT NULL, consent_text TEXT NOT NULL,
 action_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), ip_address INET, user_agent TEXT, metadata JSONB,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(consent_id) REFERENCES consents(id) ON DELETE RESTRICT,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 CHECK(length(trim(consent_text))>0),
 CHECK(metadata IS NULL OR jsonb_typeof(metadata)='object')
);
CREATE INDEX idx_consent_history_consent_id ON consent_history(consent_id);
CREATE INDEX idx_consent_history_user_id ON consent_history(user_id);
CREATE INDEX idx_consent_history_patient_id ON consent_history(patient_id);
CREATE INDEX idx_consent_history_assignment_id ON consent_history(assignment_id);
CREATE INDEX idx_consent_history_type ON consent_history(consent_type);
CREATE INDEX idx_consent_history_action ON consent_history(action);
CREATE INDEX idx_consent_history_action_at ON consent_history(action_at DESC);
CREATE INDEX idx_consent_history_patient_type ON consent_history(patient_id,consent_type,action_at DESC);
