import Foundation

extension NewsDetail {
    func toArticles() -> [Article] {
        sourceArticles.map { sa in
            let fieldLeaning = PoliticalLeaning(rawValue: sa.politicalLeaning)

            let leaning: PoliticalLeaning = fieldLeaning ?? {
                if mediaSummary.progressive.contains(sa.media) { return .progressive }
                if mediaSummary.conservative.contains(sa.media) { return .conservative }
                return .unknown
            }()

            return Article(
                title: sa.title,
                press: sa.media,
                url: sa.url,
                leaning: leaning
            )
        }
    }

    var reportingVolumeText: String {
        let p = Int((reportingVolumeCompare.progressive * 100).rounded())
        let c = Int((reportingVolumeCompare.conservative * 100).rounded())
        return "진보 \(p)% · 보수 \(c)%"
    }
}
