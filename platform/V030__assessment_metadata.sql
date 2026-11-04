ALTER TABLE assessments
    ADD COLUMN full_name VARCHAR(500),
    ADD COLUMN copyright TEXT,
    ADD COLUMN purpose_or_domain TEXT,
    ADD COLUMN min_age INTEGER,
    ADD COLUMN max_age INTEGER,
    ADD COLUMN typical_groups TEXT,
    ADD COLUMN format TEXT,
    ADD COLUMN notes_publisher TEXT,
    ADD COLUMN reference_and_additional_notes TEXT,
    ADD COLUMN charts JSONB,
    ADD COLUMN domain_charts BOOLEAN,
    ADD COLUMN t_score BOOLEAN,
    ADD COLUMN domain_t_score BOOLEAN;

ALTER TABLE assessments
    ADD CONSTRAINT chk_assessments_min_age CHECK (min_age IS NULL OR min_age >= 0),
    ADD CONSTRAINT chk_assessments_max_age CHECK (max_age IS NULL OR max_age >= 0),
    ADD CONSTRAINT chk_assessments_age_range CHECK (min_age IS NULL OR max_age IS NULL OR min_age <= max_age),
    ADD CONSTRAINT chk_assessments_charts_array CHECK (charts IS NULL OR jsonb_typeof(charts) = 'array');
