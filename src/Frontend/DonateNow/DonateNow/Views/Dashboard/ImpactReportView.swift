import SwiftUI

struct ImpactReportView: View {
    let campaignId: UUID
    @State private var reports: [ImpactReport] = []
    @State private var isGenerating: Bool = false
    @State private var isLoading: Bool = true
    
    private let reportService = ImpactReportService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Generate New Button
            Button(action: generateNewReport) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate AI Report")
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
            .disabled(isGenerating)
            
            Divider()
            
            if isLoading {
                Spacer()
                ProgressView("Loading past reports...")
                Spacer()
            } else if reports.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No reports generated yet.")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                List(reports) { report in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(report.generatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                                .font(.caption)
                        }
                        
                        Text(report.content)
                            .font(.subheadline)
                            .lineSpacing(4)
                        
                        HStack {
                            Spacer()
                            ShareLink(item: report.content) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Update")
                                }
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color.theme.primary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Impact Reports")
        .onAppear(perform: loadReports)
    }
    
    private func loadReports() {
        isLoading = true
        Task {
            do {
                let fetched = try await reportService.getReports(campaignId: campaignId)
                await MainActor.run {
                    self.reports = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func generateNewReport() {
        isGenerating = true
        Task {
            do {
                let newReport = try await reportService.generateReport(campaignId: campaignId, startDate: nil, endDate: nil)
                await MainActor.run {
                    self.reports.insert(newReport, at: 0)
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run { self.isGenerating = false }
            }
        }
    }
}
