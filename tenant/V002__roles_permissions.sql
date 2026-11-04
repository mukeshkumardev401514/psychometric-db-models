CREATE TABLE roles (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), code role_code NOT NULL UNIQUE,
 name VARCHAR(100) NOT NULL, description TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE permissions (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), code VARCHAR(150) NOT NULL UNIQUE,
 name VARCHAR(255) NOT NULL, description TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE role_permissions (
 role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
 permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
 PRIMARY KEY (role_id, permission_id)
);
INSERT INTO roles(code,name,description) VALUES
('HOSPITAL_ADMIN','Hospital Admin','Hospital administration'),
('DOCTOR','Doctor','Doctor'),('PATIENT','Patient','Patient')
ON CONFLICT (code) DO NOTHING;
INSERT INTO permissions(code,name,description) VALUES
('HOSPITAL_VIEW','View Hospital','View hospital'),('DOCTOR_VIEW','View Doctors','View doctors'),
('DOCTOR_CREATE','Create Doctor','Create doctors'),('DOCTOR_UPDATE','Update Doctor','Update doctors'),
('PATIENT_VIEW','View Patients','View patients'),('PATIENT_CREATE','Create Patient','Create patients'),
('PATIENT_UPDATE','Update Patient','Update patients'),('PATIENT_DELETE','Archive Patient','Archive patients'),
('ASSESSMENT_VIEW','View Assessment','View assessment'),('ASSESSMENT_ASSIGN','Assign Assessment','Assign assessment'),
('ASSESSMENT_START','Start Assessment','Start assessment'),('ASSESSMENT_ANSWER','Answer Assessment','Answer assessment'),
('ASSESSMENT_SUBMIT','Submit Assessment','Submit assessment'),('RESULT_VIEW','View Results','View results'),
('REPORT_VIEW','View Reports','View reports'),('REPORT_DOWNLOAD','Download Reports','Download reports'),
('RETRY_VIEW','View Retry','View retry'),('RETRY_APPROVE','Approve Retry','Approve retry'),
('RETRY_REJECT','Reject Retry','Reject retry'),('FOLLOWUP_VIEW','View Followups','View followups'),
('FOLLOWUP_CREATE','Create Followup','Create followups'),('FOLLOWUP_UPDATE','Update Followup','Update followups'),
('NOTIFICATION_VIEW','View Notifications','View notifications'),('NOTIFICATION_MANAGE','Manage Notifications','Manage notifications'),
('CONSENT_VIEW','View Consent','View consent'),('CONSENT_MANAGE','Manage Consent','Manage consent'),
('PROFILE_VIEW','View Profile','View profile'),('PROFILE_UPDATE','Update Profile','Update profile')
ON CONFLICT (code) DO NOTHING;
INSERT INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.code='HOSPITAL_ADMIN'
AND p.code IN ('HOSPITAL_VIEW','DOCTOR_VIEW','DOCTOR_CREATE','DOCTOR_UPDATE','PATIENT_VIEW','PATIENT_CREATE','PATIENT_UPDATE','ASSESSMENT_VIEW','ASSESSMENT_ASSIGN','FOLLOWUP_VIEW','FOLLOWUP_CREATE','FOLLOWUP_UPDATE','NOTIFICATION_VIEW','NOTIFICATION_MANAGE','CONSENT_VIEW','CONSENT_MANAGE','PROFILE_VIEW','PROFILE_UPDATE')
ON CONFLICT DO NOTHING;
INSERT INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.code='DOCTOR'
AND p.code IN ('PATIENT_VIEW','PATIENT_CREATE','PATIENT_UPDATE','ASSESSMENT_VIEW','ASSESSMENT_ASSIGN','RESULT_VIEW','REPORT_VIEW','REPORT_DOWNLOAD','RETRY_VIEW','RETRY_APPROVE','RETRY_REJECT','FOLLOWUP_VIEW','FOLLOWUP_CREATE','FOLLOWUP_UPDATE','NOTIFICATION_VIEW','NOTIFICATION_MANAGE','CONSENT_VIEW','CONSENT_MANAGE','PROFILE_VIEW','PROFILE_UPDATE')
ON CONFLICT DO NOTHING;
INSERT INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permissions p WHERE r.code='PATIENT'
AND p.code IN ('ASSESSMENT_VIEW','ASSESSMENT_START','ASSESSMENT_ANSWER','ASSESSMENT_SUBMIT','RETRY_VIEW','FOLLOWUP_VIEW','NOTIFICATION_VIEW','CONSENT_VIEW','CONSENT_MANAGE','PROFILE_VIEW','PROFILE_UPDATE')
ON CONFLICT DO NOTHING;
