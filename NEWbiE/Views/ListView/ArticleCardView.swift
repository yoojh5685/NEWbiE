import SwiftUI

struct ArticleCardView: View {
    let article: Article
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = URL(string: article.url) {
                openURL(url)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Circle()
                    .fill(article.color) // 진보=파랑, 보수=빨강, 기타=회색
                    .frame(width: 17, height: 17)
                    .padding(.top, 12)
                    .padding(.leading, 8)
                    .padding(.bottom, 5)

                Text(article.title.byCharWrapping)
                    .font(.custom("Pretendard-SemiBold", size: 16))
                    .foregroundColor(Color(hex: "#32353B"))
                    .lineLimit(1)                          // 최대 2줄까지만
                    .truncationMode(.tail)                 // 넘치면 ... 처리
                    .padding(.horizontal, 8)
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
        .buttonStyle(.plain) // 카드처럼 보이게
        .contextMenu {
            if let url = URL(string: article.url) {
                ShareLink(item: url) {
                    Label("링크 공유", systemImage: "square.and.arrow.up")
                }
                Button {
                    openURL(url)
                } label: {
                    Label("사파리로 열기", systemImage: "safari")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.press) 기사, \(article.title)")
    }
}
