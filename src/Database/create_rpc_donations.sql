-- Create get_all_donations RPC function
CREATE OR REPLACE FUNCTION public.get_all_donations()
RETURNS SETOF public.donations
LANGUAGE plpgsql
SECURITY DEFINER -- Bypasses RLS to prevent PostgREST client header issues
AS $$
BEGIN
  -- Manually enforce that the current authenticated user's ID is registered as an admin
  IF NOT EXISTS (
    SELECT 1 
    FROM public.admin_users 
    WHERE supabase_auth_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Access denied. User is not an admin.';
  END IF;
  
  RETURN QUERY 
  SELECT * 
  FROM public.donations
  ORDER BY created_at DESC;
END;
$$;
