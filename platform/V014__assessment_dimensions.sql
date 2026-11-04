CREATE TABLE assessment_dimensions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assessment_version_id UUID NOT NULL,

    code VARCHAR(100) NOT NULL,

    name VARCHAR(255) NOT NULL,

    description TEXT,

    display_order INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_assessment_dimensions_version
        FOREIGN KEY (assessment_version_id)
        REFERENCES assessment_versions(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_dimension_display_order
        CHECK (display_order >= 1),

    CONSTRAINT uq_dimension_code
        UNIQUE (assessment_version_id, code),

    CONSTRAINT uq_dimension_order
        UNIQUE (assessment_version_id, display_order)
);