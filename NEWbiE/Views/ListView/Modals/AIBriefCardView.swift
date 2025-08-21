import SwiftUI

struct AIBriefCardView: View {
    var onConfirm: () -> Void = {}

    // 🔒 고정 텍스트
    private let titleText = "AI로 배경을\n요약했어요"
    private let bullets = [
        "빠른 정보 파악을 돕기 위해 기사를 요약했어요",
        "기술 특성상 본문의 주요 내용이 제외되거나 사실과 다를 수 있어요. 전체 맥락을 이해하기 위해 기사 본문 전체 보기를 권장해요"
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
