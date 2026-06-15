-- v2.0 Platform Configuration Schema
-- This script creates the platform_config table to store global application settings dynamically.

CREATE TABLE IF NOT EXISTS platform_config (
    key VARCHAR(255) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Row Level Security
ALTER TABLE platform_config ENABLE ROW LEVEL SECURITY;

-- Allow read access for everyone
CREATE POLICY "Enable read access for all users" ON platform_config
    FOR SELECT USING (true);

-- Allow write access only for admins
CREATE POLICY "Enable write access for admins" ON platform_config
    FOR ALL
    USING (public.is_admin());

-- Insert Default Config Data
INSERT INTO platform_config (key, value, description)
VALUES 
    (
        'allowed_categories', 
        '["Education", "Medical", "Environment", "Disaster Relief", "Animals"]'::jsonb,
        'The list of supported categories for creating donation profiles.'
    ),
    (
        'feature_flags', 
        '{"ai_reports_enabled": true, "subscriptions_enabled": true, "donor_wall_enabled": true}'::jsonb,
        'Global toggle for V2.0 features.'
    ),
    (
        'platform_fee_percentage', 
        '5.0'::jsonb,
        'The percentage fee taken by the platform per donation.'
    )
ON CONFLICT (key) DO NOTHING;
