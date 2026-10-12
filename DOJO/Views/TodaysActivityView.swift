import SwiftUI

struct TodaysActivityView: View {

    let todaySteps: Int
    let recentWorkouts: [DOJOWorkout]
    let hasSynced: Bool

    private var todaysWorkouts: [DOJOWorkout] {
        recentWorkouts.filter {
            Calendar.current.isDateInToday($0.date)
        }
    }

    private var workoutMinutes: Int {
        todaysWorkouts.reduce(0) {
            $0 + $1.durationMinutes
        }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 8) {

                Image(systemName: "figure.walk")
                    .foregroundStyle(.orange)

                Text("TODAY'S ACTIVITY")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .overlay(Color.white.opacity(0.08))

            activityMetric(
                icon: "shoeprints.fill",
                title: "Steps",
                value: hasSynced
                    ? todaySteps.formatted()
                    : "—"
            )

            activityMetric(
                icon: "figure.strengthtraining.traditional",
                title: "Workouts",
                value: hasSynced
                    ? "\(todaysWorkouts.count)"
                    : "—"
            )

            activityMetric(
                icon: "clock.fill",
                title: "Workout Min.",
                value: hasSynced
                    ? "\(workoutMinutes)"
                    : "—"
            )

            if !hasSynced {

                Text("Tap sync to load")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08))
        )
    }

    private func activityMetric(
        icon: String,
        title: String,
        value: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 5) {

            HStack(spacing: 6) {

                Image(systemName: icon)
                    .foregroundStyle(.orange)

                Text(title)
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 10))

            Text(value)
                .font(.system(size: 21, weight: .bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        TodaysActivityView(
            todaySteps: 0,
            recentWorkouts: [],
            hasSynced: false
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}
