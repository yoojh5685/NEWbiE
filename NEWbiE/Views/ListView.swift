//
//  ListView.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI

struct ListView: View {
    let item: String
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text("상세 정보")
                .font(.title)
                .fontWeight(.semibold)
            
            Text(item)
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle(item)
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    ListView(item: "Preview Item")
        .environmentObject(NavigationManager())
}
