import Foundation

// MARK: - Performance Data Point

struct PerformanceDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Performance Data

struct PerformanceData {

    static func generateSampleHistory() -> [PerformanceDataPoint] {

        let calendar = Calendar.current
        let today = Date()

        guard let startDate = calendar.date(
            byAdding: .day,
            value: -300,
            to: today
        ) else {
            return []
        }

        var history: [PerformanceDataPoint] = []

        for day in 0...300 {

            guard let date = calendar.date(
                byAdding: .day,
                value: day,
                to: startDate
            ) else {
                continue
            }

            let progress = Double(day) / 300.0

            // Long-term upward trajectory
            let growth = 100 + (progress * 45)

            // Short-term volatility
            let volatility =
                sin(Double(day) * 0.12) * 5 +
                sin(Double(day) * 0.035) * 8

            // Temporary drawdown
            let drawdown =
                day > 80 && day < 140 ? -12.0 : 0.0

            // Midyear breakthrough
            let breakthrough =
                day > 170 ? 10.0 : 0.0

            let value = max(
                0,
                growth + volatility + drawdown + breakthrough
            )

            history.append(
                PerformanceDataPoint(
                    date: date,
                    value: value
                )
            )
        }

        return history
    }
}
