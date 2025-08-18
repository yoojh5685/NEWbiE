import SwiftUI

struct AIBriefCardView: View {
    var background_summary: [String]      // ✅ 기본값 제거, 반드시 주입
    var onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("AI로 배경을\n요약했어요")
                    .font(.pretendardBold(size: 22))
                    .foregroundColor(Color(hex: "#32353B"))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(32 - 22)
                    .fixedSize(horizontal: false, vertical: true) // ✅ 줄임/클리핑 방지
                    .layoutPriority(1)
                
                Spacer()

                Image("bigRobot")
                    .resizable()
                    .frame(width: 55, height: 55)
            }
            .padding(.top, 62)
            .padding(.horizontal, 24)
            .padding(.bottom, 37)

            // bullet 영역
            VStack(alignment: .leading, spacing: 8) {
                ForEach(background_summary.indices, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                        Text(background_summary[index])
                    }
                    .padding(.horizontal, 24)
                }
            }
            .font(.custom("Pretendard", size: 16))
            .fontWeight(.medium)
            .lineSpacing(9)
            .kerning(-0.32)
            .foregroundColor(Color(hex: "#32353B"))
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onConfirm) {
                Text("확인했어요")
                    .font(.pretendardBold(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#815CFF"))
                    .cornerRadius(16)
                    .padding(.top, 64)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .background(Color.white)
        .cornerRadius(28)
        .padding(.horizontal, 10)
    }
}

