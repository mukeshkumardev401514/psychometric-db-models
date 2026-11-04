CREATE TABLE departments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), department_code VARCHAR(100) NOT NULL UNIQUE,
 department_name VARCHAR(255) NOT NULL, description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE doctor_departments (
 doctor_id UUID NOT NULL, department_id UUID NOT NULL, is_primary BOOLEAN NOT NULL DEFAULT FALSE,
 assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), unassigned_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 PRIMARY KEY(doctor_id,department_id),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE RESTRICT,
 CHECK(unassigned_at IS NULL OR unassigned_at>=assigned_at)
);
CREATE INDEX idx_doctor_departments_department_id ON doctor_departments(department_id);
CREATE INDEX idx_doctor_departments_doctor_id ON doctor_departments(doctor_id);
CREATE UNIQUE INDEX uq_primary_department_per_doctor ON doctor_departments(doctor_id) WHERE is_primary=TRUE AND unassigned_at IS NULL;
