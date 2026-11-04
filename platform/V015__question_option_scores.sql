CREATE TABLE question_option_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    question_option_id UUID NOT NULL,

    dimension_id UUID NOT NULL,

    score NUMERIC(10,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_option_scores_option
        FOREIGN KEY (question_option_id)
        REFERENCES question_options(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_option_scores_dimension
        FOREIGN KEY (dimension_id)
        REFERENCES assessment_dimensions(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_option_dimension
        UNIQUE (question_option_id, dimension_id)
);