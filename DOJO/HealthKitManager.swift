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

// MARK: - Synchronization State

enum HealthSyncState: Equatable {

    case notSynced
    case syncing
    case updated(Date)
    case failed(String)

    var isSyncing: Bool {
        if case .syncing = self {
            return true
        }
        return false
    }

    var hasCompletedSync: Bool {
        if case .updated = self {
            return true
        }
        return false
    }

    var title: String {

        switch self {

        case .notSynced:
            return "Not Synced"

        case .syncing:
            return "Syncing..."

        case .updated:
            return "Updated"

        case .failed:
            return "Sync Error"
        }
    }
}

// MARK: - HealthKit Manager

final class HealthKitManager: ObservableObject {

    // MARK: - HealthKit Store

    private let healthStore = HKHealthStore()

    private let workoutHistoryDays = 90

    // MARK: - Published Activity

    @Published private(set) var todaySteps: Int = 0

    @Published private(set) var weeklySteps: [Date: Int] = [:]

    @Published private(set) var recentWorkouts: [DOJOWorkout] = []

    // MARK: - Published Sync State

    @Published private(set) var syncState: HealthSyncState = .notSynced

    @Published private(set) var lastSuccessfulSync: Date?

    @Published private(set) var statusMessage = "HealthKit not connected"

    // MARK: - Authorization and Synchronization

    func requestAuthorization() {

        guard !syncState.isSyncing else {
            return
        }

        guard HKHealthStore.isHealthDataAvailable() else {

            finishWithError(
                "HealthKit is unavailable on this device."
            )

            return
        }

        guard let stepType = HKObjectType.quantityType(
            forIdentifier: .stepCount
        ) else {

            finishWithError(
                "Step count is unavailable."
            )

            return
        }

        let workoutType = HKObjectType.workoutType()

        let readTypes: Set<HKObjectType> = [
            stepType,
            workoutType
        ]

        syncState = .syncing
        statusMessage = "Requesting Apple Health access..."

        healthStore.requestAuthorization(
            toShare: [],
            read: readTypes
        ) { [weak self] success, error in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                if let error = error {

                    self.finishWithError(
                        error.localizedDescription
                    )

                    return
                }

                guard success else {

                    self.finishWithError(
                        "HealthKit authorization request failed."
                    )

                    return
                }

                // Authorization request completion does not
                // prove that every read permission was granted.
                //
                // Proceed with queries and handle their results.

                self.performSync()
            }
        }
    }

    // MARK: - Execute Synchronization

    private func performSync() {

        statusMessage = "Loading Apple Health activity..."

        let group = DispatchGroup()

        let resultLock = NSLock()

        var firstError: Error?

        var fetchedTodaySteps: Int?
        var fetchedWeeklySteps: [Date: Int]?
        var fetchedWorkouts: [DOJOWorkout]?

        // MARK: Today's Steps

        group.enter()

        queryTodaySteps { result in

            resultLock.lock()

            switch result {

            case .success(let steps):
                fetchedTodaySteps = steps

            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
            }

            resultLock.unlock()
            group.leave()
        }

        // MARK: Weekly Steps

        group.enter()

        queryWeeklySteps { result in

            resultLock.lock()

            switch result {

            case .success(let steps):
                fetchedWeeklySteps = steps

            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
            }

            resultLock.unlock()
            group.leave()
        }

        // MARK: Workout History

        group.enter()

        queryRecentWorkouts { result in

            resultLock.lock()

            switch result {

            case .success(let workouts):
                fetchedWorkouts = workouts

            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
            }

            resultLock.unlock()
            group.leave()
        }

        // MARK: Finalize

        group.notify(queue: .main) {

            resultLock.lock()

            let error = firstError
            let today = fetchedTodaySteps
            let weekly = fetchedWeeklySteps
            let workouts = fetchedWorkouts

            resultLock.unlock()

            if let today = today {
                self.todaySteps = today
            }

            if let weekly = weekly {
                self.weeklySteps = weekly
            }

            if let workouts = workouts {
                self.recentWorkouts = workouts
            }

            if let error = error {

                self.finishWithError(
                    error.localizedDescription
                )

                return
            }

            let completedAt = Date()

            self.lastSuccessfulSync = completedAt

            self.syncState = .updated(completedAt)

            self.statusMessage = "Activity data updated"
        }
    }

    // MARK: - Today's Step Query

    private func queryTodaySteps(
        completion: @escaping (Result<Int, Error>) -> Void
    ) {

        guard let stepType = HKObjectType.quantityType(
            forIdentifier: .stepCount
        ) else {

            completion(
                .failure(
                    HealthSyncError.stepTypeUnavailable
                )
            )

            return
        }

        let startOfDay = Calendar.current.startOfDay(
            for: Date()
        )

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in

            if let error = error {

                completion(.failure(error))
                return
            }

            let steps = result?
                .sumQuantity()?
                .doubleValue(for: .count()) ?? 0

            completion(
                .success(Int(steps))
            )
        }

        healthStore.execute(query)
    }

    // MARK: - Seven-Day Step Query

    private func queryWeeklySteps(
        completion: @escaping (
            Result<[Date: Int], Error>
        ) -> Void
    ) {

        guard let stepType = HKObjectType.quantityType(
            forIdentifier: .stepCount
        ) else {

            completion(
                .failure(
                    HealthSyncError.stepTypeUnavailable
                )
            )

            return
        }

        let calendar = Calendar.current

        let today = calendar.startOfDay(
            for: Date()
        )

        guard let startDate = calendar.date(
            byAdding: .day,
            value: -6,
            to: today
        ),
        let endDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: today
        ) else {

            completion(
                .failure(
                    HealthSyncError.invalidDateRange
                )
            )

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

        query.initialResultsHandler = { _, results, error in

            if let error = error {

                completion(.failure(error))
                return
            }

            guard let results = results else {

                completion(
                    .failure(
                        HealthSyncError.missingQueryResults
                    )
                )

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

                let day = calendar.startOfDay(
                    for: statistics.startDate
                )

                history[day] = Int(steps)
            }

            completion(.success(history))
        }

        healthStore.execute(query)
    }

    // MARK: - Workout History Query

    private func queryRecentWorkouts(
        completion: @escaping (
            Result<[DOJOWorkout], Error>
        ) -> Void
    ) {

        let workoutType = HKObjectType.workoutType()

        let calendar = Calendar.current

        guard let startDate = calendar.date(
            byAdding: .day,
            value: -workoutHistoryDays,
            to: Date()
        ) else {

            completion(
                .failure(
                    HealthSyncError.invalidDateRange
                )
            )

            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date(),
            options: []
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in

            if let error = error {

                completion(.failure(error))
                return
            }

            let workouts = (
                samples as? [HKWorkout] ?? []
            ).map { workout in

                DOJOWorkout(
                    id: workout.uuid,
                    activity: self?.activityName(
                        for: workout.workoutActivityType
                    ) ?? "Other Workout",
                    date: workout.startDate,
                    durationMinutes: Int(
                        workout.duration / 60
                    )
                )
            }

            completion(.success(workouts))
        }

        healthStore.execute(query)
    }

    // MARK: - Error Handling

    private func finishWithError(
        _ message: String
    ) {

        syncState = .failed(message)

        statusMessage = message
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

        weeklySteps.values.filter {
            $0 >= 7000
        }.count
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

// MARK: - Synchronization Errors

private enum HealthSyncError: LocalizedError {

    case stepTypeUnavailable
    case invalidDateRange
    case missingQueryResults

    var errorDescription: String? {

        switch self {

        case .stepTypeUnavailable:
            return "Step count is unavailable."

        case .invalidDateRange:
            return "Unable to calculate the activity date range."

        case .missingQueryResults:
            return "Apple Health returned no query results."
        }
    }
}
