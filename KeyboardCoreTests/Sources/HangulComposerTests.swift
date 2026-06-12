//
//  HangulComposerTests.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

@testable import KoreanKeyboardCore
import Testing

/// 한글 조합기의 기본 조합, 삭제, 초기화 동작을 검증합니다.
@Suite
struct HangulComposerTests {
  /// 초성, 중성, 종성이 하나의 완성형 음절로 조합되는지 검증합니다.
  @Test
  func composesSimpleSyllable() {
    #expect(render(["ㅎ", "ㅏ", "ㄴ"]) == "한")
  }

  /// 종성이 결합될 수 없을 때 다음 음절 조합이 시작되는지 검증합니다.
  @Test
  func startsNewSyllableWhenFinalCannotCombine() {
    #expect(render(["ㅎ", "ㅏ", "ㄴ", "ㄱ", "ㅜ", "ㄱ"]) == "한국")
  }

  /// 종성 뒤에 모음이 입력되면 종성이 다음 음절의 초성으로 이동하는지 검증합니다.
  @Test
  func movesFinalConsonantWhenVowelFollows() {
    #expect(render(["ㄱ", "ㅏ", "ㅅ", "ㅏ"]) == "가사")
  }

  /// 두 모음이 복합 중성으로 조합되는지 검증합니다.
  @Test
  func composesCompoundVowel() {
    #expect(render(["ㄱ", "ㅗ", "ㅏ"]) == "과")
  }

  /// 상단 행에 추가된 겹자음과 복합 모음 입력이 조합되는지 검증합니다.
  @Test
  func composesAddedTopRowCharacters() {
    #expect(render(["ㅃ", "ㅐ", "ㅁ"]) == "뺌")
    #expect(render(["ㅇ", "ㅖ"]) == "예")
  }

  /// 한글이 아닌 입력이 들어오면 조합 상태가 초기화되는지 검증합니다.
  @Test
  func nonHangulInputResetsComposition() {
    var composer = HangulComposer()
    var text = ""

    apply(composer.input("ㄱ"), to: &text)
    apply(composer.input("ㅏ"), to: &text)
    apply(composer.input("1"), to: &text)
    #expect(text == "가1")

    apply(composer.backspace(), to: &text)
    #expect(text == "가")
  }

  /// 빈 문자열 입력이 텍스트를 변경하지 않는지 검증합니다.
  @Test
  func emptyInputIsNoOp() {
    var composer = HangulComposer()
    var text = "가"

    apply(composer.input(""), to: &text)

    #expect(text == "가")
  }

  /// 백스페이스가 복합 중성을 직전 조합 단계로 되돌리는지 검증합니다.
  @Test
  func backspaceRestoresPreviousCompositionStep() {
    var composer = HangulComposer()
    var text = ""
    apply(composer.input("ㄱ"), to: &text)
    apply(composer.input("ㅗ"), to: &text)
    apply(composer.input("ㅏ"), to: &text)
    #expect(text == "과")

    apply(composer.backspace(), to: &text)
    #expect(text == "고")
  }

  /// 백스페이스가 단독 복합 중성을 직전 모음으로 되돌리는지 검증합니다.
  @Test
  func backspaceRestoresStandaloneCompoundVowelStep() {
    var composer = HangulComposer()
    var text = ""
    apply(composer.input("ㅜ"), to: &text)
    apply(composer.input("ㅓ"), to: &text)
    #expect(text == "ㅝ")

    apply(composer.backspace(), to: &text)
    #expect(text == "ㅜ")
  }

  /// 조합 상태가 없을 때 백스페이스가 문서 삭제 위임 플래그를 반환하는지 검증합니다.
  @Test
  func backspaceWithoutCompositionRequestsDocumentDelete() {
    var composer = HangulComposer()
    let edit = composer.backspace()

    #expect(edit.shouldDeleteFromDocument)
    #expect(edit.deleteCount == 0)
    #expect(edit.insertedText == "")
  }

  /// 유효하지 않은 종성이 들어오면 조합하지 않고 입력 문자열을 보존하는지 검증합니다.
  @Test
  func composePreservesInvalidFinalConsonantInput() {
    #expect(HangulTables.compose(initial: "ㄱ", medial: "ㅏ", final: "A") == "ㄱㅏA")
  }

  /// 입력 문자열 배열을 조합기가 만든 최종 문자열로 렌더링합니다.
  /// - Parameter inputs: 순서대로 입력할 문자열 배열입니다.
  /// - Returns: 조합 결과 문자열입니다.
  private func render(_ inputs: [String]) -> String {
    var composer = HangulComposer()
    var text = ""

    inputs.forEach {
      apply(composer.input($0), to: &text)
    }

    return text
  }

  /// 편집 명령을 테스트용 문자열에 적용합니다.
  /// - Parameters:
  ///   - edit: 조합기가 반환한 편집 명령입니다.
  ///   - text: 편집 명령을 적용할 테스트용 문자열입니다.
  private func apply(_ edit: ComposerEdit, to text: inout String) {
    if edit.shouldDeleteFromDocument {
      _ = text.popLast()
      return
    }

    for _ in 0..<edit.deleteCount {
      _ = text.popLast()
    }
    text.append(contentsOf: edit.insertedText)
  }
}
