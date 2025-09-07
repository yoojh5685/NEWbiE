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

    // ✅ BubbleBarView 리마운트용 키 (버블 애니 재시작 컨트롤)
    @State private var bubbleRestartKey = UUID()

    // ====== 좌우 스와이프 페이징(리스트만 슬라이드) 상태 ======
    @State private var listDrag: CGFloat = 0              // 드래그 중 따라오는 값
    @State private var listOffset: CGFloat = 0            // 전환용 오프셋(인 단계만 애니메이션)
    @State private var isHorizontalSwipeActive = false    // 가로 제스처 활성화 여부
    @State private var isTransitioning = false            // 전환 중(겹침 방지용)

    private let swipeThreshold: CGFloat = 60              // 페이징 트리거 임계값
    private let activateThreshold: CGFloat = 12           // 가로/세로 판별 최소 이동량
    private let pageAnimDuration: Double = 0.22           // 인(들어오기) 애니메이션 시간
    private let pageGapFactor: CGFloat = 1.05             // 아웃 스냅 위치(살짝 더 나가 보이도록)

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            VStack(alignment: .leading, spacing: 0){
                HeaderView(
                    onTapSettings: { navigationManager.push(.appSettings) }
                )
                .padding(.top, 20)
                .padding(.horizontal, 20)

                DateNavigatorView(
                    date: $selectedDate,
                    canGoPrev: viewModel.hasYesterday(from: selectedDate),
                    canGoNext: viewModel.hasTomorrow(from: selectedDate),

                    // ✅ 버튼 → 스와이프와 동일한 슬라이드 전환 사용
                    onPrev: {
                        guard viewModel.hasYesterday(from: selectedDate) else { return }
                        slideOutAndIn(direction: .previous, width: width)
                    },
                    onNext: {
                        guard viewModel.hasTomorrow(from: selectedDate) else { return }
                        slideOutAndIn(direction: .next, width: width)
                    }
                )
                .padding(.top, 30)
                .padding(.horizontal, 42)
                .padding(.bottom, 23)

                // =========================
                // 리스트 영역 (여기만 ‘페이지 넘김’처럼 슬라이드)
                // =========================
                ZStack {
                    Color.clear
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.items) { item in
                                FeedCardView(
                                    item: item,
                                    restartKey: bubbleRestartKey,
                                    onTap: { navigationManager.push(.list(id: item.id)) }
                                )
                                .padding(.horizontal, 20)
                            }
                            // 피드가 비어 있어도 스와이프 가능하도록 공간 확보
                            if viewModel.items.isEmpty {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 240)
                                    .accessibilityHidden(true)
                            }
                        }
                        // 데이터 리로드 시 암묵적 레이아웃 애니메이션 차단(겹침 방지)
                        .animation(.none, value: viewModel.items.count)
                    }
                    // 리스트만 움직이도록 오프셋 적용 (인 단계만 애니메이션됨)
                    .offset(x: listOffset + listDrag)
                    .id(selectedDate)   // 새 날짜에서 뷰를 재생성 → 겹침 방지
                    .clipped()
                }
                .contentShape(Rectangle())
                // ✅ simultaneousGesture: 세로 스크롤과 공존. 가로 우세 + 최소 이동량일 때만 활성
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onChanged { value in
                            let dx = value.translation.width
                            let dy = value.translation.height

                            if !isHorizontalSwipeActive {
                                if abs(dx) > abs(dy), abs(dx) > activateThreshold {
                                    isHorizontalSwipeActive = true
                                } else {
                                    return // 세로 스크롤에 양보
                                }
                            }
                            listDrag = dx
                        }
                        .onEnded { value in
                            guard isHorizontalSwipeActive else { return }
                            let w = value.translation.width

                            if w < -swipeThreshold, viewModel.hasTomorrow(from: selectedDate) {
                                // ⬅️ 다음(미래) 날짜로
                                withoutAnimation { listDrag = 0 } // 충돌 방지
                                isHorizontalSwipeActive = false
                                slideOutAndIn(direction: .next, width: width)
                            } else if w > swipeThreshold, viewModel.hasYesterday(from: selectedDate) {
                                // ➡️ 이전(과거) 날짜로
                                withoutAnimation { listDrag = 0 }
                                isHorizontalSwipeActive = false
                                slideOutAndIn(direction: .previous, width: width)
                            } else {
                                // 임계값 미달 → 스냅백만
                                withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.9)) {
                                    listDrag = 0
                                }
                                isHorizontalSwipeActive = false
                            }
                        }
                )
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            // ✅ 홈으로 돌아왔을 때 버블 애니메이션 재시작
            bubbleRestartKey = UUID()
        }
        .task { await viewModel.load(date: selectedDate) }
        .onChange(of: selectedDate) { newValue in
            // ⬅️ 데이터 로드만. (버튼/스와이프 경로에서 각각 타이밍 맞춰 재시작함)
            Task { await viewModel.load(date: newValue) }
        }
    }

    // MARK: - 스와이프/버튼 공용 전환
    private enum PageDirection { case previous, next }

    /// 리스트만 좌/우로 슬라이드: 아웃(스냅) → 날짜 변경(스냅) → 인(애니)
    // MARK: - 스와이프/버튼 공용 전환
    private func slideOutAndIn(direction: PageDirection, width: CGFloat) {
        let outTarget = (direction == .next) ? -width * pageGapFactor : width * pageGapFactor
        let inStart   = (direction == .next) ?  width : -width
        let delta     = (direction == .next) ? +1 : -1

        isTransitioning = true

        // 1) 아웃: 즉시 화면 밖으로
        withoutAnimation { listOffset = outTarget }

        // 2) 날짜 변경 + 새 페이지를 반대쪽에 대기
        withoutAnimation {
            selectedDate = moveDay(delta, from: selectedDate)
            listOffset = inStart
        }

        // 3) 인: 부드럽게 제자리로
        withAnimation(.easeInOut(duration: pageAnimDuration)) {
            listOffset = 0
        }

        // 4) ✅ 애니메이션 끝난 뒤 버블 리마운트
        DispatchQueue.main.asyncAfter(deadline: .now() + pageAnimDuration) {
            bubbleRestartKey = UUID()
            isTransitioning = false
        }
    }

    private func moveDay(_ delta: Int, from base: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: delta, to: base) ?? base
    }

    // 애니메이션 없이 상태 업데이트
    private func withoutAnimation(_ updates: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { updates() }
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
    let centerOffset: CGSize

    private let circleSize: CGFloat = 28
    private let iconSize  = CGSize(width: 8.91, height: 15.27)

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(enabled ? activeBG : inactiveBG)

                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: iconSize.width, height: iconSize.height)
                    .foregroundColor(.white)
                    .offset(centerOffset)
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
    let restartKey: UUID
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

            // BubbleBarView는 restartKey로 매번 리마운트 → onAppear 재실행
            BubbleBarView(
                progressiveMedias: item.progressiveMedias ?? [],
                conservativeMedias: item.conservativeMedias ?? []
            )
            .id(restartKey)
            .frame(maxWidth: .infinity)
            .padding(.top, 19)
            .padding(.bottom, 40)
        }
        .onTapGesture(perform: onTap)
    }
}
