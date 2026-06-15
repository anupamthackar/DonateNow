-- v2.0 Security and RLS Policies
-- This script sets up Row Level Security (RLS) policies for v2.0 tables

-- Enable RLS on all new tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE donation_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE impact_reports ENABLE ROW LEVEL SECURITY;

-- 1. users Policies
-- Users can read basic profile info of other users (for creator names on campaigns)
CREATE POLICY "Public can view active user profiles" ON users
  FOR SELECT USING (is_active = true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = supabase_auth_id);

-- Admins can manage all users (Uses security definer function to avoid infinite recursion)
CREATE POLICY "Admins can manage all users" ON users
  FOR ALL USING (public.is_admin());

-- Users can insert their own profile on signup
CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = supabase_auth_id);

-- 2. donation_profiles Policies
-- Public can read verified, active campaigns
CREATE POLICY "Public can view verified campaigns" ON donation_profiles
  FOR SELECT USING (is_active = true AND verification_status = 'verified');

-- Creators can insert their own campaigns
CREATE POLICY "Creators can insert own campaigns" ON donation_profiles
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id)
  );

-- Creators can read and update their own campaigns
CREATE POLICY "Creators can manage own campaigns" ON donation_profiles
  FOR UPDATE USING (
    auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id)
  );

CREATE POLICY "Creators can view own campaigns" ON donation_profiles
  FOR SELECT USING (
    auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id)
  );

-- Admins can manage all campaigns
CREATE POLICY "Admins can manage all campaigns" ON donation_profiles
  USING (public.is_admin());

-- 3. subscriptions Policies
-- Donors can manage their own subscriptions
CREATE POLICY "Users can view own subscriptions" ON subscriptions
  FOR SELECT USING (
    auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = user_id)
  );

CREATE POLICY "Users can update own subscriptions" ON subscriptions
  FOR UPDATE USING (
    auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = user_id)
  );
  
CREATE POLICY "Users can insert own subscriptions" ON subscriptions
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = user_id)
  );

-- Admins can view all subscriptions
CREATE POLICY "Admins can view all subscriptions" ON subscriptions
  FOR SELECT USING (public.is_admin());

-- 4. tax_receipts Policies
-- Donors can view their own receipts
CREATE POLICY "Users can view own receipts" ON tax_receipts
  FOR SELECT USING (
    donation_id IN (
      SELECT id FROM donations WHERE donor_user_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
      )
    )
  );

-- Admins can view all receipts
CREATE POLICY "Admins can view all receipts" ON tax_receipts
  FOR SELECT USING (public.is_admin());

-- Note: Edge functions will insert using service_role, bypassing RLS.

-- 5. payment_logs Policies
-- Admins can view all payment logs
CREATE POLICY "Admins can view payment logs" ON payment_logs
  FOR SELECT USING (public.is_admin());

-- 6. verification_requests Policies
-- Creators can view and insert their own verification requests
CREATE POLICY "Creators can view own verification requests" ON verification_requests
  FOR SELECT USING (
    campaign_id IN (
      SELECT id FROM donation_profiles WHERE creator_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
      )
    )
  );

CREATE POLICY "Creators can insert own verification requests" ON verification_requests
  FOR INSERT WITH CHECK (
    campaign_id IN (
      SELECT id FROM donation_profiles WHERE creator_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
      )
    )
  );

-- Admins can view and update all verification requests
CREATE POLICY "Admins can manage verification requests" ON verification_requests
  USING (public.is_admin());

-- 7. campaign_progress Policies
-- Public can view campaign progress
CREATE POLICY "Public can view campaign progress" ON campaign_progress
  FOR SELECT USING (true);

-- 8. impact_reports Policies
-- Creators can view reports for their campaigns
CREATE POLICY "Creators can view own impact reports" ON impact_reports
  FOR SELECT USING (
    campaign_id IN (
      SELECT id FROM donation_profiles WHERE creator_id IN (
        SELECT id FROM users WHERE supabase_auth_id = auth.uid()
      )
    )
  );

-- Admins can view all impact reports
CREATE POLICY "Admins can view all impact reports" ON impact_reports
  FOR SELECT USING (public.is_admin());

-- 9. donations Table (Modifying existing policies)
-- Drop old public policy if it exists (assuming we had one, though v1.0 only had Admin policy)
-- Add policy for Donor Wall: Public can read non-anonymous, completed donations
CREATE POLICY "Public can view donor wall" ON donations
  FOR SELECT USING (
    status = 'completed' AND is_anonymous = false
  );

-- Add policy for Donors: Can view their own history
CREATE POLICY "Donors can view own donations" ON donations
  FOR SELECT USING (
    donor_user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
  );
