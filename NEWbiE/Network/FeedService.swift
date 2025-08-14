//
//  FeedService.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/14/25.
//

import Foundation

protocol FeedService {
    /// 선택한 날짜의 피드 목록을 가져온다
    func fetchFeeds(on date: Date) async throws -> [FeedItemModel]
}

// MARK: - Mock
struct MockFeedService: FeedService {
    func fetchFeeds(on date: Date) async throws -> [FeedItemModel] {
        // 네트워크처럼 보이도록 살짝 딜레이
        try await Task.sleep(nanoseconds: 250_000_000)
        return [
            FeedItemModel(id: 1,
                     title: "여기에 몇 글자까지 들어갈까요 저도 궁금한데요 띄어쓰기 포함 최소 30자 최대 58자라고 한번 정해보겠습니다",
                     body: "여기는 최소만 정해두고, 최대는 …으로 통일하겠습니다. 최소는 몇글자가 될까요 한번 적어볼게요. 정권 교체 시 공직사회 갈등은 반복돼요. 업무보고는 국정과제 수립의 핵심 절차…"),
            FeedItemModel(id: 2,
                     title: "두 번째 카드 제목 예시입니다. 길이가 살짝 달라도 잘 줄바꿈되게",
                     body: "본문도 2~3줄로 잘리도록 lineLimit만 조절합니다. 실제 서버 데이터 형식과 최대한 비슷하게 만들어두면 교체가 쉬워요."),
            FeedItemModel(id: 3,
                     title: "세 번째 카드",
                     body: "이건 테스트용 더미 텍스트입니다. 디자인 확인용으로만 사용합니다.")
        ]
    }
}

// MARK: - Live(향후 실제 서버 연결 시)
struct LiveFeedService: FeedService {
    let baseURL: URL

    func fetchFeeds(on date: Date) async throws -> [FeedItemModel] {
        // TODO: 실제 엔드포인트에 맞게 구현
        // 1) URLRequest 구성 (date 쿼리 포함)
        // 2) URLSession.data(for:) 호출
        // 3) JSONDecoder로 [FeedItem] 디코딩
        return []
    }
}
