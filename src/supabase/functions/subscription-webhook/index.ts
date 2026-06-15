import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import crypto from 'node:crypto'

serve(async (req) => {
  try {
    const rawBody = await req.text()
    const signature = req.headers.get('x-razorpay-signature')
    const secret = Deno.env.get('RAZORPAY_WEBHOOK_SECRET')

    if (!signature || !secret) {
      return new Response('Invalid request', { status: 400 })
    }

    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(rawBody)
      .digest('hex')

    if (expectedSignature !== signature) {
      return new Response('Invalid signature', { status: 400 })
    }

    const body = JSON.parse(rawBody)
    const event = body.event

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Handle subscription events
    if (event === 'subscription.charged') {
      const subId = body.payload.subscription.entity.id
      const paymentId = body.payload.payment.entity.id
      const amount = body.payload.payment.entity.amount / 100 // Convert back to rupees

      // Fetch subscription from DB to get user_id and campaign_id
      const { data: sub } = await supabase
        .from('subscriptions')
        .select('*')
        .eq('razorpay_sub_id', subId)
        .single()

      if (sub) {
        // Check if donation already exists (from verify-payment)
        const { data: existingDonation } = await supabase
          .from('donations')
          .select('id')
          .eq('razorpay_payment_id', paymentId)
          .maybeSingle()
          
        if (existingDonation) {
          console.log(`Donation already exists for sub ${subId} and payment ${paymentId}. Skipping.`)
          return new Response('OK', { status: 200 })
        }

        // Create a donation record for this charge
        const { data: user } = await supabase.from('users').select('*').eq('id', sub.user_id).single()
        
        const { data: donation } = await supabase
          .from('donations')
          .insert({
            campaign_id: sub.campaign_id,
            donor_user_id: sub.user_id,
            donor_name: user?.name || 'Anonymous',
            donor_email: user?.email || '',
            amount: amount,
            status: 'completed',
            razorpay_payment_id: paymentId,
            subscription_id: sub.id,
            is_recurring: true
          })
          .select()
          .single()

        // Trigger Receipt Generation
        if (donation) {
          // This would typically invoke the generate-receipt function, 
          // or push to a queue. For simplicity, we just log it here.
          console.log(`Donation created for sub ${subId}. Should trigger receipt generation for ${donation.id}`)
        }
      }
    } else if (event === 'subscription.cancelled' || event === 'subscription.halted') {
      const subId = body.payload.subscription.entity.id
      await supabase
        .from('subscriptions')
        .update({ status: 'cancelled' })
        .eq('razorpay_sub_id', subId)
    }

    return new Response('OK', { status: 200 })
  } catch (err) {
    console.error(err)
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
