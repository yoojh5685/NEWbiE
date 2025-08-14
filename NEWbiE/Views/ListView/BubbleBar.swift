import SwiftUI

struct BubbleBarView: View {
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
                // 1. 막대 바
                Rectangle()
                    .fill(LinearGradient(colors: [.blue, .white, .red],
                                         startPoint: .leading,
                                         endPoint: .trailing))
                    .frame(width: barWidth, height: barHeight)
                    .position(x: width / 2, y: barCenterY)
                    .onAppear {
                        barWidth = 0 // 초기값 0
                        bubbles = Bubble.generate(count: 10, inWidth: width)
                        scales = Array(repeating: 1.0, count: 10)
                        opacities = Array(repeating: 0.0, count: 10)

                        withAnimation(.easeOut(duration: 0.6)) {
                            barWidth = width // 애니메이션을 통해 증가
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showBubbles = true
                        }
                    }
                    .onChange(of: width) { newWidth in
                        // 회전 시 반응해서 재설정
                        barWidth = newWidth
                        bubbles = Bubble.generate(count: 10, inWidth: newWidth)
                        scales = Array(repeating: 1.0, count: 10)
                        opacities = Array(repeating: 0.0, count: 10)
                        showBubbles = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showBubbles = true
                        }
                    }

                // 2. 버블
                if showBubbles {
                    ForEach(bubbles.indices, id: \.self) { i in
                        let bubble = bubbles[i]
                        let bubbleY = barCenterY

                        Circle()
                            .fill(bubble.color)
                            .frame(width: bubble.size, height: bubble.size)
                            .scaleEffect(scales[i])
                            .opacity(opacities[i])
                            .position(x: bubble.positionX, y: bubbleY)
                            .onAppear {
                                let delay = Double.random(in: 0.0...0.6)
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        opacities[i] = 1.0
                                    }
                                    animateBubble(at: i)
                                }
                            }
                    }
                }
            }
        }
        .frame(height: 14)
    }

    func animateBubble(at index: Int) {
        let scaleUp = CGFloat.random(in: 1.4...2.0)
        let duration = Double.random(in: 0.8...1.4)

        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            scales[index] = scaleUp
        }
    }
}

struct Bubble {
    let positionX: CGFloat
    let size: CGFloat
    let duration: Double
    let color: Color
    
    static func generate(count: Int, inWidth viewWidth: CGFloat) -> [Bubble] {
        let centerX = viewWidth / 2
        let minSize: CGFloat = 4
        let maxSize: CGFloat = 6
        let edgeMargin: CGFloat = 16
        
        let blueMinX = edgeMargin
        let blueMaxX = centerX - edgeMargin
        
        let redMinX = centerX + edgeMargin
        let redMaxX = viewWidth - edgeMargin
        
        var bubbles: [Bubble] = []
        
        for i in 0..<count {
            var attempt = 0
            var newBubble: Bubble
            let isBlue = i < count / 2
            
            repeat {
                let size = CGFloat.random(in: minSize...maxSize)
                let color = isBlue ? Color.blue.opacity(0.7) : Color.red.opacity(0.7)
                let x = isBlue
                ? CGFloat.random(in: blueMinX...blueMaxX)
                : CGFloat.random(in: redMinX...redMaxX)
                
                newBubble = Bubble(
                    positionX: x,
                    size: size,
                    duration: Double.random(in: 0.8...1.4),
                    color: color
                )
                
                attempt += 1
            } while bubbles.contains(where: {
                abs($0.positionX - newBubble.positionX) < ($0.size + newBubble.size) / 2 + 2
            }) && attempt < 50
            
            bubbles.append(newBubble)
        }
        
        return bubbles
    }
}
