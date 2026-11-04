CREATE TYPE assessment_access_event AS ENUM (
 'ACCESS_REQUESTED','ACCESS_GRANTED','ACCESS_DENIED','ACCESS_USED',
 'ACCESS_EXPIRED','ACCESS_REVOKED','INVALID_TOKEN','UNAUTHORIZED_ACCESS'
);
CREATE TABLE assessment_access_audit (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), access_id UUID, assignment_id UUID NOT NULL,
 patient_id UUID NOT NULL, user_id UUID, event assessment_access_event NOT NULL,
 ip_address INET, user_agent TEXT, request_id VARCHAR(100), metadata JSONB,
 event_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(access_id) REFERENCES assessment_access(id) ON DELETE SET NULL,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(metadata IS NULL OR jsonb_typeof(metadata)='object')
);
CREATE INDEX idx_access_audit_access_id ON assessment_access_audit(access_id);
CREATE INDEX idx_access_audit_assignment_id ON assessment_access_audit(assignment_id);
CREATE INDEX idx_access_audit_patient_id ON assessment_access_audit(patient_id);
CREATE INDEX idx_access_audit_user_id ON assessment_access_audit(user_id);
CREATE INDEX idx_access_audit_event ON assessment_access_audit(event);
CREATE INDEX idx_access_audit_event_at ON assessment_access_audit(event_at DESC);
CREATE INDEX idx_access_audit_request_id ON assessment_access_audit(request_id);
