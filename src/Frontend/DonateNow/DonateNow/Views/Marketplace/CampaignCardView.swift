import SwiftUI

struct CampaignCardView: View {
    let campaign: DonationProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Campaign Image with proper loading states
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 180)
                
                if let urlString = campaign.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 180)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .transition(.opacity.animation(.easeIn(duration: 0.3)))
                        case .failure:
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(height: 180)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .frame(height: 180)
                }
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 12) {
                if let category = campaign.category {
                    Text(category.uppercased())
                        .font(.caption)
                        .bold()
                        .foregroundColor(Color.theme.primary)
                }
                
                Text(campaign.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(campaign.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                CampaignProgressBar(raised: campaign.raisedAmount, target: campaign.targetAmount)
                
                HStack {
                    Text(Formatters.formatCurrency(amount: campaign.raisedAmount))
                        .bold()
                    Text("raised of \(Formatters.formatCurrency(amount: campaign.targetAmount))")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .font(.footnote)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct CampaignProgressBar: View {
    let raised: Decimal
    let target: Decimal
    
    var percentage: Double {
        let raisedDouble = NSDecimalNumber(decimal: raised).doubleValue
        let targetDouble = NSDecimalNumber(decimal: target).doubleValue
        if targetDouble == 0 { return 0 }
        let calc = raisedDouble / targetDouble
        return min(calc, 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.2))
                
                Capsule()
                    .frame(width: geometry.size.width * CGFloat(percentage), height: 8)
                    .foregroundColor(Color.theme.primary)
                    .animation(.easeInOut(duration: 0.5), value: percentage)
            }
        }
        .frame(height: 8)
    }
}
