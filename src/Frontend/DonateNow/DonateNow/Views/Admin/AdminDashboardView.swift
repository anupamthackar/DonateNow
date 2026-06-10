import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var authService = AuthService.shared
    @State private var animateStats = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Area
                VStack(alignment: .leading, spacing: 6) {
                    Text("OVERVIEW")
                        .font(.caption2.bold())
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundColor(Color.theme.primary)
                    
                    Text("Admin Dashboard")
                        .font(.title).bold()
                        .foregroundColor(.primary)
                    
                    Text("Real-time fundraising metrics & logs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 12)
                
                if viewModel.isLoading && viewModel.totalCount == 0 {
                    // Shimmer Skeleton for Metrics
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .frame(height: 120)
                                .shimmer()
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .frame(height: 120)
                                .shimmer()
                        }
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(height: 80)
                            .shimmer()
                    }
                    .padding(.horizontal)
                } else {
                    // Main Analytics Grid
                    HStack(spacing: 16) {
                        // Card 1: Total Funds (Gradient)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "indianrupeesign.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("TOTAL FUNDS")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Text(Formatters.formatCurrency(amount: viewModel.totalAmount))
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .padding(18)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.primary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.theme.primary.opacity(0.25), radius: 12, x: 0, y: 6)
                        .scaleEffect(animateStats ? 1.0 : 0.95)
                        .opacity(animateStats ? 1.0 : 0.0)
                        
                        // Card 2: Total Count
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.text.square.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Spacer()
                                Text("DONATIONS")
                                    .font(.caption2.bold())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(viewModel.totalCount)")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        .padding(18)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                        .scaleEffect(animateStats ? 1.0 : 0.95)
                        .opacity(animateStats ? 1.0 : 0.0)
                    }
                    .padding(.horizontal)
                    
                    if let error = viewModel.errorMessage {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Quick Operations Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OPERATIONS")
                            .font(.caption2.bold())
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        NavigationLink {
                            DonorLogView()
                        } label: {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.theme.primary.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                                            .foregroundColor(Color.theme.primary)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Donor Payment Logs")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.primary)
                                    
                                    Text("Analyze successful orders and donor records")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.fetchStats()
        }
        .task {
            await viewModel.fetchStats()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateStats = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        try? await authService.signOut()
                    }
                } label: {
                    Text("Logout")
                        .font(.footnote.bold())
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdminDashboardView()
    }
}
