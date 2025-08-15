import SwiftUI

struct TermExplanationCardView: View {
    var onConfirm: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("용어 설명")
                        .font(.custom("Pretendard", size: 15))
                        .fontWeight(.regular)
                        .foregroundColor(Color(hex: "#8D94A3"))
                        .lineSpacing(22 - 15)
                        .kerning(-0.3)
                        .padding(.bottom, 4)
                    
                    Text("상임위원장")
                        .font(.custom("Pretendard-Bold", size: 24))
                        .foregroundColor(Color(hex: "#202225"))
                        .lineSpacing(32 - 24)
                        .kerning(0)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                }
                
                Spacer()
                
                Image("bigRobot")
                    .resizable()
                    .frame(width: 55, height: 55)
            }
            .padding(.top, 62)
            .padding(.horizontal, 24)
            .padding(.bottom, 37)

            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.custom("Pretendard", size: 16))
                    .fontWeight(.medium) // font-weight: 500
                    .foregroundColor(Color(hex: "#202225"))
                    .padding(.top, 2) // bullet을 첫 줄과 맞추기

                Text("국회 내 각 상임위원회를 이끄는 위원장으로, 상임위원회의 의사 진행과 운영을 총괄한다.")
                    .font(.custom("Pretendard", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#202225"))
                    .lineSpacing(25 - 16)
                    .kerning(-0.32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Button(action: onConfirm) {
                Text("확인했어요")
                    .font(.custom("Pretendard-Bold", size: 17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "#815CFF"))
                    .cornerRadius(16)
                    .padding(.top, 72)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .background(Color.white)
        .cornerRadius(28)
        .padding(.horizontal, 10)
    }
}
