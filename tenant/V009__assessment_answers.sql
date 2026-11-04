CREATE TABLE assessment_answers (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), attempt_id UUID NOT NULL, question_id UUID NOT NULL,
 selected_option_id UUID, answer_text TEXT, answer_value NUMERIC,
 status answer_status NOT NULL DEFAULT 'DRAFT', answered_at TIMESTAMPTZ, locked_at TIMESTAMPTZ,
 finalised_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(attempt_id) REFERENCES assessment_attempts(id) ON DELETE RESTRICT,
 UNIQUE(attempt_id,question_id),
 CHECK(selected_option_id IS NOT NULL OR answer_text IS NOT NULL OR answer_value IS NOT NULL),
 CHECK(status NOT IN ('LOCKED','FINAL') OR locked_at IS NOT NULL),
 CHECK(status <> 'FINAL' OR finalised_at IS NOT NULL)
);
CREATE INDEX idx_assessment_answers_attempt_id ON assessment_answers(attempt_id);
CREATE INDEX idx_assessment_answers_question_id ON assessment_answers(question_id);
CREATE INDEX idx_assessment_answers_status ON assessment_answers(status);
CREATE INDEX idx_assessment_answers_attempt_question ON assessment_answers(attempt_id,question_id);
