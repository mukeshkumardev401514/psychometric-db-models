CREATE TYPE followup_status AS ENUM ('SCHEDULED','COMPLETED','CANCELLED','MISSED');
CREATE TABLE followups (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL, patient_id UUID NOT NULL,
 assignment_id UUID, title VARCHAR(255) NOT NULL, purpose TEXT, notes TEXT,
 scheduled_at TIMESTAMPTZ NOT NULL, duration_minutes INTEGER NOT NULL DEFAULT 30,
 status followup_status NOT NULL DEFAULT 'SCHEDULED', reminder_enabled BOOLEAN NOT NULL DEFAULT TRUE,
 reminder_minutes_before INTEGER NOT NULL DEFAULT 30, completed_at TIMESTAMPTZ, cancelled_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 CHECK(duration_minutes>0), CHECK(reminder_minutes_before>=0),
 CHECK(status<>'COMPLETED' OR completed_at IS NOT NULL),
 CHECK(status<>'CANCELLED' OR cancelled_at IS NOT NULL)
);
CREATE INDEX idx_followups_doctor_id ON followups(doctor_id);
CREATE INDEX idx_followups_patient_id ON followups(patient_id);
CREATE INDEX idx_followups_assignment_id ON followups(assignment_id);
CREATE INDEX idx_followups_scheduled_at ON followups(scheduled_at);
CREATE INDEX idx_followups_status ON followups(status);
CREATE INDEX idx_followups_doctor_schedule ON followups(doctor_id,scheduled_at);
