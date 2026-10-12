import SwiftUI

struct LifetimeGrowthView: View {

    let growthPercentage: Double

    var body: some View {
        HStack(spacing: 8) {

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.caption2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 3) {

                Text("LIFETIME GROWTH")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Text(String(format: "%+.1f%%", growthPercentage))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.green)
                    .monospacedDigit()
            }

            Spacer()

            Text("A little better, every day.")
                .font(.system(size: 9))
                .italic()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.035))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        LifetimeGrowthView(growthPercentage: 27.4)
            .padding()
    }
    .preferredColorScheme(.dark)
}
