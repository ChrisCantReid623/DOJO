import Foundation
import Combine

// MARK: - Saved Progression

struct SavedProgression: Codable {

    var level: Int
    var totalXP: Int
    var currentBelt: BeltRank

    var completedMilestones: Int
    var requiredMilestones: Int

    var streakDays: Int
    var completedQuests: Int

    var awards: [ExperienceAward]

    var processedWorkoutIDs: Set<UUID>

    var enrollmentDate: Date?
}

// MARK: - Sync Award Summary

struct ExperienceSyncSummary {

    let newWorkoutCount: Int
    let earnedXP: Int
    let previousLevel: Int
    let currentLevel: Int

    var levelsGained: Int {

        max(
            0,
            currentLevel - previousLevel
        )
    }
}

// MARK: - Progression Store

final class ProgressionStore: ObservableObject {

    // MARK: - Published State

    @Published private(set)
    var progression: ProgressionModel

    @Published private(set)
    var awards: [ExperienceAward]

    @Published private(set)
    var enrollmentDate: Date?

    @Published private(set)
    var lastSyncSummary: ExperienceSyncSummary?

    // MARK: - Private State

    private var processedWorkoutIDs: Set<UUID>

    private let storageKey = "dojo.progression.v0.5"

    // MARK: - Initialization

    init() {

        if let data = UserDefaults.standard.data(
            forKey: storageKey
        ),
        let saved = try? JSONDecoder().decode(
            SavedProgression.self,
            from: data
        ) {

            progression = ProgressionModel(
                level: saved.level,
                totalXP: saved.totalXP,
                currentBelt: saved.currentBelt,
                completedMilestones: saved.completedMilestones,
                requiredMilestones: saved.requiredMilestones,
                streakDays: saved.streakDays,
                completedQuests: saved.completedQuests
            )

            awards = saved.awards

            processedWorkoutIDs =
                saved.processedWorkoutIDs

            enrollmentDate =
                saved.enrollmentDate

        } else {

            progression = ProgressionModel(
                level: 1,
                totalXP: 0,
                currentBelt: .white,
                completedMilestones: 0,
                requiredMilestones: 3,
                streakDays: 0,
                completedQuests: 0
            )

            awards = []

            processedWorkoutIDs = []

            enrollmentDate = nil
        }

        lastSyncSummary = nil
    }

    // MARK: - Process HealthKit Workouts

    @discardableResult
    func processWorkouts(
        _ workouts: [DOJOWorkout],
        synchronizedAt: Date
    ) -> ExperienceSyncSummary {

        let previousLevel = progression.level

        // MARK: Initial Enrollment

        if enrollmentDate == nil {

            enrollmentDate = synchronizedAt

            // Existing workouts establish the baseline.
            // No historical XP is awarded.

            processedWorkoutIDs.formUnion(
                workouts.map(\.id)
            )

            let summary = ExperienceSyncSummary(
                newWorkoutCount: 0,
                earnedXP: 0,
                previousLevel: previousLevel,
                currentLevel: progression.level
            )

            lastSyncSummary = summary

            save()

            return summary
        }

        // MARK: Subsequent Synchronization

        let sortedWorkouts = workouts.sorted {
            $0.date < $1.date
        }

        var newAwards: [ExperienceAward] = []

        var totalEarnedXP = 0

        for workout in sortedWorkouts {

            guard !processedWorkoutIDs.contains(
                workout.id
            ) else {
                continue
            }

            // Record the ID even if the workout
            // is ineligible for XP.

            processedWorkoutIDs.insert(
                workout.id
            )

            // Historical workouts added to HealthKit
            // after enrollment should not automatically
            // earn retroactive experience.

            guard let enrollmentDate = enrollmentDate,
                  workout.date >= enrollmentDate else {
                continue
            }

            let award = ExperienceEngine.createAward(
                for: workout,
                belt: progression.currentBelt
            )

            guard award.earnedXP > 0 else {
                continue
            }

            // Award the exact ledger amount.
            // Never multiply twice.

            progression.awardExactXP(
                award.earnedXP
            )

            awards.append(award)

            newAwards.append(award)

            let (updatedTotal, overflow) =
                totalEarnedXP.addingReportingOverflow(
                    award.earnedXP
                )

            totalEarnedXP = overflow
                ? Int.max
                : updatedTotal
        }

        let summary = ExperienceSyncSummary(
            newWorkoutCount: newAwards.count,
            earnedXP: totalEarnedXP,
            previousLevel: previousLevel,
            currentLevel: progression.level
        )

        lastSyncSummary = summary

        save()

        return summary
    }

    // MARK: - Lifetime Earned XP

    var lifetimeEarnedXP: Int {

        awards.reduce(0) { total, award in

            let (result, overflow) =
                total.addingReportingOverflow(
                    award.earnedXP
                )

            return overflow
                ? Int.max
                : result
        }
    }

    // MARK: - Save

    private func save() {

        let saved = SavedProgression(
            level: progression.level,
            totalXP: progression.totalXP,
            currentBelt: progression.currentBelt,
            completedMilestones:
                progression.completedMilestones,
            requiredMilestones:
                progression.requiredMilestones,
            streakDays: progression.streakDays,
            completedQuests:
                progression.completedQuests,
            awards: awards,
            processedWorkoutIDs:
                processedWorkoutIDs,
            enrollmentDate: enrollmentDate
        )

        guard let data = try? JSONEncoder().encode(
            saved
        ) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }
}
