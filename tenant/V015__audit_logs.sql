CREATE TABLE audit_logs (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID, action VARCHAR(100) NOT NULL,
 entity_type VARCHAR(100) NOT NULL, entity_id UUID, description TEXT, old_data JSONB, new_data JSONB,
 ip_address INET, user_agent TEXT, request_id VARCHAR(100), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(old_data IS NULL OR jsonb_typeof(old_data)='object'),
 CHECK(new_data IS NULL OR jsonb_typeof(new_data)='object')
);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type,entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_request_id ON audit_logs(request_id);
