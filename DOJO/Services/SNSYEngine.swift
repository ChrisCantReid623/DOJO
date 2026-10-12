import Foundation

// MARK: - SNSY Training Engine

final class SNSYEngine {

    static let shared = SNSYEngine()

    private let storageKey = "dojo.snsy.dailyQuest.v0.6"

    private init() {}

    // MARK: - Generate or Retrieve Daily Quest

    func dailyRecommendation(
        from workouts: [DOJOWorkout],
        hasSynced: Bool
    ) -> TrainingRecommendation {

        let calendar = Calendar.current

        // Reuse today's existing quest.
        if let saved = loadRecommendation(),
           calendar.isDate(saved.date, inSameDayAs: Date()) {
            return saved
        }

        let recommendation: TrainingRecommendation

        if !hasSynced {

            recommendation = TrainingRecommendation(
                title: "Establish Your Baseline",
                description: "Sync Apple Health to unlock your adaptive training quest.",
                durationMinutes: 0,
                experiencePoints: 0,
                icon: "heart.text.square",
                reason: "SNSY needs your recorded activity before generating a personalized recommendation.",
                activityCategory: .general
            )

            // Do not persist an unsynchronized placeholder.
            return recommendation
        }

        let today = Date()

        let sevenDaysAgo = calendar.date(
            byAdding: .day,
            value: -7,
            to: today
        ) ?? today

        let recentWorkouts = workouts.filter {
            $0.date >= sevenDaysAgo && $0.date <= today
        }

        let lastWorkout = recentWorkouts.max {
            $0.date < $1.date
        }

        let strengthCount = recentWorkouts.filter {
            $0.activity == "Strength Training" ||
            $0.activity == "Functional Training"
        }.count

        let basketballCount = recentWorkouts.filter {
            $0.activity == "Basketball"
        }.count

        let martialArtsCount = recentWorkouts.filter {
            $0.activity == "Martial Arts" ||
            $0.activity == "Boxing" ||
            $0.activity == "Kickboxing"
        }.count

        let activeDates = Set(
            recentWorkouts.map {
                calendar.startOfDay(for: $0.date)
            }
        )

        let activeDayCount = activeDates.count

        // MARK: - Rule 1: Return to Training

        if let lastWorkout,
           let daysSince = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: lastWorkout.date),
                to: calendar.startOfDay(for: today)
           ).day,
           daysSince >= 3 {

            recommendation = TrainingRecommendation(
                title: "Return to Training",
                description: "Complete a 20-minute workout to rebuild momentum.",
                durationMinutes: 20,
                experiencePoints: 30,
                icon: "figure.strengthtraining.functional",
                reason: "Your most recent recorded workout was at least three calendar days ago.",
                activityCategory: .general
            )

        // MARK: - Rule 2: Recovery-Oriented Day

        } else if activeDayCount >= 3 {

            recommendation = TrainingRecommendation(
                title: "Active Recovery",
                description: "Complete a relaxed 20-minute walk or other light activity.",
                durationMinutes: 20,
                experiencePoints: 20,
                icon: "figure.walk",
                reason: "You've recorded workouts on at least three days during the past week.",
                activityCategory: .recovery
            )

        // MARK: - Rule 3: Strength Development

        } else if strengthCount == 0 {

            recommendation = TrainingRecommendation(
                title: "Build Your Foundation",
                description: "Complete a 30-minute strength training session.",
                durationMinutes: 30,
                experiencePoints: 45,
                icon: "figure.strengthtraining.traditional",
                reason: "No strength training sessions were found in your recent workout history.",
                activityCategory: .strength
            )

        // MARK: - Rule 4: Martial Arts

        } else if martialArtsCount == 0 {

            recommendation = TrainingRecommendation(
                title: "The Martial Path",
                description: "Complete 30 minutes of martial arts practice.",
                durationMinutes: 30,
                experiencePoints: 60,
                icon: "figure.martial.arts",
                reason: "No martial arts sessions were found in your recent workout history.",
                activityCategory: .martialArts
            )

        // MARK: - Rule 5: Basketball

        } else if basketballCount == 0 {

            recommendation = TrainingRecommendation(
                title: "Sharpen Your Shot",
                description: "Complete 45 minutes of basketball practice.",
                durationMinutes: 45,
                experiencePoints: 81,
                icon: "basketball.fill",
                reason: "No basketball sessions were found in your recent workout history.",
                activityCategory: .basketball
            )

        // MARK: - Rule 6: General Consistency

        } else {

            recommendation = TrainingRecommendation(
                title: "Maintain Momentum",
                description: "Complete a 30-minute workout of your choice.",
                durationMinutes: 30,
                experiencePoints: 30,
                icon: "figure.mixed.cardio",
                reason: "Your recent training includes multiple activity types. Maintain your consistency.",
                activityCategory: .general
            )
        }

        saveRecommendation(recommendation)

        return recommendation
    }

    // MARK: - Persistence

    private func saveRecommendation(
        _ recommendation: TrainingRecommendation
    ) {

        guard let data = try? JSONEncoder().encode(
            recommendation
        ) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    private func loadRecommendation() -> TrainingRecommendation? {

        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            return nil
        }

        return try? JSONDecoder().decode(
            TrainingRecommendation.self,
            from: data
        )
    }
}
