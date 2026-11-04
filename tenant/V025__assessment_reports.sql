CREATE TYPE assessment_report_format AS ENUM ('PDF','HTML');
CREATE TYPE assessment_report_status AS ENUM ('GENERATING','GENERATED','FAILED','EXPIRED');
CREATE TABLE assessment_reports (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), result_id UUID NOT NULL, attempt_id UUID NOT NULL,
 assignment_id UUID NOT NULL, report_version INTEGER NOT NULL DEFAULT 1,
 report_format assessment_report_format NOT NULL DEFAULT 'PDF',
 status assessment_report_status NOT NULL DEFAULT 'GENERATING',
 file_name VARCHAR(255), storage_key TEXT, file_size_bytes BIGINT, mime_type VARCHAR(100),
 generated_by UUID, generated_at TIMESTAMPTZ, expires_at TIMESTAMPTZ, error_message TEXT,
 download_count INTEGER NOT NULL DEFAULT 0, last_downloaded_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(result_id) REFERENCES assessment_results(id) ON DELETE RESTRICT,
 FOREIGN KEY(attempt_id) REFERENCES assessment_attempts(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE RESTRICT,
 FOREIGN KEY(generated_by) REFERENCES users(id) ON DELETE SET NULL,
 UNIQUE(result_id,report_version), CHECK(report_version>=1),
 CHECK(file_size_bytes IS NULL OR file_size_bytes>=0), CHECK(download_count>=0),
 CHECK(status<>'GENERATED' OR (generated_at IS NOT NULL AND storage_key IS NOT NULL AND file_name IS NOT NULL)),
 CHECK(expires_at IS NULL OR generated_at IS NULL OR expires_at>=generated_at)
);
CREATE INDEX idx_assessment_reports_result_id ON assessment_reports(result_id);
CREATE INDEX idx_assessment_reports_attempt_id ON assessment_reports(attempt_id);
CREATE INDEX idx_assessment_reports_assignment_id ON assessment_reports(assignment_id);
CREATE INDEX idx_assessment_reports_status ON assessment_reports(status);
CREATE INDEX idx_assessment_reports_generated_by ON assessment_reports(generated_by);
CREATE INDEX idx_assessment_reports_generated_at ON assessment_reports(generated_at);
CREATE INDEX idx_assessment_reports_storage_key ON assessment_reports(storage_key);
CREATE INDEX idx_assessment_reports_latest ON assessment_reports(result_id,report_version DESC);
