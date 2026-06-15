#!/bin/bash

# DonateNow V2.0 Edge Functions Deployment Script
# Run this script from the `src/` directory.

echo "Deploying DonateNow Edge Functions..."

# 1. Set Secrets (Replace with actual keys before running in production if not already set)
echo "Setting secrets..."
supabase secrets set RAZORPAY_KEY_ID="rzp_test_SzvMI0AIDCH6DP"
supabase secrets set RAZORPAY_KEY_SECRET="your_actual_razorpay_secret"
supabase secrets set GEMINI_API_KEY="your_actual_gemini_api_key"

# 2. Deploy Functions
echo "Deploying generate-impact-report..."
supabase functions deploy generate-impact-report --no-verify-jwt

echo "Deploying create-subscription..."
supabase functions deploy create-subscription --no-verify-jwt

echo "Deploying verify-payment..."
supabase functions deploy verify-payment --no-verify-jwt

echo "Deploying generate-receipt-pdf..."
supabase functions deploy generate-receipt-pdf --no-verify-jwt

echo "Deployment Complete!"
