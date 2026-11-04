CREATE TYPE patient_document_type AS ENUM ('PRESCRIPTION','REFERRAL','PREVIOUS_REPORT','MEDICAL_RECORD','ASSESSMENT_DOCUMENT','CONSENT_DOCUMENT','OTHER');
CREATE TYPE patient_document_status AS ENUM ('ACTIVE','ARCHIVED','DELETED');
CREATE TABLE patient_documents (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), patient_id UUID NOT NULL, doctor_id UUID,
 assignment_id UUID, attempt_id UUID, document_type patient_document_type NOT NULL DEFAULT 'OTHER',
 title VARCHAR(255) NOT NULL, description TEXT, file_name VARCHAR(255) NOT NULL,
 storage_key TEXT NOT NULL, mime_type VARCHAR(100) NOT NULL, file_size_bytes BIGINT NOT NULL,
 file_hash VARCHAR(128), status patient_document_status NOT NULL DEFAULT 'ACTIVE',
 uploaded_by UUID NOT NULL, uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 archived_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE RESTRICT,
 FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE SET NULL,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 FOREIGN KEY(attempt_id) REFERENCES assessment_attempts(id) ON DELETE SET NULL,
 FOREIGN KEY(uploaded_by) REFERENCES users(id) ON DELETE RESTRICT,
 CHECK(file_size_bytes>0), CHECK(length(trim(title))>0),
 CHECK(status<>'ARCHIVED' OR archived_at IS NOT NULL)
);
CREATE INDEX idx_patient_documents_patient_id ON patient_documents(patient_id);
CREATE INDEX idx_patient_documents_doctor_id ON patient_documents(doctor_id);
CREATE INDEX idx_patient_documents_assignment_id ON patient_documents(assignment_id);
CREATE INDEX idx_patient_documents_attempt_id ON patient_documents(attempt_id);
CREATE INDEX idx_patient_documents_type ON patient_documents(document_type);
CREATE INDEX idx_patient_documents_status ON patient_documents(status);
CREATE INDEX idx_patient_documents_uploaded_by ON patient_documents(uploaded_by);
CREATE INDEX idx_patient_documents_uploaded_at ON patient_documents(uploaded_at DESC);
CREATE INDEX idx_patient_documents_patient_status ON patient_documents(patient_id,status);
