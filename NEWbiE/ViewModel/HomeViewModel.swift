//
//  HomeViewModel.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/14/25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [FeedItemModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var hasYesterday = false
    @Published var hasTomorrow = false
    

    private let service: FeedService

    init(service: FeedService) {
        self.service = service
        
        self.hasYesterday = false          // 서버 응답값으로 대체
        self.hasTomorrow = true          // 서버 응답값으로 대체
        
        
    }

    func load(date: Date) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await service.fetchFeeds(on: date)
            self.items = result
        } catch {
            self.errorMessage = error.localizedDescription
            self.items = []
        }
        
        
    }
}
