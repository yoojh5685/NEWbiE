import SwiftUI

struct BiasInfoCardView: View {
    var onConfirm: () -> Void = {}

    // 비율 변수 (0.0~1.0 범위로 전달)
    var progressiveRatio: CGFloat = 0.71
    var conservativeRatio: CGFloat = 0.29

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading) {
                    Text("편향도 설명")
                        .font(.custom("Pretendard", size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 68)
                        .padding(.bottom, 4)

                    // 진보/보수에 따라 색상 동적 적용된 문장
                    let isProgLead = progressiveRatio >= conservativeRatio
                    let leadLabel = isProgLead ? "진보" : "보수"
                    let leadPercent = Int(round((isProgLead ? progressiveRatio : conservativeRatio) * 100))
                    let leadColor: Color = isProgLead ? Color.blue : Color.red

                    (
                        Group {
                            Text("이 사안은 ")
                                .foregroundColor(Color(hex: "#32353B"))
                            +
                            Text(leadLabel)
                                .foregroundColor(leadColor)
                            +
                            Text("측이 ")
                                .foregroundColor(Color(hex: "#32353B"))
                            +
                            Text("\(leadPercent)%")
                                .foregroundColor(leadColor)
                            +
                            Text("로 많이 다뤘어요")
                                .foregroundColor(Color(hex: "#32353B"))
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
                    let total = max(0.0001, progressiveRatio + conservativeRatio) // 0 방지
                    let progWidth = geo.size.width * (progressiveRatio / total)
                    let consWidth = geo.size.width * (conservativeRatio / total)

                    HStack(spacing: 0) {
                        // 진보(파랑)
                        ZStack {
                            Rectangle().fill(Color.blue)
                            Text("\(Int(round(progressiveRatio * 100)))%")
                                .font(.custom("Pretendard-Bold", size: 13))
                                .foregroundColor(.white)
                        }
                        .frame(width: progWidth, height: 17)

                        // 보수(빨강)
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

                HStack(spacing: 0) {
                    // 진보 언론사
                    VStack(alignment: .leading, spacing: 0) {
                        Text("진보 언론사")
                            .font(.custom("Pretendard-Bold", size: 16))
                            .foregroundColor(.blue)
                            .padding(.bottom, 10)
                            .padding(.leading, 11)

                        VStack(spacing: 8) {
                            ForEach(["경향신문", "한겨레", "MBC", "프레시안", "미디어 오늘"], id: \.self) { name in
                                Text(name)
                                    .font(.custom("Pretendard", size: 17))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color.blue)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(30 - 17)
                                    .kerning(-0.34)
                                    .frame(alignment: .leading)
                            }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.10))
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    // 보수 언론사
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("보수 언론사")
                            .font(.custom("Pretendard-Bold", size: 16))
                            .foregroundColor(.red)
                            .padding(.bottom, 10)
                            .padding(.trailing, 11)

                        VStack(spacing: 8) {
                            ForEach(["동아일보", "문화일보", "조선일보", "중앙일보", "국민일보"], id: \.self) { name in
                                Text(name)
                                    .font(.custom("Pretendard", size: 17))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color.red)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(30 - 17)
                                    .kerning(-0.34)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal, 10)
                            }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.10))
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
            .padding(.bottom, 18)
        }
        .background(Color.white)
        .cornerRadius(28)
        .padding(.horizontal, 10)
    }
}
