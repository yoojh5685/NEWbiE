import Foundation

// MARK: - Root Detail
struct NewsDetail: Decodable, Hashable {
    let contentId: ContentID          // JSON "_id"
    let topic: String
    let date: String
    let backgroundSummary: String
    let conservativeMediaStance: String
    let contentTitle: String
    let coreIssue: String
    let fullArticleSummary: String
    let glossary: [GlossaryItem]
    let mediaSummary: MediaSummary
    let progressiveMediaStance: String
    let reportingVolumeCompare: VolumeCompare
    let sourceArticles: [SourceArticle]

    // UI 호환용: 기존에 [String]을 기대한다면 여기 사용
    var backgroundSummaryList: [String] { [backgroundSummary] }

    private enum CodingKeys: String, CodingKey {
        case contentId = "_id"
        case topic, date, backgroundSummary, conservativeMediaStance
        case contentTitle, coreIssue, fullArticleSummary, glossary
        case mediaSummary, progressiveMediaStance, reportingVolumeCompare, sourceArticles
    }
}

// MARK: - Subtypes
struct ContentID: Decodable, Hashable {
    let timestamp: Int
    let date: String                  // "2025-08-17T01:33:02.000+00:00"
}

struct GlossaryItem: Decodable, Hashable {
    let term: String
    let definition: String
}

// ✅ sheet(item:)에서 쓰기 위해 Identifiable 채택
extension GlossaryItem: Identifiable {
    var id: String { term }
}

struct MediaSummary: Decodable, Hashable {
    let progressive: [String]
    let conservative: [String]
}

struct VolumeCompare: Decodable, Hashable {
    let progressive: Double
    let conservative: Double
}

struct SourceArticle: Decodable, Hashable {
    let title: String
    let url: String
    let media: String
    let politicalLeaning: String
}
