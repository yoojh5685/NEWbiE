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
    @Environment(\.openURL) private var openURL // 설정 여는 코드
    @EnvironmentObject var viewModel: HomeViewModel 
    
    //    @EnvironmentObject var viewModel: HomeViewModel   // <- 실제 서버 통신 할 때 추가
    
    
    //    init(ridingViewModel: HomeViewModel) {
    //        self.ridingViewModel = ridingViewModel
    //    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HeaderView(
                onTapSettings: {
                    navigationManager.push(.appSettings)
                }
            )
            .padding(.top, 20)
            .padding(.horizontal, 20)
                    
            DateNavigatorView(
                date: $selectedDate,
                canGoPrev: viewModel.hasYesterday(from: selectedDate),
                canGoNext: viewModel.hasTomorrow(from: selectedDate),
                onPrev: { selectedDate = moveDay(-1, from: selectedDate) },
                onNext: { selectedDate = moveDay(+1, from: selectedDate) }
            )
            .padding(.top, 30)
            .padding(.horizontal, 42)
            .padding(.bottom, 23)
                    
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.items) { item in
                        FeedCardView(
                            item: item,
                            onTap: { navigationManager.push(.list(id: item.id)) }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .task { await viewModel.load(date: selectedDate) }
        .onChange(of: selectedDate) { newValue in
            Task { await viewModel.load(date: newValue) }
        }
//        // ✅ 로딩 메시지 오버레이 추가
//        .overlay {
//            if viewModel.isLoading {
//                Text("기사를 불러오는 중입니다.")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//            }
//        }
    }
    
    private func moveDay(_ delta: Int, from base: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: delta, to: base) ?? base
    }
}

// MARK: - Header
private struct HeaderView: View {
    var onTapSettings: () -> Void
    
    var body: some View {
        HStack(spacing:0) {
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
        .padding(.horizontal, 0)
        .padding(.top, 0)
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
                imageName: "arrow-left-b",
                enabled: canGoPrev,
                activeBG: Color(.blue),
                inactiveBG: Color(.gray),
                action: onPrev, centerOffset: CGSize(width: -0.9, height: 0)
            )
            
            Spacer()
            
            Text(dateString(date))
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            CircleIconButton(
                imageName: "arrow-right-b",
                enabled: canGoNext,
                activeBG: Color(.blue),
                inactiveBG: Color(.gray),
                action: onNext, centerOffset: CGSize(width: +0.9, height: 0)
            )
        }
    }
    
    private func dateString(_ d: Date) -> String {
        let cal = Calendar(identifier: .gregorian)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.timeZone = .current
        fmt.dateFormat = "M월 d일"

        let base = fmt.string(from: d)

        if cal.isDateInToday(d) {
            return "오늘, " + base
        } else if cal.isDateInYesterday(d) {
            return "어제, " + base
        } else {
            return base
        }
    }
}

private struct CircleIconButton: View {
    let imageName: String
    let enabled: Bool
    let activeBG: Color
    let inactiveBG: Color
    let action: () -> Void
    let centerOffset: CGSize   // 👈 화살표별 보정값

    // 원/아이콘 공통 메트릭 (원 크기/아이콘 크기만 바꿔도 유지됨)
    private let circleSize: CGFloat = 28
    private let iconSize  = CGSize(width: 8.91, height: 15.27)

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(enabled ? activeBG : inactiveBG)

                Image(imageName)
                    .resizable()
                    .renderingMode(.template)     // 원본색 쓰려면 .original
                    .scaledToFit()
                    .frame(width: iconSize.width, height: iconSize.height)
                    .foregroundColor(.white)
                    .offset(centerOffset)         // ✅ 광학 중심 보정
            }
            .frame(width: circleSize, height: circleSize)
            .contentShape(Circle())
        }
        .disabled(!enabled)
        .animation(.easeInOut(duration: 0.15), value: enabled)
    }
}

// MARK: - Card

private struct FeedCardView: View {
    let item: FeedItemModel
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title.byCharWrapping)
                .font(.custom("Pretendard", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color.text200)
                .lineSpacing(24 - 16)
                .lineLimit(2)
                .padding(.bottom, 8)
            
            Text(item.body.byCharWrapping)
                .font(.custom("Pretendard", size: 15))
                .fontWeight(.regular)
                .foregroundColor(Color.text200)
                .lineSpacing(22 - 15)
                .kerning(-0.3)
                .lineLimit(3)

            // ✅ 서버에서 받은 배열을 그대로 전달 (없으면 빈 배열)
            BubbleBarView(
                progressiveMedias: item.progressiveMedias ?? [],
                conservativeMedias: item.conservativeMedias ?? []
            )
            .padding(.top, 19)
            .padding(.bottom, 40)
        }
        .onTapGesture(perform: onTap)
    }
}
