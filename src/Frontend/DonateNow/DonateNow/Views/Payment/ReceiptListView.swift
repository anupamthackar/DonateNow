import SwiftUI

struct ReceiptListView: View {
    @State private var receipts: [TaxReceipt] = []
    @State private var isLoading: Bool = true
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading tax receipts...")
                } else if receipts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No 80G receipts found.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(receipts) { receipt in
                            NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Receipt \(receipt.receiptNumber)")
                                            .font(.headline)
                                        Text("₹\(receipt.amount.description) to \(receipt.ngoName)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        Text(receipt.createdAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tax Receipts")
            .onAppear(perform: loadReceipts)
        }
    }
    
    private func loadReceipts() {
        isLoading = true
        Task {
            do {
                // Mock fetching
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    self.receipts = [
                        TaxReceipt(id: UUID(), donationId: UUID(), receiptNumber: "DN-2023-00123", pdfUrl: "https://example.com/pdf", ngoName: "DonateNow Foundation", ngo80gNumber: "DEL/80G/123", financialYear: "2023-2024", amount: 5000, donorName: "John Doe", createdAt: Date())
                    ]
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

#Preview {
    ReceiptListView()
}
