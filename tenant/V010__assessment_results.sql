-- Table: public.assessment_results

-- DROP TABLE IF EXISTS public.assessment_results;

CREATE TABLE IF NOT EXISTS public.assessment_results
(
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    attempt_id uuid NOT NULL,
    assignment_id uuid NOT NULL,
    assessment_id uuid NOT NULL,
    assessment_version_id uuid NOT NULL,
    total_score numeric(12,4),
    dimension_scores jsonb,
    score_details jsonb,
    status report_status NOT NULL DEFAULT 'GENERATING'::report_status,
    calculated_at timestamp with time zone,
    report_status report_status NOT NULL DEFAULT 'GENERATING'::report_status,
    report_generated_at timestamp with time zone,
    report_storage_key text COLLATE pg_catalog."default",
    report_file_name character varying(255) COLLATE pg_catalog."default",
    error_message text COLLATE pg_catalog."default",
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT assessment_results_pkey PRIMARY KEY (id),
    CONSTRAINT assessment_results_attempt_id_key UNIQUE (attempt_id),
    CONSTRAINT fk_result_assignment FOREIGN KEY (assignment_id)
        REFERENCES public.assessment_assignments (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT fk_result_attempt FOREIGN KEY (attempt_id)
        REFERENCES public.assessment_attempts (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT chk_dimension_scores_json CHECK (dimension_scores IS NULL OR jsonb_typeof(dimension_scores) = 'object'::text),
    CONSTRAINT chk_score_details_json CHECK (score_details IS NULL OR jsonb_typeof(score_details) = 'object'::text)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.assessment_results
    OWNER to postgres;
-- Index: idx_assessment_results_assessment_id

-- DROP INDEX IF EXISTS public.idx_assessment_results_assessment_id;

CREATE INDEX IF NOT EXISTS idx_assessment_results_assessment_id
    ON public.assessment_results USING btree
    (assessment_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_assessment_results_assignment_id

-- DROP INDEX IF EXISTS public.idx_assessment_results_assignment_id;

CREATE INDEX IF NOT EXISTS idx_assessment_results_assignment_id
    ON public.assessment_results USING btree
    (assignment_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_assessment_results_report_status

-- DROP INDEX IF EXISTS public.idx_assessment_results_report_status;

CREATE INDEX IF NOT EXISTS idx_assessment_results_report_status
    ON public.assessment_results USING btree
    (report_status ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_assessment_results_status

-- DROP INDEX IF EXISTS public.idx_assessment_results_status;

CREATE INDEX IF NOT EXISTS idx_assessment_results_status
    ON public.assessment_results USING btree
    (status ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_assessment_results_version_id

-- DROP INDEX IF EXISTS public.idx_assessment_results_version_id;

CREATE INDEX IF NOT EXISTS idx_assessment_results_version_id
    ON public.assessment_results USING btree
    (assessment_version_id ASC NULLS LAST)
    TABLESPACE pg_default;  