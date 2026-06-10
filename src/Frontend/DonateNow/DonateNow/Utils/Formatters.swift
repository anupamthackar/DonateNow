import Foundation

struct Formatters {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN") // ₹ INR formatting
        return formatter
    }()
    
    static func formatCurrency(amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? "₹\(amount)"
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
