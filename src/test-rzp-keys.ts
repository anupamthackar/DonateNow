import Razorpay from 'npm:razorpay'
try {
  const rzp = new Razorpay({ key_id: 'rzp_test_T1tyT9XD5MA20I', key_secret: '5aIlEOFOH4S8nV38Hf2dbE65' })
  await rzp.plans.create({ period: 'monthly', interval: 1, item: { name: 'Test', amount: 1000, currency: 'INR' } })
  console.log("SUCCESS!")
} catch (e) {
  console.log(JSON.stringify(e))
}
