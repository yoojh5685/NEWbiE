import SwiftUI

struct ListView: View {
    let id: String
    
    // 애니메이션 상태
    @State private var showPoliticalSummary = false
    @State private var showArticleSource = false

    // 상세 로딩 상태
    @StateObject private var vm = DetailViewModel(service: LiveDetailService(baseURL: URL(string: "https://newsservice.shop")!))

    // ✅ 공유 시트 상태 (여기로 이동)
    @State private var isShowingShareSheet = false

    @EnvironmentObject var navigationManager: NavigationManager
    
    // ✅ 상단 바 높이(패딩 계산용)
    private let topBarHeight: CGFloat = 18
    private let topBarHorizontalPadding: CGFloat = 20
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if vm.isLoading {
                    // 필요시 스켈레톤 등
                } else if let err = vm.errorMessage {
                    VStack(spacing: 10) {
                        Text("로딩 실패").font(.headline)
                        Text(err).font(.footnote).foregroundStyle(.secondary)
                        Button("다시 시도") { Task { await vm.reload() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                } else if let d = vm.detail {
                    ListDetailView(
                        topic: d.contentTitle.byCharWrapping,
                        date: displayDate(from: d.date),
                        background_summary: d.backgroundSummaryList.map { $0.byCharWrapping },
                        full_article_summary: d.fullArticleSummary,
                        glossary: d.glossary,
                        mediaSummary: d.mediaSummary,
                        reportingVolumeCompare: d.reportingVolumeCompare
                    )
                } else {
                    EmptyView()
                }
            }
            // ✅ 상단 바만큼 여유를 더 줘서 겹침 방지
            .padding(.horizontal, topBarHorizontalPadding)
//            .padding(.top, topBarHeight)   // 기존 30 대신 고정 바 높이 반영
            .padding(.bottom, 20)

            // 이하 기존 정치 요약/기사 출처 섹션 동일
            if showPoliticalSummary {
                Group {
                    Color(hex: "#F4F4F4").frame(height: 20)
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

            if showArticleSource {
                Group {
                    Color(hex: "#F4F4F4").frame(height: 20)
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
        .background(EnableInteractivePopGesture())
        // ✅ 고정 상단 바
        .safeAreaInset(edge: .top) {
            HStack {
                // 뒤로 버튼
                Button(action: {
                    navigationManager.pop()
                }) {
                    Image("arrow-left")
                }
                .contentShape(Rectangle()) // ← 버튼 터치 영역 확보

                Spacer()

                // 공유 버튼
                Button(action: {
                    isShowingShareSheet = true
                }) {
                    Image("share")
                }
                .contentShape(Rectangle()) // ← 버튼 터치 영역 확보
            }
            .frame(height: topBarHeight)
            .padding(.horizontal, topBarHorizontalPadding)
            .padding(.top, 30)
            .padding(.bottom, 18)
            .contentShape(Rectangle())                // ← 상단바 전체 터치 영역
            .background(.white)
        }
        // ✅ 공유 시트 (상단 바의 버튼이 띄움)
        .sheet(isPresented: $isShowingShareSheet) {
            // 로딩 중/실패 대비 기본 문자열 처리
            let shareTitle = vm.detail?.contentTitle ?? "뉴스 요약"
            ShareSheet(items: [shareTitle])
        }
        .onAppear {
            Task { await vm.load(id: id.trimmingCharacters(in: .whitespacesAndNewlines)) }
            print("🔎 GET id:", id)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeInOut(duration: 0.8)) { showPoliticalSummary = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.easeInOut(duration: 0.8)) { showArticleSource = true }
            }
        }
    }

    // 날짜 변환 함수는 동일
    private func displayDate(from isoDay: String) -> String {
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
            return isoDay
        }
    }
}
