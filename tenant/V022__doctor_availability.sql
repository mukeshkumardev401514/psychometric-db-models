CREATE TYPE availability_day AS ENUM ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY');
CREATE TABLE doctor_availability (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), doctor_id UUID NOT NULL,
 day_of_week availability_day NOT NULL, start_time TIME NOT NULL, end_time TIME NOT NULL,
 timezone VARCHAR(100) NOT NULL DEFAULT 'Asia/Kolkata', is_active BOOLEAN NOT NULL DEFAULT TRUE,
 effective_from DATE, effective_until DATE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE RESTRICT,
 CHECK(end_time>start_time),
 CHECK(effective_until IS NULL OR effective_from IS NULL OR effective_until>=effective_from)
);
CREATE INDEX idx_doctor_availability_doctor_id ON doctor_availability(doctor_id);
CREATE INDEX idx_doctor_availability_day ON doctor_availability(day_of_week);
CREATE INDEX idx_doctor_availability_active ON doctor_availability(doctor_id,is_active);
