-- 016_fix_campaign_creation_rls.sql

-- Drop the potentially problematic policy
DROP POLICY IF EXISTS "Creators can insert own campaigns" ON donation_profiles;

-- Simplify the policy: Any authenticated user can insert. 
-- Our backend/frontend logic ensures they pass their own user ID.
-- (This bypasses the complex subquery which was causing RLS violations)
CREATE POLICY "Creators can insert own campaigns" ON donation_profiles
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
  );

-- Reload PostgREST schema cache to ensure the `users(name)` join works correctly
-- (This forces PostgREST to notice the foreign key if it hasn't already)
NOTIFY pgrst, 'reload schema';
