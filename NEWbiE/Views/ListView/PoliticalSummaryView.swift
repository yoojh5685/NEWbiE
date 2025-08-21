import SwiftUI

enum PoliticalSide: Hashable {
    case progressive_media_stance
    case conservative_media_stance
}

struct PoliticalSummaryView: View {
    // ✅ 서버에서 주입받을 텍스트
    let progressiveText: String
    let conservativeText: String

    @State private var selectedSide: PoliticalSide = .progressive_media_stance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - 타이틀
            Text("핵심 쟁점은 무엇인가요?")
                .font(.custom("Pretendard", size: 19))
                .fontWeight(.bold)
                .lineSpacing(30 - 19)
                .foregroundColor(Color(hex: "#32353B"))
                .padding(.bottom, 16)
            
            // MARK: - Segmented Control (진보 / 보수)
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSide = .progressive_media_stance
                    }
                }) {
                    Text("진보")
                        .font(
                            selectedSide == .progressive_media_stance
                            ? .pretendardSemiBold(size: 15)   // ✅ 선택됨 → 590 근사치로 SemiBold(600)
                            : .pretendardRegular(size: 13)    // ✅ 선택 안됨 → 400
                        )
                        .foregroundColor(
                            selectedSide == .progressive_media_stance
                            ? Color(hex: "#008AFF")
                            : Color(hex: "#8D8D8D")
                        )
                        .lineSpacing(3)
                        .kerning(-0.08)
                        .multilineTextAlignment(.center)
                        .padding(2)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedSide == .progressive_media_stance ? Color.white : Color(hex: "#F4F4F4"))
                        .cornerRadius(7)
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.black.opacity(0.04), lineWidth: 0.5))
                        .shadow(color: selectedSide == .progressive_media_stance ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
                }

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSide = .conservative_media_stance
                    }
                }) {
                    Text("보수")
                        .font(
                            selectedSide == .conservative_media_stance
                            ? .pretendardSemiBold(size: 15)   // ✅ 선택됨
                            : .pretendardRegular(size: 13)    // ✅ 선택 안됨
                        )
                        .foregroundColor(
                            selectedSide == .conservative_media_stance
                            ? Color(hex: "#FF4B41")
                            : Color(hex: "#8D8D8D")
                        )
                        .lineSpacing(5)
                        .kerning(-0.08)
                        .multilineTextAlignment(.center)
                        .padding(2)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedSide == .conservative_media_stance ? Color.white : Color(hex: "#F4F4F4"))
                        .cornerRadius(7)
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.black.opacity(0.04), lineWidth: 0.5))
                        .shadow(color: selectedSide == .conservative_media_stance ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
            .padding(2)
            .background(Color(hex: "#F4F4F4"))
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .padding(.bottom, 18)
            
            // MARK: - 요약 내용 영역
            ZStack {
                if selectedSide == .progressive_media_stance {
                    summaryView(text: progressiveText).transition(.opacity)
                }
                if selectedSide == .conservative_media_stance {
                    summaryView(text: conservativeText).transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedSide)
        }
    }
    
    
    func summaryView(text: String) -> some View {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let dot = trimmed.firstIndex(of: ".") {
            let end = trimmed.index(after: dot)
            let first = String(trimmed[..<end])
            let rest = String(trimmed[end...]).trimmingCharacters(in: .whitespaces)

            let hlColor = selectedSide == .progressive_media_stance
                ? Color(hex: "#008AFF")
                : Color(hex: "#FF4B41")

            // 👉 첫 문장 (하이라이트 + bold)
            var attributed = AttributedString(first.byCharWrapping)
            attributed.foregroundColor = .white
            attributed.backgroundColor = hlColor
            attributed.font = .custom("Pretendard", size: 17).bold()  // ✅ 첫 문장만 Bold

            // 👉 나머지 문장 (일반 weight)
            var restAttr = AttributedString("\u{2009}" + rest.byCharWrapping)
            restAttr.foregroundColor = Color(hex: "#202225")
            restAttr.font = .custom("Pretendard", size: 17).weight(.regular)

            let final = attributed + restAttr

            return Text(final)
                .lineSpacing(13)                // line-height: 30px
                .kerning(-0.34)                 // letter-spacing: -0.34px
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

        } else {
            // 문장이 하나뿐인 경우
            return Text(text.byCharWrapping)
                .font(.custom("Pretendard", size: 17).weight(.regular))
                .foregroundColor(Color(hex: "#202225"))
                .lineSpacing(13)
                .kerning(-0.34)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//#Preview {
//    PoliticalSummaryView(
//        progressiveText: "진보 언론은 조국 전 대표를 정치검찰 피해자로 규정하며 사면을 긍정적으로 보기도 한다. 그러나 사면 제도의 정치적 이용과 불투명한 심사 과정을 문제 삼으며 제도 개선 필요성을 주장한다. 일부는 사면이 불평등 해소 논의를 가로막고 진영 갈등을 심화시킨다고 우려한다.",
//        conservativeText: "보수 언론은 이번 특별사면이 대통령 권한 남용과 진영 정치의 산물이라고 평가한다. 사면 대상자의 범죄 사실과 법원의 유죄 판결을 강조하며 사면에 비판적이다. 또한, 정부 정책 전반에 대한 비판과 함께 국민 통합보다 진영 분열을 조장한다고 지적한다."
//    )
//}
