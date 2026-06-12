//
//  HangulComposer.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

import Foundation

/// 한글 조합 결과를 텍스트 입력 대상에 적용하기 위한 편집 명령입니다.
public struct ComposerEdit: Codable, Equatable, Hashable, Sendable {
  /// 기존 텍스트에서 삭제할 문자 수입니다.
  public let deleteCount: Int
  
  /// 삭제 후 삽입할 문자열입니다.
  public let insertedText: String
  
  /// 조합 상태가 비어 있어 호스트 입력 대상에 삭제를 위임해야 하는지 여부입니다.
  public let shouldDeleteFromDocument: Bool
  
  /// 조합 상태가 비어 있어 호스트 입력 대상에 삭제를 위임해야 하는지 여부입니다.
  @available(*, deprecated, renamed: "shouldDeleteFromDocument")
  public var shouldForwardDelete: Bool {
    shouldDeleteFromDocument
  }
  
  /// 편집 명령을 생성합니다.
  /// - Parameters:
  ///   - deleteCount: 기존 텍스트에서 삭제할 문자 수입니다.
  ///   - insertedText: 삭제 후 삽입할 문자열입니다.
  ///   - shouldDeleteFromDocument: 호스트 입력 대상에 삭제를 위임할지 여부입니다.
  public init(deleteCount: Int, insertedText: String, shouldDeleteFromDocument: Bool = false) {
    self.deleteCount = deleteCount
    self.insertedText = insertedText
    self.shouldDeleteFromDocument = shouldDeleteFromDocument
  }
  
  /// 편집 명령을 생성합니다.
  /// - Parameters:
  ///   - deleteCount: 기존 텍스트에서 삭제할 문자 수입니다.
  ///   - insertedText: 삭제 후 삽입할 문자열입니다.
  ///   - shouldForwardDelete: 호스트 입력 대상에 삭제를 위임할지 여부입니다.
  @available(*, deprecated, renamed: "init(deleteCount:insertedText:shouldDeleteFromDocument:)")
  public init(deleteCount: Int, insertedText: String, shouldForwardDelete: Bool) {
    self.init(deleteCount: deleteCount, insertedText: insertedText, shouldDeleteFromDocument: shouldForwardDelete)
  }
}

/// 한글 자모 입력을 완성형 음절 편집 명령으로 변환하는 타입입니다.
public protocol HangulComposing {
  /// 문자열 입력을 조합 상태에 반영합니다.
  /// - Parameter text: 입력된 문자열입니다.
  /// - Returns: 호스트 텍스트에 적용할 편집 명령입니다.
  mutating func input(_ text: String) -> ComposerEdit
  
  /// 현재 조합 상태에서 한 단계 뒤로 삭제합니다.
  /// - Returns: 호스트 텍스트에 적용할 편집 명령입니다.
  mutating func backspace() -> ComposerEdit
  
  /// 현재 한글 조합 상태를 초기화합니다.
  mutating func reset()
}

/// 한글 자모를 완성형 음절로 조합하는 기본 조합기입니다.
public struct HangulComposer: HangulComposing {
  /// 조합기가 현재 보유한 중간 조합 상태입니다.
  private enum Composition: Equatable {
    /// 조합 중인 글자가 없는 상태입니다.
    case none
    
    /// 단일 자음만 입력된 상태입니다.
    case consonant(String)
    
    /// 단일 모음만 입력된 상태입니다.
    case vowel(String)
    
    /// 초성, 중성, 선택적 종성으로 음절을 구성한 상태입니다.
    case syllable(initial: String, medial: String, final: String?)
  }
  
  /// 현재 한글 조합 상태입니다.
  private var composition: Composition = .none
  
  /// 기본 한글 조합기를 생성합니다.
  public init() {}
  
  /// 문자열 입력을 조합 상태에 반영합니다.
  /// - Parameter text: 입력된 문자열입니다.
  /// - Returns: 호스트 텍스트에 적용할 편집 명령입니다.
  public mutating func input(_ text: String) -> ComposerEdit {
    guard !text.isEmpty else {
      return ComposerEdit(deleteCount: 0, insertedText: "")
    }
    
    if HangulTables.isConsonant(text) {
      return inputConsonant(text)
    }
    
    if HangulTables.isVowel(text) {
      return inputVowel(text)
    }
    
    reset()
    return ComposerEdit(deleteCount: 0, insertedText: text)
  }
  
  /// 현재 조합 상태에서 한 단계 뒤로 삭제합니다.
  /// - Returns: 호스트 텍스트에 적용할 편집 명령입니다.
  public mutating func backspace() -> ComposerEdit {
    switch composition {
    case .none:
      return ComposerEdit(deleteCount: 0, insertedText: "", shouldDeleteFromDocument: true)
      
    case .consonant:
      composition = .none
      return ComposerEdit(deleteCount: 1, insertedText: "")
      
    case let .vowel(vowel):
      if let decomposedMedial = HangulTables.decomposedMedial(vowel) {
        composition = .vowel(decomposedMedial)
        return ComposerEdit(deleteCount: 1, insertedText: decomposedMedial)
      }
      
      composition = .none
      return ComposerEdit(deleteCount: 1, insertedText: "")
      
    case let .syllable(initial, medial, nil):
      if let decomposedMedial = HangulTables.decomposedMedial(medial) {
        let updated = HangulTables.compose(initial: initial, medial: decomposedMedial, final: nil)
        composition = .syllable(initial: initial, medial: decomposedMedial, final: nil)
        return ComposerEdit(deleteCount: 1, insertedText: updated)
      }
      
      composition = .consonant(initial)
      return ComposerEdit(deleteCount: 1, insertedText: initial)
      
    case let .syllable(initial, medial, final?):
      if let decomposedFinal = HangulTables.decomposedFinal(final) {
        let updated = HangulTables.compose(initial: initial, medial: medial, final: decomposedFinal)
        composition = .syllable(initial: initial, medial: medial, final: decomposedFinal)
        return ComposerEdit(deleteCount: 1, insertedText: updated)
      }
      
      let updated = HangulTables.compose(initial: initial, medial: medial, final: nil)
      composition = .syllable(initial: initial, medial: medial, final: nil)
      return ComposerEdit(deleteCount: 1, insertedText: updated)
    }
  }
  
  /// 현재 한글 조합 상태를 초기화합니다.
  public mutating func reset() {
    composition = .none
  }
  
  /// 자음 입력을 현재 조합 상태에 반영합니다.
  /// - Parameter consonant: 입력된 자음입니다.
  /// - Returns: 호스트 텍스트에 적용할 편집 명령입니다.
  private mutating func inputConsonant(_ consonant: String) -> ComposerEdit {
    switch composition {
    case .none:
      composition = .consonant(consonant)
      return ComposerEdit(deleteCount: 0, insertedText: consonant)
      
    case .consonant, .vowel:
      composition = .consonant(consonant)
      return ComposerEdit(deleteCount: 0, insertedText: consonant)
      
    case let .syllable(initial, medial, nil):
      guard HangulTables.isFinalConsonant(consonant) else {
        composition = .consonant(consonant)
        return ComposerEdit(deleteCount: 0, insertedText: consonant)
      }
      
      let updated = HangulTables.compose(initial: initial, medial: medial, final: consonant)
      composition = .syllable(initial: initial, medial: medial, final: consonant)
      return ComposerEdit(deleteCount: 1, insertedText: updated)
      
    case let .syllable(initial, medial, final?):
      if let combined = HangulTables.combinedFinal(final, with: consonant) {
        let updated = HangulTables.compose(initial: initial, medial: medial, final: combined)
        composition = .syllable(initial: initial, medial: medial, final: combined)
        return ComposerEdit(deleteCount: 1, insertedText: updated)
      }
      
      composition = .consonant(consonant)
      return ComposerEdit(deleteCount: 0, insertedText: consonant)
    }
  }
  
  /// 모음 입력을 현재 조합 상태에 반영합니다.
  /// - Parameter vowel: 입력된 모음입니다.
  /// - Returns: 호스트 텍스트에 적용할 편집 명령입니다.
  private mutating func inputVowel(_ vowel: String) -> ComposerEdit {
    switch composition {
    case .none:
      composition = .vowel(vowel)
      return ComposerEdit(deleteCount: 0, insertedText: vowel)
      
    case let .vowel(current):
      if let combined = HangulTables.combinedMedial(current, with: vowel) {
        composition = .vowel(combined)
        return ComposerEdit(deleteCount: 1, insertedText: combined)
      }
      
      composition = .vowel(vowel)
      return ComposerEdit(deleteCount: 0, insertedText: vowel)
      
    case let .consonant(initial):
      guard HangulTables.isInitialConsonant(initial) else {
        composition = .vowel(vowel)
        return ComposerEdit(deleteCount: 0, insertedText: vowel)
      }
      
      let updated = HangulTables.compose(initial: initial, medial: vowel, final: nil)
      composition = .syllable(initial: initial, medial: vowel, final: nil)
      return ComposerEdit(deleteCount: 1, insertedText: updated)
      
    case let .syllable(initial, medial, nil):
      if let combined = HangulTables.combinedMedial(medial, with: vowel) {
        let updated = HangulTables.compose(initial: initial, medial: combined, final: nil)
        composition = .syllable(initial: initial, medial: combined, final: nil)
        return ComposerEdit(deleteCount: 1, insertedText: updated)
      }
      
      composition = .vowel(vowel)
      return ComposerEdit(deleteCount: 0, insertedText: vowel)
      
    case let .syllable(initial, medial, final?):
      if let split = HangulTables.splitFinal(final) {
        let previous = HangulTables.compose(initial: initial, medial: medial, final: split.remaining)
        let current = HangulTables.compose(initial: split.moved, medial: vowel, final: nil)
        composition = .syllable(initial: split.moved, medial: vowel, final: nil)
        return ComposerEdit(deleteCount: 1, insertedText: previous + current)
      }
      
      guard HangulTables.isInitialConsonant(final) else {
        composition = .vowel(vowel)
        return ComposerEdit(deleteCount: 0, insertedText: vowel)
      }
      
      let previous = HangulTables.compose(initial: initial, medial: medial, final: nil)
      let current = HangulTables.compose(initial: final, medial: vowel, final: nil)
      composition = .syllable(initial: final, medial: vowel, final: nil)
      return ComposerEdit(deleteCount: 1, insertedText: previous + current)
    }
  }
}
