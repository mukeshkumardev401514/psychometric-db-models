CREATE TABLE assessment_assignments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL, patient_id UUID NOT NULL,
 assessment_id UUID NOT NULL, assessment_version_id UUID NOT NULL,
 assignment_status assignment_status NOT NULL DEFAULT 'PENDING_PAYMENT',
 assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), payment_required BOOLEAN NOT NULL DEFAULT TRUE,
 payment_completed_at TIMESTAMPTZ, started_at TIMESTAMPTZ, completed_at TIMESTAMPTZ,
 expired_at TIMESTAMPTZ, expires_at TIMESTAMPTZ, retry_allowed BOOLEAN NOT NULL DEFAULT TRUE,
 retry_count INTEGER NOT NULL DEFAULT 0, max_retry_count INTEGER NOT NULL DEFAULT 1, notes TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 CHECK(retry_count>=0), CHECK(max_retry_count>=0), CHECK(retry_count<=max_retry_count),
 CHECK(expires_at IS NULL OR expires_at>=assigned_at)
);
CREATE INDEX idx_assessment_assignments_doctor_id ON assessment_assignments(doctor_id);
CREATE INDEX idx_assessment_assignments_patient_id ON assessment_assignments(patient_id);
CREATE INDEX idx_assessment_assignments_assessment_id ON assessment_assignments(assessment_id);
CREATE INDEX idx_assessment_assignments_version_id ON assessment_assignments(assessment_version_id);
CREATE INDEX idx_assessment_assignments_status ON assessment_assignments(assignment_status);
CREATE INDEX idx_assessment_assignments_expires_at ON assessment_assignments(expires_at);
CREATE INDEX idx_assessment_assignments_patient_status ON assessment_assignments(patient_id,assignment_status);
