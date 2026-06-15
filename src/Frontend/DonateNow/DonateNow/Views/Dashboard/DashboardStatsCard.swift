import SwiftUI

struct DashboardStatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .bold()
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HStack {
        DashboardStatsCard(title: "Total Raised", value: "₹50,000", icon: "indianrupesign.circle.fill", color: .green)
        DashboardStatsCard(title: "Donors", value: "124", icon: "person.2.fill", color: .blue)
    }
    .padding()
    .background(Color(.systemGray6))
}
