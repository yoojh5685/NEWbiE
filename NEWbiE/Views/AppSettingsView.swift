import SwiftUI
import UserNotifications

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var vSize

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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image("arrow-left")
                        .padding(.top, 30)
                        .padding(.leading, 5)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.top, 30)
            }
        }
        // 🔑 여기 추가 → 화면 상단에서 네비게이션 바까지 30 띄움
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 70)
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
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                HStack(spacing: 12) {
                    Text("알림설정")
                        .font(.system(size: 16))
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
                                cancelDailyReminder()
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
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 0) {
                    SettingsRow(title: "업데이트 안내")
                    Divider().padding(.leading, 16)
                    SettingsRow(title: "서비스 이용약관")
                    Divider().padding(.leading, 16)
                    SettingsRow(title: "개인정보처리방침")
                    Divider().padding(.leading, 16)
                    SettingsRow(title: "고객센터")
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

    private func ensureSystemEnabledAndSchedule() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            scheduleDailyReminder(hour: 9, minute: 0)
            await refreshToggleFromSystem()
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            if granted { scheduleDailyReminder(hour: 9, minute: 0) }
            else { await MainActor.run { self.appNotificationEnabled = false } }
            await refreshToggleFromSystem()
        case .denied:
            openSystemNotificationSettings()
            await refreshToggleFromSystem()
        @unknown default: await refreshToggleFromSystem()
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

    private func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily.reminder"])
    }
}

private struct SettingsRow: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}
