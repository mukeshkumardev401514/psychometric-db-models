CREATE TABLE assessment_pricing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assessment_version_id UUID NOT NULL,

    price NUMERIC(12,2) NOT NULL,

    currency VARCHAR(3) NOT NULL DEFAULT 'INR',

    doctor_percentage NUMERIC(5,2) NOT NULL,

    platform_percentage NUMERIC(5,2) NOT NULL,

    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    effective_to TIMESTAMPTZ,

    status pricing_status NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_assessment_pricing_version
        FOREIGN KEY (assessment_version_id)
        REFERENCES assessment_versions(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_price_non_negative
        CHECK (price >= 0),

    CONSTRAINT chk_doctor_percentage
        CHECK (
            doctor_percentage >= 0
            AND doctor_percentage <= 100
        ),

    CONSTRAINT chk_platform_percentage
        CHECK (
            platform_percentage >= 0
            AND platform_percentage <= 100
        ),

    CONSTRAINT chk_percentage_total
        CHECK (
            doctor_percentage + platform_percentage = 100
        ),

    CONSTRAINT chk_pricing_dates
        CHECK (
            effective_to IS NULL
            OR effective_to > effective_from
        )
);