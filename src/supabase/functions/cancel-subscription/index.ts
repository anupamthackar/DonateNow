import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Razorpay from 'npm:razorpay'

const razorpay = new Razorpay({
  key_id: Deno.env.get('RAZORPAY_KEY_ID'),
  key_secret: Deno.env.get('RAZORPAY_KEY_SECRET'),
})

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const authHeader = req.headers.get('Authorization')
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader?.replace('Bearer ', '') ?? ''
    )

    if (authError || !user) throw new Error('Unauthorized')

    const { subscriptionId } = await req.json()

    // Cancel in Razorpay
    const cancelled = await razorpay.subscriptions.cancel(subscriptionId, false)

    // Update in database
    const { error: dbError } = await supabase
      .from('subscriptions')
      .update({ status: 'cancelled', cancelled_at: new Date().toISOString() })
      .eq('razorpay_sub_id', subscriptionId)
      .eq('user_id', user.id)

    if (dbError) throw dbError

    return new Response(JSON.stringify({ success: true, status: cancelled.status }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
