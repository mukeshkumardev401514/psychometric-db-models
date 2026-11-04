CREATE TABLE user_settings (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL UNIQUE,
 timezone VARCHAR(100) NOT NULL DEFAULT 'Asia/Kolkata', language_code VARCHAR(10) NOT NULL DEFAULT 'en',
 email_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE, sms_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
 push_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE, in_app_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
 assessment_reminders_enabled BOOLEAN NOT NULL DEFAULT TRUE, followup_reminders_enabled BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX idx_user_settings_timezone ON user_settings(timezone);
CREATE INDEX idx_user_settings_language ON user_settings(language_code);
