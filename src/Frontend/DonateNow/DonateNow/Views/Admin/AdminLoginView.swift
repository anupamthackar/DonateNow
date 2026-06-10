import SwiftUI

struct AdminLoginView: View {
    @StateObject private var viewModel = AdminAuthViewModel()
    @State private var animateIcon = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.primary.opacity(0.15), Color.theme.primary.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.primary.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(animateIcon ? 1.0 : 0.8)
                            .opacity(animateIcon ? 1 : 0)
                    }
                    .padding(.top, 40)
                    
                    Text("Admin Portal")
                        .font(.title).bold()
                        .foregroundColor(.primary)
                        
                    Text("Sign in to access donor analytics,\ndashboards, and transaction logs.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                
                // Login Form Card
                VStack(spacing: 20) {
                    CustomTextField(
                        label: "Email Address",
                        placeholder: "admin@donatenow.org",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .formLabelStyle()
                            .foregroundColor(.secondary)
                        
                        SecureField("Enter your password", text: $viewModel.password)
                            .padding(14)
                            .background(Color(uiColor: .systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .cardStyle()
                .padding(.horizontal)
                
                // Error Message
                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
                
                // Submit Button
                PrimaryButton(
                    title: "Sign In",
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isFormValid
                ) {
                    Task {
                        _ = await viewModel.login()
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Admin Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                animateIcon = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdminLoginView()
    }
}
