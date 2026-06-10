import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

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
    const { amount, currency } = await req.json()

    // Assuming RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET are available in environment variables
    const key_id = Deno.env.get('RAZORPAY_KEY_ID')
    const key_secret = Deno.env.get('RAZORPAY_KEY_SECRET')

    if (!key_id || !key_secret) {
        throw new Error('Razorpay credentials missing')
    }
    
    // Amount should be in paise (e.g. ₹500 = 50000 paise)
    const amountInPaise = amount * 100;

    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${btoa(`${key_id}:${key_secret}`)}`
      },
      body: JSON.stringify({
        amount: amountInPaise,
        currency: currency || "INR",
        receipt: `receipt_${Date.now()}`
      })
    })

    const data = await response.json()
    if (!response.ok) {
        throw new Error(data.error.description || 'Razorpay order creation failed')
    }

    return new Response(
      JSON.stringify({ order_id: data.id, amount: data.amount, currency: data.currency, key_id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 },
    )
  }
})
