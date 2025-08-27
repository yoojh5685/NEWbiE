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
    let progressiveMedias: [String]?
    let conservativeMedias: [String]?
}
