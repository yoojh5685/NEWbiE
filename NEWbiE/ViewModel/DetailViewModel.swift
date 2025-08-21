//  DetailViewModel.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/18/25.
//

import Foundation

/// 뉴스 상세 데이터를 불러와 화면에 제공하는 ViewModel
@MainActor
final class DetailViewModel: ObservableObject {
    // MARK: - Published State
    @Published var detail: NewsDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // 마지막으로 불러온 id (재시도/새로고침 용)
    private(set) var lastRequestedID: String?

    // MARK: - Dependencies
    private let service: DetailService

    // MARK: - Init
    init(service: DetailService) {
        self.service = service
    }

    // MARK: - Public API
    /// 지정한 컨텐츠 id로 상세를 로드합니다.
    /// - Parameter id: 서버의 콘텐츠 id (String 고정)
    func load(id: String) async {
        lastRequestedID = id
        await performFetch(for: id)
    }

    /// 마지막 id로 다시 로드합니다. (없으면 무시)
    func reload() async {
        guard let id = lastRequestedID else { return }
        await performFetch(for: id)
    }

    // MARK: - Internal
    private func performFetch(for id: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await service.fetchDetail(id: id)
            self.detail = result

            // ===========================
            // 🧪 디버깅: 용어 매칭 존재 여부
            // ===========================
            print("🧪 [DetailVM] loaded id:", id)
            print("🧪 [DetailVM] glossary.count =", result.glossary.count)
            if let first = result.glossary.first {
                print("🧪 [DetailVM] first term =", first.term)
            }
            print("🧪 [DetailVM] bg_summary.len =", result.backgroundSummary.count,
                  "| full_article.len =", result.fullArticleSummary.count)

            // 필요 시 본문/요약 앞부분 샘플
            let bgHead = String(result.backgroundSummary.prefix(160))
            let fullHead = String(result.fullArticleSummary.prefix(160))
            print("🔎 [DetailVM] bg head →", bgHead)
            print("🔎 [DetailVM] full head →", fullHead)

            // 실제 매칭 여부 로그 (normalize + 정규식 첫 매치 검사)
            debugLogGlossaryMatches(
                backgroundSummary: result.backgroundSummary,
                fullArticleSummary: result.fullArticleSummary,
                glossary: result.glossary
            )
            // ===========================

        } catch {
            self.errorMessage = (error as NSError).localizedDescription
            self.detail = nil
            print("❌ [DetailVM] fetch error:", error.localizedDescription)
        }
    }
}
