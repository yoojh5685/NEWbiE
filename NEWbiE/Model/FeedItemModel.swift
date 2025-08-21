//
//  FeedItemModel.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/14/25.
//

import Foundation

struct FeedItemModel: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let body: String
    // 나중에 감정 바(파랑↔빨강) 쓰려면 점수 넣으면 됨 (지금은 안 씀)
    // let score: Double?
}
