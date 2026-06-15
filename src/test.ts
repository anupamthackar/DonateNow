import Razorpay from 'npm:razorpay'

try {
  const rzp = new Razorpay({ key_id: undefined, key_secret: undefined })
} catch (err) {
  console.log(JSON.stringify(err))
}
