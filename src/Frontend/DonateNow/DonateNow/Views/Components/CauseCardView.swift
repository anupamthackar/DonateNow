import SwiftUI

struct CauseCardView: View {
    let cause: DonationProfile
    @State private var animatedProgress: CGFloat = 0.0
    
    var progress: Double {
        if cause.targetAmount > 0 {
            let raised = Double(truncating: cause.raisedAmount as NSNumber)
            let target = Double(truncating: cause.targetAmount as NSNumber)
            return min(raised / target, 1.0)
        }
        return 0
    }
    
    var progressPercentageString: String {
        let pct = Int(progress * 100)
        return "\(pct)%"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title & Description
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(cause.title)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Progress Badge
                    Text(progressPercentageString)
                        .font(.caption.bold())
                        .foregroundColor(Color.theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.theme.primary.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(cause.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Progress Bar & Figures
            VStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * animatedProgress, height: 8)
                            .shadow(color: Color.theme.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 8)
                
                // Figures
                Text("\(Formatters.formatCurrency(amount: cause.raisedAmount)) collected from \(Formatters.formatCurrency(amount: cause.targetAmount)) goal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .cardStyle(backgroundColor: Color(uiColor: .secondarySystemBackground), cornerRadius: 20)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animatedProgress = CGFloat(progress)
            }
        }
    }
}
