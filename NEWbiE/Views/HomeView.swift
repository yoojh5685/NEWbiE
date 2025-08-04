//
//  HomeView.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            HStack {
                Text("홈")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    print("Settings button tapped")
                    navigationManager.push(.edit)
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
            .padding()

            List {
                ForEach(0..<5) { index in
                    Button(action: {
                        print("List item \(index) tapped")
                        navigationManager.push(.list(item: "Item \(index)"))
                    }) {
                        HStack {
                            Text("Item \(index)")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
