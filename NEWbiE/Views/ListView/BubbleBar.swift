import SwiftUI

struct BubbleBarView: View {
    // 서버에서 내려온 언론사 배열 직접 사용
    let progressiveMedias: [String]
    let conservativeMedias: [String]

    @State private var bubbles: [Bubble] = []
    @State private var scales: [CGFloat] = []
    @State private var opacities: [Double] = []

    @State private var barWidth: CGFloat = 0
    @State private var showBubbles: Bool = false

    let barHeight: CGFloat = 6
    let barCenterY: CGFloat = 7

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack {
                // 1) 막대 바
                Rectangle()
                    .fill(LinearGradient(colors: [.blue, .white, .red],
                                         startPoint: .leading,
                                         endPoint: .trailing))
                    .frame(width: barWidth, height: barHeight)
                    .position(x: width / 2, y: barCenterY)
                    .onAppear {
                        setup(width: width, height: geometry.size.height)
                        withAnimation(.easeOut(duration: 0.6)) { barWidth = width }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showBubbles = true
                            logAvailability()
                        }
                    }
                    .onChange(of: width) { newWidth in
                        // 리사이즈 시 재설정
                        setup(width: newWidth, height: geometry.size.height)
                        showBubbles = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showBubbles = true
                            logAvailability()
                        }
                    }

                // 2) 버블
                if showBubbles {
                    ForEach(bubbles.indices, id: \.self) { i in
                        let bubble = bubbles[i]
                        let bubbleY = barCenterY

                        Circle()
                            .fill(bubble.color)
                            .frame(width: bubble.size, height: bubble.size) // base = 10
                            .scaleEffect(min(scales[i], 1.0))               // ⬅️ 하드 캡
                            .opacity(opacities[i])
                            .position(x: bubble.positionX, y: bubbleY)
                            .onAppear {
                                // ⬅️ 중복 애니메이션 방지 가드
                                guard opacities[i] == 0.0 && scales[i] == 0.0 else { return }

                                let delay = Double.random(in: 0.15...0.70)
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    withAnimation(.easeInOut(duration: 0.60)) {
                                        opacities[i] = 1.0
                                    }
                                    animateBubble(at: i) // 0 ↔︎ 1 반복
                                }
                            }
                    }
                }
            }
        }
        .frame(height: 14)
    }

    // MARK: - 초기 버블 생성
    private func setup(width: CGFloat, height: CGFloat) {
        bubbles = Bubble.generateEvenlySpacedFromCenter(
            progressiveMedias: progressiveMedias,
            conservativeMedias: conservativeMedias,
            inWidth: width,
            inHeight: height,
            spacingBetweenEdges: 12,
            portraitOffset: 63,
            fixedSize: 10
        )
        // 리셋
        scales = Array(repeating: 0.0, count: bubbles.count)
        opacities = Array(repeating: 0.0, count: bubbles.count)
    }

    private func logAvailability() {
        print("=== 기사 유무 체크 ===")
        for name in progressiveMedias { print("[Blue] \(name) → 있음 ✅") }
        for name in conservativeMedias { print("[Red ] \(name) → 있음 ✅") }
    }

    /// 0 → 1 → 0 반복 (최대 1.0로 제한)
    private func animateBubble(at index: Int) {
        let duration = Double.random(in: 1.2...1.8)
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            scales[index] = 1.0
        }
    }
}

// MARK: - Bubble 구조체
struct Bubble {
    let positionX: CGFloat
    let size: CGFloat
    let duration: Double
    let color: Color
    let mediaName: String
}

// MARK: - 버블 위치 생성
extension Bubble {
    static func generateEvenlySpacedFromCenter(
        progressiveMedias: [String],
        conservativeMedias: [String],
        inWidth viewWidth: CGFloat,
        inHeight viewHeight: CGFloat,
        spacingBetweenEdges: CGFloat,
        portraitOffset: CGFloat,
        fixedSize: CGFloat
    ) -> [Bubble] {
        let centerX = viewWidth / 2
        let leftCount = progressiveMedias.count
        let rightCount = conservativeMedias.count
        let centerSpacing = fixedSize + spacingBetweenEdges

        let isLandscape = viewWidth > viewHeight
        let adaptiveOffset: CGFloat = isLandscape ? viewWidth * 0.15 : portraitOffset

        var bubbles: [Bubble] = []

        // 왼쪽(진보/파랑)
        for i in 0..<leftCount {
            let x = (centerX - adaptiveOffset) - CGFloat(i) * centerSpacing
            bubbles.append(Bubble(
                positionX: x,
                size: fixedSize,
                duration: Double.random(in: 1.0...1.5),
                color: Color.blue.opacity(0.7),
                mediaName: progressiveMedias[i]
            ))
        }
        // 오른쪽(보수/빨강)
        for i in 0..<rightCount {
            let x = (centerX + adaptiveOffset) + CGFloat(i) * centerSpacing
            bubbles.append(Bubble(
                positionX: x,
                size: fixedSize,
                duration: Double.random(in: 1.2...1.8),
                color: Color.red.opacity(0.7),
                mediaName: conservativeMedias[i]
            ))
        }

        return bubbles
    }
}
