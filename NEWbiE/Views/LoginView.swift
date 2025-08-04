//
//  LoginView.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .imageScale(.large)
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            Text("NEWbiE")
                .font(.largeTitle)
                .fontWeight(.bold)
            
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
