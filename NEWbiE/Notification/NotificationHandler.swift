//
//  NotificationHandler.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/15/25.
//

import SwiftUI
import UserNotifications

final class NotificationHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var lastRoute: String?

    // 앱이 켜져 있을 때도 배너/사운드 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }

    // 사용자가 알림을 탭했을 때 라우팅 정보 전달
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let route = response.notification.request.content.userInfo["route"] as? String
        DispatchQueue.main.async { self.lastRoute = route }
        completionHandler()
    }
}
