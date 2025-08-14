//
//  HomeView.swift
//  NEWbiE
//
//  Created by 유재혁 on 8/5/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedDate: Date = .now
    @StateObject private var viewModel = HomeViewModel(service: MockFeedService()) // 이거 실제 서버 할 땐 없애고
    
//    @EnvironmentObject var viewModel: HomeViewModel   // <- 실제 서버 통신 할 때 추가


//    init(ridingViewModel: HomeViewModel) {
//        self.ridingViewModel = ridingViewModel
//    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView(
                    onTapSettings: { navigationManager.push(.edit) }
                )

                DateNavigatorView(
                    date: $selectedDate,
                    canGoPrev: viewModel.hasYesterday,
                    canGoNext: viewModel.hasTomorrow,
                    onPrev: { selectedDate = moveDay(-1, from: selectedDate) },
                    onNext: { selectedDate = moveDay(+1, from: selectedDate) }
                )
                .padding(.vertical, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 24) {
                    ForEach(viewModel.items) { item in
                        FeedCardView(
                            item: item,
                            onTap: { navigationManager.push(.list(item: "Item \(item.id)")) }
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.top, 8)
        }
        .background(Color(.systemBackground))
        .task { await viewModel.load(date: selectedDate) }
        .onChange(of: selectedDate) { newValue in
            Task { await viewModel.load(date: newValue) }
        }
        //   로딩 / 에러 옵션 표시
//        .overlay {
//            if viewModel.isLoading {
//                ProgressView().scaleEffect(1.2)
//            }
//        }
//        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil), actions: {
//            Button("확인", role: .cancel) { viewModel.errorMessage = nil }
//        }, message: {
//            Text(viewModel.errorMessage ?? "")
//        })
    }

    private func moveDay(_ delta: Int, from base: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: delta, to: base) ?? base
    }
}

// MARK: - Header
private struct HeaderView: View {
    var onTapSettings: () -> Void

    var body: some View {
        HStack {
            Image("NEWbiE")
                .resizable()
                .scaledToFit()
                .frame(height: 24)

            Spacer()

            Button(action: onTapSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(Color.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Date Navigator
private struct DateNavigatorView: View {
    @Binding var date: Date
    
    var canGoPrev: Bool
    var canGoNext: Bool
    
    var onPrev: () -> Void
    var onNext: () -> Void

    var body: some View {
        HStack {
            CircleIconButton(
                systemName: "chevron.left",
                enabled: canGoPrev,
                activeBG: Color(.blue),
                inactiveBG: Color(.gray),
                action: onPrev
            )
            
            Spacer()
            
            Text(dateString(date))
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            CircleIconButton(
                systemName: "chevron.right",
                enabled: canGoNext,
                activeBG: Color(.blue),
                inactiveBG: Color(.gray),
                action: onNext
            )
        }
    }

    private func dateString(_ d: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "오늘, M월 d일"
        return fmt.string(from: d)
    }
}

private struct CircleIconButton: View {
    let systemName: String
    let enabled: Bool
    let activeBG: Color
    let inactiveBG: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline.weight(.semibold))
                .foregroundColor(Color.white)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(enabled ? activeBG : inactiveBG)
                )
        }
        .disabled(!enabled)            // 탭 막기
        .animation(.easeInOut(duration: 0.15), value: enabled)
    }
}


// MARK: - Card

private struct FeedCardView: View {
    let item: FeedItemModel
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(item.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            // 여기에 색 바 나중에 추가할게
            
        }
        .padding(16)
        .onTapGesture(perform: onTap)
    }
}


#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}


// 서버 통신 시
//#Preview {
//    HomeView()
//        .environmentObject(NavigationManager())
//        .environmentObject(HomeViewModel(service: MockFeedService()))
//}
