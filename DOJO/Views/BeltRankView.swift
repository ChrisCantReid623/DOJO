import SwiftUI

struct BeltRankView: View {

    // MARK: - Progression Data

    let progression: ProgressionModel

    // MARK: - Testing State

    @State private var displayedBelt: BeltRank = .white

    @AppStorage("dojoBeltTestingMode")
    private var testingMode = true

    // MARK: - Demonstration Data

    private let demoLifetimeGrowth = 27.4

    // MARK: - Displayed XP Multiplier

    private var displayedMultiplier: Double {

        displayedBelt.xpMultiplier
    }

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            testingControls

            Divider()
                .overlay(
                    Color.white.opacity(0.08)
                )

            beltIdentity

            levelProgressSection

            multiplierSection

            milestoneSection

            Divider()
                .overlay(
                    Color.white.opacity(0.08)
                )

            masteryStatistics

            LifetimeGrowthView(
                growthPercentage: demoLifetimeGrowth
            )

            Text(
                "PROGRESSION STATISTICS • DEMONSTRATION DATA"
            )
            .font(.system(size: 9))
            .tracking(1.2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                Color.white.opacity(0.05)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20
            )
            .stroke(
                Color.white.opacity(0.08),
                lineWidth: 1
            )
        )
        .onAppear {

            displayedBelt =
                progression.currentBelt
        }
        .onChange(of: testingMode) {
            _, enabled in

            if !enabled {

                withAnimation(
                    .easeInOut(
                        duration: 0.3
                    )
                ) {

                    displayedBelt =
                        progression.currentBelt
                }
            }
        }
    }

    // MARK: - Testing Controls

    private var testingControls: some View {

        VStack(spacing: 12) {

            HStack {

                Image(
                    systemName: "hammer.fill"
                )
                .foregroundStyle(.orange)

                Text("Belt Testing Mode")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Toggle(
                    "Belt Testing Mode",
                    isOn: $testingMode
                )
                .labelsHidden()
                .tint(.orange)
            }

            if testingMode {

                Button {

                    cycleBelt()

                } label: {

                    HStack(spacing: 10) {

                        Image(
                            systemName:
                                "arrow.triangle.2.circlepath"
                        )

                        Text("Cycle Belt")

                        Spacer()

                        Text(
                            displayedBelt.title
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Image(
                            systemName: "chevron.right"
                        )
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                        .fill(
                            Color.white.opacity(0.10)
                        )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "Cycle to next belt"
                )
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Belt Identity

    private var beltIdentity: some View {

        HStack(spacing: 20) {

            ZStack {

                Circle()
                    .fill(
                        displayedBelt.color.opacity(
                            0.12
                        )
                    )
                    .frame(
                        width: 90,
                        height: 90
                    )

                Circle()
                    .stroke(
                        displayedBelt == .black
                            ? Color.gray
                            : displayedBelt.color,
                        lineWidth: 2
                    )
                    .frame(
                        width: 90,
                        height: 90
                    )

                martialArtsBeltIcon
            }

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                Text("CURRENT RANK")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)

                Text(
                    displayedBelt.title.uppercased()
                )
                .font(.title2)
                .fontWeight(.bold)

                Text(
                    "\(progression.levelTitle) • Level \(progression.level)"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Belt Icon

    private var martialArtsBeltIcon: some View {

        let beltColor: Color =
            displayedBelt == .black
                ? Color(white: 0.18)
                : displayedBelt.color

        return ZStack {

            // Horizontal belt

            RoundedRectangle(
                cornerRadius: 4
            )
            .fill(beltColor)
            .frame(
                width: 65,
                height: 15
            )

            // Left hanging end

            RoundedRectangle(
                cornerRadius: 3
            )
            .fill(beltColor)
            .frame(
                width: 12,
                height: 32
            )
            .rotationEffect(
                .degrees(15)
            )
            .offset(
                x: -9,
                y: 14
            )

            // Right hanging end

            RoundedRectangle(
                cornerRadius: 3
            )
            .fill(beltColor)
            .frame(
                width: 12,
                height: 32
            )
            .rotationEffect(
                .degrees(-15)
            )
            .offset(
                x: 9,
                y: 14
            )

            // Central knot

            RoundedRectangle(
                cornerRadius: 3
            )
            .fill(
                displayedBelt == .black
                    ? Color(white: 0.28)
                    : beltColor
            )
            .frame(
                width: 21,
                height: 19
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 3
                )
                .stroke(
                    Color.black.opacity(0.3),
                    lineWidth: 1
                )
            )
        }
    }

    // MARK: - Level Progress

    private var levelProgressSection: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Text("LEVEL PROGRESS")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(
                    "LEVEL \(progression.level)"
                )
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
            }

            GeometryReader { geometry in

                ZStack(
                    alignment: .leading
                ) {

                    Capsule()
                        .fill(
                            Color.white.opacity(0.12)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .yellow,
                                    .orange
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width:
                                geometry.size.width
                                * progression.progress
                        )
                }
            }
            .frame(height: 10)

            HStack {

                Text(
                    "\(progression.currentXP.formatted()) / \(progression.requiredXP.formatted()) XP"
                )

                Spacer()

                Text(
                    "\(progression.remainingXP.formatted()) XP to Level \(progression.level + 1)"
                )
            }
            .font(.system(size: 10))
            .foregroundStyle(.secondary)

            Text(
                "Lifetime XP: \(progression.totalXP.formatted())"
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - XP Multiplier

    private var multiplierSection: some View {

        HStack(spacing: 12) {

            Image(
                systemName: "bolt.fill"
            )
            .font(.title3)
            .foregroundStyle(.yellow)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("UNIVERSAL XP MULTIPLIER")
                    .font(.system(size: 10))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                Text(
                    String(
                        format: "%.2f×",
                        displayedMultiplier
                    )
                )
                .font(
                    .system(
                        size: 23,
                        weight: .bold
                    )
                )
                .foregroundStyle(.yellow)
            }

            Spacer()

            Text(
                "BELT BONUS"
            )
            .font(.system(size: 9))
            .tracking(1)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(
                cornerRadius: 12
            )
            .fill(
                Color.yellow.opacity(0.06)
            )
        )
    }

    // MARK: - Mastery Milestones

    private var milestoneSection: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Text("BELT MASTERY")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(
                    "\(progression.completedMilestones) / \(progression.requiredMilestones)"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in

                ZStack(
                    alignment: .leading
                ) {

                    Capsule()
                        .fill(
                            Color.white.opacity(0.12)
                        )

                    Capsule()
                        .fill(
                            displayedBelt == .black
                                ? Color.gray
                                : displayedBelt.color
                        )
                        .frame(
                            width:
                                geometry.size.width
                                * progression.milestoneProgress
                        )
                }
            }
            .frame(height: 6)

            if let nextBelt =
                displayedBelt.nextRank {

                Text(
                    "Next Belt: \(nextBelt.title)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

            } else {

                Text(
                    "Highest Belt Achieved"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if testingMode {

                Text(
                    "Belt preview only • Milestones remain unchanged"
                )
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Mastery Statistics

    private var masteryStatistics: some View {

        HStack(
            alignment: .top,
            spacing: 8
        ) {

            masteryMetric(
                icon: "flame.fill",
                value:
                    "\(progression.streakDays)",
                title: "Day Streak",
                color: .orange
            )

            masteryMetric(
                icon: "checkmark.seal.fill",
                value:
                    "\(progression.completedQuests)",
                title: "Quests",
                color: .yellow
            )

            VStack(spacing: 5) {

                Image(
                    systemName:
                        "chart.line.uptrend.xyaxis"
                )
                .foregroundStyle(.green)

                Text(
                    String(
                        format: "%+.1f%%",
                        demoLifetimeGrowth
                    )
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(.green)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

                Text("Lifetime")
                    .font(
                        .system(size: 10)
                    )
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Metric Component

    private func masteryMetric(
        icon: String,
        value: String,
        title: String,
        color: Color
    ) -> some View {

        VStack(spacing: 5) {

            Image(
                systemName: icon
            )
            .foregroundStyle(color)

            Text(value)
                .font(
                    .system(
                        size: 17,
                        weight: .bold
                    )
                )

            Text(title)
                .font(
                    .system(size: 10)
                )
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Cycle Belt

    private func cycleBelt() {

        let belts =
            BeltRank.allCases

        guard let currentIndex =
            belts.firstIndex(
                of: displayedBelt
            ) else {

            return
        }

        let nextIndex =
            (currentIndex + 1)
            % belts.count

        withAnimation(
            .easeInOut(
                duration: 0.3
            )
        ) {

            displayedBelt =
                belts[nextIndex]
        }
    }
}

// MARK: - Preview

#Preview {

    ZStack {

        Color.black
            .ignoresSafeArea()

        BeltRankView(
            progression: .preview
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}
