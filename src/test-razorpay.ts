import Razorpay from 'npm:razorpay'
try {
  const rzp = new Razorpay({ key_id: 'rzp_test_invalid', key_secret: 'invalid' })
  await rzp.plans.create({ period: 'monthly', interval: 1, item: { name: 'Test', amount: 1000, currency: 'INR' } })
} catch (e) {
  console.log(JSON.stringify(e))
}
