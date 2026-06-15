-- V2 Master Setup (Idempotent & Safe)
-- Run this single script in Supabase SQL Editor to cleanly set up the entire V2 database.
-- It resolves any partial creation states, drops conflicting triggers/policies, and prevents recursion.

-- =========================================================================
-- 1. CREATE SCHEMA TABLES FIRST (So we can safely interact with them)
-- =========================================================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role VARCHAR(20) NOT NULL DEFAULT 'donor',
  avatar_url TEXT,
  supabase_auth_id UUID UNIQUE REFERENCES auth.users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS donation_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(100),
  target_amount DECIMAL(12,2) NOT NULL CHECK (target_amount > 0),
  raised_amount DECIMAL(12,2) DEFAULT 0,
  image_url TEXT,
  verification_status VARCHAR(20) DEFAULT 'draft',
  is_active BOOLEAN DEFAULT true,
  start_date TIMESTAMPTZ DEFAULT now(),
  end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  campaign_id UUID NOT NULL REFERENCES donation_profiles(id),
  razorpay_sub_id VARCHAR(255) UNIQUE NOT NULL,
  amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) DEFAULT 'INR',
  frequency VARCHAR(20) DEFAULT 'monthly',
  status VARCHAR(20) DEFAULT 'active',
  next_charge_date TIMESTAMPTZ,
  retry_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  cancelled_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS tax_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id UUID NOT NULL REFERENCES donations(id),
  receipt_number VARCHAR(50) UNIQUE NOT NULL,
  pdf_url TEXT NOT NULL,
  ngo_name VARCHAR(255) NOT NULL,
  ngo_80g_number VARCHAR(100) NOT NULL,
  financial_year VARCHAR(10) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  donor_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(donation_id)
);

ALTER TABLE donations
  ADD COLUMN IF NOT EXISTS campaign_id UUID REFERENCES donation_profiles(id),
  ADD COLUMN IF NOT EXISTS donor_user_id UUID REFERENCES users(id),
  ADD COLUMN IF NOT EXISTS is_anonymous BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS subscription_id UUID REFERENCES subscriptions(id),
  ADD COLUMN IF NOT EXISTS receipt_id UUID REFERENCES tax_receipts(id);

CREATE TABLE IF NOT EXISTS payment_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id UUID NOT NULL REFERENCES donations(id),
  event_type VARCHAR(50) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  razorpay_event_id VARCHAR(255),
  metadata_json JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES donation_profiles(id),
  documents_url TEXT[] NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  reviewer_id UUID REFERENCES users(id),
  review_notes TEXT,
  submitted_at TIMESTAMPTZ DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS campaign_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES donation_profiles(id),
  total_raised DECIMAL(12,2) NOT NULL,
  total_donors INTEGER NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  snapshot_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS impact_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES donation_profiles(id),
  content TEXT NOT NULL,
  statistics_json JSONB NOT NULL,
  date_range_start DATE NOT NULL,
  date_range_end DATE NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS platform_config (
    key VARCHAR(255) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- =========================================================================
-- 2. CLEANUP & RECREATE TRIGGERS (Tables exist now, so DROP TRIGGER works)
-- =========================================================================
DROP TRIGGER IF EXISTS set_updated_at_users ON users;
CREATE TRIGGER set_updated_at_users
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_donation_profiles ON donation_profiles;
CREATE TRIGGER set_updated_at_donation_profiles
  BEFORE UPDATE ON donation_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_subscriptions ON subscriptions;
CREATE TRIGGER set_updated_at_subscriptions
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- =========================================================================
-- 3. FIX INFINITE RECURSION FUNCTION
-- =========================================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users 
    WHERE supabase_auth_id = auth.uid() 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =========================================================================
-- 4. CLEANUP OLD POLICIES
-- =========================================================================
DROP POLICY IF EXISTS "Admins can manage all users" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Public can view active user profiles" ON users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

DROP POLICY IF EXISTS "Public can view verified campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Creators can insert own campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Creators can manage own campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Creators can view own campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Admins can manage all campaigns" ON donation_profiles;

DROP POLICY IF EXISTS "Enable read access for all users" ON platform_config;
DROP POLICY IF EXISTS "Enable write access for admins" ON platform_config;

-- =========================================================================
-- 5. RE-APPLY SECURE POLICIES
-- =========================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE donation_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_config ENABLE ROW LEVEL SECURITY;

-- users table policies
CREATE POLICY "Public can view active user profiles" ON users FOR SELECT USING (is_active = true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = supabase_auth_id);
CREATE POLICY "Users can insert their own profile" ON users FOR INSERT WITH CHECK (auth.uid() = supabase_auth_id);
CREATE POLICY "Admins can manage all users" ON users FOR ALL USING (public.is_admin());

-- platform_config policies
CREATE POLICY "Enable read access for all users" ON platform_config FOR SELECT USING (true);
CREATE POLICY "Enable write access for admins" ON platform_config FOR ALL USING (public.is_admin());

-- donation_profiles policies
CREATE POLICY "Public can view verified campaigns" ON donation_profiles FOR SELECT USING (is_active = true AND verification_status = 'verified');
CREATE POLICY "Creators can insert own campaigns" ON donation_profiles FOR INSERT WITH CHECK (auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id));
CREATE POLICY "Creators can manage own campaigns" ON donation_profiles FOR UPDATE USING (auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id));
CREATE POLICY "Creators can view own campaigns" ON donation_profiles FOR SELECT USING (auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id));
CREATE POLICY "Admins can manage all campaigns" ON donation_profiles USING (public.is_admin());

-- Insert defaults safely
INSERT INTO platform_config (key, value, description)
VALUES 
    ('allowed_categories', '["Education", "Medical", "Environment", "Disaster Relief", "Animals"]'::jsonb, 'Categories'),
    ('feature_flags', '{"ai_reports_enabled": true, "subscriptions_enabled": true, "donor_wall_enabled": true}'::jsonb, 'Flags'),
    ('platform_fee_percentage', '5.0'::jsonb, 'Fee')
ON CONFLICT (key) DO NOTHING;

-- =========================================================================
-- 6. GRANT TABLE PERMISSIONS
-- =========================================================================
-- Ensure the Supabase API roles have permission to access the tables
GRANT ALL ON TABLE public.users TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.donation_profiles TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.subscriptions TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.tax_receipts TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.payment_logs TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.verification_requests TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.campaign_progress TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.impact_reports TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.platform_config TO anon, authenticated, service_role;

