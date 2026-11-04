CREATE TABLE assessment_result_dimensions (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), result_id UUID NOT NULL, dimension_id UUID NOT NULL,
 dimension_code VARCHAR(100) NOT NULL, dimension_name VARCHAR(255) NOT NULL,
 raw_score NUMERIC(12,4), normalized_score NUMERIC(12,4), percentile NUMERIC(7,4),
 interpretation VARCHAR(100), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(result_id) REFERENCES assessment_results(id) ON DELETE CASCADE,
 UNIQUE(result_id,dimension_id), CHECK(normalized_score IS NULL OR normalized_score>=0),
 CHECK(percentile IS NULL OR percentile BETWEEN 0 AND 100)
);
CREATE INDEX idx_result_dimensions_result_id ON assessment_result_dimensions(result_id);
CREATE INDEX idx_result_dimensions_dimension_id ON assessment_result_dimensions(dimension_id);
CREATE INDEX idx_result_dimensions_dimension_code ON assessment_result_dimensions(dimension_code);
