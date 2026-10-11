import Foundation
import SwiftUI

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

    // MARK: - Title

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

    // MARK: - Color

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

    // MARK: - Next Rank

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
    var totalXP: Int

    // MARK: - Mastery

    var currentBelt: BeltRank
    var completedMilestones: Int
    var requiredMilestones: Int

    // MARK: - Consistency

    var streakDays: Int
    var completedQuests: Int

    // MARK: - XP Configuration

    static let startingXPRequirement = 500
    static let levelGrowthRate = 1.15

    // MARK: - XP Requirement

    static func xpRequired(
        for level: Int
    ) -> Int {

        let safeLevel = max(1, level)

        let requirement =
            Double(startingXPRequirement)
            * pow(
                levelGrowthRate,
                Double(safeLevel - 1)
            )

        guard requirement.isFinite else {
            return Int.max
        }

        return Int(
            min(
                requirement.rounded(),
                Double(Int.max - 1)
            )
        )
    }

    // MARK: - Lifetime XP Threshold

    static func lifetimeXPRequired(
        toReach targetLevel: Int
    ) -> Int {

        guard targetLevel > 1 else {
            return 0
        }

        var total = 0

        for currentLevel in 1..<targetLevel {

            let requirement = xpRequired(
                for: currentLevel
            )

            let (sum, overflow) =
                total.addingReportingOverflow(
                    requirement
                )

            if overflow {
                return Int.max
            }

            total = sum
        }

        return total
    }

    // MARK: - Current Level XP

    var currentXP: Int {

        let previousXP =
            Self.lifetimeXPRequired(
                toReach: level
            )

        return max(
            0,
            totalXP - previousXP
        )
    }

    // MARK: - Required XP

    var requiredXP: Int {

        Self.xpRequired(
            for: level
        )
    }

    // MARK: - Progress

    var progress: Double {

        guard requiredXP > 0 else {
            return 0
        }

        return min(
            max(
                Double(currentXP)
                / Double(requiredXP),
                0
            ),
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

    // MARK: - Multiplier

    var xpMultiplier: Double {

        currentBelt.xpMultiplier
    }

    // MARK: - Level Title

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

    // MARK: - Award Exact XP

    mutating func awardExactXP(
        _ earnedXP: Int
    ) {

        guard earnedXP > 0 else {
            return
        }

        let (newTotal, overflow) =
            totalXP.addingReportingOverflow(
                earnedXP
            )

        totalXP = overflow
            ? Int.max
            : newTotal

        // XP advances levels, never belts.

        while level < Int.max {

            let threshold =
                Self.lifetimeXPRequired(
                    toReach: level + 1
                )

            if totalXP < threshold {
                break
            }

            level += 1
        }
    }

    // MARK: - Award Base XP

    mutating func awardXP(
        baseXP: Int
    ) {

        guard baseXP > 0 else {
            return
        }

        let adjusted =
            Double(baseXP)
            * xpMultiplier

        guard adjusted.isFinite else {
            return
        }

        awardExactXP(
            Int(
                min(
                    adjusted.rounded(),
                    Double(Int.max - 1)
                )
            )
        )
    }

    // MARK: - Preview

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
