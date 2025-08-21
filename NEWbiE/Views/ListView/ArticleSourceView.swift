import SwiftUI

struct ArticleSourceView: View {
    let articles: [Article]                 // ✅ 서버에서 주입할 기사들
    
    // ✅ BiasInfoCardView로 넘길 데이터들 추가
    let progressiveRatio: CGFloat
    let conservativeRatio: CGFloat
    let progressiveMedias: [String]
    let conservativeMedias: [String]
    
    @State private var showBiasInfo = false

    var body: some View {
        let total = articles.count
        let columns = articles.chunked(into: 2) // [[상,하], [상,하], …]

        return VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack(spacing: 12) {
                Text("\(total)개의 출처기사")
                    .font(.custom("Pretendard", size: 19))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#32353B"))
                    .lineSpacing(30 - 19)

                Image("arrow_right")
                    .frame(width: 11, height: 20)
            }
            .padding(.bottom, 20)

            // 가로 스크롤 + 2단 카드
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(columns.enumerated()), id: \.offset) { _, pair in
                        VStack(spacing: 16) {
                            if let first = pair.first {
                                ArticleCardView(article: first)
                            }
                            if pair.count > 1, let second = pair.last {
                                ArticleCardView(article: second)
                            } else {
                                Spacer()   // ✅ 짝 안 맞을 때 아래를 채워줌
                            }
                        }
                    }
                    Spacer().frame(width: 4)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.none) { showBiasInfo = true } }
        .sheet(isPresented: $showBiasInfo) {
            ZStack {
                Color.clear.ignoresSafeArea()
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        BiasInfoCardView(
                            onConfirm: { withAnimation(.none) { showBiasInfo = false } },
                            progressiveRatio: progressiveRatio,
                            conservativeRatio: conservativeRatio,
                            progressiveMedias: progressiveMedias,
                            conservativeMedias: conservativeMedias
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
        .animation(nil, value: showBiasInfo)
    }
}

// 배열 2개씩 묶는 유틸
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var result: [[Element]] = []
        var chunk: [Element] = []
        for el in self {
            chunk.append(el)
            if chunk.count == size {
                result.append(chunk)
                chunk.removeAll()
            }
        }
        if !chunk.isEmpty { result.append(chunk) }
        return result
    }
}
