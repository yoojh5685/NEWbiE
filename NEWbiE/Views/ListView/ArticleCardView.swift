import SwiftUI

struct ArticleCardView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Circle()
                .fill(article.color)
                .frame(width: 17, height: 17)
                .padding(.top, 12)
                .padding(.leading, 8)
                .padding(.bottom, 5)

            Text(article.title)
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundColor(Color(hex: "#32353B"))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 8)
                .padding(.bottom, 3)
                .lineSpacing(4)

            Text(article.press)
                .font(.custom("Pretendard", size: 13))
                .foregroundColor(Color(hex: "#32353B"))
                .lineSpacing(6)
                .kerning(-0.26)
                .padding(.leading, 8)
                .padding(.bottom, 12)
        }
        .frame(width: 301, height: 92, alignment: .leading)
        .background(Color(hex: "#F4F4F4"))
        .cornerRadius(12)
    }
}
//// 프리뷰
//#Preview {
//    ArticleCardView(article: Article(
//        title: "기사 제목 이름 적고 몇글자까지 들어갈까...",
//        press: "연합뉴스",
//        color: .blue
//    ))
//}
