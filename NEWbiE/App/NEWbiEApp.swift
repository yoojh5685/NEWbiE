import SwiftUI
import UserNotifications

@main
struct NEWbiEApp: App {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var notificationHandler = NotificationHandler()
    @AppStorage("didAskNotificationPermission") private var didAskNoti = false
    @StateObject private var homeVM: HomeViewModel

    // MARK: - Splash states
    @State private var splashOpacity = 0.0
    @State private var contentOpacity = 0.0
    @State private var removeSplash = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // 👍 홈 등장에 약간의 깊이감을 주기 위한 상태
    @State private var contentScale: CGFloat = 0.98
    @State private var contentBlur: CGFloat = 4

    // 타이밍
    private let introDuration: Double = 0.9
    private let holdDelay: Double = 1.0
    private let crossFadeDuration: Double = 0.9

    init() {
        let base = URL(string: "https://newsservice.shop")!
        let liveDetailService = LiveDetailService(baseURL: base)
        let liveFeedService   = LiveFeedService(baseURL: base, detailService: liveDetailService)
        _homeVM = StateObject(wrappedValue: HomeViewModel(service: liveFeedService))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // ===== 메인 앱 컨텐츠 =====
                NavigationStack(path: $navigationManager.path) {
                    ZStack {
                        // 배경을 시스템 배경색으로 고정해 스플래시와 톤을 맞춤 (플래시 방지)
                        Color(.systemBackground).ignoresSafeArea()

                        HomeView()
                            .preferredColorScheme(.light)
//                        // 로그인 기능 추가 시
//                        if navigationManager.isLoggedIn {
//
//                        } else {
//                            LoginView()
//                                .preferredColorScheme(.light)
//                        }
                    }
                    .navigationDestination(for: ViewType.self) { viewType in
                        switch viewType {
                        case .list(let id):
                            ListView(id: id).preferredColorScheme(.light)
                        case .appSettings:
                            AppSettingsView().preferredColorScheme(.light)
                        }
                    }
                }
                .environmentObject(navigationManager)
                .environmentObject(homeVM)
                // ⬇️ 크로스 페이드 + 스케일 + 블러
                .opacity(contentOpacity)
                .scaleEffect(contentScale)
                .blur(radius: contentBlur)
                // Reduce Motion일 땐 효과 없이 바로
                .animation(reduceMotion ? .none :
                           .interpolatingSpring(stiffness: 220, damping: 24).speed(1.0),
                           value: contentScale)
                .animation(reduceMotion ? .none :
                           .easeInOut(duration: crossFadeDuration),
                           value: contentOpacity)
                .animation(reduceMotion ? .none :
                           .easeOut(duration: crossFadeDuration),
                           value: contentBlur)

                // ===== 스플래시 오버레이 =====
                if !removeSplash {
                    SplashScreen()
                        .opacity(splashOpacity)
                        .transition(.opacity)
                        .ignoresSafeArea()
                        .preferredColorScheme(.light)
                }
            }
            .task {
                UNUserNotificationCenter.current().delegate = notificationHandler
                if !didAskNoti {
                    await requestNotificationPermissionIfNeeded()
                    didAskNoti = true
                }
            }
            .onAppear {
                if reduceMotion {
                    contentOpacity = 1
                    contentScale = 1
                    contentBlur = 0
                    removeSplash = true
                    return
                }

                // 1) 스플래시 페이드 인
                withAnimation(.easeIn(duration: introDuration)) {
                    splashOpacity = 1.0
                }

                // 2) 잠깐 머문 뒤 크로스 페이드 + 홈 디테일 애니메이션
                DispatchQueue.main.asyncAfter(deadline: .now() + introDuration + holdDelay) {
                    // 페이드 전환
                    withAnimation(.easeInOut(duration: crossFadeDuration)) {
                        splashOpacity = 0.0
                        contentOpacity = 1.0
                    }
                    // 홈은 살짝 확대되며 또렷해지도록
                    withAnimation(.interpolatingSpring(stiffness: 220, damping: 24)) {
                        contentScale = 1.0
                        contentBlur = 0.0
                    }

                    // 3) 전환 완료 후 스플래시 제거
                    DispatchQueue.main.asyncAfter(deadline: .now() + crossFadeDuration) {
                        removeSplash = true
                    }
                }
            }
        }
    }
}

// MARK: - 스플래시 뷰
struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image("thumbNail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
        }
    }
}
