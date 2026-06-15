-- Seed file for v2.0 causes (donation_profiles)
-- Adds 3 sample campaigns for each of the 5 allowed categories

DO $$
DECLARE
    demo_user_id UUID;
BEGIN
    -- 1. Create or get a dummy NGO user (with NULL supabase_auth_id so we don't need real auth)
    SELECT id INTO demo_user_id FROM public.users WHERE email = 'demo@ngo.org' LIMIT 1;
    
    IF demo_user_id IS NULL THEN
        INSERT INTO public.users (email, name, phone, role, is_active)
        VALUES ('demo@ngo.org', 'Demo NGO', '+919876543210', 'admin', true)
        RETURNING id INTO demo_user_id;
    END IF;

    -- 2. Seed Education
    INSERT INTO public.donation_profiles (creator_id, title, description, category, target_amount, raised_amount, image_url, verification_status)
    VALUES
        (demo_user_id, 'Build a School in Rural Bihar', 'Help us build a primary school for 200 children who currently walk 10km to study.', 'Education', 500000.00, 15000.00, 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800', 'verified'),
        (demo_user_id, 'Laptops for Underprivileged College Students', 'Providing digital access to bright students from low-income families.', 'Education', 200000.00, 45000.00, 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800', 'verified'),
        (demo_user_id, 'Sponsor a Girl Child Education', 'Fund one year of education, books, and uniforms for 50 young girls.', 'Education', 100000.00, 8000.00, 'https://images.unsplash.com/photo-1510531704581-5b28709ec2b1?w=800', 'verified');

    -- 3. Seed Medical
    INSERT INTO public.donation_profiles (creator_id, title, description, category, target_amount, raised_amount, image_url, verification_status)
    VALUES
        (demo_user_id, 'Urgent Heart Surgery for 5yo Aryan', 'Aryan was born with a congenital heart defect and needs surgery immediately.', 'Medical', 300000.00, 210000.00, 'https://images.unsplash.com/photo-1538108149393-cebb609b5311?w=800', 'verified'),
        (demo_user_id, 'Free Dialysis Camp for Senior Citizens', 'Supporting chronic kidney patients who cannot afford weekly dialysis.', 'Medical', 150000.00, 25000.00, 'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800', 'verified'),
        (demo_user_id, 'Cancer Treatment Fund for Maya', 'Help a single mother afford chemotherapy rounds.', 'Medical', 500000.00, 320000.00, 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800', 'verified');

    -- 4. Seed Environment
    INSERT INTO public.donation_profiles (creator_id, title, description, category, target_amount, raised_amount, image_url, verification_status)
    VALUES
        (demo_user_id, 'Plant 10,000 Trees in Deforested Areas', 'Join our massive reforestation drive in the Western Ghats.', 'Environment', 100000.00, 42000.00, 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800', 'verified'),
        (demo_user_id, 'Clean Our Rivers Initiative', 'Funding boats, nets, and volunteers to clean plastic from local rivers.', 'Environment', 200000.00, 89000.00, 'https://images.unsplash.com/photo-1621451537084-482c73073e0f?w=800', 'verified'),
        (demo_user_id, 'Save the Urban Wetlands', 'Protecting vital urban wetland ecosystems from encroachment.', 'Environment', 150000.00, 15000.00, 'https://images.unsplash.com/photo-1500329008985-d81b4d08b3ba?w=800', 'verified');

    -- 5. Seed Disaster Relief
    INSERT INTO public.donation_profiles (creator_id, title, description, category, target_amount, raised_amount, image_url, verification_status)
    VALUES
        (demo_user_id, 'Assam Flood Relief Fund', 'Providing food, clean water, and medical aid to displaced families.', 'Disaster Relief', 1000000.00, 650000.00, 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800', 'verified'),
        (demo_user_id, 'Earthquake Rebuilding Materials', 'Buying cement and bricks for villages destroyed in the recent quake.', 'Disaster Relief', 800000.00, 120000.00, 'https://images.unsplash.com/photo-1563604044391-45607db3b97b?w=800', 'verified'),
        (demo_user_id, 'Winter Blankets for the Homeless', 'Distributing heavy blankets during severe cold waves.', 'Disaster Relief', 50000.00, 48000.00, 'https://images.unsplash.com/photo-1518398046578-8cca57782e17?w=800', 'verified');

    -- 6. Seed Animals
    INSERT INTO public.donation_profiles (creator_id, title, description, category, target_amount, raised_amount, image_url, verification_status)
    VALUES
        (demo_user_id, 'Stray Dog Rescue & Rehab Center', 'Funding food and vet care for 300+ rescued stray dogs.', 'Animals', 200000.00, 115000.00, 'https://images.unsplash.com/photo-1548681528-6a5c45b66b42?w=800', 'verified'),
        (demo_user_id, 'Wildlife Anti-Poaching Patrols', 'Equipping rangers to protect endangered tigers and rhinos.', 'Animals', 500000.00, 95000.00, 'https://images.unsplash.com/photo-1564349683136-77e08dba1ef7?w=800', 'verified'),
        (demo_user_id, 'Cattle Feed for Drought Areas', 'Providing fodder and water for abandoned cattle in dry regions.', 'Animals', 150000.00, 22000.00, 'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=800', 'verified');

END $$;
