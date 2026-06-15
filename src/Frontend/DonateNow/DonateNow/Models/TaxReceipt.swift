import Foundation

struct TaxReceipt: Codable, Identifiable {
    let id: UUID
    let donationId: UUID
    let receiptNumber: String
    let pdfUrl: String
    let ngoName: String
    let ngo80gNumber: String
    let financialYear: String
    let amount: Decimal
    let donorName: String
    let createdAt: Date
    
    // Optional joined data
    var campaignTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case donationId = "donation_id"
        case receiptNumber = "receipt_number"
        case pdfUrl = "pdf_url"
        case ngoName = "ngo_name"
        case ngo80gNumber = "ngo_80g_number"
        case financialYear = "financial_year"
        case amount
        case donorName = "donor_name"
        case createdAt = "created_at"
    }
}
