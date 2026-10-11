import SwiftUI
import Charts

// MARK: - Chart Time Range

enum PerformanceTimeRange: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case yearToDate = "YTD"
    case all = "ALL"

    var id: String { rawValue }
}

// MARK: - Performance Chart

struct PerformanceChartView: View {

    @State private var selectedRange: PerformanceTimeRange = .yearToDate

    private let history = PerformanceData.generateSampleHistory()

    // MARK: - Filtered History

    private var filteredHistory: [PerformanceDataPoint] {

        let calendar = Calendar.current
        let today = Date()

        let startDate: Date

        switch selectedRange {

        case .oneMonth:
            startDate = calendar.date(
                byAdding: .month,
                value: -1,
                to: today
            ) ?? today

        case .threeMonths:
            startDate = calendar.date(
                byAdding: .month,
                value: -3,
                to: today
            ) ?? today

        case .sixMonths:
            startDate = calendar.date(
                byAdding: .month,
                value: -6,
                to: today
            ) ?? today

        case .yearToDate:
            let year = calendar.component(.year, from: today)

            startDate = calendar.date(
                from: DateComponents(year: year, month: 1, day: 1)
            ) ?? today

        case .all:
            startDate = .distantPast
        }

        return history.filter { $0.date >= startDate }
    }

    // MARK: - Performance Calculations

    private var startingValue: Double {
        filteredHistory.first?.value ?? 100
    }

    private var currentValue: Double {
        filteredHistory.last?.value ?? 100
    }

    private var percentageChange: Double {
        guard startingValue != 0 else { return 0 }

        return ((currentValue / startingValue) - 1) * 100
    }

    private var percentageText: String {
        String(format: "%+.1f%%", percentageChange)
    }

    // MARK: - Interface

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            // Header

            HStack {

                VStack(alignment: .leading, spacing: 6) {

                    Text("PERSONAL PERFORMANCE")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    Text("The Long Game")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()
            }

            // Time Range Selector

            HStack(spacing: 8) {

                ForEach(PerformanceTimeRange.allCases) { range in

                    Button {
                        selectedRange = range
                    } label: {

                        Text(range.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                selectedRange == range
                                ? Color.black
                                : Color.gray
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedRange == range
                                ? Color.yellow
                                : Color.clear
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Performance Percentage

            HStack(alignment: .firstTextBaseline, spacing: 12) {

                Text(percentageText)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        percentageChange >= 0
                        ? Color.green
                        : Color.red
                    )

                Text("\(selectedRange.rawValue) Growth")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Chart

            Chart {

                ForEach(filteredHistory) { point in

                    AreaMark(
                        x: .value("Date", point.date),
                        yStart: .value("Baseline", 100),
                        yEnd: .value("Performance", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.35),
                                Color.yellow.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Performance", point.value)
                    )
                    .foregroundStyle(Color.yellow)
                    .lineStyle(
                        StrokeStyle(lineWidth: 2.5)
                    )
                }

                RuleMark(y: .value("Starting Index", 100))
                    .foregroundStyle(Color.gray.opacity(0.4))
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: 1,
                            dash: [4, 4]
                        )
                    )
            }
            .chartYScale(domain: 60...180)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.15))

                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.15))

                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 230)

            // MARK: - Summary

            HStack {

                summaryMetric(
                    title: "Starting Index",
                    value: String(format: "%.1f", startingValue)
                )

                Spacer()

                summaryMetric(
                    title: "Current Index",
                    value: String(format: "%.1f", currentValue)
                )

                Spacer()

                summaryMetric(
                    title: "Growth",
                    value: percentageText
                )
            }

            Text("Illustrative performance data")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Reusable Metric

    private func summaryMetric(
        title: String,
        value: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 5) {

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {

    ScrollView {

        PerformanceChartView()
            .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
