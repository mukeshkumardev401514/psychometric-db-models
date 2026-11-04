CREATE TABLE assessment_subcategories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES assessment_categories(id) ON DELETE RESTRICT,
    code VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 1 CHECK (display_order >= 1),
    status assessment_category_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_subcategory_code UNIQUE (category_id, code),
    CONSTRAINT uq_subcategory_category UNIQUE (id, category_id)
);

CREATE UNIQUE INDEX uq_subcategory_name
    ON assessment_subcategories (category_id, lower(name));

ALTER TABLE assessments
    ADD COLUMN subcategory_id UUID REFERENCES assessment_subcategories(id) ON DELETE RESTRICT,
    ADD CONSTRAINT chk_subcategory_requires_category
        CHECK (subcategory_id IS NULL OR category_id IS NOT NULL),
    ADD CONSTRAINT fk_assessment_subcategory_category
        FOREIGN KEY (subcategory_id, category_id)
        REFERENCES assessment_subcategories(id, category_id) ON DELETE RESTRICT;

CREATE INDEX idx_assessments_subcategory_id ON assessments(subcategory_id);
