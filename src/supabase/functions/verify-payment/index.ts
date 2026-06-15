import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { createHmac } from "node:crypto";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const {
        razorpay_order_id,
        razorpay_subscription_id,
        razorpay_payment_id,
        razorpay_signature,
        donor_name,
        donor_email,
        donor_phone,
        amount,
        cause_id,
        campaign_id,
        is_anonymous,
        is_recurring
    } = await req.json()

    const key_secret = Deno.env.get('RAZORPAY_KEY_SECRET')
    if (!key_secret) {
        throw new Error('Razorpay credentials missing')
    }

    let payload_to_sign = "";
    if (razorpay_subscription_id) {
        payload_to_sign = razorpay_payment_id + "|" + razorpay_subscription_id;
    } else {
        payload_to_sign = razorpay_order_id + "|" + razorpay_payment_id;
    }

    const generated_signature = createHmac('sha256', key_secret)
      .update(payload_to_sign)
      .digest('hex');

    if (generated_signature !== razorpay_signature) {
        throw new Error('Payment verification failed. Invalid signature.')
    }
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseServiceKey) {
        throw new Error('Supabase credentials missing')
    }
    
    // Use the Service Role Key to bypass RLS and insert the donation safely
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // --- Step 1: Look up the donor's user ID by email ---
    let donor_user_id = null
    if (donor_email) {
      const { data: userRow } = await supabase
        .from('users')
        .select('id')
        .eq('email', donor_email)
        .maybeSingle()
      if (userRow) {
        donor_user_id = userRow.id
      }
    }
    
    // --- Step 1b: If it's a subscription, activate it ---
    let db_subscription_id = null;
    if (razorpay_subscription_id) {
      const { data: sub, error: subError } = await supabase
        .from('subscriptions')
        .update({ status: 'active' })
        .eq('razorpay_sub_id', razorpay_subscription_id)
        .select('id')
        .single();
        
      if (!subError && sub) {
        db_subscription_id = sub.id;
      }
    }
    
    // --- Step 2: Insert the donation record ---
    const { data: donation, error: donationError } = await supabase
      .from('donations')
      .insert({
        cause_id: cause_id || null,
        campaign_id: campaign_id || null,
        donor_name,
        donor_email,
        donor_phone,
        amount,
        is_anonymous: is_anonymous || false,
        donor_user_id,
        status: 'completed',
        razorpay_order_id: razorpay_order_id || null,
        razorpay_payment_id,
        razorpay_signature,
        is_recurring: is_recurring || false,
        subscription_id: db_subscription_id
      })
      .select()
      .single()
      
    if (donationError) {
        throw new Error(`Database error (donation): ${donationError.message}`)
    }

    // --- Step 3: Insert payment_log record ---
    const { error: logError } = await supabase
      .from('payment_logs')
      .insert({
        donation_id: donation.id,
        event_type: 'payment.captured',
        amount,
        status: 'completed',
        razorpay_event_id: razorpay_payment_id,
        metadata_json: {
          razorpay_order_id,
          razorpay_subscription_id,
          razorpay_payment_id,
          donor_email,
          campaign_id: campaign_id || null,
          is_anonymous: is_anonymous || false
        }
      })

    if (logError) {
      console.error('payment_logs insert error (non-fatal):', logError.message)
    }

    // --- Step 4: Update campaign raised_amount ---
    const effectiveCampaignId = campaign_id || cause_id
    if (effectiveCampaignId) {
      // Use RPC to atomically increment raised_amount
      const { error: updateError } = await supabase.rpc(
        'increment_raised_amount',
        { p_campaign_id: effectiveCampaignId, p_amount: amount }
      )

      // Fallback: If the RPC doesn't exist yet, do a manual update
      if (updateError) {
        console.error('RPC increment_raised_amount failed, trying direct update:', updateError.message)
        
        const { data: currentCampaign } = await supabase
          .from('donation_profiles')
          .select('raised_amount')
          .eq('id', effectiveCampaignId)
          .single()

        if (currentCampaign) {
          const newRaised = parseFloat(currentCampaign.raised_amount || 0) + parseFloat(amount)
          await supabase
            .from('donation_profiles')
            .update({ raised_amount: newRaised })
            .eq('id', effectiveCampaignId)
        }
      }
    }

    // --- Step 5: Auto-generate a tax receipt record ---
    const now = new Date()
    const financialYear = now.getMonth() >= 3 
      ? `${now.getFullYear()}-${now.getFullYear() + 1}` 
      : `${now.getFullYear() - 1}-${now.getFullYear()}`
    
    const receiptNumber = `80G-${Date.now()}-${Math.random().toString(36).substring(2, 6).toUpperCase()}`
    
    const { error: receiptError } = await supabase
      .from('tax_receipts')
      .insert({
        donation_id: donation.id,
        receipt_number: receiptNumber,
        pdf_url: '', // Will be populated by generate-receipt function later
        ngo_name: 'DonateNow Foundation',
        ngo_80g_number: '80G/2024/DEMO-12345',
        financial_year: financialYear,
        amount,
        donor_name
      })

    if (receiptError) {
      console.error('tax_receipts insert error (non-fatal):', receiptError.message)
    }

    return new Response(
      JSON.stringify({ success: true, donation_id: donation.id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 },
    )
  }
})
