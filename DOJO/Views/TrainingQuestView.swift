import SwiftUI

// MARK: - Training Quest Model

struct TrainingQuest {
    let title: String
    let description: String
    let durationMinutes: Int
    let experiencePoints: Int
    let icon: String

    static let preview = TrainingQuest(
        title: "The Daily Discipline",
        description: "Complete a 20-minute bodyweight workout.",
        durationMinutes: 20,
        experiencePoints: 25,
        icon: "figure.strengthtraining.functional"
    )
}

// MARK: - Training Quest View

struct TrainingQuestView: View {

    let quest: TrainingQuest

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            // MARK: - Header

            HStack {

                Image(systemName: "target")
                    .foregroundStyle(.orange)

                Text("TODAY'S TRAINING QUEST")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("DEMO")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            // MARK: - Quest Details

            HStack(alignment: .top, spacing: 16) {

                Image(systemName: quest.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
                    .frame(width: 55, height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.orange.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 8) {

                    Text(quest.title)
                        .font(.headline)

                    Text(quest.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {

                        Label(
                            "\(quest.durationMinutes) min",
                            systemImage: "clock"
                        )

                        Label(
                            "+\(quest.experiencePoints) XP",
                            systemImage: "star.fill"
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Divider()
                .overlay(Color.white.opacity(0.08))

            // MARK: - Scheduling Information

            HStack(spacing: 10) {

                Image(systemName: "calendar")
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {

                    Text("Adaptive Scheduling")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Calendar integration coming soon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Preview

#Preview {

    ZStack {

        Color.black.ignoresSafeArea()

        TrainingQuestView(quest: .preview)
            .padding()
    }
    .preferredColorScheme(.dark)
}
