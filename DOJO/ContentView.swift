import SwiftUI

struct ContentView: View {

    // MARK: - HealthKit Manager

    @StateObject private var healthKit = HealthKitManager()

    // MARK: - Sorted Activity History

    private var sortedDays: [Date] {
        healthKit.weeklySteps.keys.sorted()
    }

    // MARK: - Main View

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    // MARK: - Header

                    VStack(spacing: 8) {

                        Image(systemName: "figure.martial.arts")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)

                        Text("DOJO")
                            .font(.largeTitle)
                            .bold()

                        Text("Your Personal Training Agent")
                            .foregroundStyle(.secondary)
                    }

                    // MARK: - Today's Activity

                    GroupBox("Today's Activity") {

                        VStack(spacing: 12) {

                            Text(healthKit.todaySteps.formatted())
                                .font(
                                    .system(
                                        size: 48,
                                        weight: .bold
                                    )
                                )

                            Text("Steps Today")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }

                    // MARK: - Weekly Summary

                    GroupBox("Weekly Summary") {

                        VStack(spacing: 16) {

                            metricRow(
                                "Total Steps",
                                healthKit.weeklyTotalSteps.formatted()
                            )

                            metricRow(
                                "Daily Average",
                                healthKit.weeklyAverageSteps.formatted()
                            )

                            metricRow(
                                "Active Days (7,000+)",
                                "\(healthKit.activeDays) / 7"
                            )
                        }
                        .padding()
                    }

                    // MARK: - Seven-Day History

                    GroupBox("Seven-Day History") {

                        VStack(spacing: 12) {

                            if sortedDays.isEmpty {

                                Text("No activity history available")
                                    .foregroundStyle(.secondary)

                            } else {

                                ForEach(sortedDays, id: \.self) { date in

                                    HStack {

                                        Text(
                                            date.formatted(
                                                .dateTime.weekday(.wide)
                                            )
                                        )

                                        Spacer()

                                        Text(
                                            (healthKit.weeklySteps[date] ?? 0)
                                                .formatted()
                                        )
                                        .bold()
                                    }

                                    Divider()
                                }
                            }
                        }
                        .padding()
                    }

                    // MARK: - Workout Summary

                    GroupBox("Workout Summary") {

                        VStack(spacing: 16) {

                            metricRow(
                                "Recorded Workouts",
                                "\(healthKit.totalRecordedWorkouts)"
                            )

                            metricRow(
                                "Total Workout Minutes",
                                "\(healthKit.totalWorkoutMinutes)"
                            )

                            metricRow(
                                "Average Duration",
                                "\(healthKit.averageWorkoutMinutes) min"
                            )
                        }
                        .padding()
                    }

                    // MARK: - Recent Workouts

                    GroupBox("Recent Workouts") {

                        VStack(spacing: 16) {

                            if healthKit.recentWorkouts.isEmpty {

                                Text("No workouts available")
                                    .foregroundStyle(.secondary)

                            } else {

                                ForEach(healthKit.recentWorkouts) { workout in

                                    HStack(spacing: 12) {

                                        Image(
                                            systemName:
                                                "figure.strengthtraining.traditional"
                                        )
                                        .font(.title2)
                                        .foregroundStyle(.orange)

                                        VStack(
                                            alignment: .leading,
                                            spacing: 4
                                        ) {

                                            Text(workout.activity)
                                                .font(.headline)

                                            Text(
                                                workout.date.formatted(
                                                    date: .abbreviated,
                                                    time: .omitted
                                                )
                                            )
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Text(
                                            "\(workout.durationMinutes) min"
                                        )
                                        .bold()
                                    }

                                    Divider()
                                }
                            }
                        }
                        .padding()
                    }

                    // MARK: - HealthKit Status

                    Text(healthKit.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // MARK: - Sync Button

                    Button {

                        healthKit.requestAuthorization()

                    } label: {

                        Label(
                            "Sync Apple Health",
                            systemImage: "arrow.clockwise"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                }
                .padding()
            }
            .navigationTitle("Activity Dashboard")
        }
    }

    // MARK: - Reusable Metric Row

    private func metricRow(
        _ title: String,
        _ value: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(value)
                .bold()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
