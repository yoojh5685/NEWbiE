//
//  LoginView.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI
import UserNotifications

struct LoginView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    @AppStorage("didAskNotificationPermission") private var didAskNoti = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("logo_v1")
                .resizable()
                .frame(width: 300, height: 300)
                .foregroundStyle(.tint)
            
            Button("로그인") {
                navigationManager.login()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(NavigationManager())
}
