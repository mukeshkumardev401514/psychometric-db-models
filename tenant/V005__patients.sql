CREATE TABLE patients (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL UNIQUE,
 patient_code VARCHAR(50) NOT NULL UNIQUE, date_of_birth DATE, gender gender_code,
 address_line1 VARCHAR(255), address_line2 VARCHAR(255), city VARCHAR(100), state VARCHAR(100),
 postal_code VARCHAR(20), country VARCHAR(100) DEFAULT 'India',
 emergency_contact_name VARCHAR(255), emergency_contact_mobile VARCHAR(20),
 emergency_contact_relation VARCHAR(100), notes TEXT,
 status tenant_user_status NOT NULL DEFAULT 'ACTIVE',
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 CHECK(date_of_birth IS NULL OR date_of_birth <= CURRENT_DATE)
);
CREATE INDEX idx_patients_user_id ON patients(user_id);
CREATE INDEX idx_patients_patient_code ON patients(patient_code);
CREATE INDEX idx_patients_status ON patients(status);
