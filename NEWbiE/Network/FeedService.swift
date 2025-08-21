// FeedService.swift

import Foundation

protocol FeedService {
    /// 선택한 날짜의 피드 목록을 가져온다
    func fetchFeeds(on date: Date) async throws -> [FeedItemModel]
}

// MARK: - Live(실서버)
struct LiveFeedService: FeedService {
    let baseURL: URL
    let detailService: DetailService   // ← 이미 쓰고 있는 상세 서비스 (LiveDetailService 등)

    func fetchFeeds(on date: Date) async throws -> [FeedItemModel] {
        // 1) 날짜 포맷
        let day = Self.dayString(from: date)  // "2025-08-17"

        // 2) URL 구성: /api/contents/date/{day}
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("contents")
            .appendingPathComponent("date")
            .appendingPathComponent(day)

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        // 3) 요청
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // 4) id 리스트 파싱 (여러 포맷 방어)
        let ids = try parseIDs(from: data)

        // 5) 각 id로 상세를 동시에 불러와 FeedItemModel 생성
        var items: [FeedItemModel] = []
        items.reserveCapacity(ids.count)

        try await withThrowingTaskGroup(of: FeedItemModel?.self) { group in
            for id in ids {
                group.addTask {
                    do {
                        let detail = try await detailService.fetchDetail(id: id)
                        // 홈 카드에 쓸 title/body 결정: contentTitle + fullArticleSummary(또는 coreIssue)
                        let title = detail.contentTitle
                        let body  = (!detail.fullArticleSummary.isEmpty ? detail.fullArticleSummary
                                     : detail.coreIssue)

                        return FeedItemModel(
                            id: id,
                            title: title,
                            body: body
                        )
                    } catch {
                        // 개별 실패는 리스트에서 제외
                        print("⚠️ detail fail for id \(id):", error)
                        return nil
                    }
                }
            }

            for try await result in group {
                if let item = result { items.append(item) }
            }
        }

        // (선택) 정렬 규칙이 필요하면 여기서 정렬
        return items
    }

    // MARK: helpers

    private static func dayString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.locale   = Locale(identifier: "ko_KR")
        fmt.timeZone = TimeZone(identifier: "Asia/Seoul")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    /// 날짜 엔드포인트 응답을 유연하게 파싱
    /// - 허용: ["id1","id2"...]  또는  [{"id":".."},{"_id":".."}...]
    private func parseIDs(from data: Data) throws -> [String] {
        let dec = JSONDecoder()

        // 1) [String]
        if let arr = try? dec.decode([String].self, from: data) {
            return arr
        }

        // 2) [{id:".."}] or [{"_id":".."}]
        struct Row: Decodable {
            let id: String?
            let _id: String?

            // 다른 키 이름도 대비 가능하면 추가
            // let contentId: String?
        }
        if let rows = try? dec.decode([Row].self, from: data) {
            let ids = rows.compactMap { $0.id ?? $0._id }
            if !ids.isEmpty { return ids }
        }

        // 3) { "items": [String] } / { "contents": [{...}] } 같은 래핑 객체 대응
        struct WrapA: Decodable { let items: [String] }
        if let w = try? dec.decode(WrapA.self, from: data) {
            return w.items
        }
        struct WrapB: Decodable { let contents: [Row] }
        if let w = try? dec.decode(WrapB.self, from: data) {
            let ids = w.contents.compactMap { $0.id ?? $0._id }
            if !ids.isEmpty { return ids }
        }

        // 파싱 실패
        throw URLError(.cannotParseResponse)
    }
}
