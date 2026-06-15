-- v2.0 Schema Changes
-- This script creates the new tables and modifies existing tables for DonateNow v2.0

-- 1. users Table (Replaces admin_users concept)
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

CREATE TRIGGER set_updated_at_users
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 2. donation_profiles Table (Extends causes)
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

CREATE TRIGGER set_updated_at_donation_profiles
  BEFORE UPDATE ON donation_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 3. subscriptions Table
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

CREATE TRIGGER set_updated_at_subscriptions
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 4. tax_receipts Table (Must exist before we alter donations to add FK to it)
CREATE TABLE IF NOT EXISTS tax_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Note: donation_id will be added as FK after we alter donations, or we can just reference it now if donations exists
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

-- 5. Extend existing donations Table
ALTER TABLE donations
  ADD COLUMN IF NOT EXISTS campaign_id UUID REFERENCES donation_profiles(id),
  ADD COLUMN IF NOT EXISTS donor_user_id UUID REFERENCES users(id),
  ADD COLUMN IF NOT EXISTS is_anonymous BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS subscription_id UUID REFERENCES subscriptions(id),
  ADD COLUMN IF NOT EXISTS receipt_id UUID REFERENCES tax_receipts(id);

-- 6. payment_logs Table
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

-- 7. verification_requests Table
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

-- 8. campaign_progress Table
CREATE TABLE IF NOT EXISTS campaign_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES donation_profiles(id),
  total_raised DECIMAL(12,2) NOT NULL,
  total_donors INTEGER NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  snapshot_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 9. impact_reports Table
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

-- Create Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_supabase_auth_id ON users(supabase_auth_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

CREATE INDEX IF NOT EXISTS idx_profiles_creator_id ON donation_profiles(creator_id);
CREATE INDEX IF NOT EXISTS idx_profiles_verification_status ON donation_profiles(verification_status);
CREATE INDEX IF NOT EXISTS idx_profiles_is_active ON donation_profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_profiles_category ON donation_profiles(category);
CREATE INDEX IF NOT EXISTS idx_profiles_title_search ON donation_profiles USING gin(to_tsvector('english', title || ' ' || description));

CREATE INDEX IF NOT EXISTS idx_donations_campaign_id ON donations(campaign_id);
CREATE INDEX IF NOT EXISTS idx_donations_donor_user_id ON donations(donor_user_id);
CREATE INDEX IF NOT EXISTS idx_donations_subscription_id ON donations(subscription_id);
CREATE INDEX IF NOT EXISTS idx_donations_is_anonymous ON donations(is_anonymous);

CREATE INDEX IF NOT EXISTS idx_payment_logs_donation_id ON payment_logs(donation_id);
CREATE INDEX IF NOT EXISTS idx_payment_logs_event_type ON payment_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_payment_logs_created_at ON payment_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_verification_campaign_id ON verification_requests(campaign_id);
CREATE INDEX IF NOT EXISTS idx_verification_status ON verification_requests(status);
CREATE INDEX IF NOT EXISTS idx_verification_reviewer_id ON verification_requests(reviewer_id);

CREATE INDEX IF NOT EXISTS idx_receipts_donation_id ON tax_receipts(donation_id);
CREATE INDEX IF NOT EXISTS idx_receipts_receipt_number ON tax_receipts(receipt_number);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_campaign_id ON subscriptions(campaign_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_next_charge ON subscriptions(next_charge_date);

CREATE INDEX IF NOT EXISTS idx_reports_campaign_id ON impact_reports(campaign_id);

CREATE INDEX IF NOT EXISTS idx_progress_campaign_id ON campaign_progress(campaign_id);
CREATE INDEX IF NOT EXISTS idx_progress_snapshot_date ON campaign_progress(snapshot_date DESC);
