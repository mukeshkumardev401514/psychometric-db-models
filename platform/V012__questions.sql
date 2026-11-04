CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assessment_section_id UUID NOT NULL,

    question_text TEXT NOT NULL,

    question_type question_type NOT NULL,

    display_order INTEGER NOT NULL,

    is_required BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_questions_section
        FOREIGN KEY (assessment_section_id)
        REFERENCES assessment_sections(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_question_display_order
        CHECK (display_order >= 1),

    CONSTRAINT uq_question_order
        UNIQUE (assessment_section_id, display_order)
);