try {
  const Razorpay = require('razorpay');
  const rzp = new Razorpay({ key_id: undefined, key_secret: undefined })
} catch(e) {
  console.log(e.message);
}
