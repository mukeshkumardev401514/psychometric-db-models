CREATE TABLE doctors (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL UNIQUE,
 doctor_code VARCHAR(50) NOT NULL UNIQUE, specialization VARCHAR(255), qualification VARCHAR(255),
 medical_registration_number VARCHAR(100), registration_authority VARCHAR(255), registration_year INTEGER,
 designation VARCHAR(255), department VARCHAR(255), experience_years NUMERIC(5,2), bio TEXT,
 is_verified BOOLEAN NOT NULL DEFAULT FALSE, verified_at TIMESTAMPTZ,
 status tenant_user_status NOT NULL DEFAULT 'ACTIVE', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 CHECK(registration_year IS NULL OR registration_year BETWEEN 1900 AND 2100),
 CHECK(experience_years IS NULL OR experience_years >= 0),
 CHECK(is_verified=FALSE OR verified_at IS NOT NULL)
);
CREATE INDEX idx_doctors_user_id ON doctors(user_id);
CREATE INDEX idx_doctors_specialization ON doctors(specialization);
CREATE INDEX idx_doctors_status ON doctors(status);
CREATE INDEX idx_doctors_registration_number ON doctors(medical_registration_number);
