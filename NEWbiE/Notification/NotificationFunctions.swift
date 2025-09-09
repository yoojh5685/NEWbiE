//
//  NotificationFunctions.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/15/25.
//  Updated by ChatGPT on 9/9/25 — 아침/저녁 시간 분리(8시/18시), 문구 여러 개 로테이션
//

import SwiftUI
import UserNotifications

// MARK: - Public API
/// 최초 알림 요청 + 스케줄 보장
/// - 권한이 허용되면 매일 아침 8시 / 저녁 6시에 알림을 잡습니다.
/// - 문구는 아래 메시지 풀에서 선택됩니다.
func requestNotificationPermissionIfNeeded() async {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()

    switch settings.authorizationStatus {
    case .notDetermined:
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await scheduleMorningAndEveningReminders()
            } else {
                // 거부 시: 필요하면 설정 앱 유도 UI 노출
            }
        } catch {
            // 로깅 등
        }

    case .denied:
        // 거부 상태: 필요시 설정 앱 유도 버튼 제공
        break

    case .authorized, .provisional, .ephemeral:
        await scheduleMorningAndEveningReminders()

    @unknown default:
        break
    }
}

/// 아침/저녁 2개 알림을 스케줄링.
/// 이미 잡혀 있던 동일 ID 알림은 정리 후 다시 잡습니다.
@MainActor
func scheduleMorningAndEveningReminders() async {
    let center = UNUserNotificationCenter.current()

    // 중복 방지를 위해 기존 대기 알림 제거
    let ids = [NotificationID.morning.rawValue, NotificationID.evening.rawValue]
    center.removePendingNotificationRequests(withIdentifiers: ids)

    // 오늘 날짜 기반으로 문구를 선택(하루에 한 문구 고정이 되도록 결정적 선택)
    let today = Date()

    // 아침 8시
    let morningContent = NotificationContentFactory.content(for: .morning, referenceDate: today)
    let morningTrigger = makeDailyTrigger(hour: 8, minute: 0)
    let morningReq = UNNotificationRequest(identifier: NotificationID.morning.rawValue,
                                           content: morningContent,
                                           trigger: morningTrigger)

    // 저녁 6시
    let eveningContent = NotificationContentFactory.content(for: .evening, referenceDate: today)
    let eveningTrigger = makeDailyTrigger(hour: 18, minute: 00)
    let eveningReq = UNNotificationRequest(identifier: NotificationID.evening.rawValue,
                                           content: eveningContent,
                                           trigger: eveningTrigger)

    do {
        try await center.add(morningReq)
        try await center.add(eveningReq)
    } catch {
        // 로깅 등
    }
}

// MARK: - Helpers
private enum TimeSlot { case morning, evening }
private enum NotificationID: String { case morning = "reminder.morning", evening = "reminder.evening" }

private enum NotificationContentFactory {
    // 제공된 문구(개행/공백 포함)는 그대로 유지합니다.
    private static let morningPool: [String] = [
        // ver.1 아침
        "밤 사이 어떤 소식이 있었을까요?\n\n지금 뉴비에서 확인해보세요!",
        // ver.3 아침
        "오늘 아침 수다에 끼고 싶다면!",
        // ver.4 아침
        "점심 토크에서 좀 ‘아는 체’ 할 수 있는 "
    ]

    private static let eveningPool: [String] = [
        // ver.2 저녁
        "똑똑! 똑똑함 채우러 갈 사람~",
        // ver.5 저녁
        "퇴근길 1분 투자로 비판적 시각 기르러 가기!"
    ]

    /// 날짜 기준 결정적 인덱스로 문구 선택(앱 재실행 시에도 같은 날엔 동일 문구)
    private static func pickMessage(from pool: [String], date: Date) -> String {
        let dayNumber = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? Int.random(in: 0...365)
        let idx = dayNumber % max(pool.count, 1)
        return pool[idx]
    }

    static func content(for slot: TimeSlot, referenceDate: Date) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "NEWbiE"

        switch slot {
        case .morning:
            content.body = pickMessage(from: morningPool, date: referenceDate)
        case .evening:
            content.body = pickMessage(from: eveningPool, date: referenceDate)
        }

        content.sound = .default
        return content
    }
}

fileprivate func makeDailyTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
    var comps = DateComponents()
    comps.hour = hour
    comps.minute = minute
    return UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
}


// MARK: - 사용 가이드
// 1) 앱 시작 시점(App/SceneDelegate 등)에서 아래를 호출하세요.
//    Task { await requestNotificationPermissionIfNeeded() }
// 2) 문구는 하루 단위로 고정 선택됩니다. 문구를 매일 바꾸려면
//    앱이 최소 하루에 한 번은 실행되어 scheduleMorningAndEveningReminders()가 호출되도록 해주세요.
//    (백그라운드 갱신/푸시 토큰 갱신 시점 등에 함께 호출해도 좋습니다.)
