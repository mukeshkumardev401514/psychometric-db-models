-- ============================================
-- Financial Enums
-- ============================================

CREATE TYPE subscription_status AS ENUM (
    'TRIAL',
    'ACTIVE',
    'PAST_DUE',
    'SUSPENDED',
    'CANCELLED',
    'EXPIRED'
);

CREATE TYPE billing_interval AS ENUM (
    'MONTHLY',
    'YEARLY'
);

CREATE TYPE payment_status AS ENUM (
    'CREATED',
    'PENDING',
    'PAID',
    'FAILED',
    'CANCELLED',
    'REFUNDED',
    'PARTIALLY_REFUNDED'
);

CREATE TYPE payment_event_status AS ENUM (
    'RECEIVED',
    'PROCESSED',
    'FAILED',
    'IGNORED'
);

CREATE TYPE payout_status AS ENUM (
    'PENDING',
    'PROCESSING',
    'PAID',
    'FAILED',
    'CANCELLED'
);

CREATE TYPE payout_mode AS ENUM (
    'PER_TRANSACTION',
    'DAILY_BATCH'
);

CREATE TYPE payout_method AS ENUM (
    'UPI'
);

CREATE TYPE payout_account_status AS ENUM (
    'PENDING_VERIFICATION',
    'VERIFIED',
    'SUSPENDED'
);

CREATE TYPE subscription_plan_status AS ENUM (
    'ACTIVE',
    'INACTIVE'
);