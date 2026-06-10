import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { createHmac } from "node:crypto";

serve(async (req) => {
  try {
    const signature = req.headers.get('x-razorpay-signature')
    const webhookSecret = Deno.env.get('RAZORPAY_WEBHOOK_SECRET')
    
    if (!signature || !webhookSecret) {
        return new Response('Missing signature or secret', { status: 400 })
    }

    const body = await req.text()
    
    const expectedSignature = createHmac('sha256', webhookSecret)
        .update(body)
        .digest('hex');
        
    if (expectedSignature !== signature) {
        return new Response('Invalid signature', { status: 400 })
    }
    
    const payload = JSON.parse(body)
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const supabase = createClient(supabaseUrl!, supabaseServiceKey!)
    
    if (payload.event === 'payment.captured') {
        const payment = payload.payload.payment.entity
        await supabase
            .from('donations')
            .update({ status: 'completed', payment_method: payment.method })
            .eq('razorpay_payment_id', payment.id)
    } else if (payload.event === 'payment.failed') {
        const payment = payload.payload.payment.entity
        await supabase
            .from('donations')
            .update({ status: 'failed' })
            .eq('razorpay_payment_id', payment.id)
    }

    return new Response('ok', { status: 200 })
  } catch (error) {
    console.error(error)
    return new Response('Webhook error', { status: 400 })
  }
})
