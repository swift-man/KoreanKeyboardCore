//
//  HangulComposerTests.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

import KoreanKeyboardCore
import Testing

/// 키보드 레이아웃 공급자가 각 입력 모드의 키 구성을 올바르게 반환하는지 검증합니다.
@Suite
struct KeyboardLayoutTests {
  /// 한글 레이아웃에 영문, 숫자, 시스템 키보드 전환 키가 포함되는지 검증합니다.
  @Test
  func hangulRowsExposeEnglishAndNumberSwitches() {
    let rows = KoreanKeyboardLayoutProvider().rows(for: KeyboardState(mode: .hangul))
    let keys = rows.flatMap(\.keys).map(\.key)
    
    #expect(keys.contains(.modeSwitch(.english)))
    #expect(keys.contains(.modeSwitch(.numbers)))
    #expect(keys.contains(.keyboardSwitch))
  }
  
  /// 한글 레이아웃은 겹자음과 복합 모음을 직접 제공하므로 Shift 키를 노출하지 않는지 검증합니다.
  @Test
  func hangulRowsDoNotExposeShiftKey() {
    let rows = KoreanKeyboardLayoutProvider().rows(for: KeyboardState(mode: .hangul))
    let keys = rows.flatMap(\.keys).map(\.key)
    
    #expect(!keys.contains(.shift))
  }
  
  /// 영문 레이아웃이 Shift 상태에 따라 소문자와 대문자를 반환하는지 검증합니다.
  @Test
  func englishRowsRespectShiftState() {
    let provider = KoreanKeyboardLayoutProvider()
    
    let lowerRows = provider.rows(for: KeyboardState(mode: .english, isShifted: false))
    let upperRows = provider.rows(for: KeyboardState(mode: .english, isShifted: true))
    
    #expect(lowerRows.flatMap(\.keys).map(\.key).contains(.character("q")))
    #expect(upperRows.flatMap(\.keys).map(\.key).contains(.character("Q")))
  }
  
  /// 영문 레이아웃에 한글, 숫자, 시스템 키보드 전환 키가 포함되는지 검증합니다.
  @Test
  func englishRowsExposeHangulAndNumberSwitches() {
    let rows = KoreanKeyboardLayoutProvider().rows(for: KeyboardState(mode: .english))
    let keys = rows.flatMap(\.keys).map(\.key)
    
    #expect(keys.contains(.modeSwitch(.hangul)))
    #expect(keys.contains(.modeSwitch(.numbers)))
    #expect(keys.contains(.keyboardSwitch))
  }
  
  /// 숫자 레이아웃에서 한글과 영문 모드로 전환할 수 있는지 검증합니다.
  @Test
  func numberRowsCanSwitchToHangulOrEnglish() {
    let rows = KoreanKeyboardLayoutProvider().rows(for: KeyboardState(mode: .numbers))
    let keys = rows.flatMap(\.keys).map(\.key)
    
    #expect(keys.contains(.modeSwitch(.hangul)))
    #expect(keys.contains(.modeSwitch(.english)))
    #expect(keys.contains(.keyboardSwitch))
  }
  
  /// 입력 모드를 바꾸면 Shift 상태가 해제되는지 검증합니다.
  @Test
  func switchingModeClearsShiftState() {
    var state = KeyboardState(mode: .english, isShifted: true)
    
    state.switchMode(to: .hangul)
    
    #expect(state.mode == .hangul)
    #expect(!state.isShifted)
  }
  
  /// 텍스트 입력 키가 삽입 문자열을 올바르게 노출하는지 검증합니다.
  @Test
  func characterKeysExposeInsertedText() {
    #expect(KeyboardKey.character("a").insertedText == "a")
    #expect(KeyboardKey.space.insertedText == " ")
    #expect(KeyboardKey.returnKey.insertedText == "\n")
    #expect(KeyboardKey.backspace.insertedText == nil)
  }
}
