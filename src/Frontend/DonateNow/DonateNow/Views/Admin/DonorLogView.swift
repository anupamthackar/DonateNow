import SwiftUI

struct DonorLogView: View {
    @StateObject private var viewModel = DonorLogViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar & Filter Toggle
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search donor name or email", text: $viewModel.searchText)
                            .focused($isSearchFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: viewModel.searchText) { _, _ in
                                Task { await viewModel.fetchDonations() }
                            }
                        
                        if !viewModel.searchText.isEmpty {
                            Button {
                                viewModel.searchText = ""
                                isSearchFocused = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSearchFocused ? Color.theme.primary.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                    
                    // Filter Toggle Button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.isFilterActive.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.isFilterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(viewModel.isFilterActive ? Color.theme.primary : .secondary)
                            .padding(10)
                            .background(viewModel.isFilterActive ? Color.theme.primary.opacity(0.1) : Color.clear)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                
                // Expandable Date Filter Panel
                if viewModel.isFilterActive {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Filter by Date Range")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        DatePicker("From Date", selection: $viewModel.startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .font(.subheadline)
                        
                        DatePicker("To Date", selection: $viewModel.endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .font(.subheadline)
                        
                        Button {
                            Task { await viewModel.fetchDonations() }
                        } label: {
                            Text("Apply Date Filter")
                                .font(.footnote.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(
                                        colors: [Color.theme.primary, Color.theme.primary.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemBackground))
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
            
            // Content
            if viewModel.isLoading && viewModel.donations.isEmpty {
                // Shimmer Loading States
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { _ in
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color(uiColor: .secondarySystemBackground))
                                    .frame(width: 44, height: 44)
                                    .shimmer()
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                        .frame(width: 140, height: 16)
                                        .shimmer()
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                        .frame(width: 180, height: 12)
                                        .shimmer()
                                }
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                                    .frame(width: 70, height: 16)
                                    .shimmer()
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground).opacity(0.4))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                }
            } else if let error = viewModel.errorMessage {
                // Error State
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Failed to Load Logs")
                        .font(.headline)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        Task { await viewModel.fetchDonations() }
                    } label: {
                        Text("Retry")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.theme.primary)
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.donations.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                    
                    Text(viewModel.searchText.isEmpty ? "No Donations Yet" : "No Matches Found")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.searchText.isEmpty ? "Transactions will appear here once donors complete payments." : "Try adjusting your spelling or dates.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    if !viewModel.searchText.isEmpty {
                        Button("Clear Search") {
                            withAnimation {
                                viewModel.searchText = ""
                            }
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(Color.theme.primary)
                        .padding(.top, 8)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                // Donation Logs Scroll List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.donations) { donation in
                            DonationLogCard(donation: donation)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                }
                .refreshable {
                    await viewModel.fetchDonations()
                }
            }
        }
        .navigationTitle("Donor Logs")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchDonations()
        }
    }
}

// Custom log row card view
struct DonationLogCard: View {
    let donation: Donation
    
    var statusColor: Color {
        switch donation.status.lowercased() {
        case "completed":
            return .green
        case "pending", "initiated":
            return .orange
        case "failed":
            return .red
        default:
            return .secondary
        }
    }
    
    // Generate initials for the avatar
    var initials: String {
        let parts = donation.donorName.split(separator: " ")
        if let first = parts.first?.first {
            if parts.count > 1, let last = parts.last?.first {
                return "\(first)\(last)".uppercased()
            }
            return String(first).uppercased()
        }
        return "?"
    }
    
    // Semi-random background colors based on donor name hash
    var avatarColor: Color {
        let colors: [Color] = [.blue, .purple, .orange, .pink, .teal, .indigo, Color.theme.primary]
        let index = abs(donation.donorName.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Circular Initial Avatar
            Text(initials)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [avatarColor, avatarColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: avatarColor.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // Donor details
            VStack(alignment: .leading, spacing: 4) {
                Text(donation.donorName)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                Text(donation.donorEmail)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Text(Formatters.formatDate(donation.createdAt))
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                    
                    if let phone = donation.donorPhone, !phone.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 8))
                            Text(phone)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            // Amount and status badge
            VStack(alignment: .trailing, spacing: 6) {
                Text(Formatters.formatCurrency(amount: donation.amount))
                    .font(.subheadline.bold())
                    .foregroundColor(Color.theme.primary)
                
                Text(donation.status.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.12))
                    .cornerRadius(4)
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        DonorLogView()
    }
}
