-- ============================================
-- Assessment Categories
-- ============================================

CREATE TYPE assessment_category_status AS ENUM (
    'ACTIVE',
    'INACTIVE'
);

CREATE TABLE assessment_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    code VARCHAR(100) NOT NULL UNIQUE,

    name VARCHAR(255) NOT NULL,

    description TEXT,

    display_order INTEGER NOT NULL DEFAULT 1,

    status assessment_category_status NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_assessment_category_display_order
        CHECK (display_order >= 1)
);