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
                    navigationManager.push(.appSettings)   // ✅ 시스템 설정으로 바로 가지 않음
                }
            )
            .padding(.top, 20)
            .padding(.horizontal, 20)
                    
            // HomeView.swift (본문의 DateNavigatorView 부분만 교체)
            DateNavigatorView(
                date: $selectedDate,
                canGoPrev: viewModel.hasYesterday(from: selectedDate),
                canGoNext: viewModel.hasTomorrow(from: selectedDate),
                onPrev: { selectedDate = moveDay(-1, from: selectedDate) },
                onNext: { selectedDate = moveDay(+1, from: selectedDate) }
            )
                    .padding(.top, 30)
                    .padding(.horizontal, 45)
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
                    } // : VStack
            }
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
    let systemName: String
    let enabled: Bool
    let activeBG: Color
    let inactiveBG: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 10))
                .font(.headline.weight(.semibold))
                .foregroundColor(Color.white)
                .frame(width: 22, height: 22)
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
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.pretendardSemiBold(size: 16))
                .foregroundColor(Color.text200)
                .lineLimit(2)
                .padding(.bottom, 8)
            
            Text(item.body)
                .font(.pretendardRegular(size: 15))
                .foregroundColor(Color.text200)
                .lineLimit(3)
            
            BubbleBarView()
                .padding(.top,19)
                .padding(.bottom, 40)
            
        }
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
