CREATE TABLE tenant_settings (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), setting_key VARCHAR(100) NOT NULL UNIQUE,
 setting_value JSONB NOT NULL, description TEXT, is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 CHECK(jsonb_typeof(setting_value) IN ('object','array','string','number','boolean'))
);
CREATE INDEX idx_tenant_settings_active ON tenant_settings(is_active);
CREATE INDEX idx_tenant_settings_key ON tenant_settings(setting_key);
INSERT INTO tenant_settings(setting_key,setting_value,description) VALUES
('ASSESSMENT_DEFAULT_RETRY_COUNT','1','Default number of retries allowed for an assessment'),
('DEFAULT_TIMEZONE','"Asia/Kolkata"','Default timezone for the tenant'),
('PATIENT_RESULT_VISIBILITY','"DOCTOR_ONLY"','Controls who can view assessment results'),
('ASSESSMENT_CONSENT_REQUIRED','true','Whether assessment consent is mandatory before starting'),
('DATA_PROCESSING_CONSENT_REQUIRED','true','Whether data processing consent is mandatory'),
('REPORT_SHARING_CONSENT_REQUIRED','true','Whether report sharing consent is mandatory'),
('FOLLOWUP_REMINDER_ENABLED','true','Enable follow-up reminders'),
('FOLLOWUP_DEFAULT_REMINDER_MINUTES','30','Default reminder time before follow-up')
ON CONFLICT(setting_key) DO NOTHING;
