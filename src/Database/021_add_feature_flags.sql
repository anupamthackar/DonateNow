-- 021_add_feature_flags.sql

-- Add features JSONB array to public.users to hold granular permissions
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '["donate", "create_campaign", "view_profile"]'::jsonb;

-- Seed existing admins with the admin_dashboard feature
UPDATE public.users
SET features = '["donate", "create_campaign", "view_profile", "admin_dashboard"]'::jsonb
WHERE role = 'admin';

-- Seed non-admins with the basic features
UPDATE public.users
SET features = '["donate", "create_campaign", "view_profile"]'::jsonb
WHERE role != 'admin' OR role IS NULL;

-- Reload schema cache so PostgREST recognizes the new 'features' column
NOTIFY pgrst, 'reload schema';
