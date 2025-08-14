//
//  EditView.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI

struct EditView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gear")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text("설정")
                .font(.title)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EditView()
        .environmentObject(NavigationManager())
}


//            Button("로그아웃") {
//                navigationManager.logout()
//            }
//            .buttonStyle(.bordered)
//            .controlSize(.large)
//            .foregroundColor(.red)
