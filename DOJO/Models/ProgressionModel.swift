import SwiftUI
import Foundation

// MARK: - Belt Rank

enum BeltRank: Int, CaseIterable, Codable {

    case white
    case yellow
    case orange
    case green
    case blue
    case purple
    case brown
    case black

    // MARK: - Display Name

    var title: String {

        switch self {

        case .white:
            return "White Belt"

        case .yellow:
            return "Yellow Belt"

        case .orange:
            return "Orange Belt"

        case .green:
            return "Green Belt"

        case .blue:
            return "Blue Belt"

        case .purple:
            return "Purple Belt"

        case .brown:
            return "Brown Belt"

        case .black:
            return "Black Belt"
        }
    }

    // MARK: - Belt Color

    var color: Color {

        switch self {

        case .white:
            return .white

        case .yellow:
            return .yellow

        case .orange:
            return .orange

        case .green:
            return .green

        case .blue:
            return .blue

        case .purple:
            return .purple

        case .brown:
            return Color(
                red: 0.55,
                green: 0.30,
                blue: 0.15
            )

        case .black:
            return .black
        }
    }

    // MARK: - Next Belt

    var nextRank: BeltRank? {

        BeltRank(
            rawValue: rawValue + 1
        )
    }

    // MARK: - Universal XP Multiplier

    var xpMultiplier: Double {

        switch self {

        case .white:
            return 1.00

        case .yellow:
            return 1.10

        case .orange:
            return 1.20

        case .green:
            return 1.30

        case .blue:
            return 1.40

        case .purple:
            return 1.50

        case .brown:
            return 1.75

        case .black:
            return 2.00
        }
    }
}

// MARK: - Progression Model

struct ProgressionModel {

    // MARK: - Experience

    var level: Int

    // Total lifetime experience.
    // This value never resets when leveling up.

    var totalXP: Int

    // MARK: - Mastery

    var currentBelt: BeltRank

    // Belt promotions are earned through
    // separate mastery milestones.

    var completedMilestones: Int

    var requiredMilestones: Int

    // MARK: - Consistency

    var streakDays: Int

    var completedQuests: Int

    // MARK: - Experience Configuration

    static let startingXPRequirement = 500

    static let levelGrowthRate = 1.15

    // MARK: - XP Required for a Level

    static func xpRequired(
        for level: Int
    ) -> Int {

        let safeLevel = max(1, level)

        let exponent = Double(
            safeLevel - 1
        )

        let requirement =
            Double(startingXPRequirement)
            * pow(levelGrowthRate, exponent)

        // Avoid integer overflow at extremely
        // high levels.

        if !requirement.isFinite ||
            requirement >= Double(Int.max) {

            return Int.max
        }

        return max(
            1,
            Int(requirement.rounded())
        )
    }

    // MARK: - Total XP Needed to Reach a Level

    static func lifetimeXPRequired(
        toReach targetLevel: Int
    ) -> Int {

        guard targetLevel > 1 else {
            return 0
        }

        var total = 0

        for level in 1..<targetLevel {

            let requirement = xpRequired(
                for: level
            )

            let (newTotal, overflow) =
                total.addingReportingOverflow(
                    requirement
                )

            if overflow {
                return Int.max
            }

            total = newTotal
        }

        return total
    }

    // MARK: - Current Level XP

    var currentXP: Int {

        let previousLevelsXP =
            Self.lifetimeXPRequired(
                toReach: level
            )

        return max(
            0,
            totalXP - previousLevelsXP
        )
    }

    // MARK: - Next Level Requirement

    var requiredXP: Int {

        Self.xpRequired(
            for: level
        )
    }

    // MARK: - Level Progress

    var progress: Double {

        guard requiredXP > 0 else {
            return 0
        }

        let percentage =
            Double(currentXP)
            / Double(requiredXP)

        return min(
            max(percentage, 0),
            1
        )
    }

    // MARK: - Remaining XP

    var remainingXP: Int {

        max(
            0,
            requiredXP - currentXP
        )
    }

    // MARK: - Current XP Multiplier

    var xpMultiplier: Double {

        currentBelt.xpMultiplier
    }

    // MARK: - Level Classification

    var levelTitle: String {

        switch level {

        case 1...10:
            return "Novice"

        case 11...20:
            return "Apprentice"

        case 21...30:
            return "Practitioner"

        case 31...40:
            return "Adept"

        case 41...50:
            return "Expert"

        case 51...60:
            return "Master"

        case 61...70:
            return "Grandmaster"

        default:
            return "Sage"
        }
    }

    // MARK: - Milestone Progress

    var milestoneProgress: Double {

        guard requiredMilestones > 0 else {
            return 1
        }

        return min(
            max(
                Double(completedMilestones)
                / Double(requiredMilestones),
                0
            ),
            1
        )
    }

    // MARK: - Award Experience

    mutating func awardXP(
        baseXP: Int
    ) {

        guard baseXP > 0 else {
            return
        }

        // Universal belt multiplier.

        let adjustedXP =
            Double(baseXP)
            * xpMultiplier

        guard adjustedXP.isFinite else {
            return
        }

        let earnedXP = Int(
            min(
                adjustedXP.rounded(),
                Double(Int.max)
            )
        )

        let (newTotal, overflow) =
            totalXP.addingReportingOverflow(
                earnedXP
            )

        totalXP = overflow
            ? Int.max
            : newTotal

        // Level up as many times as necessary.

        while level < Int.max {

            let requirement = requiredXP

            if currentXP < requirement {
                break
            }

            level += 1
        }
    }

    // MARK: - Preview Data

    static let preview = ProgressionModel(

        level: 3,

        totalXP:
            lifetimeXPRequired(
                toReach: 3
            ) + 340,

        currentBelt: .white,

        completedMilestones: 0,

        requiredMilestones: 3,

        streakDays: 12,

        completedQuests: 8
    )
}
