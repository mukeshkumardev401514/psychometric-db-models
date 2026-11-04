CREATE TABLE assessment_attempts (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), assignment_id UUID NOT NULL,
 attempt_number INTEGER NOT NULL DEFAULT 1, status attempt_status NOT NULL DEFAULT 'NOT_STARTED',
 started_at TIMESTAMPTZ, expires_at TIMESTAMPTZ, completed_at TIMESTAMPTZ,
 last_activity_at TIMESTAMPTZ, submitted_at TIMESTAMPTZ, duration_minutes INTEGER NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE RESTRICT,
 UNIQUE(assignment_id,attempt_number), CHECK(attempt_number>=1), CHECK(duration_minutes>0),
 CHECK(expires_at IS NULL OR started_at IS NULL OR expires_at>=started_at),
 CHECK(completed_at IS NULL OR started_at IS NOT NULL)
);
CREATE INDEX idx_assessment_attempts_assignment_id ON assessment_attempts(assignment_id);
CREATE INDEX idx_assessment_attempts_status ON assessment_attempts(status);
CREATE INDEX idx_assessment_attempts_expires_at ON assessment_attempts(expires_at);
CREATE INDEX idx_assessment_attempts_last_activity ON assessment_attempts(last_activity_at);
CREATE UNIQUE INDEX uq_active_attempt_per_assignment ON assessment_attempts(assignment_id) WHERE status='IN_PROGRESS';
