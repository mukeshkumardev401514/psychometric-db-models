CREATE TYPE tenant_type AS ENUM (
    'HOSPITAL_ORGANIZATION',
    'INDIVIDUAL_DOCTOR'
);

CREATE TYPE tenant_status AS ENUM (
    'PROVISIONING',
    'ACTIVE',
    'SUSPENDED',
    'INACTIVE'
);

CREATE TYPE user_status AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'LOCKED'
);

CREATE TYPE provisioning_status AS ENUM (
    'STARTED',
    'SUCCESS',
    'FAILED'
);