import SwiftUI

struct DonationView: View {
    let causeId: UUID
    @StateObject private var viewModel = DonationViewModel()
    @State private var animateHero = false
    
    let predefinedAmounts: [Double] = [100, 500, 1000, 2000]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if viewModel.isLoading && viewModel.activeCause == nil {
                    // Skeleton Loading State
                    VStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 180)
                            .shimmer()
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 60)
                            .shimmer()
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 160)
                            .shimmer()
                    }
                    .padding(.horizontal)
                    .frame(minHeight: 400)
                } else if let cause = viewModel.activeCause {
                    // Hero Header
                    VStack(spacing: 8) {
                        Image(systemName: "hands.and.sparkles.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.primary.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateHero ? 1.0 : 0.5)
                            .opacity(animateHero ? 1 : 0)
                        
                        Text("Make a Difference Today")
                            .font(.title2).bold()
                            .foregroundColor(.primary)
                            .opacity(animateHero ? 1 : 0)
                            .offset(y: animateHero ? 0 : 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            animateHero = true
                        }
                    }
                    
                    // Cause Detail Card
                    CauseCardView(cause: cause)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Amount Selection Section
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Choose Amount", systemImage: "indianrupeesign.circle")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Pills Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(predefinedAmounts, id: \.self) { amount in
                                AmountPill(amount: amount, isSelected: viewModel.selectedAmount == amount) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.selectedAmount = amount
                                        viewModel.customAmount = ""
                                    }
                                }
                            }
                        }
                        
                        // Custom Amount TextField
                        CustomTextField(
                            label: "Or Enter Custom Amount (₹)",
                            placeholder: "e.g. 1500",
                            text: $viewModel.customAmount,
                            keyboardType: .numberPad
                        )
                        .onChange(of: viewModel.customAmount) { _, newValue in
                            if !newValue.isEmpty {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedAmount = nil
                                }
                            }
                        }
                    }
                    .cardStyle()
                    
                    // Donor Information Form
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Your Details", systemImage: "person.crop.circle")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        CustomTextField(
                            label: "Full Name *",
                            placeholder: "Rahul Sharma",
                            text: $viewModel.donorName
                        )
                        
                        CustomTextField(
                            label: "Email Address *",
                            placeholder: "rahul@example.com",
                            text: $viewModel.donorEmail,
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            label: "Phone Number (Optional)",
                            placeholder: "9876543210",
                            text: $viewModel.donorPhone,
                            keyboardType: .phonePad
                        )
                        
                        Toggle(isOn: $viewModel.isRecurring) {
                            Text("Make this a monthly donation")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("Support this cause every month automatically")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.theme.primary))
                        .padding(.top, 8)
                        
                        Toggle(isOn: $viewModel.isAnonymous) {
                            Text("Make my donation anonymous")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("Hide my name on the Donor Wall")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.theme.primary))
                        .padding(.top, 8)
                    }
                    .cardStyle()
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    // Donate Button
                    PrimaryButton(
                        title: "Donate \(Formatters.formatCurrency(amount: viewModel.finalAmount))",
                        isLoading: viewModel.isLoading,
                        isEnabled: viewModel.isFormValid
                    ) {
                        Task {
                            await viewModel.initiateDonation()
                        }
                    }
                    .padding(.bottom, 24)
                    
                } else {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer(minLength: 40)
                        
                        ZStack {
                            Circle()
                                .fill(Color(uiColor: .systemGray5))
                                .frame(width: 100, height: 100)
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("No Active Causes")
                            .font(.title2).bold()
                        
                        Text("There are no fundraising causes active at the moment.\nPlease check back soon.")
                            .bodyTextStyle()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button {
                            Task { await viewModel.fetchCause(id: causeId) }
                        } label: {
                            Label("Retry", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.theme.primary)
                        
                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Support Cause")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.fetchCause(id: causeId)
            }
        }
        .fullScreenCover(isPresented: $viewModel.isThankYouActive) {
            if let result = viewModel.verificationResult {
                ThankYouView(donationId: result.donation_id, amount: viewModel.completedAmount)
            }
        }
    }
}

struct DonationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DonationView(causeId: UUID())
        }
    }
}
