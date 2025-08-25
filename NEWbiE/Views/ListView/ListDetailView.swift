import SwiftUI

struct ListDetailView: View {
    // MARK: - 서버에서 받아올 변수들
    let topic: String
    let date: String
    let background_summary: [String]
    let full_article_summary: String
    let glossary: [GlossaryItem]
    let mediaSummary: MediaSummary
    let reportingVolumeCompare: VolumeCompare
    
    // MARK: - 상태 변수
    @State private var isSummaryExpanded = false
    @State private var summaryTextHeight: CGFloat = 0
    @State private var showBrief = false
    @State private var showSummaryCard = false
    @State private var showFullSummary = false
    @State private var currentTerm: GlossaryItem? = nil
    @State private var showBiasInfo = false

    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            // ✅ 상단 바/공유 버튼 제거됨

            // MARK: - ScrollView
            ScrollView {
                VStack(alignment: .leading) {
                    // MARK: - 제목
                    VStack(alignment: .leading, spacing: 0) {
                        Text(topic)
                            .font(.pretendardBold(size: 26))
                            .foregroundColor(Color(hex: "#202225"))
                            .lineSpacing(10)
                            .kerning(0)
                            .padding(.bottom, 8)
                        
                        Text(date)
                            .font(.pretendardRegular(size: 13))
                            .foregroundColor(Color(hex: "#5D6574"))
                            .lineSpacing(6)
                            .kerning(-0.26)
                    }

                    // MARK: - 막대 바
                    BubbleBarView()
                        .contentShape(Rectangle())
                        .onTapGesture { withAnimation(.none) {
                            showBiasInfo = true
                        }}
                        .padding(.top, 17)

                    // MARK: - 요약 카드
                    if showSummaryCard {
                        HStack(alignment: .top, spacing: 11) {          // ✅ 상단 정렬
                            // 막대
                            VStack(spacing: 0) {                         // ✅ 위에 고정
                                Rectangle()
                                    .fill(Color(hex: "#8D94A3"))
                                    .opacity(0.3)
                                    .frame(width: 3, height: summaryTextHeight)
                                    .animation(nil, value: summaryTextHeight)   // ✅ 흔들림 방지
                                Spacer(minLength: 0)
                            }

                            // 내용
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 0) {
                                    Image("robot")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .padding(.trailing, 6)
                                    
                                    Text("배경 요약")
                                        .font(.custom("Pretendard", size: 13))
                                        .fontWeight(.medium)
                                        .underline(true, color: .primary)
                                        .lineSpacing(6)
                                        .kerning(-0.26)
                                        .padding(.trailing, 8)
                                    
                                    Image("question")
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                }
                                .onTapGesture { withAnimation(.none) { showBrief = true } }

                                // 요약 내용
                                summaryTextView
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ViewHeightReader())
                        }
                        .frame(maxWidth: .infinity)
                        .onPreferenceChange(ViewHeightKey.self) { value in
                            let newHeight = ceil(max(0, value))
                            guard abs(newHeight - summaryTextHeight) > 0.5 else { return }
                            withTransaction(Transaction(animation: nil)) {  // ✅ 값 반영도 비애니메이션
                                summaryTextHeight = newHeight
                            }
                        }
                        .background(Color.white)
                        .opacity(showSummaryCard ? 1 : 0)
                        .offset(y: showSummaryCard ? 0 : 20)
                        .padding(.top, 18)
                        .padding(.bottom, 30)
                    }
                    // MARK: - 전체 요약
                    if showFullSummary {
                        GlossaryText(
                            text: full_article_summary,
                            glossary: glossary,
                            debug: false,
                            applyByCharWrapping: true
                        ) { g in
                            currentTerm = g
                        }
                        .font(.pretendardRegular(size: 17))
                        .lineSpacing(13)
                        .kerning(-0.34)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(showFullSummary ? 1 : 0)
                        .offset(y: showFullSummary ? 0 : 20)
                    }
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)

        // ✅ AIBriefCardView 시트
        .sheet(isPresented: $showBrief) {
            ZStack {
                Color.clear.ignoresSafeArea()
                
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        AIBriefCardView(
                            onConfirm: {
                                withAnimation(.none) {
                                    showBrief = false
                                }
                            }
                        )
                        .padding(.bottom, -geo.safeAreaInsets.bottom + 34)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .presentationDetents([.height(385)])
            .presentationBackground(.clear)
            .presentationDragIndicator(.hidden)
        }

        // ✅ 용어 모달
        .sheet(item: $currentTerm) { g in
            ZStack {
                Color.clear.ignoresSafeArea()
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        TermExplanationCardView(
                            term: g.term,
                            definition: g.definition,
                            onConfirm: { withAnimation(.none) { currentTerm = nil } }
                        )
                        .padding(.bottom, -geo.safeAreaInsets.bottom + 34)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .presentationDetents([.medium, .large]) // 기본 크기 유지, 글 길면 자동 확장
            .presentationBackground(.clear)
            .presentationDragIndicator(.hidden)
        }

        // ✅ BiasInfoCardView 모달 시트 (막대바 탭)
        .sheet(isPresented: $showBiasInfo) {
            ZStack {
                Color.clear.ignoresSafeArea()
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        BiasInfoCardView(
                            onConfirm: { withAnimation(.none) { showBiasInfo = false } },
                            progressiveRatio: CGFloat(reportingVolumeCompare.progressive),
                            conservativeRatio: CGFloat(reportingVolumeCompare.conservative),
                            progressiveMedias: mediaSummary.progressive,
                            conservativeMedias: mediaSummary.conservative
                        )
                        .padding(.bottom, -geo.safeAreaInsets.bottom + 34)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .presentationDetents([.height(497)])
            .presentationBackground(.clear)
            .presentationDragIndicator(.hidden)
        }

        .animation(nil, value: showBrief)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    showSummaryCard = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    showFullSummary = true
                }
            }
        }
    }
    
    // MARK: - Summary Text View
    var summaryTextView: some View {
        // 1) 문단 분리
        let paragraphs: [String] = background_summary
            .flatMap { $0.splitIntoParagraphsByPeriod() }

        // 2) 접힘 로직 유지
        let collapsedCount = 2
        let visible: [String] = isSummaryExpanded
            ? paragraphs
            : Array(paragraphs.prefix(collapsedCount))

        // 3) GlossaryText만 사용
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(visible.enumerated()), id: \.offset) { _, para in
                GlossaryText(
                    text: para,
                    glossary: glossary,
                    debug: false,
                    applyByCharWrapping: true,
                    onTapTerm: { g in
                        currentTerm = g
                    }
                )
                .font(.custom("Pretendard", size: 17))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineSpacing(8)
                .kerning(-0.34)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            }
            // 더보기 버튼
            if !isSummaryExpanded && paragraphs.count > collapsedCount {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isSummaryExpanded = true }
                } label: {
                    HStack(spacing: 5) {
                        Text("요약 더 보기")
                            .font(.custom("Pretendard", size: 15))
                            .fontWeight(.semibold)
                            .kerning(-0.3)
                            .foregroundColor(Color(hex: "#4C525C"))
                        Image("arrow_down")
                            .resizable()
                            .frame(width: 12, height: 7)
                            .foregroundColor(Color(hex: "#4C525C"))
                    }
                }
            }
        }
    }
}

// MARK: - ViewHeightKey
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - ViewHeightReader (Text 높이 측정용)
struct ViewHeightReader: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightKey.self, value: geometry.size.height)
        }
    }
}

// MARK: - Helpers
private extension String {
    /// "문장. 문장." → ["문장.", "문장."] (공백/개행 정리, 빈 조각 제거)
    func splitIntoParagraphsByPeriod() -> [String] {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // '.' 기준으로 나누고 다시 '.' 붙여서 반환
        return trimmed
            .split(separator: ".", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0 + "." }
    }
}
