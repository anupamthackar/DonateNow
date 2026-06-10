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
        razorpay_payment_id,
        razorpay_signature,
        donor_name,
        donor_email,
        donor_phone,
        amount,
        cause_id
    } = await req.json()

    const key_secret = Deno.env.get('RAZORPAY_KEY_SECRET')
    if (!key_secret) {
        throw new Error('Razorpay credentials missing')
    }

    const generated_signature = createHmac('sha256', key_secret)
      .update(razorpay_order_id + "|" + razorpay_payment_id)
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
    
    const { data, error } = await supabase
      .from('donations')
      .insert({
        cause_id,
        donor_name,
        donor_email,
        donor_phone,
        amount,
        status: 'pending', // will be updated to completed by webhook
        razorpay_order_id,
        razorpay_payment_id,
        razorpay_signature
      })
      .select()
      .single()
      
    if (error) {
        throw new Error(`Database error: ${error.message}`)
    }

    return new Response(
      JSON.stringify({ success: true, donation_id: data.id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 },
    )
  }
})
