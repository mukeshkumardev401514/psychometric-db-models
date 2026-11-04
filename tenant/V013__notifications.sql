CREATE TABLE notifications (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL,
 type notification_type NOT NULL, status notification_status NOT NULL DEFAULT 'PENDING',
 title VARCHAR(255) NOT NULL, message TEXT NOT NULL, assignment_id UUID, attempt_id UUID,
 followup_id UUID, scheduled_at TIMESTAMPTZ, sent_at TIMESTAMPTZ, read_at TIMESTAMPTZ,
 retry_count INTEGER NOT NULL DEFAULT 0, max_retry_count INTEGER NOT NULL DEFAULT 3,
 error_message TEXT, metadata JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE SET NULL,
 FOREIGN KEY(attempt_id) REFERENCES assessment_attempts(id) ON DELETE SET NULL,
 FOREIGN KEY(followup_id) REFERENCES followups(id) ON DELETE SET NULL,
 CHECK(retry_count>=0), CHECK(max_retry_count>=0), CHECK(retry_count<=max_retry_count),
 CHECK(metadata IS NULL OR jsonb_typeof(metadata)='object')
);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at);
CREATE INDEX idx_notifications_assignment_id ON notifications(assignment_id);
CREATE INDEX idx_notifications_followup_id ON notifications(followup_id);
CREATE INDEX idx_notifications_pending_schedule ON notifications(status,scheduled_at) WHERE status='PENDING';
