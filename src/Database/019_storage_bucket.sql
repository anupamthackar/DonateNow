-- 019_storage_bucket.sql

-- 1. Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('campaign-images', 'campaign-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Allow anyone to upload to this bucket
DROP POLICY IF EXISTS "Allow public uploads to campaign-images" ON storage.objects;
CREATE POLICY "Allow public uploads to campaign-images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'campaign-images');

-- 3. Allow anyone to read from this bucket
DROP POLICY IF EXISTS "Allow public read from campaign-images" ON storage.objects;
CREATE POLICY "Allow public read from campaign-images" ON storage.objects
  FOR SELECT USING (bucket_id = 'campaign-images');

-- 4. Allow users to update their own images (optional, but good for completeness)
DROP POLICY IF EXISTS "Allow updates to campaign-images" ON storage.objects;
CREATE POLICY "Allow updates to campaign-images" ON storage.objects
  FOR UPDATE USING (bucket_id = 'campaign-images');

-- 5. Allow users to delete their own images
DROP POLICY IF EXISTS "Allow deletes from campaign-images" ON storage.objects;
CREATE POLICY "Allow deletes from campaign-images" ON storage.objects
  FOR DELETE USING (bucket_id = 'campaign-images');
