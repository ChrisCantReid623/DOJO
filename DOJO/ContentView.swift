import SwiftUI

struct ContentView: View {

    // MARK: - Shared State

    @StateObject private var healthKit = HealthKitManager()

    @State private var hasSynced = false

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

                    // DOJO Branding

                    dojoHeader

                    // Belt Progression

                    BeltRankView(
                        progression: progression
                    )

                    // Daily Training Quest

                    TrainingQuestView(
                        quest: .preview
                    )

                    // Activity Overview

                    HStack(
                        alignment: .top,
                        spacing: 12
                    ) {

                        TodaysActivityView(
                            todaySteps: healthKit.todaySteps,
                            recentWorkouts: healthKit.recentWorkouts,
                            hasSynced: hasSynced
                        )

                        RecentTrainingDaysView(
                            recentWorkouts: healthKit.recentWorkouts,
                            hasSynced: hasSynced
                        )
                    }

                    // Philosophy

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

                    // Page Header

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

                    // Performance Chart

                    PerformanceChartView()

                    // Apple Health Activity

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

                hasSynced = true

                healthKit.requestAuthorization()

            } label: {

                Image(
                    systemName: "arrow.clockwise"
                )
                .foregroundStyle(.orange)
            }
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

                    Image(
                        systemName: "heart.text.square"
                    )
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)

                    Text("Activity Not Synced")
                        .font(.headline)

                    Text(
                        "Tap the sync icon above to load your Apple Health activity."
                    )
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
