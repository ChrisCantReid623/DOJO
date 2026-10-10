import Foundation
import HealthKit
import Combine

final class HealthKitManager: ObservableObject {

    private let healthStore = HKHealthStore()

    @Published var todaySteps: Int = 0
    @Published var statusMessage = "HealthKit not connected"

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
                } else {
                    self?.statusMessage = "Authorization request failed"
                }
            }
        }
    }

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
                self?.statusMessage = "Step query completed"
            }
        }

        healthStore.execute(query)
    }
}
