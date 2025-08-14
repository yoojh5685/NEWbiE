////
////  EditView.swift
////  NEWbiE
////
////  Created by 유재혁 on 8/5/25.
////
//
//import SwiftUI
//
//struct EditView: View {
//    @EnvironmentObject var navigationManager: NavigationManager
//    
//    @Environment(\.openURL) private var openURL
//    var body: some View {
//        Button("iOS 설정에서 변경하기") {
//            openURL(URL(string: UIApplication.openSettingsURLString)!)
//        }
//    }
//}
//
//#Preview {
//    EditView()
//        .environmentObject(NavigationManager())
//}
//
//
////            Button("로그아웃") {
////                navigationManager.logout()
////            }
////            .buttonStyle(.bordered)
////            .controlSize(.large)
////            .foregroundColor(.red)
