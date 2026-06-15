import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { GoogleGenerativeAI } from "npm:@google/generative-ai"

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Verify creator authentication
    const authHeader = req.headers.get('Authorization')
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader?.replace('Bearer ', '') ?? ''
    )

    if (authError || !user) throw new Error('Unauthorized')

    const { campaignId, startDate, endDate } = await req.json()
    if (!campaignId) throw new Error('Campaign ID is required')

    // 1. Fetch Campaign Data
    const { data: campaign, error: campError } = await supabase
      .from('donation_profiles')
      .select('*')
      .eq('id', campaignId)
      .eq('creator_id', user.id) // Ensure security
      .single()

    if (campError || !campaign) throw new Error('Campaign not found or access denied')

    // 2. Fetch Donation Statistics for the given period
    let query = supabase
      .from('donations')
      .select('*')
      .eq('campaign_id', campaignId)
      .eq('status', 'completed')

    if (startDate) query = query.gte('created_at', startDate)
    if (endDate) query = query.lte('created_at', endDate)

    const { data: donations, error: donError } = await query
    if (donError) throw donError

    const totalDonors = new Set(donations.map(d => d.donor_email)).size
    const totalRaisedPeriod = donations.reduce((sum, d) => sum + d.amount, 0)
    const avgDonation = totalDonors > 0 ? totalRaisedPeriod / donations.length : 0

    const statsObject = {
      totalDonors,
      totalRaisedPeriod,
      avgDonation,
      totalDonations: donations.length,
      period: `${startDate || 'Start'} to ${endDate || 'Now'}`
    }

    // 3. Generate AI Report using Google Gemini
    const apiKey = Deno.env.get("GEMINI_API_KEY")
    if (!apiKey) throw new Error('AI API Key not configured')
    
    const genAI = new GoogleGenerativeAI(apiKey)
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" })

    const prompt = `
      You are an AI assistant helping an NGO creator write an impact report for their donors.
      Campaign Title: "${campaign.title}"
      Category: ${campaign.category}
      Overall Target: ₹${campaign.target_amount}
      Overall Raised: ₹${campaign.raised_amount}
      
      Recent Performance (${statsObject.period}):
      - Donations count: ${statsObject.totalDonations}
      - Unique Donors: ${statsObject.totalDonors}
      - Amount Raised in Period: ₹${statsObject.totalRaisedPeriod}
      
      Write a warm, professional, 3-paragraph impact report summarizing these achievements. 
      Thank the donors, mention the recent growth, and gently remind them of the remaining target.
    `

    const result = await model.generateContent(prompt)
    const reportContent = result.response.text()

    // 4. Save the report
    const { data: report, error: repError } = await supabase
      .from('impact_reports')
      .insert({
        campaign_id: campaignId,
        content: reportContent,
        statistics_json: JSON.stringify(statsObject),
        date_range_start: startDate || new Date(new Date().setMonth(new Date().getMonth() - 1)).toISOString(), // default 1 month
        date_range_end: endDate || new Date().toISOString()
      })
      .select()
      .single()

    if (repError) throw repError

    return new Response(JSON.stringify({ success: true, report }), {
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
