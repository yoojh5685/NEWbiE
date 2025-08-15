import SwiftUI

enum PoliticalSide: Hashable {
    case progressive
    case conservative
}

struct PoliticalSummaryView: View {
    @State private var selectedSide: PoliticalSide = .progressive
    
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
                // 진보 버튼
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSide = .progressive
                    }
                }) {
                    Text("진보")
                        .font(.custom("Pretendard", size: 13).weight(.semibold))
                        .foregroundColor(selectedSide == .progressive ? Color(hex: "#008AFF") : Color(hex: "#8D8D8D"))
                        .lineSpacing(3)
                        .kerning(-0.08)
                        .multilineTextAlignment(.center)
                        .padding(2)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            selectedSide == .progressive ? Color.white : Color(hex: "#F4F4F4")
                        )
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.black.opacity(0.04), lineWidth: 0.5)
                        )
                        .shadow(
                            color: selectedSide == .progressive ? Color.black.opacity(0.1) : .clear,
                            radius: 4, x: 0, y: 2
                        )
                }
                
                // 보수 버튼
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSide = .conservative
                    }
                }) {
                    Text("보수")
                        .font(.custom("SF Pro", size: 13).weight(.medium))
                        .foregroundColor(selectedSide == .conservative ? Color(hex: "#FF4B41") : Color(hex: "#8D8D8D"))
                        .lineSpacing(5)
                        .kerning(-0.08)
                        .multilineTextAlignment(.center)
                        .padding(2)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            selectedSide == .conservative ? Color.white : Color(hex: "#F4F4F4")
                        )
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.black.opacity(0.04), lineWidth: 0.5)
                        )
                        .shadow(
                            color: selectedSide == .conservative ? Color.black.opacity(0.1) : .clear,
                            radius: 4, x: 0, y: 2
                        )
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
            .padding(2)
            .background(Color(hex: "#F4F4F4"))
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .padding(.bottom, 18)
            
            // MARK: - 요약 내용 영역
            ZStack {
                if selectedSide == .progressive {
                    summaryView(
                        text: "민주당 주도의 상임위원장 선출이 추경안과 개혁 입법 추진에 긍정적 영향을 줄 것으로 보도했다. 국민의힘의 표결 보이콧과 농성에 대해 여야 갈등으로 진단하면서도, 민주당의 국회 운영과 입법 활동을 중심으로 객관적 사실을 전달했다. 법사위원장 선출 과정에서의 민주당의 주도권 확보와 이에 따른 입법 가속화 가능성을 중점적으로 다뤘다."                    )
                    .transition(.opacity)
                }
                
                if selectedSide == .conservative {
                    summaryView(
                        text: "국민의힘의 법사위원장 요구 무시와 민주당의 일방적 상임위원장 선출을 의회 폭거로 규정했다. 민주당의 국회 운영 방식이 협치 원칙을 파괴하고 의회 민주주의를 위협한다고 비판했다. 총리 후보자의 범죄 혐의 문제를 강조하며 지명 철회와 법사위원장 반환을 촉구하는 농성 보도를 중심으로 강경한 반대 입장을 전했다."
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedSide)
        }
    }
    
    @ViewBuilder
    func summaryView(
        text: String
    ) -> some View {
        Text(text.byCharWrapping)
            .font(.custom("Pretendard", size: 17).weight(.regular))
            .foregroundColor(Color(hex: "#202225"))
            .lineSpacing(13)
            .tracking(-0.34)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
