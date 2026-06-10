-- Seed default cause
INSERT INTO causes (title, description, target_amount, is_active)
VALUES (
  'Education for Underprivileged Children',
  'Help us provide quality education, books, and school supplies to 500+ underprivileged children in rural India. Every donation makes a difference in shaping a child''s future.',
  500000.00,
  true
);

-- Seed admin user (after Supabase Auth user is created)
-- Note: You should create the user in Supabase Auth first, then grab their UUID and insert it here.
-- INSERT INTO admin_users (email, name, role, supabase_auth_id)
-- VALUES ('admin@donatenow.org', 'NGO Admin', 'admin', '<supabase_auth_user_id>');
