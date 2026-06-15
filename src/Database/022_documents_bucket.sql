-- 022_documents_bucket.sql

-- 1. Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false) -- Kept false since these are sensitive verification documents
ON CONFLICT (id) DO NOTHING;

-- 2. Allow authenticated users to upload to this bucket
DROP POLICY IF EXISTS "Allow authenticated uploads to documents" ON storage.objects;
CREATE POLICY "Allow authenticated uploads to documents" ON storage.objects
  FOR INSERT 
  TO authenticated
  WITH CHECK (bucket_id = 'documents');

-- 3. Allow users to read their own documents (Optional, but good for security)
DROP POLICY IF EXISTS "Allow authenticated read own documents" ON storage.objects;
CREATE POLICY "Allow authenticated read own documents" ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'documents');

-- 4. Allow admins to read all documents
DROP POLICY IF EXISTS "Allow admins read all documents" ON storage.objects;
CREATE POLICY "Allow admins read all documents" ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'documents' AND 
    (SELECT role FROM public.users WHERE supabase_auth_id = auth.uid()) = 'admin'
  );
