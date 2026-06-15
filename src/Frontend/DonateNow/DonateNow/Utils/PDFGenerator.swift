import Foundation
import UIKit
import PDFKit

class PDFGenerator {
    static func generateReceipt(for receipt: TaxReceipt) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "DonateNow App",
            kCGPDFContextAuthor: "DonateNow NGO",
            kCGPDFContextTitle: "80G Tax Receipt - \(receipt.receiptNumber)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 page size
        let pageWidth = 595.2
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Tax_Receipt_\(receipt.receiptNumber).pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { (context) in
                context.beginPage()
                
                // Background
                let bgRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
                context.cgContext.setFillColor(UIColor.white.cgColor)
                context.cgContext.fill(bgRect)
                
                // Header
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 28),
                    .foregroundColor: UIColor(red: 22/255, green: 163/255, blue: 74/255, alpha: 1.0)
                ]
                let titleText = receipt.ngoName.isEmpty ? "DonateNow NGO" : receipt.ngoName
                let titleSize = titleText.size(withAttributes: titleAttributes)
                let titleRect = CGRect(x: (pageWidth - titleSize.width) / 2.0, y: 50, width: titleSize.width, height: titleSize.height)
                titleText.draw(in: titleRect, withAttributes: titleAttributes)
                
                // Subtitle
                let subtitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.gray
                ]
                let subtitleText = "Official 80G Tax Exemption Receipt"
                let subtitleSize = subtitleText.size(withAttributes: subtitleAttributes)
                let subtitleRect = CGRect(x: (pageWidth - subtitleSize.width) / 2.0, y: 85, width: subtitleSize.width, height: subtitleSize.height)
                subtitleText.draw(in: subtitleRect, withAttributes: subtitleAttributes)
                
                // Divider
                let dividerRect = CGRect(x: 50, y: 120, width: pageWidth - 100, height: 1)
                context.cgContext.setFillColor(UIColor.lightGray.cgColor)
                context.cgContext.fill(dividerRect)
                
                // Receipt Details
                let bodyFont = UIFont.systemFont(ofSize: 14)
                let boldFont = UIFont.boldSystemFont(ofSize: 14)
                
                var cursorY: CGFloat = 150
                
                func drawLine(label: String, value: String) {
                    let labelRect = CGRect(x: 50, y: cursorY, width: 200, height: 20)
                    let valueRect = CGRect(x: 250, y: cursorY, width: pageWidth - 300, height: 20)
                    
                    label.draw(in: labelRect, withAttributes: [.font: bodyFont, .foregroundColor: UIColor.darkGray])
                    value.draw(in: valueRect, withAttributes: [.font: boldFont, .foregroundColor: UIColor.black])
                    
                    cursorY += 30
                }
                
                drawLine(label: "Receipt Number:", value: receipt.receiptNumber)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                drawLine(label: "Date:", value: dateFormatter.string(from: receipt.createdAt))
                
                drawLine(label: "Donor Name:", value: receipt.donorName)
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.currencyCode = "INR"
                let amountString = formatter.string(from: NSDecimalNumber(decimal: receipt.amount)) ?? "₹\(receipt.amount)"
                drawLine(label: "Donation Amount:", value: amountString)
                
                drawLine(label: "Financial Year:", value: receipt.financialYear)
                drawLine(label: "80G Approval Number:", value: receipt.ngo80gNumber)
                
                // Divider
                cursorY += 20
                let divRect2 = CGRect(x: 50, y: cursorY, width: pageWidth - 100, height: 1)
                context.cgContext.setFillColor(UIColor.lightGray.cgColor)
                context.cgContext.fill(divRect2)
                cursorY += 30
                
                // Footer message
                let footerText = "This receipt is valid for tax deduction under section 80G of the Income Tax Act.\nThank you for your generous contribution to \(titleText)."
                let footerRect = CGRect(x: 50, y: cursorY, width: pageWidth - 100, height: 100)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                paragraphStyle.lineSpacing = 6
                
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: paragraphStyle
                ]
                
                footerText.draw(in: footerRect, withAttributes: footerAttributes)
                
                // Signature placeholder
                let sigRect = CGRect(x: pageWidth - 200, y: pageHeight - 150, width: 150, height: 20)
                let sigParagraphStyle = NSMutableParagraphStyle()
                sigParagraphStyle.alignment = .center
                "Authorized Signatory".draw(in: sigRect, withAttributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black, .paragraphStyle: sigParagraphStyle])
            }
            return tempURL
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }
}
