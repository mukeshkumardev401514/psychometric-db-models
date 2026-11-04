CREATE TABLE users (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), email VARCHAR(255) NOT NULL UNIQUE,
 mobile VARCHAR(20) UNIQUE, password_hash TEXT, first_name VARCHAR(100) NOT NULL,
 last_name VARCHAR(100), status tenant_user_status NOT NULL DEFAULT 'ACTIVE',
 email_verified BOOLEAN NOT NULL DEFAULT FALSE, mobile_verified BOOLEAN NOT NULL DEFAULT FALSE,
 last_login_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE user_roles (
 user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE, PRIMARY KEY(user_id,role_id)
);
CREATE TABLE user_otp_verifications (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 otp_code VARCHAR(20) NOT NULL, purpose VARCHAR(100) NOT NULL, expires_at TIMESTAMPTZ NOT NULL,
 verified_at TIMESTAMPTZ, attempts INTEGER NOT NULL DEFAULT 0, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_user_otp_user_expiry ON user_otp_verifications(user_id,expires_at);
