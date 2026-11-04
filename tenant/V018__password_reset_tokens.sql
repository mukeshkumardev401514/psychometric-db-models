CREATE TABLE password_reset_tokens (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL, token_hash TEXT NOT NULL UNIQUE,
 expires_at TIMESTAMPTZ NOT NULL, used_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 ip_address INET, user_agent TEXT,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 CHECK(expires_at>created_at)
);
CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);
CREATE INDEX idx_password_reset_tokens_active ON password_reset_tokens(user_id,expires_at) WHERE used_at IS NULL;
