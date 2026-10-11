import Foundation
import SwiftUI

// MARK: - Belt Rank

enum BeltRank: Int, CaseIterable, Codable {
    case white = 0
    case yellow
    case orange
    case green
    case blue
    case purple
    case brown
    case black

    var title: String {
        switch self {
        case .white: return "White Belt"
        case .yellow: return "Yellow Belt"
        case .orange: return "Orange Belt"
        case .green: return "Green Belt"
        case .blue: return "Blue Belt"
        case .purple: return "Purple Belt"
        case .brown: return "Brown Belt"
        case .black: return "Black Belt"
        }
    }

    var color: Color {
        switch self {
        case .white: return .white
        case .yellow: return .yellow
        case .orange: return .orange
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .brown: return .brown
        case .black: return .black
        }
    }

    var nextRank: BeltRank? {
        BeltRank(rawValue: rawValue + 1)
    }
}

// MARK: - Progression Model

struct ProgressionModel {

    // Demonstration values only.
    // Actual progression will eventually come from SNSY.

    var currentBelt: BeltRank = .white

    var level: Int = 3

    var currentXP: Int = 340

    var requiredXP: Int = 500

    var streakDays: Int = 12

    var completedQuests: Int = 8

    var progress: Double {
        guard requiredXP > 0 else { return 0 }

        return min(
            max(Double(currentXP) / Double(requiredXP), 0),
            1
        )
    }

    var remainingXP: Int {
        max(requiredXP - currentXP, 0)
    }

    static let preview = ProgressionModel()
}
