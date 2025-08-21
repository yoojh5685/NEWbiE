import SwiftUI

enum PoliticalLeaning: String, Codable {
    case progressive
    case conservative
    case unknown
}

struct Article: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let press: String
    let url: String
    let leaning: PoliticalLeaning

    // 색상 규칙: 진보=파란계열, 보수=빨간계열
    var color: Color {
        switch leaning {
        case .progressive:   return Color(hex: "#0A84FF") // 파란색
        case .conservative:  return Color(hex: "#FF3B30") // 빨간색
        case .unknown:       return Color.gray.opacity(0.6)
        }
    }
}
