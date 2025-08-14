//
//  NavigationManager.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import Foundation
import SwiftUI

enum ViewType: Hashable {
//    case edit
    case list(item: String)
}

final class NavigationManager: ObservableObject {
    @Published var path: [ViewType] = [] {
        didSet {
            print("Path changed: \(path)")
        }
    }
    @Published var isLoggedIn: Bool = false

    func push(_ view: ViewType) {
        print("Pushing view: \(view)")
        path.append(view)
        print("Current path count: \(path.count)")
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }
    
    func login() {
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
        popToRoot() // 로그아웃 시 모든 화면을 초기화
    }
}
