import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { PDFDocument, rgb } from 'https://cdn.skypack.dev/pdf-lib'

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { donationId } = await req.json()
    if (!donationId) throw new Error('Donation ID required')

    // Fetch donation and user details
    const { data: donation, error: donError } = await supabase
      .from('donations')
      .select('*, donation_profiles(title), users!donor_user_id(name, email)')
      .eq('id', donationId)
      .single()

    if (donError || !donation) throw new Error('Donation not found')

    // 1. Generate Receipt Number via RPC
    const { data: receiptNumber, error: rpcError } = await supabase.rpc('generate_receipt_number')
    if (rpcError) throw rpcError

    // 2. Generate PDF
    const pdfDoc = await PDFDocument.create()
    const page = pdfDoc.addPage([600, 400])
    
    page.drawText('DonateNow - Official 80G Tax Receipt', { x: 50, y: 350, size: 20 })
    page.drawText(`Receipt No: ${receiptNumber}`, { x: 50, y: 310, size: 12 })
    page.drawText(`Date: ${new Date().toLocaleDateString()}`, { x: 400, y: 310, size: 12 })
    
    page.drawText(`Received with thanks from: ${donation.users?.name || donation.donor_name}`, { x: 50, y: 270, size: 12 })
    page.drawText(`Amount: INR ${donation.amount}`, { x: 50, y: 240, size: 14, color: rgb(0, 0.5, 0) })
    page.drawText(`Towards Campaign: ${donation.donation_profiles?.title}`, { x: 50, y: 210, size: 12 })
    
    // Mock 80G data (In real app, fetch from NGO entity associated with campaign)
    const ngoName = "DonateNow Foundation"
    const ngo80gNumber = "DEL/80G/2023-24/12345"
    
    page.drawText(`NGO Name: ${ngoName}`, { x: 50, y: 150, size: 10 })
    page.drawText(`80G Reg No: ${ngo80gNumber}`, { x: 50, y: 130, size: 10 })
    page.drawText('This receipt is valid for tax exemption under section 80G of Income Tax Act.', { x: 50, y: 100, size: 10, color: rgb(0.3, 0.3, 0.3) })

    const pdfBytes = await pdfDoc.save()

    // 3. Upload to Storage
    const fileName = `${donation.donor_user_id || 'guest'}/${receiptNumber}.pdf`
    const { error: uploadError } = await supabase.storage
      .from('receipts')
      .upload(fileName, pdfBytes, {
        contentType: 'application/pdf',
        upsert: true
      })

    if (uploadError) throw uploadError

    const { data: publicUrlData } = supabase.storage.from('receipts').getPublicUrl(fileName)
    const pdfUrl = publicUrlData.publicUrl

    // 4. Save to TaxReceipts Table
    const financialYear = new Date().getMonth() >= 3 ? `${new Date().getFullYear()}-${new Date().getFullYear()+1}` : `${new Date().getFullYear()-1}-${new Date().getFullYear()}`
    
    const { data: receipt, error: recError } = await supabase
      .from('tax_receipts')
      .insert({
        donation_id: donationId,
        receipt_number: receiptNumber,
        pdf_url: pdfUrl,
        ngo_name: ngoName,
        ngo_80g_number: ngo80gNumber,
        financial_year: financialYear,
        amount: donation.amount,
        donor_name: donation.users?.name || donation.donor_name
      })
      .select()
      .single()

    if (recError) throw recError

    // 5. Link receipt to donation
    await supabase.from('donations').update({ receipt_id: receipt.id }).eq('id', donationId)

    return new Response(JSON.stringify({ success: true, receipt: receipt }), {
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
