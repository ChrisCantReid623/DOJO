import SwiftUI

struct BeltRankView: View {

    let progression: ProgressionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .center, spacing: 20) {

                // MARK: - Belt Emblem

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 100, height: 100)

                    Circle()
                        .stroke(
                            Color.yellow.opacity(0.8),
                            lineWidth: 2
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "figure.martial.arts")
                        .font(.system(size: 44))
                        .foregroundStyle(progression.currentBelt.color)
                }

                // MARK: - Rank Information

                VStack(alignment: .leading, spacing: 8) {

                    Text("CURRENT RANK")
                        .font(.caption2)
                        .tracking(3)
                        .foregroundStyle(.secondary)

                    Text(progression.currentBelt.title.uppercased())
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Novice • Level \(progression.level)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            // MARK: - XP Progress

            VStack(alignment: .leading, spacing: 8) {

                HStack {
                    Text("Rank Progress")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(progression.currentXP) / \(progression.requiredXP) XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {

                        Capsule()
                            .fill(Color.white.opacity(0.12))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * progression.progress
                            )
                    }
                }
                .frame(height: 10)

                if let nextRank = progression.currentBelt.nextRank {
                    Text("Next Rank: \(nextRank.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Highest Belt Achieved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        BeltRankView(progression: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
