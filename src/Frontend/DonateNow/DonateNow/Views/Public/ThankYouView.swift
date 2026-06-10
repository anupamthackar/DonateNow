import SwiftUI

struct ThankYouView: View {
    let donationId: UUID
    let amount: Double
    @Environment(\.dismiss) private var dismiss
    
    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var pulseRings = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Animated Celebration Icon
            ZStack {
                // Pulsing rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.theme.primary.opacity(0.15), lineWidth: 2)
                        .frame(width: CGFloat(140 + index * 40), height: CGFloat(140 + index * 40))
                        .scaleEffect(pulseRings ? 1.1 : 0.9)
                        .opacity(pulseRings ? 0 : 0.6)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                            value: pulseRings
                        )
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.theme.primary.opacity(0.3), radius: 20, y: 8)
                    .scaleEffect(showCheckmark ? 1.0 : 0.3)
                    .opacity(showCheckmark ? 1 : 0)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showCheckmark ? 1.0 : 0.1)
                    .opacity(showCheckmark ? 1 : 0)
            }
            .padding(.bottom, 32)
            
            // Thank You Messages
            VStack(spacing: 10) {
                Text("Thank You! 🎉")
                    .font(.largeTitle).bold()
                    .foregroundColor(.primary)
                
                Text("Your generous donation of")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text(Formatters.formatCurrency(amount: amount))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("has been received successfully.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .padding(.bottom, 32)
            
            // Transaction Details Card
            VStack(spacing: 14) {
                HStack {
                    Label("Status", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer()
                    Text("Confirmed")
                        .font(.subheadline).bold()
                        .foregroundColor(Color.theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.theme.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transaction Reference")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(donationId.uuidString)
                        .font(.caption).monospaced()
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .cardStyle()
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // Back Button
            PrimaryButton(title: "Back to Donations") {
                dismiss()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .opacity(showContent ? 1 : 0)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: 600)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                showCheckmark = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                pulseRings = true
            }
        }
    }
}

#Preview {
    ThankYouView(donationId: UUID(), amount: 1500)
}
