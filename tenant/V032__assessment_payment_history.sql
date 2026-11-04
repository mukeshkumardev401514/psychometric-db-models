CREATE TYPE assessment_payment_event AS ENUM (
 'PAYMENT_REQUIRED','PAYMENT_INITIATED','PAYMENT_SUCCESSFUL','PAYMENT_FAILED',
 'PAYMENT_CANCELLED','PAYMENT_REFUNDED','PAYMENT_PARTIALLY_REFUNDED'
);
CREATE TABLE assessment_payment_history (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), assignment_id UUID NOT NULL,
 payment_event assessment_payment_event NOT NULL, platform_payment_id UUID,
 razorpay_order_id VARCHAR(255), razorpay_payment_id VARCHAR(255),
 currency VARCHAR(10) NOT NULL DEFAULT 'INR', amount NUMERIC(12,2),
 event_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), failure_reason TEXT, metadata JSONB,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(assignment_id) REFERENCES assessment_assignments(id) ON DELETE RESTRICT,
 CHECK(amount IS NULL OR amount>=0),
 CHECK(metadata IS NULL OR jsonb_typeof(metadata)='object')
);
CREATE INDEX idx_payment_history_assignment_id ON assessment_payment_history(assignment_id);
CREATE INDEX idx_payment_history_event ON assessment_payment_history(payment_event);
CREATE INDEX idx_payment_history_event_at ON assessment_payment_history(event_at DESC);
CREATE INDEX idx_payment_history_platform_payment ON assessment_payment_history(platform_payment_id);
CREATE INDEX idx_payment_history_order_id ON assessment_payment_history(razorpay_order_id);
CREATE INDEX idx_payment_history_payment_id ON assessment_payment_history(razorpay_payment_id);
CREATE INDEX idx_payment_history_assignment_event ON assessment_payment_history(assignment_id,event_at DESC);
