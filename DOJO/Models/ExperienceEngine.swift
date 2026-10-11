import Foundation

// MARK: - Experience Award

struct ExperienceAward: Identifiable, Codable {

    let id: UUID
    let workoutID: UUID
    let activity: String
    let workoutDate: Date
    let baseXP: Int
    let multiplier: Double
    let earnedXP: Int
    let awardedAt: Date
}

// MARK: - Experience Engine

struct ExperienceEngine {

    // MARK: - Activity XP Rates

    static func xpPerMinute(
        for activity: String
    ) -> Double {

        switch activity {

        case "Walking",
             "Elliptical",
             "Yoga",
             "Pilates",
             "Flexibility",
             "Cooldown":
            return 1.0

        case "Strength Training",
             "Functional Training",
             "Cycling",
             "Hiking",
             "Rowing",
             "Stair Climbing":
            return 1.5

        case "Running",
             "Basketball",
             "Swimming":
            return 1.8

        case "Martial Arts",
             "Boxing",
             "Kickboxing",
             "HIIT":
            return 2.0

        default:
            return 1.0
        }
    }

    // MARK: - Base XP

    static func calculateBaseXP(
        for workout: DOJOWorkout
    ) -> Int {

        guard workout.durationMinutes > 0 else {
            return 0
        }

        let rawXP =
            Double(workout.durationMinutes)
            * xpPerMinute(for: workout.activity)

        guard rawXP.isFinite else {
            return 0
        }

        return Int(
            min(
                rawXP.rounded(),
                Double(Int.max - 1)
            )
        )
    }

    // MARK: - Final XP

    static func calculateXP(
        for workout: DOJOWorkout,
        belt: BeltRank
    ) -> Int {

        let baseXP = calculateBaseXP(
            for: workout
        )

        guard baseXP > 0 else {
            return 0
        }

        let adjustedXP =
            Double(baseXP) * belt.xpMultiplier

        guard adjustedXP.isFinite else {
            return 0
        }

        return Int(
            min(
                adjustedXP.rounded(),
                Double(Int.max - 1)
            )
        )
    }

    // MARK: - Create Award

    static func createAward(
        for workout: DOJOWorkout,
        belt: BeltRank
    ) -> ExperienceAward {

        let baseXP = calculateBaseXP(
            for: workout
        )

        return ExperienceAward(
            id: UUID(),
            workoutID: workout.id,
            activity: workout.activity,
            workoutDate: workout.date,
            baseXP: baseXP,
            multiplier: belt.xpMultiplier,
            earnedXP: calculateXP(
                for: workout,
                belt: belt
            ),
            awardedAt: Date()
        )
    }
}
