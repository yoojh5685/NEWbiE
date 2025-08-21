import SwiftUI

/// UINavigationController의 스와이프‑뒤로가기를 강제로 활성화
struct EnableInteractivePopGesture: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        // 네비게이션 스택에 올라간 다음에 설정해야 해서 async
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                // 다른 제스처와 충돌로 비활성화된 경우 delegate를 nil로 풀어준다
                nav.interactivePopGestureRecognizer?.delegate = nil
            }
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
