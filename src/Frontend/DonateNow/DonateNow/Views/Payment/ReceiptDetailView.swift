import SwiftUI

struct ReceiptDetailView: View {
    let receipt: TaxReceipt
    @State private var isDownloading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Receipt Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("80G Tax Receipt")
                        .font(.title2)
                        .bold()
                    
                    Text(receipt.receiptNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Details Card
                VStack(spacing: 16) {
                    DetailRow(title: "Date", value: receipt.createdAt.formatted(date: .long, time: .omitted))
                    DetailRow(title: "Donor Name", value: receipt.donorName)
                    DetailRow(title: "Amount", value: "₹\(receipt.amount.description)")
                    DetailRow(title: "NGO", value: receipt.ngoName)
                    DetailRow(title: "80G Reg Number", value: receipt.ngo80gNumber)
                    DetailRow(title: "Financial Year", value: receipt.financialYear)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button(action: downloadPDF) {
                    if isDownloading {
                        ProgressView()
                    } else {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                            Text("Download PDF")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .bold()
                    }
                }
                .padding(.top, 10)
                
                Text("This receipt is valid for tax exemption under section 80G of the Income Tax Act.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func downloadPDF() {
        isDownloading = true
        // Simulate download
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isDownloading = false
            // In real app, open UIApplication.shared.open(url)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .multilineTextAlignment(.trailing)
        }
    }
}
