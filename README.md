# DonateNow (iOS Native App)

<p align="center">
  <strong>A modern, native iOS donation platform for local NGOs.</strong>
</p>

## 📖 Overview

**DonateNow** is a native iOS application built to help NGOs collect donations seamlessly and track donor information without manual reconciliation. Built with Swift and SwiftUI, it integrates Razorpay for secure payments and Supabase for a real-time backend and secure server-side logic via Edge Functions.

---

## ✨ Core Features

| Feature | Description |
|---|---|
| 💳 **Native Payments** | Integrated Razorpay iOS SDK for UPI, cards, and netbanking |
| ⚡ **Real-time DB** | Automatic donor record creation in Supabase |
| 🛡️ **Secure Backend** | Edge Functions handle signature verification (secrets stay off-device) |
| 📱 **Universal App** | Adaptive layouts for both iPhone and iPad |
| 🔐 **Admin Dashboard** | In-app admin login protected by Supabase Auth and Keychain |
| 📋 **Donor Log** | Searchable, filterable list of all donations for the NGO team |

---

## 🏗️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| **Frontend** | SwiftUI & Swift 5.9+ | Modern, declarative native iOS UI, adaptive layouts |
| **Architecture** | MVVM | Separation of UI and business logic, reactive state via `@Observable` |
| **Database & Auth** | Supabase Swift SDK | Built-in Auth, Row-Level Security, PostgreSQL |
| **Payments** | Razorpay iOS SDK | India-focused, native checkout sheet |
| **Server Logic** | Supabase Edge Functions (Deno) | Server-side execution for key secrets and webhooks |

---

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   NATIVE iOS APP                     │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │  Public Views │  │  Admin Panel │  │ Services  │ │
│  │  - Donation   │  │  - Dashboard │  │ - Supabase│ │
│  │  - Thank You  │  │  - Donor Log │  │ - Payment │ │
│  │               │  │  - Login     │  │ - Auth    │ │
│  └──────┬───────┘  └──────┬───────┘  └─────┬─────┘ │
│         │                 │                 │       │
└─────────┼─────────────────┼─────────────────┼───────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   RAZORPAY   │   │   SUPABASE   │   │   SUPABASE   │
│  (Payments)  │   │    (Auth)    │   │  (Database)  │
│  - iOS SDK   │   │  - Admin JWT │   │  - donations │
│              │   │  - Keychain  │   │  - causes    │
└──────┬───────┘   └──────────────┘   └───────▲──────┘
       │                                      │
       ▼                                      │
┌──────────────┐                      ┌───────┴──────┐
│   RAZORPAY   │      Webhooks        │   SUPABASE   │
│   (Backend)  ├─────────────────────►│Edge Functions│
└──────────────┘                      └──────────────┘
```

---

## 📁 Project Structure

```
DonateNow/
├── AI Agent/                    → AI design and architecture docs
├── src/
│   ├── Backend/                 → Supabase Edge Functions (Deno/TS)
│   ├── Database/                → SQL schema and migrations
│   ├── Frontend/DonateNow/      → Native iOS App Workspace
│   │   ├── DonateNowApp.swift   → App entry point
│   │   ├── Configuration/       → Local environment config (Config.xcconfig)
│   │   ├── Models/              → Swift Codable structs
│   │   ├── Views/               → SwiftUI views (Public, Admin, Components)
│   │   ├── ViewModels/          → State and business logic (@Observable)
│   │   ├── Services/            → Supabase and Payment API calls
│   │   ├── Theme/               → Colors, Typography, ViewModifiers
│   │   ├── DonateNowTests/      → Unit & Integration tests (Swift Testing)
│   │   └── DonateNowUITests/    → End-to-End tests (XCUITest)
│   └── supabase/                → Local Supabase configuration
```

---

## 🔄 How It Works

1. Donor opens the app and views the active cause.
2. Selects an amount (e.g. ₹500) and fills in their name and email.
3. Taps "Donate Now" → App calls `create-order` Edge Function.
4. Razorpay iOS native checkout sheet is presented.
5. Donor completes payment via UPI / card / netbanking.
6. Razorpay success callback triggers `verify-payment` Edge Function.
7. Edge Function verifies signature and saves to Supabase.
8. App navigates to Thank-You view.

---

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 15+
- An Apple ID (Apple Developer Account optional for Simulator)
- A [Supabase](https://supabase.com) project
- A [Razorpay](https://razorpay.com) account (test mode)

### Installation

```bash
# Clone the repository
git clone https://github.com/anupamthackar/DonateNow.git
cd DonateNow

# Set up environment variables
cp "AI Agent/extended/Config.example.xcconfig" "src/Frontend/DonateNow/Configuration/Config.xcconfig"
# Edit Config.xcconfig with your Supabase URL and public keys
```

Open the project in Xcode, let Swift Package Manager resolve dependencies, select a Simulator (e.g., iPhone 15 Pro), and hit **Run (Cmd+R)**.

### Environment Variables

| Variable | Location | Description |
|---|---|---|
| `SUPABASE_URL` | `Config.xcconfig` (iOS) | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | `Config.xcconfig` (iOS) | Supabase anonymous/public key |
| `RAZORPAY_KEY_ID` | `Config.xcconfig` (iOS) | Razorpay test key ID (`rzp_test_...`) |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Vault (Server) | Service role key (bypasses RLS) |
| `RAZORPAY_KEY_SECRET` | Supabase Vault (Server) | Razorpay key secret |
| `RAZORPAY_WEBHOOK_SECRET` | Supabase Vault (Server) | Webhook signature verification secret |

---

## 🔒 Security

- **Row-Level Security (RLS)**: Enforced on all Supabase tables. The app cannot insert donation records directly.
- **Server-Side Verification**: Edge Functions verify Razorpay signatures.
- **Keychain Storage**: Supabase Swift SDK securely stores Admin JWTs.
- **App Transport Security (ATS)**: Enforced by iOS (HTTPS only).
- **No PCI Data**: Credit card info is securely handled by the native Razorpay SDK; the app never touches it.

---

## 🌐 Supabase Edge Functions

Since secrets cannot be stored on the device, critical operations run via Edge Functions:

| Function | Auth | Purpose |
|---|---|---|
| `create-order` | Anon | Creates a Razorpay order server-side |
| `verify-payment` | Anon | Verifies HMAC signature and inserts donation |
| `razorpay-webhook`| Razorpay Signature | Updates donation status asynchronously |

---

## 🧪 Testing

The project uses the modern **Swift Testing** framework alongside XCTest for comprehensive coverage.

- **Unit Tests (`Swift Testing`)**: Robust tests covering `Validators`, `Formatters`, and `Models` decoding logic.
- **Integration Tests (`Swift Testing`)**: Verifies Supabase connections, `create-order` execution, and `verify-payment` handling, including edge cases and failure scenarios.
- **UI Tests (`XCUITest`)**: End-to-end user flows for the Donation flow, Admin Dashboard, and validation states.

**Running Tests:**
- In Xcode, select the `DonateNow` scheme and press **Cmd+U**.
- Alternatively, run via `xcodebuild` from the terminal:
  ```bash
  xcodebuild test -project src/Frontend/DonateNow/DonateNow.xcodeproj -scheme DonateNow -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
  ```

---

## ⚠️ Current Limitations (MVP)

- 🔸 **Test mode only** — No real money processed (Razorpay test keys).
- 🔸 **Simulator Distribution** — Requires an Apple Developer Account for TestFlight/App Store.
- 🔸 **No Web Version** — This is a native iOS application.
- 🔸 **Single cause** — No multi-cause or campaign support.
- 🔸 **No tax receipts** — No 80G certificate generation.

---

## 📚 Documentation

Detailed project documentation is available in the [`AI Agent/`](./AI%20Agent/) directory:

| Document | Description |
|---|---|
| [Business Idea](./AI%20Agent/business_idea.mdc) | Problem statement, proposed solution, business goals |
| [PRD](./AI%20Agent/PRD.mdc) | Product requirements, user flows, Edge Functions, edge cases |
| [Project Scope](./AI%20Agent/Project_Scope.mdc) | Scope definition, assumptions, constraints, risks |
| [KPIs](./AI%20Agent/KPI.mdc) | Measurable iOS success criteria and performance targets |
| [Architecture](./AI%20Agent/extended/architecture.mdc) | MVVM architecture, tech stack, Xcode project structure |
| [ERD](./AI%20Agent/extended/ERD.mdc) | Database schema and Supabase configurations |
| [Security](./AI%20Agent/extended/security.mdc) | iOS Security policies (Keychain, ATS) |

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
