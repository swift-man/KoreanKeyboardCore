//
//  KeyboardKey.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

/// 키보드의 개별 키가 수행할 동작을 나타냅니다.
public enum KeyboardKey: Codable, Equatable, Hashable, Sendable {
  /// 텍스트 입력 키입니다.
  case character(String)
  
  /// Shift 상태를 전환하는 키입니다.
  case shift
  
  /// 조합 중인 글자 또는 이전 문자를 삭제하는 키입니다.
  case backspace
  
  /// 키보드 내부 입력 모드를 전환하는 키입니다.
  case modeSwitch(KeyboardMode)
  
  /// iOS에 등록된 다음 키보드로 전환하는 글로브 키입니다.
  case keyboardSwitch
  
  /// 공백을 입력하는 키입니다.
  case space
  
  /// 줄바꿈을 입력하는 키입니다.
  case returnKey
  
  /// 키를 눌렀을 때 바로 삽입할 수 있는 텍스트입니다.
  public var insertedText: String? {
    switch self {
    case let .character(value):
      return value
    case .space:
      return " "
    case .returnKey:
      return "\n"
    case .shift, .backspace, .modeSwitch, .keyboardSwitch:
      return nil
    }
  }
  
  /// 모드 전환 키가 가리키는 대상 모드입니다.
  public var modeSwitchTarget: KeyboardMode? {
    switch self {
    case let .modeSwitch(mode):
      return mode
    case .character, .shift, .backspace, .keyboardSwitch, .space, .returnKey:
      return nil
    }
  }
}
