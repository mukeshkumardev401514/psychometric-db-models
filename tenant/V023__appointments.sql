CREATE TYPE appointment_status AS ENUM ('SCHEDULED','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED','NO_SHOW','RESCHEDULED');
CREATE TYPE appointment_mode AS ENUM ('IN_PERSON','VIDEO','PHONE');
CREATE TABLE appointments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL, patient_id UUID NOT NULL,
 followup_id UUID, title VARCHAR(255) NOT NULL,
 appointment_mode appointment_mode NOT NULL DEFAULT 'IN_PERSON',
 scheduled_start_at TIMESTAMPTZ NOT NULL, scheduled_end_at TIMESTAMPTZ NOT NULL,
 timezone VARCHAR(100) NOT NULL DEFAULT 'Asia/Kolkata', status appointment_status NOT NULL DEFAULT 'SCHEDULED',
 meeting_url TEXT, location TEXT, notes TEXT, cancellation_reason TEXT, cancelled_at TIMESTAMPTZ,
 completed_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(followup_id) REFERENCES followups(id) ON DELETE SET NULL,
 CHECK(scheduled_end_at>scheduled_start_at),
 CHECK(appointment_mode<>'VIDEO' OR meeting_url IS NOT NULL),
 CHECK(status<>'CANCELLED' OR cancelled_at IS NOT NULL)
);
CREATE INDEX idx_appointments_doctor_id ON appointments(doctor_id);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_followup_id ON appointments(followup_id);
CREATE INDEX idx_appointments_start_at ON appointments(scheduled_start_at);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_doctor_schedule ON appointments(doctor_id,scheduled_start_at);
CREATE INDEX idx_appointments_patient_schedule ON appointments(patient_id,scheduled_start_at);
