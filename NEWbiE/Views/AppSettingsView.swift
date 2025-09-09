import SwiftUI
import UserNotifications
import WebKit   // ⬅️ 추가

// MARK: - WKWebView Wrapper
private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView { WKWebView() }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

// MARK: - 개인정보처리방침 화면 (백버튼/네비색 처리)
private struct PolicyWebView: View {
    @Environment(\..dismiss) private var dismiss

    let urlString: String
    let title: String

    var body: some View {
        WebView(url: URL(string: urlString)!)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)                    // 기본 백버튼 숨김
            .toolbarBackground(Color.white, for: .navigationBar)    // 네비게이션바 흰색
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {                 // ← AppSettingsView와 동일한 커스텀 백버튼
                        Image("arrow-left")
                            .padding(.leading, 5)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(size: 16, weight: .regular))
                }
            }
    }
}

struct AppSettingsView: View {
    @Environment(\..dismiss) private var dismiss
    @Environment(\..scenePhase) private var scenePhase
    @Environment(\..verticalSizeClass) private var vSize

    @AppStorage("appNotificationEnabled") private var appNotificationEnabled: Bool = true
    @State private var isNotificationOn: Bool = false
    @State private var userToggled = false
    @State private var showGoToSettingsAlert = false

    // ✅ 네비게이션바 appearance 초기 설정
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGroupedBackground  // 배경색 동일하게
        appearance.shadowColor = .clear                                // 선 제거

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some View {
        let isLandscape = (vSize == .compact)

        Group {
            if isLandscape {
                ScrollView(.vertical, showsIndicators: false) {
                    content.padding(.bottom, 24)
                }
            } else {
                content
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(EnableInteractivePopGesture())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("arrow-left")
                        .padding(.leading, 5)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .font(.system(size: 16, weight: .regular))
            }
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 48)
        }
        .onAppear { Task { await refreshToggleFromSystem() } }
        .onChange(of: scenePhase) { phase in
            if phase == .active { Task { await refreshToggleFromSystem() } }
        }
        .alert("시스템에서 알림을 끌 수 있어요", isPresented: $showGoToSettingsAlert) {
            Button("취소", role: .cancel) {
                isNotificationOn = true
                appNotificationEnabled = true
            }
            Button("설정 열기") { openSystemNotificationSettings() }
        } message: {
            Text("앱 알림을 완전히 끄려면 iOS 설정에서\n알림 허용을 꺼주세요.")
        }
    }

    // MARK: - 본문
    private var content: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("설정")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                HStack(spacing: 12) {
                    Text("알림설정")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)

                    Spacer()

                    Toggle("", isOn: $isNotificationOn)
                        .labelsHidden()
                        .simultaneousGesture(TapGesture().onEnded { userToggled = true })
                        .onChange(of: isNotificationOn) { on in
                            guard userToggled else { return }
                            userToggled = false

                            if on {
                                appNotificationEnabled = true
                                Task { await ensureSystemEnabledAndSchedule() }
                            } else {
                                appNotificationEnabled = false
                                cancelDailyReminders()   // ⬅️ 아침/저녁 모두 취소
                                showGoToSettingsAlert = true
                            }
                        }
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
                .padding(.horizontal, 20)

                Text("정보")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 0) {
                    // 개인정보처리방침: 커스텀 백버튼/흰색 네비 포함한 래퍼 화면으로 이동
                    SettingsRow(title: "서비스 이용약관")
                    Divider().padding(.leading, 16)
                    NavigationLink(
                        destination: PolicyWebView(
                            urlString: "https://hguhimin.notion.site/2621653962958053b7a7ff318ea9dd0f?source=copy_link",
                            title: "개인정보처리방침"
                        )
                    ) {
                        SettingsRow(title: "개인정보처리방침")
                    }

                    Divider().padding(.leading, 16)
                    SettingsRow(title: "고객센터")
                    Divider().padding(.leading, 16)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            Spacer()
        }
    }

    // MARK: - 동기화 함수들
    private func refreshToggleFromSystem() async {
        let sysOn = await isSystemNotificationAuthorized()
        await MainActor.run { self.isNotificationOn = (sysOn && appNotificationEnabled) }
    }

    /// 시스템 권한 상태에 맞춰 NEWbiE 아침(08:00)/저녁(18:00) 알림을 스케줄링
    private func ensureSystemEnabledAndSchedule() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            await scheduleMorningAndEveningReminders()   // ⬅️ 변경: 9시 단일 → 아침/저녁 2개
            await refreshToggleFromSystem()
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            if granted {
                await scheduleMorningAndEveningReminders()
            } else {
                await MainActor.run { self.appNotificationEnabled = false }
            }
            await refreshToggleFromSystem()
        case .denied:
            openSystemNotificationSettings()
            await refreshToggleFromSystem()
        @unknown default:
            await refreshToggleFromSystem()
        }
    }

    private func isSystemNotificationAuthorized() async -> Bool {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        switch s.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    private func openSystemNotificationSettings() {
        DispatchQueue.main.async {
            if let url = URL(string: UIApplication.openNotificationSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }

    /// 기존 대기 알림(아침/저녁) 모두 취소
    private func cancelDailyReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [
                "reminder.morning",   // NotificationFunctions.swift의 ID와 동일해야 함
                "reminder.evening"
            ])
    }
}

private struct SettingsRow: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .contentShape(Rectangle())
    }
}
