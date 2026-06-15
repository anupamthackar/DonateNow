-- v2.0 Data Migration
-- This script migrates data from v1.0 tables to v2.0 tables

-- 1. Migrate admin_users to users
INSERT INTO users (id, email, name, role, supabase_auth_id, is_active, created_at, updated_at)
SELECT 
  id, 
  email, 
  name, 
  role, 
  supabase_auth_id, 
  true as is_active, 
  created_at, 
  updated_at
FROM admin_users
ON CONFLICT (email) DO NOTHING;

-- 2. Populate users from existing unique donors (as 'donor' role)
-- We only use those with valid emails, and we don't have supabase_auth_id for them yet.
INSERT INTO users (email, name, role, is_active, created_at, updated_at)
SELECT DISTINCT ON (donor_email)
  donor_email, 
  donor_name, 
  'donor' as role, 
  true as is_active, 
  now() as created_at, 
  now() as updated_at
FROM donations
WHERE donor_email IS NOT NULL AND donor_email != ''
ON CONFLICT (email) DO NOTHING;

-- 3. Migrate causes to donation_profiles
-- We need to assign a creator_id. We'll pick the first admin user we migrated.
DO $$
DECLARE
  v_admin_id UUID;
BEGIN
  SELECT id INTO v_admin_id FROM users WHERE role = 'admin' LIMIT 1;
  
  IF v_admin_id IS NULL THEN
    -- If no admin exists, create a dummy system admin to own migrated campaigns
    INSERT INTO users (email, name, role) 
    VALUES ('system@donatenow.app', 'System Admin', 'admin') 
    RETURNING id INTO v_admin_id;
  END IF;

  INSERT INTO donation_profiles (
    id, 
    creator_id, 
    title, 
    description, 
    target_amount, 
    raised_amount, 
    image_url, 
    verification_status, 
    is_active, 
    created_at, 
    updated_at
  )
  SELECT 
    id, 
    v_admin_id as creator_id, 
    title, 
    description, 
    target_amount, 
    raised_amount, 
    image_url, 
    'verified' as verification_status, -- existing causes are assumed verified
    is_active, 
    created_at, 
    updated_at
  FROM causes
  ON CONFLICT (id) DO NOTHING;
END $$;

-- 4. Update donations table
-- Link donations to the newly migrated donation_profiles
UPDATE donations
SET campaign_id = cause_id
WHERE cause_id IS NOT NULL AND campaign_id IS NULL;

-- Link donations to the newly created users based on email
UPDATE donations d
SET donor_user_id = u.id
FROM users u
WHERE d.donor_email = u.email AND d.donor_user_id IS NULL;
