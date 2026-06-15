import SwiftUI

struct TaxReceiptListView: View {
    @StateObject private var viewModel = TaxReceiptViewModel()
    @State private var selectedPDF: PDFURLWrapper?
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading your receipts...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if viewModel.receipts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No tax receipts found.")
                        .font(.headline)
                    Text("Your 80G tax receipts will appear here after your donations are verified.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                List {
                    ForEach(viewModel.receipts) { receipt in
                        ReceiptRowView(receipt: receipt) { pdfURL in
                            self.selectedPDF = PDFURLWrapper(url: pdfURL)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Tax Receipts (80G)")
        .task {
            await viewModel.fetchMyReceipts()
        }
        .sheet(item: $selectedPDF) { wrapper in
            ShareSheet(activityItems: [wrapper.url])
        }
    }
}

struct PDFURLWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

struct ReceiptRowView: View {
    let receipt: TaxReceipt
    let onDownload: (URL) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Receipt #\(receipt.receiptNumber)")
                    .font(.headline)
                
                Text(formatDate(receipt.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                if let pdfURL = PDFGenerator.generateReceipt(for: receipt) {
                    onDownload(pdfURL)
                }
            }) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
