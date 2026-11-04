CREATE TYPE patient_timeline_event_type AS ENUM (
 'PATIENT_CREATED','DOCTOR_ASSIGNED','DOCTOR_UNASSIGNED','ASSESSMENT_ASSIGNED','PAYMENT_COMPLETED',
 'ASSESSMENT_STARTED','ASSESSMENT_SAVED','ASSESSMENT_COMPLETED','ASSESSMENT_EXPIRED',
 'RETRY_REQUESTED','RETRY_APPROVED','RETRY_REJECTED','RESULT_GENERATED','REPORT_GENERATED',
 'FOLLOWUP_CREATED','FOLLOWUP_COMPLETED','FOLLOWUP_CANCELLED','APPOINTMENT_CREATED',
 'APPOINTMENT_COMPLETED','APPOINTMENT_CANCELLED','APPOINTMENT_RESCHEDULED','CLINICAL_NOTE_CREATED',
 'DOCUMENT_UPLOADED','MESSAGE_SENT','CONSENT_GRANTED','CONSENT_REVOKED'
);
CREATE TABLE patient_timeline_events (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), patient_id UUID NOT NULL, doctor_id UUID,
 event_type patient_timeline_event_type NOT NULL, event_title VARCHAR(255) NOT NULL,
 event_description TEXT, assignment_id UUID, attempt_id UUID, result_id UUID, followup_id UUID,
 appointment_id UUID, clinical_note_id UUID, document_id UUID, message_id UUID, consent_id UUID,
 performed_by UUID, event_data JSONB, event_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE SET NULL,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 FOREIGN KEY(attempt_id) REFERENCES assessment_attempts(id) ON DELETE SET NULL,
 FOREIGN KEY(result_id) REFERENCES assessment_results(id) ON DELETE SET NULL,
 FOREIGN KEY(followup_id) REFERENCES followups(id) ON DELETE SET NULL,
 FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
 FOREIGN KEY(clinical_note_id) REFERENCES clinical_notes(id) ON DELETE SET NULL,
 FOREIGN KEY(document_id) REFERENCES patient_documents(id) ON DELETE SET NULL,
 FOREIGN KEY(message_id) REFERENCES doctor_patient_messages(id) ON DELETE SET NULL,
 FOREIGN KEY(consent_id) REFERENCES consents(id) ON DELETE SET NULL,
 FOREIGN KEY(performed_by) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(length(trim(event_title))>0),
 CHECK(event_data IS NULL OR jsonb_typeof(event_data)='object')
);
CREATE INDEX idx_patient_timeline_patient_id ON patient_timeline_events(patient_id);
CREATE INDEX idx_patient_timeline_doctor_id ON patient_timeline_events(doctor_id);
CREATE INDEX idx_patient_timeline_event_type ON patient_timeline_events(event_type);
CREATE INDEX idx_patient_timeline_event_at ON patient_timeline_events(event_at DESC);
CREATE INDEX idx_patient_timeline_patient_event ON patient_timeline_events(patient_id,event_at DESC);
CREATE INDEX idx_patient_timeline_assignment ON patient_timeline_events(assignment_id);
CREATE INDEX idx_patient_timeline_attempt ON patient_timeline_events(attempt_id);
CREATE INDEX idx_patient_timeline_followup ON patient_timeline_events(followup_id);
CREATE INDEX idx_patient_timeline_appointment ON patient_timeline_events(appointment_id);
