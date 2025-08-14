//
//  NotificationFunctions.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/15/25.
//

import SwiftUI
import UserNotifications //

// 최초 알림요청 헬퍼
func requestNotificationPermissionIfNeeded() async {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()

    switch settings.authorizationStatus {
    case .notDetermined:
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                // 허용 직후에도 원하는 초기 세팅 실행
                scheduleDailyReminder(hour: 9, minute: 0)
            } else {
                // 거부 시에는 설정 앱으로 유도 UI를 띄우는 쪽으로 처리 (필요 시)
            }
        } catch { /* 로깅 등 */ }

    case .denied:
        // 거부 상태: 필요시 설정 앱 유도 버튼 제공
        break

    case .authorized, .provisional, .ephemeral:
        // 이미 허용된 상태: 초기 스케줄 보장
        scheduleDailyReminder(hour: 9, minute: 0)
    @unknown default: break
    }
}

func scheduleDailyReminder(hour: Int, minute: Int) {
    var comps = DateComponents()
    comps.hour = hour
    comps.minute = minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
    let content = UNMutableNotificationContent()
    content.title = "NEWbiE"
    content.body = "오늘 요약 보러가기"
    content.sound = .default

    let req = UNNotificationRequest(identifier: "daily.reminder", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(req)
}
