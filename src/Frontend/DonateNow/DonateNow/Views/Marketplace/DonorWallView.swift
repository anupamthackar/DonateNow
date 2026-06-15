import SwiftUI

struct DonorWallView: View {
    let campaignId: UUID
    @StateObject private var viewModel = DonorWallViewModel()
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading contributors...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if viewModel.donors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No donors yet.")
                        .font(.headline)
                    Text("Be the first to support this cause!")
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(viewModel.donors) { donor in
                        DonorRowView(donor: donor)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Donor Wall")
        .task {
            await viewModel.fetchDonors(for: campaignId)
        }
    }
}

struct DonorRowView: View {
    let donor: PublicDonor
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(initials)
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(displayName)
                        .font(.headline)
                    
                    if donor.isRecurring == true {
                        Text("Monthly")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                }
                
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(Formatters.formatCurrency(amount: donor.amount))
                .font(.subheadline)
                .bold()
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
    
    private var displayName: String {
        return donor.isAnonymous ? "Anonymous Donor" : donor.donorName
    }
    
    private var initials: String {
        if donor.isAnonymous { return "A" }
        let components = donor.donorName.components(separatedBy: " ")
        if let first = components.first?.first {
            if components.count > 1, let last = components.last?.first {
                return "\(first)\(last)".uppercased()
            }
            return String(first).uppercased()
        }
        return "?"
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: donor.createdAt, relativeTo: Date())
    }
}
