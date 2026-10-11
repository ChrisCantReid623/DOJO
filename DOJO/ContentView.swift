import SwiftUI

struct ContentView: View {

    // MARK: - Shared State

    @StateObject private var healthKit =
        HealthKitManager()

    @StateObject private var progressionStore =
        ProgressionStore()

    @State private var dailyQuest: TrainingQuest =
        TrainingQuest(
            title: "Establish Your Baseline",
            description: "Sync Apple Health to unlock your adaptive training quest.",
            durationMinutes: 0,
            experiencePoints: 0,
            icon: "heart.text.square"
        )

    // MARK: - Main Navigation

    var body: some View {

        TabView {

            dojoPage
                .tabItem {
                    Label(
                        "DOJO",
                        systemImage: "house.fill"
                    )
                }

            trainingPage
                .tabItem {
                    Label(
                        "Training",
                        systemImage: "figure.strengthtraining.traditional"
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
        .onAppear {
            refreshDailyQuest()
        }
        .onChange(
            of: healthKit.lastSuccessfulSync
        ) { _, newValue in

            guard let synchronizedAt = newValue else {
                return
            }

            progressionStore.processWorkouts(
                healthKit.recentWorkouts,
                synchronizedAt: synchronizedAt
            )

            refreshDailyQuest()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.significantTimeChangeNotification
            )
        ) { _ in
            refreshDailyQuest()
        }
    }

    // MARK: - SNSY Quest Generation

    private func refreshDailyQuest() {

        let recommendation =
            SNSYEngine.shared.dailyRecommendation(
                from: healthKit.recentWorkouts,
                hasSynced: healthKit.syncState.hasCompletedSync
            )

        dailyQuest = TrainingQuest(
            recommendation: recommendation
        )
    }

    // MARK: - PAGE 1 - DOJO

    private var dojoPage: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 14) {

                    dojoHeader

                    BeltRankView(
                        progression:
                            progressionStore.progression
                    )

                    experienceSummary

                    Text(
                        "Train for today. Improve for tomorrow. Measure over a lifetime."
                    )
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
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

    // MARK: - PAGE 2 - TRAINING

    private var trainingPage: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 14) {

                    trainingHeader

                    TrainingQuestView(
                        quest: dailyQuest
                    )
                    .frame(maxWidth: .infinity)

                    TodaysActivityView(
                        todaySteps: healthKit.todaySteps,
                        recentWorkouts:
                            healthKit.recentWorkouts,
                        hasSynced:
                            healthKit.syncState.hasCompletedSync
                    )
                    .frame(maxWidth: .infinity)

                    RecentTrainingDaysView(
                        recentWorkouts:
                            healthKit.recentWorkouts,
                        hasSynced:
                            healthKit.syncState.hasCompletedSync
                    )
                    .frame(maxWidth: .infinity)

                    Text(
                        "Consistency builds discipline. Discipline builds mastery."
                    )
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .background(
                Color.black.ignoresSafeArea()
            )
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                syncToolbarButton
            }
        }
    }

    // MARK: - PAGE 3 - PERFORMANCE

    private var performancePage: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 14) {

                    performanceHeader

                    PerformanceChartView()

                    activitySection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
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

    // MARK: - Compact Headers

    private var dojoHeader: some View {
        compactHeader(
            title: "DOJO",
            subtitle: "THE LONG GAME"
        )
    }

    private var trainingHeader: some View {
        compactHeader(
            title: "TRAINING",
            subtitle: "THE DAILY DISCIPLINE"
        )
    }

    private var performanceHeader: some View {
        compactHeader(
            title: "PERFORMANCE",
            subtitle: "MEASURE THE LONG GAME"
        )
    }

    private func compactHeader(
        title: String,
        subtitle: String
    ) -> some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(
                        .system(
                            size: 28,
                            weight: .bold
                        )
                    )
                    .tracking(2)

                Text(subtitle)
                    .font(.system(size: 10))
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Experience Engine Card

    private var experienceSummary: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)

                Text("EXPERIENCE ENGINE")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            Divider()
                .overlay(
                    Color.white.opacity(0.08)
                )

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text("TOTAL XP")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(
                        progressionStore.progression
                            .totalXP.formatted()
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 5
                ) {

                    Text("WORKOUTS REWARDED")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(
                        "\(progressionStore.awards.count)"
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                }
            }

            if let summary =
                progressionStore.lastSyncSummary {

                Divider()
                    .overlay(
                        Color.white.opacity(0.08)
                    )

                HStack {

                    Text("Last Sync Rewards")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(
                        "+\(summary.earnedXP.formatted()) XP"
                    )
                    .foregroundStyle(.green)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)

                if summary.levelsGained > 0 {

                    Text(
                        "LEVEL UP! +\(summary.levelsGained) levels"
                    )
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
                }
            }

            if progressionStore.enrollmentDate == nil {

                Text(
                    "Your first successful sync establishes your workout baseline."
                )
                .font(.caption)
                .foregroundStyle(.secondary)

            } else if let enrollmentDate =
                progressionStore.enrollmentDate {

                Text(
                    "Enrolled: \(enrollmentDate.formatted(date: .abbreviated, time: .shortened))"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
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

    // MARK: - Shared HealthKit Sync Button

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

                    Image(systemName: "arrow.clockwise")
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

    // MARK: - Apple Health Activity

    private var activitySection: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

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

                    Image(systemName: "heart.text.square")
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
        .frame(maxWidth: .infinity)
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
