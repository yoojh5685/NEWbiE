// Utils/GlossaryDebug.swift
import Foundation

/// 검색 안정화를 위한 정리:
/// - 특수 공백(NBSP 등)을 일반 공백으로
/// - 제로폭 문자 제거
/// - 유니코드 호환 정규화(NFKC)
public func normalizeForSearch(_ s: String) -> String {
    let zws: [Character] = ["\u{200B}", "\u{200C}", "\u{200D}", "\u{FEFF}"] // ZWSP, ZWNJ, ZWJ, BOM
    var out = s
        .replacingOccurrences(of: "\u{00A0}", with: " ") // NBSP
        .replacingOccurrences(of: "\u{202F}",with: " ") // NNBSP
        .replacingOccurrences(of: "\u{2009}", with: " ") // thin space
        .replacingOccurrences(of: "\u{2002}", with: " ") // en
        .replacingOccurrences(of: "\u{2003}", with: " ") // em
    out.removeAll(where: { zws.contains($0) })
    return out.precomposedStringWithCompatibilityMapping
}

/// term 내 일반 공백을 `\\s+` 로 치환해 다양한 공백(줄바꿈 등)도 허용
private func regexPattern(for term: String) -> String {
    let escaped = NSRegularExpression.escapedPattern(for: term)
    return escaped.replacingOccurrences(of: "\\ ", with: "\\s+")
}

/// 텍스트에서 term의 **첫 매치**가 있는지 확인 (있으면 true)
public func containsTermOnce(_ term: String, in text: String) -> Bool {
    let normText = normalizeForSearch(text)
    let normTerm = normalizeForSearch(term)
    let pattern = regexPattern(for: normTerm)

    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
        return false
    }
    let ns = normText as NSString
    let range = NSRange(location: 0, length: ns.length)
    return regex.firstMatch(in: normText, options: [], range: range) != nil
}

/// 디버깅 로그: 각 term이 어느 텍스트에 존재하는지 출력
func debugLogGlossaryMatches(
    backgroundSummary: String,
    fullArticleSummary: String,
    glossary: [GlossaryItem]
) {
    let bg = normalizeForSearch(backgroundSummary)
    let full = normalizeForSearch(fullArticleSummary)

    print("🧪 [Glossary] terms:", glossary.count,
          "| bg.len:", bg.count, "| full.len:", full.count)

    for g in glossary {
        let t = g.term
        guard !t.isEmpty else { continue }
        let inBG   = containsTermOnce(t, in: bg)
        let inFull = containsTermOnce(t, in: full)

        if inBG || inFull {
            print("✅ '\(t)' found → bg:\(inBG ? "Y" : "N"), full:\(inFull ? "Y" : "N")")
        } else {
            print("— '\(t)' not found")
        }
    }
}
