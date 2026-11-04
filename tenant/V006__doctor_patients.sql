CREATE TABLE doctor_patients (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL, patient_id UUID NOT NULL,
 is_primary_doctor BOOLEAN NOT NULL DEFAULT FALSE, assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 unassigned_at TIMESTAMPTZ, status tenant_user_status NOT NULL DEFAULT 'ACTIVE',
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 UNIQUE(doctor_id,patient_id), CHECK(unassigned_at IS NULL OR unassigned_at >= assigned_at)
);
CREATE INDEX idx_doctor_patients_doctor_id ON doctor_patients(doctor_id);
CREATE INDEX idx_doctor_patients_patient_id ON doctor_patients(patient_id);
CREATE INDEX idx_doctor_patients_status ON doctor_patients(status);
CREATE UNIQUE INDEX uq_primary_doctor_per_patient ON doctor_patients(patient_id) WHERE is_primary_doctor=TRUE AND status='ACTIVE';
