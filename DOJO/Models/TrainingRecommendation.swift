import Foundation

// MARK: - Training Recommendation

struct TrainingRecommendation: Codable, Identifiable {

    let id: UUID
    let date: Date

    let title: String
    let description: String

    let durationMinutes: Int
    let experiencePoints: Int

    let icon: String
    let reason: String

    let activityCategory: TrainingActivityCategory

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String,
        description: String,
        durationMinutes: Int,
        experiencePoints: Int,
        icon: String,
        reason: String,
        activityCategory: TrainingActivityCategory
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.description = description
        self.durationMinutes = durationMinutes
        self.experiencePoints = experiencePoints
        self.icon = icon
        self.reason = reason
        self.activityCategory = activityCategory
    }
}

// MARK: - Activity Categories

enum TrainingActivityCategory: String, Codable {

    case walking
    case strength
    case basketball
    case martialArts
    case recovery
    case general
}
