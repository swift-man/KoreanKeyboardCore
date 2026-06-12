//
//  KeyboardMode.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

/// 키보드가 현재 표시할 입력 모드를 나타냅니다.
public enum KeyboardMode: String, CaseIterable, Codable, Equatable, Hashable, Sendable {
  /// 한글 자모 입력 모드입니다.
  case hangul
  
  /// 영문 알파벳 입력 모드입니다.
  case english
  
  /// 숫자와 기본 기호 입력 모드입니다.
  case numbers
  
  /// 모드 전환 키에 표시할 제목입니다.
  public var switchKeyTitle: String {
    switch self {
    case .hangul:
      return "한글"
    case .english:
      return "ABC"
    case .numbers:
      return "123"
    }
  }
}
