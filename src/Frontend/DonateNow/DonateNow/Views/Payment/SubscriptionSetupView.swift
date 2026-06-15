import SwiftUI

struct SubscriptionSetupView: View {
    let campaign: DonationProfile
    @State private var amount: String = "1000"
    @State private var frequency: String = "monthly"
    @State private var isProcessing: Bool = false
    @State private var paymentSuccess: Bool = false
    @State private var errorMessage: String? = nil
    
    let frequencies = ["monthly", "yearly"]
    
    // In real app, injected via Environment
    private let paymentService = PaymentService.shared 
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set up Recurring Donation")
                .font(.title2)
                .bold()
            
            Text("Your recurring donation helps \(campaign.title) plan for the long term.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount (INR)")
                    .font(.subheadline)
                    .bold()
                TextField("Enter amount", text: $amount)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Frequency")
                    .font(.subheadline)
                    .bold()
                Picker("Frequency", selection: $frequency) {
                    ForEach(frequencies, id: \.self) { freq in
                        Text(freq.capitalized).tag(freq)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            if paymentSuccess {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("Subscription Active!")
                        .bold()
                    Button("Done") { dismiss() }
                        .padding(.top, 10)
                }
            } else {
                Button(action: setupSubscription) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Subscribe Now")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .bold()
                    }
                }
                .disabled(isProcessing || amount.isEmpty)
            }
        }
        .padding()
        .navigationTitle("Subscribe")
    }
    
    private func setupSubscription() {
        guard let amountDecimal = Decimal(string: amount) else { return }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                // In a real app, this would call the `create-subscription` edge function
                // which returns a Razorpay Sub ID, then opens the Razorpay SDK.
                // Here we mock the success.
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                await MainActor.run {
                    isProcessing = false
                    paymentSuccess = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Failed to setup subscription: \(error.localizedDescription)"
                }
            }
        }
    }
}
