//
//  KeyboardLayout.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

import Foundation

/// 키보드 상태에 맞는 행 레이아웃을 제공하는 타입입니다.
public protocol KeyboardLayoutProviding {
  /// 현재 키보드 상태에 맞는 행 목록을 반환합니다.
  /// - Parameter state: 레이아웃을 계산할 키보드 상태입니다.
  /// - Returns: 화면에 표시할 키보드 행 목록입니다.
  func rows(for state: KeyboardState) -> [KeyboardRow]
}

/// 한글, 영문, 숫자 입력 모드를 제공하는 기본 키보드 레이아웃 공급자입니다.
public struct KoreanKeyboardLayoutProvider: KeyboardLayoutProviding {
  /// 기본 키보드 레이아웃 공급자를 생성합니다.
  public init() {}
  
  /// 현재 키보드 상태에 맞는 행 목록을 반환합니다.
  /// - Parameter state: 레이아웃을 계산할 키보드 상태입니다.
  /// - Returns: 화면에 표시할 키보드 행 목록입니다.
  public func rows(for state: KeyboardState) -> [KeyboardRow] {
    switch state.mode {
    case .hangul:
      return hangulRows()
    case .english:
      return englishRows(isShifted: state.isShifted)
    case .numbers:
      return numberRows()
    }
  }
  
  /// 한글 입력 모드에서 사용할 키보드 행 목록을 만듭니다.
  /// - Returns: 한글 자모와 하단 제어 키로 구성된 행 목록입니다.
  private func hangulRows() -> [KeyboardRow] {
    [
      KeyboardRow(keys: ["ㅃ", "ㅉ", "ㄸ", "ㄲ", "ㅆ", "ㅒ", "ㅖ"].map(characterKey), horizontalInset: 20),
      KeyboardRow(keys: ["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅛ", "ㅕ", "ㅑ", "ㅐ", "ㅔ"].map(characterKey)),
      KeyboardRow(keys: ["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"].map(characterKey), horizontalInset: 22),
      KeyboardRow(keys: [
        characterKey("ㅋ"),
        characterKey("ㅌ"),
        characterKey("ㅊ"),
        characterKey("ㅍ"),
        characterKey("ㅠ"),
        characterKey("ㅜ"),
        characterKey("ㅡ"),
        KeyboardKeySpec(key: .backspace, width: 1.32)
      ], horizontalInset: 14),
      KeyboardRow(keys: [
        KeyboardKeySpec(key: .modeSwitch(.english), width: 1.2),
        KeyboardKeySpec(key: .modeSwitch(.numbers), width: 1.2),
        KeyboardKeySpec(key: .keyboardSwitch, width: 1.2),
        KeyboardKeySpec(key: .space, width: 4.4),
        KeyboardKeySpec(key: .returnKey, width: 2.0)
      ])
    ]
  }
  
  /// 영문 입력 모드에서 사용할 키보드 행 목록을 만듭니다.
  /// - Parameter isShifted: 영문 키를 대문자로 표시할지 여부입니다.
  /// - Returns: 영문 알파벳과 하단 제어 키로 구성된 행 목록입니다.
  private func englishRows(isShifted: Bool) -> [KeyboardRow] {
    let firstRow = letters(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], isShifted: isShifted)
    let secondRow = letters(["a", "s", "d", "f", "g", "h", "j", "k", "l"], isShifted: isShifted)
    let thirdRow = letters(["z", "x", "c", "v", "b", "n", "m"], isShifted: isShifted)
    
    return [
      KeyboardRow(keys: firstRow),
      KeyboardRow(keys: secondRow, horizontalInset: 22),
      KeyboardRow(keys: [
        KeyboardKeySpec(key: .shift, width: 1.32)
      ] + thirdRow + [
        KeyboardKeySpec(key: .backspace, width: 1.32)
      ]),
      KeyboardRow(keys: [
        KeyboardKeySpec(key: .modeSwitch(.hangul), width: 1.2),
        KeyboardKeySpec(key: .modeSwitch(.numbers), width: 1.2),
        KeyboardKeySpec(key: .keyboardSwitch, width: 1.2),
        KeyboardKeySpec(key: .space, width: 4.4),
        KeyboardKeySpec(key: .returnKey, width: 2.0)
      ])
    ]
  }
  
  /// 숫자 입력 모드에서 사용할 키보드 행 목록을 만듭니다.
  /// - Returns: 숫자, 기본 기호, 하단 제어 키로 구성된 행 목록입니다.
  private func numberRows() -> [KeyboardRow] {
    [
      KeyboardRow(keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map(characterKey)),
      KeyboardRow(keys: ["-", "/", ":", ";", "(", ")", "₩", "&", "@", "\""].map(characterKey)),
      KeyboardRow(keys: [
        characterKey("."),
        characterKey(","),
        characterKey("?"),
        characterKey("!"),
        characterKey("'"),
        KeyboardKeySpec(key: .backspace, width: 1.32)
      ], horizontalInset: 14),
      KeyboardRow(keys: [
        KeyboardKeySpec(key: .modeSwitch(.hangul), width: 1.2),
        KeyboardKeySpec(key: .modeSwitch(.english), width: 1.2),
        KeyboardKeySpec(key: .keyboardSwitch, width: 1.2),
        KeyboardKeySpec(key: .space, width: 4.4),
        KeyboardKeySpec(key: .returnKey, width: 2.0)
      ])
    ]
  }
  
  /// 문자열 배열을 영문 문자 키 스펙 목록으로 변환합니다.
  /// - Parameters:
  ///   - values: 키에 표시할 영문 문자열 목록입니다.
  ///   - isShifted: 대문자로 변환할지 여부입니다.
  /// - Returns: 문자 키 스펙 목록입니다.
  private func letters(_ values: [String], isShifted: Bool) -> [KeyboardKeySpec] {
    values.map { characterKey(isShifted ? $0.uppercased() : $0) }
  }
  
  /// 문자열을 문자 입력 키 스펙으로 감쌉니다.
  /// - Parameter value: 키가 입력할 문자열입니다.
  /// - Returns: 문자 입력 키 스펙입니다.
  private func characterKey(_ value: String) -> KeyboardKeySpec {
    KeyboardKeySpec(key: .character(value))
  }
}
