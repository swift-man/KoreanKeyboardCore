//
//  HangulTables.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

/// 한글 자모 조합에 필요한 표와 계산 함수를 제공합니다.
enum HangulTables {
  /// 완성형 한글 초성 순서입니다.
  static let initials = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
  
  /// 완성형 한글 중성 순서입니다.
  static let medials = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
  
  /// 완성형 한글 종성 순서입니다.
  static let finals = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
  
  /// 두 중성을 하나의 복합 중성으로 합치는 표입니다.
  private static let medialCombinations = [
    "ㅗㅏ": "ㅘ",
    "ㅗㅐ": "ㅙ",
    "ㅗㅣ": "ㅚ",
    "ㅜㅓ": "ㅝ",
    "ㅜㅔ": "ㅞ",
    "ㅜㅣ": "ㅟ",
    "ㅡㅣ": "ㅢ"
  ]
  
  /// 두 종성을 하나의 복합 종성으로 합치는 표입니다.
  private static let finalCombinations = [
    "ㄱㅅ": "ㄳ",
    "ㄴㅈ": "ㄵ",
    "ㄴㅎ": "ㄶ",
    "ㄹㄱ": "ㄺ",
    "ㄹㅁ": "ㄻ",
    "ㄹㅂ": "ㄼ",
    "ㄹㅅ": "ㄽ",
    "ㄹㅌ": "ㄾ",
    "ㄹㅍ": "ㄿ",
    "ㄹㅎ": "ㅀ",
    "ㅂㅅ": "ㅄ"
  ]
  
  /// 복합 종성을 이전 음절에 남길 종성과 다음 음절 초성으로 나누는 표입니다.
  private static let splitFinals = [
    "ㄳ": (remaining: "ㄱ", moved: "ㅅ"),
    "ㄵ": (remaining: "ㄴ", moved: "ㅈ"),
    "ㄶ": (remaining: "ㄴ", moved: "ㅎ"),
    "ㄺ": (remaining: "ㄹ", moved: "ㄱ"),
    "ㄻ": (remaining: "ㄹ", moved: "ㅁ"),
    "ㄼ": (remaining: "ㄹ", moved: "ㅂ"),
    "ㄽ": (remaining: "ㄹ", moved: "ㅅ"),
    "ㄾ": (remaining: "ㄹ", moved: "ㅌ"),
    "ㄿ": (remaining: "ㄹ", moved: "ㅍ"),
    "ㅀ": (remaining: "ㄹ", moved: "ㅎ"),
    "ㅄ": (remaining: "ㅂ", moved: "ㅅ")
  ]
  
  /// 값이 한글 자음인지 확인합니다.
  /// - Parameter value: 확인할 문자열입니다.
  /// - Returns: 자음이면 `true`, 아니면 `false`입니다.
  static func isConsonant(_ value: String) -> Bool {
    guard !value.isEmpty else {
      return false
    }
    
    return initials.contains(value) || finals.contains(value)
  }
  
  /// 값이 한글 모음인지 확인합니다.
  /// - Parameter value: 확인할 문자열입니다.
  /// - Returns: 모음이면 `true`, 아니면 `false`입니다.
  static func isVowel(_ value: String) -> Bool {
    medials.contains(value)
  }
  
  /// 값이 초성으로 사용할 수 있는 자음인지 확인합니다.
  /// - Parameter value: 확인할 문자열입니다.
  /// - Returns: 초성으로 사용할 수 있으면 `true`, 아니면 `false`입니다.
  static func isInitialConsonant(_ value: String) -> Bool {
    initials.contains(value)
  }
  
  /// 값이 종성으로 사용할 수 있는 자음인지 확인합니다.
  /// - Parameter value: 확인할 문자열입니다.
  /// - Returns: 종성으로 사용할 수 있으면 `true`, 아니면 `false`입니다.
  static func isFinalConsonant(_ value: String) -> Bool {
    finals.dropFirst().contains(value)
  }
  
  /// 두 중성을 복합 중성으로 합칩니다.
  /// - Parameters:
  ///   - lhs: 먼저 입력된 중성입니다.
  ///   - rhs: 이어서 입력된 중성입니다.
  /// - Returns: 합칠 수 있으면 복합 중성, 아니면 `nil`입니다.
  static func combinedMedial(_ lhs: String, with rhs: String) -> String? {
    medialCombinations[lhs + rhs]
  }
  
  /// 두 종성을 복합 종성으로 합칩니다.
  /// - Parameters:
  ///   - lhs: 먼저 입력된 종성입니다.
  ///   - rhs: 이어서 입력된 자음입니다.
  /// - Returns: 합칠 수 있으면 복합 종성, 아니면 `nil`입니다.
  static func combinedFinal(_ lhs: String, with rhs: String) -> String? {
    finalCombinations[lhs + rhs]
  }
  
  /// 복합 종성을 이전 음절에 남길 종성과 다음 음절 초성으로 나눕니다.
  /// - Parameter value: 나눌 복합 종성입니다.
  /// - Returns: 나눌 수 있으면 남길 종성과 이동할 초성 쌍, 아니면 `nil`입니다.
  static func splitFinal(_ value: String) -> (remaining: String, moved: String)? {
    splitFinals[value]
  }
  
  /// 복합 중성에서 직전 조합 단계의 중성을 꺼냅니다.
  /// - Parameter value: 분해할 복합 중성입니다.
  /// - Returns: 분해할 수 있으면 이전 중성, 아니면 `nil`입니다.
  static func decomposedMedial(_ value: String) -> String? {
    medialCombinations.first { $0.value == value }?.key.first.map(String.init)
  }
  
  /// 복합 종성에서 직전 조합 단계의 종성을 꺼냅니다.
  /// - Parameter value: 분해할 복합 종성입니다.
  /// - Returns: 분해할 수 있으면 이전 종성, 아니면 `nil`입니다.
  static func decomposedFinal(_ value: String) -> String? {
    finalCombinations.first { $0.value == value }?.key.first.map(String.init)
  }
  
  /// 초성, 중성, 종성을 완성형 한글 음절로 조합합니다.
  /// - Parameters:
  ///   - initial: 초성입니다.
  ///   - medial: 중성입니다.
  ///   - final: 선택적 종성입니다.
  /// - Returns: 조합된 완성형 음절입니다. 조합할 수 없으면 입력 문자열을 이어 붙여 반환합니다.
  static func compose(initial: String, medial: String, final: String?) -> String {
    guard
      let initialIndex = initials.firstIndex(of: initial),
      let medialIndex = medials.firstIndex(of: medial)
    else {
      return initial + medial + (final ?? "")
    }
    
    let finalIndex = final.flatMap { finals.firstIndex(of: $0) } ?? 0
    let scalarValue = 0xAC00 + ((initialIndex * 21) + medialIndex) * 28 + finalIndex
    
    guard let scalar = UnicodeScalar(scalarValue) else {
      return initial + medial + (final ?? "")
    }
    
    return String(Character(scalar))
  }
}
