-- ============================================
-- Add Category to Assessments
-- ============================================

ALTER TABLE assessments
ADD COLUMN category_id UUID;

ALTER TABLE assessments
ADD CONSTRAINT fk_assessments_category
    FOREIGN KEY (category_id)
    REFERENCES assessment_categories(id)
    ON DELETE RESTRICT;

CREATE INDEX idx_assessments_category_id
    ON assessments(category_id);