import SwiftUI

struct ListView: View {
    let item: String
    
    @State private var showPoliticalSummary = false
    @State private var showArticleSource = false
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                ListDetailView(
                    articleTitle: "여기에는 띄어쓰기 포함 최대 30자, 최소는 58자라고 합시다",
                    date: "2025년 7월 22일 20:10",
                    background_summary: [
                        "한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 총 3문단 ㄱㄴ",
                        "한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 총 3문단 ㄱㄴ",
                        "한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 총 3문단 ㄱㄴ"
                    ],
                    full_article_summary: "여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다"
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            // MARK: - PoliticalSummaryView + 구분선 애니메이션
            if showPoliticalSummary {
                Group {
                    Color(hex: "#F4F4F4")
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 0) {
                        PoliticalSummaryView()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .opacity(showPoliticalSummary ? 1 : 0)
                .offset(y: showPoliticalSummary ? 0 : -20)
            }
            
            // MARK: - ArticleSourceView + 구분선 애니메이션
            if showArticleSource {
                Group {
                    Color(hex: "#F4F4F4")
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 0) {
                        ArticleSourceView()
                    }
                    .padding(.leading, 20)
                }
                .opacity(showArticleSource ? 1 : 0)
                .offset(y: showArticleSource ? 0 : -20)
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showPoliticalSummary = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showArticleSource = true
                }
            }
        }
    }
}
