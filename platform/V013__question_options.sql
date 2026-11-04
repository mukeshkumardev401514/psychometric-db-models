CREATE TABLE question_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    question_id UUID NOT NULL,

    option_text VARCHAR(500) NOT NULL,

    option_value VARCHAR(100),

    display_order INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_question_options_question
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_option_display_order
        CHECK (display_order >= 1),

    CONSTRAINT uq_question_option_order
        UNIQUE (question_id, display_order)
);