import SwiftUI

struct ContentView: View {

    // MARK: - Shared State

    @StateObject private var healthKit = HealthKitManager()

    private let progression = ProgressionModel.preview

    // MARK: - Navigation

    var body: some View {

        TabView {

            homePage
                .tabItem {
                    Label(
                        "DOJO",
                        systemImage: "house.fill"
                    )
                }

            performancePage
                .tabItem {
                    Label(
                        "Performance",
                        systemImage: "chart.xyaxis.line"
                    )
                }
        }
        .tint(.orange)
        .preferredColorScheme(.dark)
    }

    // MARK: - Page 1: DOJO Home

    private var homePage: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    dojoHeader

                    BeltRankView(
                        progression: progression
                    )

                    TrainingQuestView(
                        quest: .preview
                    )

                    HStack(
                        alignment: .top,
                        spacing: 12
                    ) {

                        TodaysActivityView(
                            todaySteps: healthKit.todaySteps,
                            recentWorkouts: healthKit.recentWorkouts,
                            hasSynced: healthKit.syncState.hasCompletedSync
                        )

                        RecentTrainingDaysView(
                            recentWorkouts: healthKit.recentWorkouts,
                            hasSynced: healthKit.syncState.hasCompletedSync
                        )
                    }

                    Text(
                        "Train for today. Improve for tomorrow. Measure over a lifetime."
                    )
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                }
                .padding()
            }
            .background(
                Color.black.ignoresSafeArea()
            )
            .navigationTitle("DOJO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                syncToolbarButton
            }
        }
    }

    // MARK: - Page 2: Performance

    private var performancePage: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    VStack(spacing: 6) {

                        Image(
                            systemName: "chart.line.uptrend.xyaxis"
                        )
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)

                        Text("PERFORMANCE")
                            .font(
                                .system(
                                    size: 28,
                                    weight: .bold
                                )
                            )
                            .tracking(3)

                        Text("MEASURE THE LONG GAME")
                            .font(.caption)
                            .tracking(2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                    PerformanceChartView()

                    activitySection
                }
                .padding()
            }
            .background(
                Color.black.ignoresSafeArea()
            )
            .navigationTitle("Performance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                syncToolbarButton
            }
        }
    }

    // MARK: - DOJO Header

    private var dojoHeader: some View {

        VStack(spacing: 6) {

            Image(
                systemName: "figure.martial.arts"
            )
            .font(.system(size: 36))
            .foregroundStyle(.orange)

            Text("DOJO")
                .font(
                    .system(
                        size: 32,
                        weight: .bold
                    )
                )
                .tracking(4)

            Text("THE LONG GAME")
                .font(.caption)
                .tracking(3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    // MARK: - Shared Sync Button

    private var syncToolbarButton: some ToolbarContent {

        ToolbarItem(
            placement: .topBarTrailing
        ) {

            Button {

                healthKit.requestAuthorization()

            } label: {

                if healthKit.syncState.isSyncing {

                    ProgressView()
                        .tint(.orange)

                } else {

                    Image(
                        systemName: "arrow.clockwise"
                    )
                    .foregroundStyle(.orange)
                }
            }
            .disabled(
                healthKit.syncState.isSyncing
            )
            .accessibilityLabel(
                "Sync Apple Health"
            )
        }
    }

    // MARK: - Apple Health Activity Section

    private var activitySection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            HStack {

                Image(
                    systemName: "heart.text.square"
                )
                .foregroundStyle(.orange)

                Text("APPLE HEALTH ACTIVITY")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            if healthKit.syncState.isSyncing {

                VStack(spacing: 12) {

                    ProgressView()
                        .tint(.orange)

                    Text("Synchronizing Apple Health...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

            } else if healthKit.syncState.hasCompletedSync {

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
                        "Recent Workouts (90 Days)",
                        "\(healthKit.totalRecordedWorkouts)"
                    )

                    activityRow(
                        "Workout Minutes (90 Days)",
                        "\(healthKit.totalWorkoutMinutes)"
                    )
                }

                if let lastSync =
                    healthKit.lastSuccessfulSync {

                    Text(
                        "Last updated: \(lastSync.formatted(date: .abbreviated, time: .shortened))"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

            } else {

                VStack(spacing: 12) {

                    Image(
                        systemName: "heart.text.square"
                    )
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                    Text(healthKit.syncState.title)
                        .font(.headline)

                    Text(healthKit.statusMessage)
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
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                Color.white.opacity(0.05)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20
            )
            .stroke(
                Color.white.opacity(0.08),
                lineWidth: 1
            )
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
