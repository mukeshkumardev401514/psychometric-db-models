CREATE TABLE scoring_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assessment_version_id UUID NOT NULL,

    dimension_id UUID NOT NULL,

    min_score NUMERIC(10,2) NOT NULL,

    max_score NUMERIC(10,2) NOT NULL,

    result_label VARCHAR(255) NOT NULL,

    interpretation TEXT,

    recommendation TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_scoring_rules_version
        FOREIGN KEY (assessment_version_id)
        REFERENCES assessment_versions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_scoring_rules_dimension
        FOREIGN KEY (dimension_id)
        REFERENCES assessment_dimensions(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_score_range
        CHECK (min_score <= max_score)
);