import SwiftUI

struct BiasInfoCardView: View {
    var onConfirm: () -> Void = {}

    // ✅ 외부에서 주입
    let progressiveRatio: CGFloat
    let conservativeRatio: CGFloat
    let progressiveMedias: [String]
    let conservativeMedias: [String]

    @Environment(\.verticalSizeClass) private var vSize

    var body: some View {
        let isLandscape = (vSize == .compact)

        // 원래 카드 뷰 (그대로 유지)
        let card = VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading) {
                    Text("편향도 설명")
                        .font(.custom("Pretendard", size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 68)
                        .padding(.bottom, 4)

                    // 동적 문장 (원래 로직 유지)
                    let isProgLead = progressiveRatio >= conservativeRatio
                    let leadLabel = isProgLead ? "진보" : "보수"
                    let leadPercent = Int(round((isProgLead ? progressiveRatio : conservativeRatio) * 100))
                    let leadColor: Color = isProgLead ? Color.blue : Color.red

                    (
                        Group {
                            Text("이 사안은 ").foregroundColor(Color(hex: "#32353B")) +
                            Text(leadLabel).foregroundColor(leadColor).fontWeight(.bold) +
                            Text("측이 ").foregroundColor(Color(hex: "#32353B")) +
                            Text("\(leadPercent)%").foregroundColor(leadColor).fontWeight(.bold) +
                            Text("로 많이 다뤘어요").foregroundColor(Color(hex: "#32353B"))
                        }
                        .font(.custom("Pretendard", size: 16))
                        .fontWeight(.medium)
                        .lineSpacing(9)
                        .kerning(-0.32)
                    )
                    .padding(.bottom, 14)
                }
                .padding(.leading, 24)

                // 퍼센트 바
                GeometryReader { geo in
                    let total = max(0.0001, progressiveRatio + conservativeRatio)
                    let progWidth = geo.size.width * (progressiveRatio / total)
                    let consWidth = geo.size.width * (conservativeRatio / total)

                    HStack(spacing: 0) {
                        ZStack {
                            Rectangle().fill(Color.blue)
                            Text("\(Int(round(progressiveRatio * 100)))%")
                                .font(.custom("Pretendard-Bold", size: 13))
                                .foregroundColor(.white)
                        }
                        .frame(width: progWidth, height: 17)

                        ZStack {
                            Rectangle().fill(Color.red)
                            Text("\(Int(round(conservativeRatio * 100)))%")
                                .font(.custom("Pretendard-Bold", size: 13))
                                .foregroundColor(.white)
                        }
                        .frame(width: consWidth, height: 17)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 17)
                .padding(.horizontal, 10)
                .padding(.bottom, 16)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("•")
                        .font(.custom("Pretendard", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#32353B"))

                    Text("현재 출처 기사는 아래와 같아요")
                        .font(.custom("Pretendard", size: 16))
                        .fontWeight(.medium)
                        .lineSpacing(25 - 16)
                        .kerning(-0.32)
                        .foregroundColor(Color(hex: "#32353B"))
                }
                .padding(.leading, 34)
                .padding(.bottom, 8)

                HStack(spacing: 40) {
                    BiasColumn(title: "진보 언론사", color: .blue, items: progressiveMedias)
                    BiasColumn(title: "보수 언론사", color: .red, items: conservativeMedias)
                }
                .padding(.horizontal, 43)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onConfirm) {
                Text("확인했어요")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#815CFF"))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 18) // ← 세로모드일 때 이 값이 그대로 유지됨
        }
        .background(Color.white)
        .cornerRadius(28)
        .padding(.horizontal, 10)

        // ✅ 세로: 그대로 / 가로: 스크롤만 추가
        Group {
            if isLandscape {
                ScrollView(.vertical, showsIndicators: false) {
                    card
                }
            } else {
                card
            }
        }
    }
}

private struct BiasColumn: View {
    let title: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.custom("Pretendard-Bold", size: 16))
                .foregroundColor(color)
                .multilineTextAlignment(.center)

            if !items.isEmpty {
                VStack(spacing: 8) {
                    ForEach(items, id: \.self) { name in
                        Text(name)
                            .font(.custom("Pretendard", size: 17))
                            .foregroundColor(color)
                            .multilineTextAlignment(.center)
                            .kerning(-0.34)
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
