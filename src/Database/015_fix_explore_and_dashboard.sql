-- 015_fix_explore_and_dashboard.sql
-- Fixes RLS and schema issues for Explore, Dashboard, and Campaign Creation

-- =========================================================================
-- 1. Fix missing columns in payment_logs
-- =========================================================================
ALTER TABLE payment_logs 
ADD COLUMN IF NOT EXISTS amount DECIMAL,
ADD COLUMN IF NOT EXISTS status VARCHAR(50),
ADD COLUMN IF NOT EXISTS razorpay_event_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS metadata_json JSONB;

-- =========================================================================
-- 2. Relax donation_profiles RLS so Explore section and Admin Dashboard can see them
-- =========================================================================
DROP POLICY IF EXISTS "Public can view verified campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Admins can manage all campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Anon can view completed donations for donor wall" ON donations;

-- Let everyone view all campaigns (the frontend handles filtering by status)
CREATE POLICY "Public can view all campaigns" ON donation_profiles 
  FOR SELECT USING (true);

-- Admins get full ALL access
CREATE POLICY "Admins can manage all campaigns" ON donation_profiles 
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 3. Fix the "new row violates row-level security policy" for draft campaigns
-- =========================================================================
-- Use a SECURITY DEFINER function to reliably resolve auth.uid() to public.users.id
CREATE OR REPLACE FUNCTION public.get_user_id_by_auth()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT id FROM public.users WHERE supabase_auth_id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP POLICY IF EXISTS "Creators can insert own campaigns" ON donation_profiles;
CREATE POLICY "Creators can insert own campaigns" ON donation_profiles
  FOR INSERT WITH CHECK (
    creator_id = public.get_user_id_by_auth()
  );

DROP POLICY IF EXISTS "Creators can manage own campaigns" ON donation_profiles;
DROP POLICY IF EXISTS "Creators can update own campaigns" ON donation_profiles;
CREATE POLICY "Creators can update own campaigns" ON donation_profiles
  FOR UPDATE USING (
    creator_id = public.get_user_id_by_auth()
  );

-- =========================================================================
-- 4. Fix payment_logs for Admin Dashboard
-- =========================================================================
-- Ensure Admins have ALL access to payment_logs
DROP POLICY IF EXISTS "Admins can manage all payment logs" ON payment_logs;
CREATE POLICY "Admins can manage all payment logs" ON payment_logs
  FOR ALL USING (public.is_admin());

-- =========================================================================
-- 5. Fix users table SELECT policy
-- =========================================================================
-- Ensure users table allows fetching names for joins (needed by Explore & Dashboard)
DROP POLICY IF EXISTS "Public can view active user profiles" ON users;
CREATE POLICY "Public can view all user profiles" ON users
  FOR SELECT USING (true);
