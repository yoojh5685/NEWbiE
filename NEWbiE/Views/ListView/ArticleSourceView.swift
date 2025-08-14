import SwiftUI

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let press: String
    let color: Color
}

let dummyArticles: [Article] = [
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "한겨레", color: .blue),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "조선일보", color: .red),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "경향신문", color: .blue),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "동아일보", color: .red),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "서울신문", color: .blue),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "중앙일보", color: .red),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "한국일보", color: .blue),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "세계일보", color: .red),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "매일경제", color: .blue),
    Article(title: "기사 제목 이름 적고 몇글자까지 들어갈까...", press: "한국경제", color: .red)
]


struct ArticleSourceView: View {
    @State private var showBiasInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Text("10개의 출처기사")
                    .font(.custom("Pretendard", size: 19))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#32353B"))
                    .lineSpacing(30 - 19)
                
                Image("arrow_right")
                    .frame(width: 11, height:20)
            }
            .padding(.bottom, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<5) { i in
                        VStack(spacing: 16) {
                            ArticleCardView(article: dummyArticles[i])
                            ArticleCardView(article: dummyArticles[i + 5])
                        }
                    }
                    Spacer()
                        .frame(width: 4)
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
                            onConfirm: { withAnimation(.none) { showBiasInfo = false } }
                        )
                        .padding(.bottom, -geo.safeAreaInsets.bottom)
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
