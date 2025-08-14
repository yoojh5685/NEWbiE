import SwiftUI

struct ListView: View {
    let item: String
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                ListDetailView(
                    articleTitle: "여기에는 띄어쓰기 포함 최대 30자, 최소는 58자라고 합시다",
                    articleDate: "2025년 7월 22일 20:10",
                    summaryParagraphs: [
                        "한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 총 3문단 ㄱㄴ",
                        "한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 총 3문단 ㄱㄴ",
                        "한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 한문단에 띄어쓰기 포함 최소 57자이구요 최대는 82자까지 가능해요. 총 3문단 ㄱㄴ"
                    ],
                    fullContent: "여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 여기에는 띄어쓰기 포함해서 몇글자까지 들어갈까요 한번 세어봅시다 "
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 20)
                
            Color(hex: "#F4F4F4")
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                PoliticalSummaryView()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            Color(hex: "#F4F4F4")
                .frame(height: 20)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                ArticleSourceView()
            }
            .padding(.leading, 20)            
            
        }
        .scrollIndicators(.hidden) // 스크롤바 숨김
        .navigationBarTitleDisplayMode(.inline)
    }
}
