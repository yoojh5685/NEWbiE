import SwiftUI
import UserNotifications

@main
struct NEWbiEApp: App {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var homeVM = HomeViewModel(service: MockFeedService()) // <- 주입할 VM
    @StateObject private var notificationHandler = NotificationHandler()

    @AppStorage("didAskNotificationPermission") private var didAskNoti = false  // ⭐️ 추가
    
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
//                    case .edit:
//                        EditView()
                    case .list(let item):
                        ListView(item: item)
                    }
                }
            }
            .environmentObject(navigationManager)
            .environmentObject(homeVM) // <- 여기서 homeViewModel 넣어주기
//            BiasInfoCardView()
            .task {
                // 1) delegate 지정 (포그라운드에서도 배너/사운드)
                UNUserNotificationCenter.current().delegate = notificationHandler
                
                // 2) 최초 1회만 권한 요청 (로그인 여부 무관)
                if !didAskNoti {
                    await requestNotificationPermissionIfNeeded()
                    didAskNoti = true
                }
            }
        }
    }
}
