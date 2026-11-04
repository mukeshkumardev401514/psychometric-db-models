CREATE TYPE message_sender_type AS ENUM ('DOCTOR','PATIENT','SYSTEM');
CREATE TYPE message_status AS ENUM ('SENT','DELIVERED','READ','FAILED');
CREATE TABLE doctor_patient_messages (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL, patient_id UUID NOT NULL,
 assignment_id UUID, followup_id UUID, appointment_id UUID, sender_user_id UUID NOT NULL,
 sender_type message_sender_type NOT NULL, message_text TEXT NOT NULL,
 status message_status NOT NULL DEFAULT 'SENT', sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 delivered_at TIMESTAMPTZ, read_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 FOREIGN KEY(followup_id) REFERENCES followups(id) ON DELETE SET NULL,
 FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
 FOREIGN KEY(sender_user_id) REFERENCES users(id) ON DELETE RESTRICT,
 CHECK(length(trim(message_text))>0),
 CHECK(status NOT IN ('DELIVERED','READ') OR delivered_at IS NOT NULL),
 CHECK(status<>'READ' OR read_at IS NOT NULL)
);
CREATE INDEX idx_messages_doctor_id ON doctor_patient_messages(doctor_id);
CREATE INDEX idx_messages_patient_id ON doctor_patient_messages(patient_id);
CREATE INDEX idx_messages_assignment_id ON doctor_patient_messages(assignment_id);
CREATE INDEX idx_messages_followup_id ON doctor_patient_messages(followup_id);
CREATE INDEX idx_messages_appointment_id ON doctor_patient_messages(appointment_id);
CREATE INDEX idx_messages_sender ON doctor_patient_messages(sender_user_id);
CREATE INDEX idx_messages_status ON doctor_patient_messages(status);
CREATE INDEX idx_messages_sent_at ON doctor_patient_messages(sent_at DESC);
CREATE INDEX idx_messages_patient_conversation ON doctor_patient_messages(patient_id,sent_at DESC);
CREATE INDEX idx_messages_doctor_conversation ON doctor_patient_messages(doctor_id,patient_id,sent_at DESC);
