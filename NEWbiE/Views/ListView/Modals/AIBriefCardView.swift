import SwiftUI

struct AIBriefCardView: View {
    var onConfirm: () -> Void = {}

    // 🔒 고정 텍스트
    private let titleText = "AI로 배경을 요약했어요"
    private let bullets = [
        "해당 이슈를 이해하는 데 도움을 주는 과거 사건이나 정보를 정리했어요.",
        "현재 베타 버전으로 아직 신뢰도가 다소 부족할 수 있어요. 기사 본문 요약을 꼭 함께 읽길 권장해요."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                Text(titleText)
                    .font(.pretendardBold(size: 22))
                    .foregroundColor(Color(hex: "#32353B"))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(32 - 22)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Spacer()

                Image("bigRobot")
                    .resizable()
                    .frame(width: 55, height: 55)
            }
            .padding(.top, 62)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // ✅ 불릿 영역 (스크린샷 스타일)
            VStack(alignment: .leading, spacing: 12) {        // 문단 간 간격
                ForEach(bullets, id: \.self) { text in
                    HStack(alignment: .top, spacing: 6) {     // 불릿과 본문 간 간격
                        Text("•")
                            .font(.custom("Pretendard", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#32353B"))

                        Text(text)
                            .font(.custom("Pretendard", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#32353B"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true) // 줄바꿈 시 높이 확장
                            .lineSpacing(6)                                // 문장 내 줄 간격
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 24)

            // 확인 버튼
            Button(action: onConfirm) {
                Text("확인했어요")
                    .font(.pretendardBold(size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#815CFF"))
                    .cornerRadius(16)
                    .padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .background(Color.white)
        .cornerRadius(28)
        .padding(.horizontal, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI로 배경을 요약했어요 안내")
    }
}
