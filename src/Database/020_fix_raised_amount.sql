-- 020_fix_raised_amount.sql

-- 1. Fix increment_raised_amount to update both causes and campaigns
CREATE OR REPLACE FUNCTION public.increment_raised_amount(p_campaign_id UUID, p_amount DECIMAL)
RETURNS VOID AS $$
BEGIN
  -- Try updating donation_profiles (Campaigns)
  UPDATE public.donation_profiles
  SET raised_amount = COALESCE(raised_amount, 0) + p_amount,
      updated_at = now()
  WHERE id = p_campaign_id;

  -- Try updating causes (Platform Causes)
  UPDATE public.causes
  SET raised_amount = COALESCE(raised_amount, 0) + p_amount,
      updated_at = now()
  WHERE id = p_campaign_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
