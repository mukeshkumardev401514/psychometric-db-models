CREATE TYPE retry_action AS ENUM ('REQUESTED','APPROVED','REJECTED','STARTED','COMPLETED','EXPIRED','CANCELLED');
CREATE TABLE assessment_retry_history (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), assignment_id UUID NOT NULL, previous_attempt_id UUID,
 new_attempt_id UUID, retry_number INTEGER NOT NULL, action retry_action NOT NULL,
 requested_by UUID, action_by UUID, reason TEXT, notes TEXT,
 requested_at TIMESTAMPTZ, action_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE RESTRICT,
 FOREIGN KEY(previous_attempt_id) REFERENCES assessment_attempts(id) ON DELETE RESTRICT,
 FOREIGN KEY(new_attempt_id) REFERENCES assessment_attempts(id) ON DELETE RESTRICT,
 FOREIGN KEY(requested_by) REFERENCES users(id) ON DELETE SET NULL,
 FOREIGN KEY(action_by) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(retry_number>=1), CHECK(requested_at IS NULL OR action_at>=requested_at)
);
CREATE INDEX idx_retry_history_assignment_id ON assessment_retry_history(assignment_id);
CREATE INDEX idx_retry_history_previous_attempt ON assessment_retry_history(previous_attempt_id);
CREATE INDEX idx_retry_history_new_attempt ON assessment_retry_history(new_attempt_id);
CREATE INDEX idx_retry_history_requested_by ON assessment_retry_history(requested_by);
CREATE INDEX idx_retry_history_action_by ON assessment_retry_history(action_by);
CREATE INDEX idx_retry_history_action ON assessment_retry_history(action);
CREATE INDEX idx_retry_history_action_at ON assessment_retry_history(action_at);
CREATE INDEX idx_retry_history_assignment_retry ON assessment_retry_history(assignment_id,retry_number);
