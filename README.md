# 💚 DonateNow

A simple, transparent digital donation platform built for local NGOs to replace manual bank-transfer-based donation collection with a modern, seamless online experience.

---

## 🎯 Problem

Local NGOs often rely on **bank transfers** and **manual spreadsheets** to manage donations — leading to lost donor data, poor donor experience, and zero real-time visibility into fundraising progress.

**DonateNow** solves this by providing:
- A **public donation page** donors can access via a single shareable link
- **Instant payment processing** through Razorpay (UPI, cards, netbanking)
- **Automatic donor record creation** — zero manual data entry
- An **admin dashboard** for the NGO team to track donations in real time

---

## ✨ Features

### For Donors
| Feature | Description |
|---|---|
| 🏠 Public Donation Page | View cause details and predefined donation amounts (₹100 / ₹500 / ₹1000 / ₹2000) or enter a custom amount |
| 💳 Razorpay Checkout | Secure payment via UPI, credit/debit card, or netbanking |
| 🙏 Thank-You Page | Instant confirmation with donation summary after payment |

### For NGO Admins
| Feature | Description |
|---|---|
| 🔐 Admin Login | Secure email/password authentication via Supabase Auth |
| 📊 Dashboard | Real-time stats — total donations, total amount raised, recent activity |
| 📋 Donor Log | Searchable, filterable, paginated table of all donations |

---

## 🏗️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| **Frontend + Backend** | Next.js 14+ (App Router) | Full-stack, SSR, API routes, fast |
| **Database + Auth** | Supabase (PostgreSQL) | Built-in auth, Row-Level Security, free tier |
| **Payments** | Razorpay (Test Mode) | India-focused, UPI support, easy integration |
| **Hosting** | Vercel | Free tier, seamless Next.js deployment |
| **Styling** | CSS Modules / Vanilla CSS | Scoped styling, no external dependencies |

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                    NEXT.JS APP                       │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │  Public Pages │  │  Admin Panel │  │ API Routes│ │
│  │  - Donate     │  │  - Dashboard │  │ - Orders  │ │
│  │  - Thank You  │  │  - Donor Log │  │ - Verify  │ │
│  │               │  │  - Login     │  │ - Webhook │ │
│  └──────┬───────┘  └──────┬───────┘  └─────┬─────┘ │
│         │                 │                 │       │
└─────────┼─────────────────┼─────────────────┼───────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   RAZORPAY   │   │   SUPABASE   │   │   SUPABASE   │
│  (Payments)  │   │    (Auth)    │   │  (Database)  │
│  - Checkout  │   │  - Admin JWT │   │  - donations │
│  - Webhooks  │   │  - Sessions  │   │  - causes    │
└──────────────┘   └──────────────┘   └──────────────┘
```

---

## 📁 Project Structure

```
src/
├── app/
│   ├── layout.js                → Root layout
│   ├── page.js                  → Donation page (public)
│   ├── thank-you/page.js        → Thank-you page
│   ├── admin/
│   │   ├── login/page.js        → Admin login
│   │   ├── page.js              → Admin dashboard
│   │   └── donors/page.js       → Donor log
│   └── api/
│       ├── create-order/        → Create Razorpay order
│       ├── verify-payment/      → Verify payment + save donation
│       └── webhook/razorpay/    → Handle Razorpay webhooks
├── components/                  → Reusable UI components
├── lib/                         → Supabase clients, Razorpay SDK, utilities
└── styles/                      → Global + module CSS
```

---

## 🔄 How It Works

```
1. Donor visits the donation page
2. Selects an amount (e.g. ₹500) and fills in name + email
3. Clicks "Donate Now" → Razorpay Checkout opens
4. Completes payment via UPI / card / netbanking
5. Thank-you page displayed instantly with donation summary
6. Donation auto-recorded in Supabase database
7. Admin logs in and sees the donation in the donor log
```

---

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- A [Supabase](https://supabase.com) project (free tier)
- A [Razorpay](https://razorpay.com) account (test mode)

### Installation

```bash
# Clone the repository
git clone https://github.com/anupamthackar/DonateNow.git
cd DonateNow

# Install dependencies
npm install

# Set up environment variables
cp AI\ Agent/extended/.env.example .env.local
# Edit .env.local with your Supabase and Razorpay credentials

# Run the development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the app.

### Environment Variables

| Variable | Description |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Your Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous/public key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (server-only) |
| `NEXT_PUBLIC_RAZORPAY_KEY_ID` | Razorpay test key ID (`rzp_test_...`) |
| `RAZORPAY_KEY_SECRET` | Razorpay key secret (server-only) |
| `RAZORPAY_WEBHOOK_SECRET` | Webhook signature verification secret |

---

## 🔒 Security

- **Row-Level Security (RLS)** on all Supabase tables
- **Razorpay signature verification** on every payment and webhook
- **Admin routes protected** by Supabase Auth (JWT)
- **No payment card data** stored in the database — handled entirely by Razorpay
- **Server-side secrets** never exposed to the client

---

## 📊 API Endpoints

| Method | Endpoint | Auth | Purpose |
|---|---|---|---|
| `POST` | `/api/create-order` | Public | Create a Razorpay order |
| `POST` | `/api/verify-payment` | Public | Verify payment + save donation |
| `POST` | `/api/webhook/razorpay` | Razorpay Signature | Handle payment events |
| `GET` | `/api/admin/donations` | Admin JWT | Fetch donor log |
| `GET` | `/api/admin/stats` | Admin JWT | Fetch dashboard statistics |
| `GET` | `/api/health` | Public | Health check |

---

## 🧪 Testing

The project uses a layered testing approach:

- **Unit Tests** — Validation logic, currency formatting, signature verification (Jest)
- **Integration Tests** — API routes with Supabase + Razorpay (Supertest)
- **E2E Tests** — Full donation flow, admin login + donor log (Playwright)

```bash
# Run unit tests
npm test

# Run E2E tests
npx playwright test
```

---

## ⚠️ Current Limitations (MVP)

- 🔸 **Test mode only** — no real money processed
- 🔸 **Single cause** — no multi-cause or campaign support
- 🔸 **No email notifications** — no automated thank-you emails
- 🔸 **No recurring donations** — one-time only
- 🔸 **No tax receipts** — no 80G certificate generation
- 🔸 **Web only** — no mobile app
- 🔸 **INR only** — single currency

---

## 🗺️ Roadmap

| Phase | Features |
|---|---|
| **Phase 2** | Email receipts, CSV export, 80G tax certificates |
| **Phase 3** | Multi-cause support, campaign management |
| **Phase 4** | Recurring donations, donor accounts |
| **Phase 5** | Mobile app, social sharing, analytics dashboard |

---

## 📚 Documentation

Detailed project documentation is available in the [`AI Agent/`](./AI%20Agent/) directory:

| Document | Description |
|---|---|
| [Business Idea](./AI%20Agent/business_idea.mdc) | Problem statement, proposed solution, business goals |
| [PRD](./AI%20Agent/PRD.mdc) | Product requirements, user flows, API contracts, edge cases |
| [Project Scope](./AI%20Agent/Project_Scope.mdc) | Scope definition, assumptions, constraints, risks |
| [KPIs](./AI%20Agent/KPI.mdc) | Measurable success criteria and acceptance tests |
| [Architecture](./AI%20Agent/extended/architecture.mdc) | System architecture, tech stack, component structure |
| [ERD](./AI%20Agent/extended/ERD.mdc) | Database schema and entity relationships |
| [Security](./AI%20Agent/extended/security.mdc) | Security policies and implementation details |
| [Testing](./AI%20Agent/extended/testing.md) | Testing strategy and test cases |

---

## 🤝 Contributing

This is currently an MVP built for a specific NGO. Contributions, suggestions, and feedback are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source. See the [LICENSE](./LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for NGOs that make a difference.
</p>
