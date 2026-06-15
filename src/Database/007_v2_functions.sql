-- v2.0 SQL Functions
-- This script creates the new RPC functions and triggers for DonateNow v2.0

-- 1. Get campaign stats for creator dashboard
CREATE OR REPLACE FUNCTION get_campaign_stats(p_campaign_id UUID)
RETURNS JSON AS $$
BEGIN
  RETURN (
    SELECT json_build_object(
      'total_raised', COALESCE(SUM(amount), 0),
      'total_donors', COUNT(DISTINCT donor_email),
      'total_donations', COUNT(*),
      'avg_donation', COALESCE(AVG(amount), 0),
      'latest_donation', MAX(created_at)
    )
    FROM donations
    WHERE campaign_id = p_campaign_id AND status = 'completed'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Get platform-wide stats for admin dashboard
CREATE OR REPLACE FUNCTION get_platform_stats()
RETURNS JSON AS $$
BEGIN
  RETURN (
    SELECT json_build_object(
      'total_campaigns', (SELECT COUNT(*) FROM donation_profiles WHERE is_active = true),
      'verified_campaigns', (SELECT COUNT(*) FROM donation_profiles WHERE verification_status = 'verified'),
      'pending_verifications', (SELECT COUNT(*) FROM verification_requests WHERE status = 'pending'),
      'total_donations', (SELECT COUNT(*) FROM donations WHERE status = 'completed'),
      'total_raised', (SELECT COALESCE(SUM(amount), 0) FROM donations WHERE status = 'completed'),
      'total_subscribers', (SELECT COUNT(*) FROM subscriptions WHERE status = 'active'),
      'total_users', (SELECT COUNT(*) FROM users WHERE is_active = true)
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Auto-update raised_amount on donation completion
CREATE OR REPLACE FUNCTION update_campaign_raised_amount()
RETURNS TRIGGER AS $$
BEGIN
  -- If a donation becomes completed, add its amount to the campaign's raised_amount
  IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
    UPDATE donation_profiles
    SET raised_amount = raised_amount + NEW.amount
    WHERE id = NEW.campaign_id;
  END IF;
  
  -- If a completed donation is refunded or failed later, subtract the amount
  IF OLD.status = 'completed' AND NEW.status != 'completed' THEN
    UPDATE donation_profiles
    SET raised_amount = raised_amount - OLD.amount
    WHERE id = OLD.campaign_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_raised_amount ON donations;

CREATE TRIGGER trg_update_raised_amount
  AFTER INSERT OR UPDATE ON donations
  FOR EACH ROW EXECUTE FUNCTION update_campaign_raised_amount();

-- 4. Generate receipt number sequence
CREATE SEQUENCE IF NOT EXISTS receipt_number_seq START 1;

CREATE OR REPLACE FUNCTION generate_receipt_number()
RETURNS VARCHAR AS $$
DECLARE
  v_year TEXT;
  v_seq INTEGER;
BEGIN
  v_year := TO_CHAR(now(), 'YYYY');
  v_seq := nextval('receipt_number_seq');
  RETURN 'DN-' || v_year || '-' || LPAD(v_seq::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;
