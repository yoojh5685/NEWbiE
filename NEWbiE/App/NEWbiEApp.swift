import SwiftUI
import UserNotifications

@main
struct NEWbiEApp: App {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var notificationHandler = NotificationHandler()

    @AppStorage("didAskNotificationPermission") private var didAskNoti = false

    @StateObject private var homeVM: HomeViewModel

    init() {
        // ✅ 로컬 변수로 생성 (self 캡쳐 없음)
        let base = URL(string: "https://newsservice.shop")!
        let liveDetailService = LiveDetailService(baseURL: base)          // DetailService 프로토콜 채택
        let liveFeedService   = LiveFeedService(baseURL: base, detailService: liveDetailService)

        _homeVM = StateObject(wrappedValue: HomeViewModel(service: liveFeedService))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationManager.path) {
                ZStack {
                    if navigationManager.isLoggedIn {
                        HomeView()
                            .preferredColorScheme(.light)
                    } else {
                        LoginView()
                            .preferredColorScheme(.light)
                    }
                }
                .navigationDestination(for: ViewType.self) { viewType in
                    switch viewType {
                    case .list(let id):
                        ListView(id: id)
                            .preferredColorScheme(.light)
                    case .appSettings:
                        AppSettingsView()
                            .preferredColorScheme(.light)// ✅ 아래에서 정의
                    }
                }
            }
            .environmentObject(navigationManager)
            .environmentObject(homeVM)
            .task {
                UNUserNotificationCenter.current().delegate = notificationHandler
                if !didAskNoti {
                    await requestNotificationPermissionIfNeeded()
                    didAskNoti = true
                }
            }
        }
    }
}
