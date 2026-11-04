CREATE TABLE assessment_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assessment_id UUID NOT NULL,

    version_number INTEGER NOT NULL,

    duration_minutes INTEGER NOT NULL,

    status assessment_version_status NOT NULL DEFAULT 'DRAFT',

    published_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_assessment_versions_assessment
        FOREIGN KEY (assessment_id)
        REFERENCES assessments(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_assessment_version
        UNIQUE (assessment_id, version_number),

    CONSTRAINT chk_duration_positive
        CHECK (duration_minutes > 0)
);