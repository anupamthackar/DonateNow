import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Razorpay from 'npm:razorpay'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Verify user is authenticated
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('CustomError: Missing Authorization Header from frontend!')
    }
    
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    )

    if (authError || !user) {
      throw new Error(`CustomError: Supabase Auth failed: ${authError?.message || 'No user found'}`)
    }

    const bodyText = await req.text()
    let bodyJson
    try {
      bodyJson = JSON.parse(bodyText)
    } catch(e) {
      throw new Error('CustomError: Invalid JSON body')
    }
    
    const { campaignId, amount, frequency } = bodyJson

    if (!campaignId || !amount || !frequency) {
      throw new Error('CustomError: Missing required fields')
    }

    const amountInPaise = Math.round(amount * 100)
    const planName = `DonateNow ${frequency} - ${campaignId}`.substring(0, 49)

    let razorpay
    try {
      razorpay = new Razorpay({
        key_id: Deno.env.get('RAZORPAY_KEY_ID') || '',
        key_secret: Deno.env.get('RAZORPAY_KEY_SECRET') || '',
      })
    } catch(e) {
      throw new Error('CustomError: Failed to init Razorpay SDK: ' + String(e))
    }

    let plan
    try {
      plan = await razorpay.plans.create({
        period: frequency === 'monthly' ? 'monthly' : 'yearly',
        interval: 1,
        item: {
          name: planName,
          amount: amountInPaise,
          currency: 'INR'
        }
      })
    } catch(e) {
      throw new Error('CustomError: Razorpay Plan Error: ' + JSON.stringify(e))
    }

    let subscription
    try {
      subscription = await razorpay.subscriptions.create({
        plan_id: plan.id,
        total_count: 120,
        customer_notify: 1
      })
    } catch(e) {
      throw new Error('CustomError: Razorpay Sub Error: ' + JSON.stringify(e))
    }

    const { error: dbError } = await supabase
      .from('subscriptions')
      .insert({
        id: subscription.id,
        user_id: user.id,
        campaign_id: campaignId,
        amount: amount,
        frequency: frequency,
        status: 'created',
        razorpay_plan_id: plan.id
      })

    if (dbError) {
      throw new Error('CustomError: DB Insert Error: ' + dbError.message)
    }

    return new Response(
      JSON.stringify({ subscriptionId: subscription.id, planId: plan.id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error("create-subscription explicit error:", error)
    
    // Always return a highly specific error string so we know exactly where it failed!
    let msg = error?.message || String(error)
    return new Response(
      JSON.stringify({ error: msg }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})
