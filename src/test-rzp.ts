import Razorpay from 'npm:razorpay'
try {
  const rzp = new Razorpay({ key_id: 'rzp_test_invalid', key_secret: 'invalid' })
  await rzp.subscriptions.create({ plan_id: 'plan_123', total_count: 12, customer_notify: 1 })
} catch (e) {
  console.log(JSON.stringify(e))
}
