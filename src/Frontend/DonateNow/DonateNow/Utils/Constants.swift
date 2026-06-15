import Foundation

enum Constants {
    static var supabaseURL: URL {
        guard var urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            fatalError("SUPABASE_URL missing in Info.plist")
        }
        
        // Trim whitespaces
        urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If Xcode stripped out the '//' and the rest of the line as a comment,
        // the string might literally just be 'https:' or 'https:/'
        if urlString == "https:" || urlString == "https:/" || urlString.isEmpty {
            urlString = "https://gqubhatlrjfcxrrywsjr.supabase.co"
        } else if urlString.contains("https:") && !urlString.contains("https://") {
            urlString = urlString.replacingOccurrences(of: "https:", with: "https://")
        } else if !urlString.contains("://") {
            urlString = "https://" + urlString
        }
        
        guard let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL invalid: \(urlString)")
        }
        return url
    }
    
    static var supabaseAnonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY missing in Info.plist")
        }
        return key
    }
    
    static var razorpayKeyID: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "RAZORPAY_KEY_ID") as? String,
              !key.isEmpty else {
            return "rzp_test_dummyKey12345"
        }
        if key == "$(RAZORPAY_KEY_ID)" {
            return "rzp_test_dummyKey12345"
        }
        return key
    }
}
