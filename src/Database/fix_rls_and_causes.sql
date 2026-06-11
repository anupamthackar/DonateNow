-- 1. Create the SELECT policy on causes for public (anon/authenticated) reads
DROP POLICY IF EXISTS "Public can view active causes" ON public.causes;
CREATE POLICY "Public can view active causes" ON public.causes
  FOR SELECT TO anon, authenticated USING (is_active = true);

-- 2. Sync the auth user admin@donatenow.org to admin_users table with the correct UUID
INSERT INTO public.admin_users (email, name, role, supabase_auth_id)
SELECT email, COALESCE(raw_user_meta_data->>'name', 'NGO Admin'), 'admin', id
FROM auth.users
ON CONFLICT (email) DO UPDATE 
SET supabase_auth_id = EXCLUDED.supabase_auth_id;

-- 3. Create the handle_new_auth_user trigger function
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.admin_users (email, name, role, supabase_auth_id)
  VALUES (new.email, COALESCE(new.raw_user_meta_data->>'name', 'NGO Admin'), 'admin', new.id)
  ON CONFLICT (email) DO UPDATE 
  SET supabase_auth_id = EXCLUDED.supabase_auth_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Register trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();
