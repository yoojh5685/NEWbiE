import SwiftUI

struct BubbleBarView: View {
    // 서버에서 내려온 언론사 배열
    let progressiveMedias: [String]
    let conservativeMedias: [String]

    // 선택적 비율: 안 주면 개수로 자동 계산
    let progressiveRatio: CGFloat?
    let conservativeRatio: CGFloat?

    init(
        progressiveMedias: [String],
        conservativeMedias: [String],
        progressiveRatio: CGFloat? = nil,
        conservativeRatio: CGFloat? = nil
    ) {
        self.progressiveMedias = progressiveMedias
        self.conservativeMedias = conservativeMedias
        self.progressiveRatio = progressiveRatio
        self.conservativeRatio = conservativeRatio
    }

    @State private var bubbles: [Bubble] = []
    @State private var scales: [CGFloat] = []
    @State private var opacities: [Double] = []

    // 바 애니메이션: 중앙(흰색)에서 좌·우로 퍼지기
    @State private var leftExtent: CGFloat = 0
    @State private var rightExtent: CGFloat = 0
    @State private var showBubbles: Bool = false

    // 스타일
    private let barHeight: CGFloat = 6
    private let barCenterY: CGFloat = 7
    private let desiredSpacing: CGFloat = 12
    private let baseBubbleSize: CGFloat = 10
    private let barAnimDuration: Double = 0.6

    var body: some View {
        GeometryReader { geo in
            let width  = geo.size.width
            let height = geo.size.height

            // 비율 산출
            let (progShare, _) = computeShares()
            let splitX = width * progShare.clamped01()

            ZStack {
                // 왼쪽 세그먼트: 파랑 → 흰색
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .white]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: leftExtent, height: barHeight)
                .position(x: splitX - leftExtent / 2, y: barCenterY)
                .clipped()

                // 오른쪽 세그먼트: 흰색 → 빨강
                LinearGradient(
                    gradient: Gradient(colors: [.white, .red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: rightExtent, height: barHeight)
                .position(x: splitX + rightExtent / 2, y: barCenterY)
                .clipped()

                // 버블
                if showBubbles {
                    ForEach(bubbles.indices, id: \.self) { i in
                        let b = bubbles[i]
                        Circle()
                            .fill(b.color)
                            .frame(width: b.size, height: b.size)
                            .scaleEffect(min(scales[i], 1.0))
                            .opacity(opacities[i])
                            // ⬇️ 지그재그 yOffset 적용 (나머지 로직은 그대로)
                            .position(x: b.positionX, y: barCenterY + b.yOffset)
                            .onAppear {
                                guard opacities[i] == 0.0 && scales[i] == 0.0 else { return }
                                let delay = Double.random(in: 0.20...0.75)
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    withAnimation(.easeInOut(duration: 0.60)) { opacities[i] = 1.0 }
                                    animateBubble(at: i)
                                }
                            }
                    }
                }
            }
            .onAppear {
                // 초기 세팅
                setup(width: width, height: height, progShare: progShare)
                // 중앙에서 좌우로 퍼지는 바 애니
                leftExtent = 0
                rightExtent = 0
                withAnimation(.easeOut(duration: barAnimDuration)) {
                    leftExtent = splitX
                    rightExtent = width - splitX
                }
                // 바 애니 끝난 뒤 버블 등장
                DispatchQueue.main.asyncAfter(deadline: .now() + barAnimDuration) {
                    showBubbles = true
                }
            }
            // 회전/리사이즈 대응
            .onChange(of: width) { newWidth in
                showBubbles = false
                setup(width: newWidth, height: height, progShare: progShare)
                let newSplit = newWidth * progShare.clamped01()
                leftExtent = 0; rightExtent = 0
                withAnimation(.easeOut(duration: barAnimDuration)) {
                    leftExtent = newSplit
                    rightExtent = newWidth - newSplit
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + barAnimDuration) {
                    showBubbles = true
                }
            }
            // 데이터/비율 변경 시 재계산 & 동일 애니
            .onChange(of: progressiveMedias) { _ in reanimate(width: width, height: height) }
            .onChange(of: conservativeMedias) { _ in reanimate(width: width, height: height) }
        }
        .frame(height: 14)
    }

    // MARK: - 비율 계산 (값 우선, 없으면 개수 / 둘 다 0이면 0.5)
    private func computeShares() -> (progShare: CGFloat, consShare: CGFloat) {
        if let pr = progressiveRatio, let cr = conservativeRatio {
            let sum = pr + cr
            if sum == 0 { return (0.5, 0.5) }
            let p = (pr / sum).clamped01()
            return (p, 1 - p)
        } else {
            let pCount = CGFloat(progressiveMedias.count)
            let cCount = CGFloat(conservativeMedias.count)
            let sum = pCount + cCount
            if sum == 0 { return (0.5, 0.5) }
            let p = (pCount / sum).clamped01()
            return (p, 1 - p)
        }
    }

    // MARK: - 세팅 (비율 기반 배치)
    private func setup(width: CGFloat, height: CGFloat, progShare: CGFloat) {
        bubbles = Bubble.generateByRatio(
            progressiveMedias: progressiveMedias,
            conservativeMedias: conservativeMedias,
            totalWidth: width,
            progShare: progShare,
            desiredSpacing: desiredSpacing,
            baseSize: baseBubbleSize
        )
        scales = Array(repeating: 0.0, count: bubbles.count)
        opacities = Array(repeating: 0.0, count: bubbles.count)
    }

    // 비율/배열 변경 시 동일한 연출로 재애니
    private func reanimate(width: CGFloat, height: CGFloat) {
        let (p, _) = computeShares()
        showBubbles = false
        setup(width: width, height: height, progShare: p)
        let splitX = width * p.clamped01()
        leftExtent = 0; rightExtent = 0
        withAnimation(.easeOut(duration: barAnimDuration)) {
            leftExtent = splitX
            rightExtent = width - splitX
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + barAnimDuration) {
            showBubbles = true
        }
    }

    // 버블 반복 애니
    private func animateBubble(at index: Int) {
        let duration = Double.random(in: 0.8...1.2)  // ⬅️ 기존 1.2~1.8 → 0.8~1.2
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            scales[index] = 1.0
        }
    }
}

// MARK: - 모델 (yOffset 추가)
private struct Bubble {
    let positionX: CGFloat
    let size: CGFloat
    let color: Color
    let isProgressive: Bool
    let yOffset: CGFloat     // ← 지그재그용 오프셋
}

// MARK: - 생성 로직 (지그재그 + 크기 커짐(5~10) + 간격 10 + 중앙 기준 시작 + 경계 여유)
private extension Bubble {
    static func generateByRatio(
        progressiveMedias: [String],
        conservativeMedias: [String],
        totalWidth: CGFloat,
        progShare: CGFloat,
        desiredSpacing: CGFloat,
        baseSize: CGFloat
    ) -> [Bubble] {

        let splitX = totalWidth * progShare
        let leftCount  = progressiveMedias.count
        let rightCount = conservativeMedias.count

        // 고정 설정
        let spacing: CGFloat   = 10   // 버블 간 간격
        let centerGap: CGFloat = 30    // 흰색 경계에서 띄우는 여유

        var bubbles: [Bubble] = []
        let zigZag: (Int) -> CGFloat = { i in (i % 2 == 0) ? -6 : 6 }

        // ⬇️ 크기 커지는 함수 (min 5 ~ max 10)
        func progressiveSize(for index: Int, count: Int) -> CGFloat {
            guard count > 1 else { return 5 }
            let ratio = CGFloat(index) / CGFloat(count - 1) // 0 ~ 1
            let size = 5 + ratio * (10 - 5)
            return max(5, min(size, 10))
        }

        // 좌측(진보): splitX에서 떨어져 시작 → 왼쪽 끝 쪽으로 갈수록 점점 커짐
        if leftCount > 0 {
            var cursor = splitX - centerGap
            for i in 0..<leftCount {   // ⬅️ reversed() 제거, 정방향
                let size = progressiveSize(for: i, count: leftCount)
                let x = cursor - size / 2
                bubbles.append(Bubble(positionX: max(size/2, x),
                                      size: size,
                                      color: Color.blue.opacity(0.7),
                                      isProgressive: true,
                                      yOffset: zigZag(i)))
                cursor -= (size + spacing)
            }
        }

        // 우측(보수): splitX에서 떨어져 시작 → 오른쪽 끝 쪽으로 갈수록 index 증가 → 점점 커짐
        if rightCount > 0 {
            var cursor = splitX + centerGap
            for i in 0..<rightCount {
                let size = progressiveSize(for: i, count: rightCount)
                let x = cursor + size / 2
                bubbles.append(Bubble(positionX: min(totalWidth - size/2, x),
                                      size: size,
                                      color: Color.red.opacity(0.7),
                                      isProgressive: false,
                                      yOffset: zigZag(i)))
                cursor += (size + spacing)
            }
        }

        return bubbles
    }
}

private extension CGFloat {
    func clamped01() -> CGFloat { Swift.max(0, Swift.min(1, self)) }
}
