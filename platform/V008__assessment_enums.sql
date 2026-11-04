CREATE TYPE assessment_status AS ENUM (
    'DRAFT',
    'PUBLISHED',
    'ARCHIVED'
);

CREATE TYPE assessment_version_status AS ENUM (
    'DRAFT',
    'PUBLISHED',
    'ARCHIVED'
);

CREATE TYPE question_type AS ENUM (
    'SINGLE_CHOICE',
    'MULTIPLE_CHOICE',
    'TEXT',
    'SCALE',
    'YES_NO'
);

CREATE TYPE pricing_status AS ENUM (
    'ACTIVE',
    'INACTIVE'
);