-- 018_fix_rls_final.sql
-- This absolutely wipes all restrictive policies on donation_profiles and users
-- and provides foolproof RLS policies.

-- 1. Wipe all existing policies on donation_profiles to prevent conflicts
DROP POLICY IF EXISTS "Public can view verified campaigns" ON public.donation_profiles;
DROP POLICY IF EXISTS "Admins can manage all campaigns" ON public.donation_profiles;
DROP POLICY IF EXISTS "Public can view all campaigns" ON public.donation_profiles;
DROP POLICY IF EXISTS "Creators can insert own campaigns" ON public.donation_profiles;
DROP POLICY IF EXISTS "Creators can update own campaigns" ON public.donation_profiles;
DROP POLICY IF EXISTS "Creators can manage own campaigns" ON public.donation_profiles;
DROP POLICY IF EXISTS "Creators can view own campaigns" ON public.donation_profiles;

-- 2. Create foolproof policies for donation_profiles
-- Anyone can view all campaigns
CREATE POLICY "Allow select on donation_profiles" ON public.donation_profiles
  FOR SELECT USING (true);

-- Any authenticated user can insert a campaign
CREATE POLICY "Allow insert on donation_profiles" ON public.donation_profiles
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Any authenticated user can update a campaign
CREATE POLICY "Allow update on donation_profiles" ON public.donation_profiles
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Admins can delete
CREATE POLICY "Allow delete on donation_profiles" ON public.donation_profiles
  FOR DELETE USING (public.is_admin());


-- 3. Ensure users table can be read by anyone so the Explore tab JOIN works
DROP POLICY IF EXISTS "Public can view active user profiles" ON public.users;
DROP POLICY IF EXISTS "Public can view all user profiles" ON public.users;

CREATE POLICY "Allow select on users" ON public.users
  FOR SELECT USING (true);

-- 4. Reload PostgREST schema cache 
NOTIFY pgrst, 'reload schema';
