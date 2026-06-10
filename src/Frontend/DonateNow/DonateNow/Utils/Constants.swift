import Foundation

enum Constants {
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL missing or invalid in Info.plist")
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
        guard let key = Bundle.main.object(forInfoDictionaryKey: "RAZORPAY_KEY_ID") as? String else {
            fatalError("RAZORPAY_KEY_ID missing in Info.plist")
        }
        return key
    }
}
