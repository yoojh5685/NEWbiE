// HomeViewModel.swift
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [FeedItemModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: FeedService

    init(service: FeedService) {
        self.service = service
    }

    func load(date: Date) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.fetchFeeds(on: date)
            self.items = result
        } catch {
            self.items = []
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Navigation guards
    private var cal: Calendar { Calendar(identifier: .gregorian) }

    /// 어제 버튼은 언제나 가능(최소 날짜 제한이 생기면 여기서 제어)
    func hasYesterday(from date: Date) -> Bool { true }

    /// 아직 오지 않은 날(= 오늘 이후)로는 못 가게
    func hasTomorrow(from date: Date) -> Bool {
        let startOfToday = cal.startOfDay(for: Date())
        let startOfGiven = cal.startOfDay(for: date)
        // date가 오늘보다 과거일 때만 "다음 날"로 이동 가능
        return startOfGiven < startOfToday
    }
}
