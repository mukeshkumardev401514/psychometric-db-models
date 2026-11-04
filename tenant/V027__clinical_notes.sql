CREATE TYPE clinical_note_type AS ENUM ('GENERAL','ASSESSMENT','FOLLOWUP','APPOINTMENT');
CREATE TYPE clinical_note_status AS ENUM ('ACTIVE','ARCHIVED');
CREATE TABLE clinical_notes (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL, patient_id UUID NOT NULL,
 assignment_id UUID, attempt_id UUID, followup_id UUID, appointment_id UUID,
 note_type clinical_note_type NOT NULL DEFAULT 'GENERAL', title VARCHAR(255), note_text TEXT NOT NULL,
 status clinical_note_status NOT NULL DEFAULT 'ACTIVE', created_by UUID NOT NULL, updated_by UUID,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), archived_at TIMESTAMPTZ,
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 FOREIGN KEY(attempt_id) REFERENCES assessment_attempts(id) ON DELETE SET NULL,
 FOREIGN KEY(followup_id) REFERENCES followups(id) ON DELETE SET NULL,
 FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
 FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(updated_by) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(length(trim(note_text))>0), CHECK(status<>'ARCHIVED' OR archived_at IS NOT NULL)
);
CREATE INDEX idx_clinical_notes_doctor_id ON clinical_notes(doctor_id);
CREATE INDEX idx_clinical_notes_patient_id ON clinical_notes(patient_id);
CREATE INDEX idx_clinical_notes_assignment_id ON clinical_notes(assignment_id);
CREATE INDEX idx_clinical_notes_attempt_id ON clinical_notes(attempt_id);
CREATE INDEX idx_clinical_notes_followup_id ON clinical_notes(followup_id);
CREATE INDEX idx_clinical_notes_appointment_id ON clinical_notes(appointment_id);
CREATE INDEX idx_clinical_notes_type ON clinical_notes(note_type);
CREATE INDEX idx_clinical_notes_status ON clinical_notes(status);
CREATE INDEX idx_clinical_notes_patient_created ON clinical_notes(patient_id,created_at DESC);
