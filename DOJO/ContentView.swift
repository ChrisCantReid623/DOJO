import SwiftUI

struct ContentView: View {

    @StateObject private var healthKit = HealthKitManager()

    private let progression = ProgressionModel.preview

    @State private var hasSynced = false

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    // MARK: - DOJO Header

                    VStack(spacing: 6) {

                        Image(systemName: "figure.martial.arts")
                            .font(.system(size: 36))
                            .foregroundStyle(.orange)

                        Text("DOJO")
                            .font(.system(size: 32, weight: .bold))
                            .tracking(4)

                        Text("THE LONG GAME")
                            .font(.caption)
                            .tracking(3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                    // MARK: - Belt Rank

                    BeltRankView(progression: progression)

                    // MARK: - Lifetime Growth

                    LifetimeGrowthView(growthPercentage: 27.4)

                    // MARK: - Performance Chart

                    PerformanceChartView()

                    // MARK: - Training Quest

                    TrainingQuestView(quest: .preview)

                    // MARK: - Activity Dashboard

                    activitySection

                    // MARK: - Footer

                    Text("Train for today. Improve for tomorrow. Measure over a lifetime.")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - Apple Health Sync

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button {
                        hasSynced = true
                        healthKit.requestAuthorization()
                    } label: {

                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.orange)
                    }
                    .accessibilityLabel("Sync Apple Health")
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Activity Section

    private var activitySection: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack {

                Image(systemName: "heart.text.square")
                    .foregroundStyle(.orange)

                Text("APPLE HEALTH ACTIVITY")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            if hasSynced {

                VStack(spacing: 14) {

                    activityRow(
                        "Steps Today",
                        healthKit.todaySteps.formatted()
                    )

                    activityRow(
                        "Weekly Steps",
                        healthKit.weeklyTotalSteps.formatted()
                    )

                    activityRow(
                        "Daily Average",
                        healthKit.weeklyAverageSteps.formatted()
                    )

                    activityRow(
                        "Active Days",
                        "\(healthKit.activeDays) / 7"
                    )

                    activityRow(
                        "Recent Workouts",
                        "\(healthKit.totalRecordedWorkouts)"
                    )

                    activityRow(
                        "Workout Minutes",
                        "\(healthKit.totalWorkoutMinutes)"
                    )
                }

                Text(healthKit.statusMessage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

            } else {

                VStack(spacing: 12) {

                    Image(systemName: "heart.text.square")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)

                    Text("Activity Not Synced")
                        .font(.headline)

                    Text("Tap the sync icon above to load your Apple Health activity.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
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

    // MARK: - Reusable Activity Row

    private func activityRow(
        _ title: String,
        _ value: String
    ) -> some View {

        HStack {

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
