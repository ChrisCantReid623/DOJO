import SwiftUI

struct RecentTrainingDaysView: View {

    let recentWorkouts: [DOJOWorkout]
    let hasSynced: Bool

    private let calendar = Calendar.current

    private var lastSevenDays: [Date] {

        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset - 6,
                to: today
            )
        }
    }

    private func hasWorkout(on date: Date) -> Bool {

        recentWorkouts.contains { workout in
            calendar.isDate(workout.date, inSameDayAs: date)
        }
    }

    private var trainingDayCount: Int {

        lastSevenDays.filter {
            hasWorkout(on: $0)
        }.count
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 8) {

                Image(systemName: "calendar")
                    .foregroundStyle(.orange)

                Text("RECENT TRAINING")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .overlay(Color.white.opacity(0.08))

            HStack(spacing: 3) {

                ForEach(lastSevenDays, id: \.self) { date in

                    VStack(spacing: 9) {

                        Text(
                            date.formatted(
                                .dateTime.weekday(.narrow)
                            )
                        )
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)

                        Circle()
                            .fill(
                                !hasSynced
                                    ? Color.gray.opacity(0.25)
                                    : hasWorkout(on: date)
                                        ? Color.green
                                        : Color.white.opacity(0.15)
                            )
                            .frame(width: 12, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Spacer(minLength: 0)

            Text(
                hasSynced
                    ? "\(trainingDayCount) / 7 training days"
                    : "Not synchronized"
            )
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)

            Text("Based on recorded workouts")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
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
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        RecentTrainingDaysView(
            recentWorkouts: [],
            hasSynced: false
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}
