const Razorpay = require('razorpay');
const rzp = new Razorpay({ key_id: 'rzp_test_123', key_secret: 'invalid' });
rzp.plans.create({ period: 'monthly', interval: 1, item: { name: 'Test', amount: 1000, currency: 'INR' } })
  .catch(err => console.log("ERROR:", err));
