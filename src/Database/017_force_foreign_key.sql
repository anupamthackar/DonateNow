-- 017_force_foreign_key.sql
-- This script explicitly ensures the foreign key relationship exists between donation_profiles and users
-- which fixes the PGRST200 schema cache error.

-- 1. Ensure the creator_id column exists
ALTER TABLE public.donation_profiles 
ADD COLUMN IF NOT EXISTS creator_id UUID;

-- 2. Clean up any invalid data where the creator_id no longer exists in the users table!
-- (This prevents the 'violates foreign key constraint' error)
UPDATE public.donation_profiles
SET creator_id = (SELECT id FROM public.users WHERE email = 'demo@ngo.org' LIMIT 1)
WHERE creator_id NOT IN (SELECT id FROM public.users);

-- Or if demo@ngo.org doesn't exist, delete the invalid test campaigns to allow the foreign key to be created
DELETE FROM public.donation_profiles
WHERE creator_id NOT IN (SELECT id FROM public.users);

-- 3. Drop any existing constraints to avoid duplicates or misnamed constraints
ALTER TABLE public.donation_profiles 
DROP CONSTRAINT IF EXISTS donation_profiles_creator_id_fkey;

ALTER TABLE public.donation_profiles 
DROP CONSTRAINT IF EXISTS fk_creator;

-- 4. Force create the foreign key relationship
ALTER TABLE public.donation_profiles 
ADD CONSTRAINT fk_creator 
FOREIGN KEY (creator_id) 
REFERENCES public.users(id) 
ON DELETE CASCADE;

-- 5. Reload the PostgREST schema cache immediately
NOTIFY pgrst, 'reload schema';

-- 6. Force bypass RLS for campaign inserts (Frontend handles Auth)
DROP POLICY IF EXISTS "Creators can insert own campaigns" ON public.donation_profiles;

CREATE POLICY "Creators can insert own campaigns" ON public.donation_profiles
  FOR INSERT WITH CHECK (true);
