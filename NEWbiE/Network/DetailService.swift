import Foundation

protocol DetailService {
    func fetchDetail(id: String) async throws -> NewsDetail
}

//extension DetailService {
//    // 테스트용 고정 id 호출
//    func fetchFixedDetail() async throws -> NewsDetail {
//        try await fetchDetail(id: "68a1314edc6a64f30b075fed")
//    }
//}

struct LiveDetailService: DetailService {
    let baseURL: URL   // ← 이제 API.baseURL 고정 안 하고 외부에서 주입받음

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func fetchDetail(id: String) async throws -> NewsDetail {
        let url = baseURL.appendingPathComponent("api")
                         .appendingPathComponent("contents")
                         .appendingPathComponent(id.trimmingCharacters(in: .whitespacesAndNewlines))
        print("🔎 GET:", url.absoluteString)

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 15
        req.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "DetailService",
                          code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(NewsDetail.self, from: data)
    }
}
