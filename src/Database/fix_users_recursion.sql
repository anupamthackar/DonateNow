-- Fix Infinite Recursion in `users` table RLS policies

-- 1. Create a SECURITY DEFINER function to bypass RLS when checking admin status
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users 
    WHERE supabase_auth_id = auth.uid() 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. Drop all recursive or problematic policies on the `users` table
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Enable write access for admins" ON public.platform_config;

-- 3. Re-create the Admin policy using the non-recursive function
CREATE POLICY "Admins can manage all users" ON public.users
  FOR ALL
  USING (public.is_admin());

-- 4. Add the missing INSERT policy so new users can actually sign up and create their profile row!
CREATE POLICY "Users can insert their own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = supabase_auth_id);

-- 5. Fix the platform_config policy to use the same non-recursive function
CREATE POLICY "Enable write access for admins" ON public.platform_config
    FOR ALL
    USING (public.is_admin());
