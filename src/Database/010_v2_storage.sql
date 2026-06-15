-- v2.0 Storage Buckets Setup
-- This script creates the required Storage buckets and sets their RLS policies

-- 1. Create buckets if they don't exist
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('documents', 'documents', false),
  ('receipts', 'receipts', false),
  ('campaign-images', 'campaign-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Setup RLS policies for 'documents' bucket
-- Creators can upload their own verification documents
CREATE POLICY "Creators can upload verification documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents' AND 
    (auth.uid() = owner OR auth.uid() IN (SELECT supabase_auth_id FROM public.users WHERE role = 'creator'))
  );

-- Admins can read all documents
CREATE POLICY "Admins can view verification documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'documents' AND 
    auth.uid() IN (SELECT supabase_auth_id FROM public.users WHERE role = 'admin')
  );

-- 3. Setup RLS policies for 'receipts' bucket
-- Donors can read their own receipts (we assume the object name includes their user id, or we manage access via Edge Function)
-- Since Edge Function generates receipts using service_role, no INSERT policy is needed for users.
-- To allow donors to read their own receipts securely, we can restrict by folder path if we use `auth.uid()` as the folder.
-- For now, allow authenticated users to read receipts that belong to their donations.
CREATE POLICY "Donors can view their own receipts" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'receipts' AND 
    (
      -- This is a bit complex in storage.objects, so typically we rely on the signed URL or we structure the path as `userId/receipt.pdf`
      -- For simplicity in this demo, if the path contains their auth.uid(), they can read it.
      (auth.uid()::text = (string_to_array(name, '/'))[1])
      OR 
      (auth.uid() IN (SELECT supabase_auth_id FROM public.users WHERE role = 'admin'))
    )
  );

-- 4. Setup RLS policies for 'campaign-images' bucket
-- Public can view campaign images
CREATE POLICY "Public can view campaign images" ON storage.objects
  FOR SELECT USING (bucket_id = 'campaign-images');

-- Creators can upload images to their campaigns
CREATE POLICY "Creators can upload campaign images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'campaign-images' AND 
    auth.uid() IN (SELECT supabase_auth_id FROM public.users WHERE role IN ('creator', 'admin'))
  );
