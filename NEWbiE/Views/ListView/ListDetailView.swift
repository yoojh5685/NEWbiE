import SwiftUI

struct ListDetailView: View {
    // MARK: - 서버에서 받아올 변수들
    let articleTitle: String
    let articleDate: String
    let summaryParagraphs: [String]
    let fullContent: String
    
    // MARK: - 상태 변수
    @State private var isSummaryExpanded = false
    @State private var summaryTextHeight: CGFloat = 0
    
    @State private var showBrief = false
    @State private var isShowingShareSheet = false
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            // MARK: - 상단 바
            HStack {
                Button(action: {
                    navigationManager.pop()
                }) {
                    Image("arrow-left")
                }
                
                Spacer()
                
                Button(action: {
                    isShowingShareSheet = true
                }) {
                    Image("share")
                }
                // 기본적인 공유 기능만 넣어둠(나중에 수정 필요)
                .sheet(isPresented: $isShowingShareSheet) {
                    ShareSheet(items: [articleTitle])
                }
            }
            .background(Color.white)
            .padding(.bottom, 18)
            
            // MARK: - ScrollView
            ScrollView {
                VStack(alignment: .leading) {
                    // MARK: - 제목
                    VStack(alignment: .leading, spacing: 4) {
                        Text(articleTitle)
                            .font(.pretendardBold(size: 26))
                            .foregroundColor(Color(hex: "#202225"))
                            .lineSpacing(10)
                            .kerning(0)
                        
                        Text(articleDate)
                            .font(.pretendardRegular(size: 13))
                            .foregroundColor(Color(hex: "#5D6574"))
                            .lineSpacing(6)
                            .kerning(-0.26)
                    }
                    .padding(.bottom, 26)
                    
                    // MARK: - 막대 바
                    BubbleBarView()
                        .padding(.bottom, 6)
                    
                    // MARK: - 요약 카드
                    HStack(spacing: 11) {
                        Rectangle()
                            .fill(Color(hex: "#8D94A3"))
                            .opacity(0.3)
                            .frame(width: 3, height: summaryTextHeight)
                        
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image("robot")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                
                                Text("배경 요약")
                                    .font(.custom("Pretendard", size: 13))
                                    .fontWeight(.medium) // 500 weight
                                    .underline(true, color: .primary)
                                    .lineSpacing(6)
                                    .kerning(-0.26)
                                
                                Button(action: {
                                    // 물음표 팝업
                                }) {
                                    Image("question")
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                }
                            }
                            // 카드 전체 탭
                            .onTapGesture {
                                withAnimation(.none) {
                                    showBrief = true
                                }
                            }
                            
                            // 요약 내용
                            summaryTextView
                            
                            // 더보기 버튼 (접기 기능 제거)
                            if !isSummaryExpanded {
                                Button(action: {
                                    isSummaryExpanded = true
                                }) {
                                    HStack(spacing: 5) {
                                        Text("요약 더 보기")
                                            .font(.custom("Pretendard", size: 15))
                                            .fontWeight(.semibold)
                                            .kerning(-0.3)
                                            .lineSpacing(0)
                                            .foregroundColor(Color(hex: "#4C525C"))
                                        
                                        Image("arrow_down")
                                            .resizable()
                                            .frame(width: 12, height: 7)
                                            .foregroundColor(Color(hex: "#4C525C"))
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background( // 높이 측정용 뷰
                            ViewHeightReader()
                        )
                    }
                    //                    .border(Color.yellow)
                    .frame(maxWidth: .infinity)
                    .onPreferenceChange(ViewHeightKey.self) { value in
                        summaryTextHeight = value
                    }
                    .background(Color.white)
                    .padding(.bottom, 30)
                    //                    .border(Color.red)
                    
                    Text(fullContent.byCharWrapping)
                        .font(.pretendardRegular(size: 17))
                        .lineSpacing(13)
                        .kerning(-0.34)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showBrief) {
            ZStack {
                Color.clear.ignoresSafeArea()
                
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        AIBriefCardView(
                            summaryParagraphs: summaryParagraphs,
                            onConfirm: { withAnimation(.none) { showBrief = false } }
                        )
                        .padding(.bottom, -geo.safeAreaInsets.bottom) // ✅ 하단 겹치기
                    }
                    // 시트 전체 영역에 딱 맞춤 + 맨 아래 정렬
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                }
                .ignoresSafeArea(edges: .bottom)                   // ✅ bottom safe area 무시
            }
            .presentationDetents([.height(352)])                   // 고정 높이
            .presentationBackground(.clear)
            .presentationDragIndicator(.hidden)
        }
        .animation(nil, value: showBrief)
    }
    
    // MARK: - 요약 텍스트 뷰
    var summaryTextView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(summaryParagraphs.indices, id: \.self) { index in
                if isSummaryExpanded || index == 0 {
                    Text(summaryParagraphs[index])
                        .font(.custom("Pretendard", size: 17))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineSpacing(8)
                        .kerning(-0.34)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
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
