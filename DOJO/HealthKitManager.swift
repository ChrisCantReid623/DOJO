import Foundation
import HealthKit
import Combine

// MARK: - Workout Model

struct DOJOWorkout: Identifiable {
    let id: UUID
    let activity: String
    let date: Date
    let durationMinutes: Int
}

// MARK: - HealthKit Manager

final class HealthKitManager: ObservableObject {

    // MARK: - HealthKit Store

    private let healthStore = HKHealthStore()

    // MARK: - Published Properties

    @Published var todaySteps: Int = 0
    @Published var weeklySteps: [Date: Int] = [:]
    @Published var recentWorkouts: [DOJOWorkout] = []
    @Published var statusMessage = "HealthKit not connected"

    // MARK: - Authorization

    func requestAuthorization() {

        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "HealthKit is unavailable"
            return
        }

        guard let stepType = HKObjectType.quantityType(
            forIdentifier: .stepCount
        ) else {
            statusMessage = "Step count unavailable"
            return
        }

        let workoutType = HKObjectType.workoutType()

        let readTypes: Set<HKObjectType> = [
            stepType,
            workoutType
        ]

        healthStore.requestAuthorization(
            toShare: [],
            read: readTypes
        ) { [weak self] success, error in

            DispatchQueue.main.async {

                if let error = error {
                    self?.statusMessage = error.localizedDescription
                    return
                }

                if success {

                    self?.statusMessage = "Authorization request completed"

                    self?.fetchTodaySteps()
                    self?.fetchWeeklySteps()
                    self?.fetchRecentWorkouts()

                } else {
                    self?.statusMessage = "Authorization request failed"
                }
            }
        }
    }

    // MARK: - Today's Step Count

    func fetchTodaySteps() {

        guard let stepType = HKObjectType.quantityType(
            forIdentifier: .stepCount
        ) else {
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in

            DispatchQueue.main.async {

                if let error = error {
                    self?.statusMessage = error.localizedDescription
                    return
                }

                let steps = result?
                    .sumQuantity()?
                    .doubleValue(for: .count()) ?? 0

                self?.todaySteps = Int(steps)
                self?.statusMessage = "Activity data updated"
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Seven-Day Step History

    func fetchWeeklySteps() {

        guard let stepType = HKObjectType.quantityType(
            forIdentifier: .stepCount
        ) else {
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let startDate = calendar.date(
            byAdding: .day,
            value: -6,
            to: today
        ) else {
            return
        }

        guard let endDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: today
        ) else {
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate
        )

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: today,
            intervalComponents: DateComponents(day: 1)
        )

        query.initialResultsHandler = { [weak self] _, results, error in

            if let error = error {
                DispatchQueue.main.async {
                    self?.statusMessage = error.localizedDescription
                }
                return
            }

            guard let results = results else {
                return
            }

            var history: [Date: Int] = [:]

            results.enumerateStatistics(
                from: startDate,
                to: Date()
            ) { statistics, _ in

                let steps = statistics
                    .sumQuantity()?
                    .doubleValue(for: .count()) ?? 0

                history[statistics.startDate] = Int(steps)
            }

            DispatchQueue.main.async {
                self?.weeklySteps = history
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Recent Workouts

    func fetchRecentWorkouts() {

        let workoutType = HKObjectType.workoutType()

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: 20,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in

            if let error = error {
                DispatchQueue.main.async {
                    self?.statusMessage = error.localizedDescription
                }
                return
            }

            let workouts = (samples as? [HKWorkout] ?? []).map { workout in

                DOJOWorkout(
                    id: workout.uuid,
                    activity: self?.activityName(
                        for: workout.workoutActivityType
                    ) ?? "Other",
                    date: workout.startDate,
                    durationMinutes: Int(
                        workout.duration / 60
                    )
                )
            }

            DispatchQueue.main.async {
                self?.recentWorkouts = workouts
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Workout Classification

    private func activityName(
        for type: HKWorkoutActivityType
    ) -> String {

        switch type {

        case .traditionalStrengthTraining:
            return "Strength Training"

        case .functionalStrengthTraining:
            return "Functional Training"

        case .running:
            return "Running"

        case .walking:
            return "Walking"

        case .cycling:
            return "Cycling"

        case .basketball:
            return "Basketball"

        case .martialArts:
            return "Martial Arts"

        case .highIntensityIntervalTraining:
            return "HIIT"

        case .swimming:
            return "Swimming"

        case .yoga:
            return "Yoga"

        case .elliptical:
            return "Elliptical"

        case .stairClimbing:
            return "Stair Climbing"

        case .hiking:
            return "Hiking"

        case .rowing:
            return "Rowing"

        case .boxing:
            return "Boxing"

        case .kickboxing:
            return "Kickboxing"

        case .pilates:
            return "Pilates"

        case .flexibility:
            return "Flexibility"

        case .cooldown:
            return "Cooldown"

        default:
            return "Other Workout"
        }
    }

    // MARK: - Weekly Activity Statistics

    var weeklyTotalSteps: Int {
        weeklySteps.values.reduce(0, +)
    }

    var weeklyAverageSteps: Int {

        guard !weeklySteps.isEmpty else {
            return 0
        }

        return weeklyTotalSteps / weeklySteps.count
    }

    var activeDays: Int {
        weeklySteps.values.filter { $0 >= 7000 }.count
    }

    // MARK: - Workout Statistics

    var totalRecordedWorkouts: Int {
        recentWorkouts.count
    }

    var totalWorkoutMinutes: Int {
        recentWorkouts.reduce(0) {
            $0 + $1.durationMinutes
        }
    }

    var averageWorkoutMinutes: Int {

        guard !recentWorkouts.isEmpty else {
            return 0
        }

        return totalWorkoutMinutes / recentWorkouts.count
    }
}
