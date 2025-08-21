import SwiftUI

struct ListView: View {
    /// 서버 콘텐츠 id (String 고정)
    let id: String
    
    // 애니메이션 상태
    @State private var showPoliticalSummary = false
    @State private var showArticleSource = false

    // 상세 로딩 상태
    @StateObject private var vm = DetailViewModel(service: LiveDetailService(baseURL: URL(string: "https://newsservice.shop")!))

    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // 1) 로딩/에러/성공 상태 분기
                if vm.isLoading {
                } else if let err = vm.errorMessage {
                    VStack(spacing: 10) {
                        Text("로딩 실패").font(.headline)
                        Text(err).font(.footnote).foregroundStyle(.secondary)
                        Button("다시 시도") {
                            Task { await vm.reload() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                } else if let d = vm.detail {
                    // 2) 성공 시: 서버 데이터 → ListDetailView 전달
                    ListDetailView(
                        topic: d.contentTitle.byCharWrapping,                           // 또는 d.topic (원하는 값으로 교체 가능)
                        date: displayDate(from: d.date),                 // "2025-08-17" → "2025년 8월 17일"
                        background_summary: d.backgroundSummaryList.map { $0.byCharWrapping },     // String → [String]로 변환해둠
                        full_article_summary: d.fullArticleSummary,
                        glossary: d.glossary,
                        mediaSummary: d.mediaSummary,
                        reportingVolumeCompare: d.reportingVolumeCompare
                    )
                } else {
                    // 최초 진입 직후 잠깐 보일 수 있는 빈 상태
                    EmptyView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            // MARK: - PoliticalSummaryView + 구분선 애니메이션
            if showPoliticalSummary {
                Group {
                    Color(hex: "#F4F4F4")
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 0) {
                        if let d = vm.detail {
                            PoliticalSummaryView(
                                progressiveText: d.progressiveMediaStance,
                                conservativeText: d.conservativeMediaStance
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .opacity(showPoliticalSummary ? 1 : 0)
                .offset(y: showPoliticalSummary ? 0 : -20)
            }
            
            // MARK: - ArticleSourceView + 구분선 애니메이션
            if showArticleSource {
                Group {
                    Color(hex: "#F4F4F4")
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)

                    VStack(spacing: 12) {
                        if let d = vm.detail {
                            ArticleSourceView(
                                articles: d.toArticles(),
                                progressiveRatio: CGFloat(d.reportingVolumeCompare.progressive),
                                conservativeRatio: CGFloat(d.reportingVolumeCompare.conservative),
                                progressiveMedias: d.mediaSummary.progressive,
                                conservativeMedias: d.mediaSummary.conservative
                            )
                            .padding(.leading, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .opacity(showArticleSource ? 1 : 0)
                .offset(y: showArticleSource ? 0 : -20)
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(EnableInteractivePopGesture()) // ✅ 스와이프‑뒤로 활성화
        .onAppear {
            // 상세 로딩
            Task { await vm.load(id: id.trimmingCharacters(in: .whitespacesAndNewlines)) }
            print("🔎 GET id:", id)

            // 섹션 등장 애니메이션 예약
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeInOut(duration: 0.8)) { showPoliticalSummary = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.easeInOut(duration: 0.8)) { showArticleSource = true }
            }
        }
    }

    /// "YYYY-MM-DD" → "YYYY년 M월 d일" 변환
    private func displayDate(from isoDay: String) -> String {
        // 입력: "2025-08-17"
        let inFmt = DateFormatter()
        inFmt.calendar = Calendar(identifier: .gregorian)
        inFmt.locale = Locale(identifier: "ko_KR")
        inFmt.timeZone = TimeZone(identifier: "Asia/Seoul")
        inFmt.dateFormat = "yyyy-MM-dd"

        let outFmt = DateFormatter()
        outFmt.calendar = Calendar(identifier: .gregorian)
        outFmt.locale = Locale(identifier: "ko_KR")
        outFmt.timeZone = TimeZone(identifier: "Asia/Seoul")
        outFmt.dateFormat = "yyyy년 M월 d일"

        if let date = inFmt.date(from: isoDay) {
            return outFmt.string(from: date)
        } else {
            return isoDay // 파싱 실패 시 원문 출력
        }
    }
}
