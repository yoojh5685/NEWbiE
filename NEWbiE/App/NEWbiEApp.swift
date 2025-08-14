import SwiftUI

@main
struct NEWbiEApp: App {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var homeVM = HomeViewModel(service: MockFeedService()) // <- 주입할 VM

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
            .environmentObject(homeVM) // <- 여기서 homeViewModel 넣어주기
//            BiasInfoCardView()
        }
    }
}
