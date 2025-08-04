//
//  NEWbiEApp.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI

@main
struct NEWbiEApp: App {
    @StateObject private var navigationManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationManager.path) {
                ZStack {
                    if navigationManager.isLoggedIn {
                        HomeView()
                    } else {
                        LoginView()
                    }
                }
                .navigationDestination(for: ViewType.self) { viewType in
                    switch viewType {
                    case .edit:
                        EditView()
                    case .list(let item):
                        ListView(item: item)
                    }
                }
            }
            .environmentObject(navigationManager)
        }
    }
}
