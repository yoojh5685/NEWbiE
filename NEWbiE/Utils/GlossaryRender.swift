// Utils/GlossaryRender.swift
import SwiftUI
import Foundation

// MARK: - (옵션) 용어 정규식 패턴 유틸
/// 내부 사용: term을 정규식 패턴으로 (공백은 \s+ 허용)
/// 현재 구현에서는 직접 사용하지 않지만, 추후 정교한 매칭에 사용할 수 있습니다.
private func regexPattern(for term: String) -> String {
    let escaped = NSRegularExpression.escapedPattern(for: term)
    return escaped.replacingOccurrences(of: "\\ ", with: "\\s+")
}

// MARK: - By-Character Wrapping
/// 기존 문자 속성(특히 밑줄)을 보존한 채 각 글자 뒤에 ZWSP를 넣는다.
/// - ZWSP에는 '밑줄만' 복사하여 밑줄이 끊겨 보이지 않게 함(링크는 복사하지 않음).
private func attributedByCharWrapping(_ input: AttributedString) -> AttributedString {
    var out = AttributedString()
    var i = input.startIndex

    while i < input.endIndex {
        let next = input.index(i, offsetByCharacters: 1)
        let ch = input[i..<next]      // 원문 1글자(속성 포함)

        // 현재 글자에 밑줄이 있는지 체크
        var hasUnderline = false
        for run in ch.runs {
            if run.underlineStyle != nil { hasUnderline = true; break }
        }

        // 원문 글자 추가
        out += ch

        // ZWSP 추가 (+ 밑줄만 복사)
        var zwsp = AttributedString("\u{200B}")
        if hasUnderline {
            zwsp.underlineStyle = .single   // ← 밑줄만 적용, 링크는 적용 X
        }
        out += zwsp

        i = next
    }
    return out
}

// MARK: - Attributed 생성
/// fullText에서 glossary의 '첫 등장'만 밑줄 + 링크(term://...) 부여.
/// 색상은 **본문 그대로 유지**(foregroundColor 변경 없음).
///
/// - Parameters:
///   - fullText: 원문 텍스트
///   - glossary: (term/definition) 목록
///   - debug: 콘솔 디버그 로그 출력 여부
///   - applyByCharWrapping: ZWSP로 글자단위 줄바꿈 적용 여부
/// - Returns: (attr, matches) -> 변환된 AttributedString과 매칭된 용어 리스트
func makeGlossaryAttributed(
    fullText: String,
    glossary: [GlossaryItem],
    debug: Bool = false,
    applyByCharWrapping: Bool = false
) -> (attr: AttributedString, matches: [GlossaryItem]) {

    var attributed = AttributedString(fullText)
    var matches: [GlossaryItem] = []

    // 각 용어마다 '첫 등장' 위치 찾기 (대소문자 무시)
    for g in glossary {
        let sanitizedTerm = normalizeForSearch(g.term) // NOTE: 프로젝트 내에 이미 존재하는 헬퍼 사용
        if sanitizedTerm.isEmpty { continue }

        if let range = attributed.range(of: g.term, options: .caseInsensitive) {
            // 밑줄 + 링크만 적용 (색상은 본문 유지)
            attributed[range].underlineStyle = .single
            attributed[range].foregroundColor = .black
            attributed[range].link = URL(
                string: "term://\(g.term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? g.term)"
            )
            matches.append(g)
        } else if debug {
            print("🔎 [GlossaryRender] not found → '\(g.term)'")
        }
    }

    // 글자단위 줄바꿈 적용 (full_article_summary 등에서 필요)
    if applyByCharWrapping {
        attributed = attributedByCharWrapping(attributed)
        if debug { print("ℹ️ [GlossaryRender] applied byCharWrapping") }
    }

    if debug {
        print("🧪 [makeGlossaryAttributed] matches=\(matches.map { $0.term }) | applyByCharWrapping=\(applyByCharWrapping)")
    }

    return (attributed, matches)
}

// MARK: - View Wrapper
/// 밑줄/링크가 적용된 AttributedString을 Text로 표시하고,
/// term:// 링크 탭을 콜백(onTapTerm)으로 전달하는 뷰.
struct GlossaryText: View {
    let attr: AttributedString
    let glossary: [GlossaryItem]
    let onTapTerm: (GlossaryItem) -> Void

    init(text: String,
         glossary: [GlossaryItem],
         debug: Bool = false,
         applyByCharWrapping: Bool = false,
         onTapTerm: @escaping (GlossaryItem) -> Void)
    {
        self.glossary = glossary
        self.onTapTerm = onTapTerm
        let made = makeGlossaryAttributed(
            fullText: text,
            glossary: glossary,
            debug: debug,
            applyByCharWrapping: applyByCharWrapping
        )
        self.attr = made.attr
    }

    var body: some View {
        Text(attr)
            .environment(\.openURL, OpenURLAction { url in
                // term://<encoded-term> 클릭 → 해당 GlossaryItem 찾아 콜백
                guard url.scheme == "term" else { return .systemAction }
                let raw = url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let key = raw.removingPercentEncoding ?? raw
                let sanitizedKey = normalizeForSearch(key)

                if let g = glossary.first(where: {
                    normalizeForSearch($0.term).caseInsensitiveCompare(sanitizedKey) == .orderedSame
                }) {
                    onTapTerm(g)
                    return .handled
                }
                return .discarded
            })
    }
}
