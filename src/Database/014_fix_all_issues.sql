-- 014_fix_all_issues.sql
-- Comprehensive fix for RLS, triggers, and missing DB infrastructure
-- Run this in the Supabase SQL Editor

-- =========================================================================
-- 1. RPC: Atomically increment raised_amount (used by verify-payment)
-- =========================================================================
CREATE OR REPLACE FUNCTION public.increment_raised_amount(p_campaign_id UUID, p_amount DECIMAL)
RETURNS VOID AS $$
BEGIN
  UPDATE donation_profiles
  SET raised_amount = raised_amount + p_amount,
      updated_at = now()
  WHERE id = p_campaign_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =========================================================================
-- 2. Enable RLS on remaining tables
-- =========================================================================
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE impact_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;

-- =========================================================================
-- 3. RLS Policies for donations
-- =========================================================================
DROP POLICY IF EXISTS "Service role can insert donations" ON donations;
DROP POLICY IF EXISTS "Users can view own donations" ON donations;
DROP POLICY IF EXISTS "Admins can view all donations" ON donations;
DROP POLICY IF EXISTS "Anon can view completed donations for donor wall" ON donations;

-- Service role inserts (from edge functions) — bypass RLS inherently
-- Users can view their own donations
CREATE POLICY "Users can view own donations" ON donations
  FOR SELECT USING (
    donor_user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
  );

-- Admins can view all donations
CREATE POLICY "Admins can view all donations" ON donations
  FOR ALL USING (public.is_admin());

-- Public can view completed donations for Donor Wall (limited columns enforced by query)
CREATE POLICY "Anon can view completed donations for donor wall" ON donations
  FOR SELECT USING (status = 'completed');

-- =========================================================================
-- 4. RLS Policies for tax_receipts
-- =========================================================================
DROP POLICY IF EXISTS "Users can view own receipts" ON tax_receipts;
DROP POLICY IF EXISTS "Admins can manage all receipts" ON tax_receipts;

CREATE POLICY "Users can view own receipts" ON tax_receipts
  FOR SELECT USING (
    donation_id IN (
      SELECT id FROM donations 
      WHERE donor_user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
    )
  );

CREATE POLICY "Admins can manage all receipts" ON tax_receipts
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 5. RLS Policies for payment_logs
-- =========================================================================
DROP POLICY IF EXISTS "Users can view own payment logs" ON payment_logs;
DROP POLICY IF EXISTS "Admins can manage all payment logs" ON payment_logs;

CREATE POLICY "Users can view own payment logs" ON payment_logs
  FOR SELECT USING (
    donation_id IN (
      SELECT id FROM donations 
      WHERE donor_user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
    )
  );

CREATE POLICY "Admins can manage all payment logs" ON payment_logs
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 6. RLS Policies for impact_reports (public read for verified campaigns)
-- =========================================================================
DROP POLICY IF EXISTS "Public can view impact reports" ON impact_reports;
DROP POLICY IF EXISTS "Admins can manage impact reports" ON impact_reports;

CREATE POLICY "Public can view impact reports" ON impact_reports
  FOR SELECT USING (
    campaign_id IN (
      SELECT id FROM donation_profiles 
      WHERE verification_status = 'verified' AND is_active = true
    )
  );

CREATE POLICY "Admins can manage impact reports" ON impact_reports
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 7. RLS Policies for subscriptions
-- =========================================================================
DROP POLICY IF EXISTS "Users can view own subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admins can manage all subscriptions" ON subscriptions;

CREATE POLICY "Users can view own subscriptions" ON subscriptions
  FOR SELECT USING (
    user_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
  );

CREATE POLICY "Admins can manage all subscriptions" ON subscriptions
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 8. RLS Policies for verification_requests
-- =========================================================================
DROP POLICY IF EXISTS "Creators can view own requests" ON verification_requests;
DROP POLICY IF EXISTS "Creators can submit requests" ON verification_requests;
DROP POLICY IF EXISTS "Admins can manage all requests" ON verification_requests;

CREATE POLICY "Creators can view own requests" ON verification_requests
  FOR SELECT USING (
    campaign_id IN (
      SELECT id FROM donation_profiles 
      WHERE creator_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
    )
  );

CREATE POLICY "Creators can submit requests" ON verification_requests
  FOR INSERT WITH CHECK (
    campaign_id IN (
      SELECT id FROM donation_profiles 
      WHERE creator_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
    )
  );

CREATE POLICY "Admins can manage all requests" ON verification_requests
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 9. Fix donation_profiles INSERT policy for campaign creation
-- Current policy checks: auth.uid() IN (SELECT supabase_auth_id FROM users WHERE id = creator_id)
-- This fails because creator_id is the NEW row's value. Fix to allow any authenticated user
-- to create a campaign with their own user ID.
-- =========================================================================
DROP POLICY IF EXISTS "Creators can insert own campaigns" ON donation_profiles;

CREATE POLICY "Creators can insert own campaigns" ON donation_profiles
  FOR INSERT WITH CHECK (
    creator_id IN (SELECT id FROM users WHERE supabase_auth_id = auth.uid())
  );

-- =========================================================================
-- 10. Add "Community" to allowed_categories if missing
-- =========================================================================
UPDATE platform_config 
SET value = '["Education", "Medical", "Environment", "Community", "Disaster Relief", "Animals"]'::jsonb,
    updated_at = now()
WHERE key = 'allowed_categories';

-- =========================================================================
-- 11. Grant permissions on the increment function
-- =========================================================================
GRANT EXECUTE ON FUNCTION public.increment_raised_amount TO service_role;
GRANT EXECUTE ON FUNCTION public.increment_raised_amount TO authenticated;

-- =========================================================================
-- 12. Ensure campaign_progress and platform_config have public read
-- =========================================================================
ALTER TABLE campaign_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view campaign progress" ON campaign_progress;
CREATE POLICY "Public can view campaign progress" ON campaign_progress
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage campaign progress" ON campaign_progress;  
CREATE POLICY "Admins can manage campaign progress" ON campaign_progress
  FOR ALL USING (public.is_admin());

GRANT ALL ON TABLE public.campaign_progress TO anon, authenticated, service_role;
