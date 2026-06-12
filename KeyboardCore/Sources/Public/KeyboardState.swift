//
//  KeyboardState.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

/// 키보드 레이아웃을 결정하는 현재 입력 상태입니다.
public struct KeyboardState: Codable, Equatable, Hashable, Sendable {
  /// 현재 선택된 키보드 입력 모드입니다.
  public var mode: KeyboardMode
  
  /// 영문 레이아웃에서 Shift가 켜져 있는지 여부입니다.
  public var isShifted: Bool
  
  /// 키보드 상태를 생성합니다.
  /// - Parameters:
  ///   - mode: 처음 표시할 키보드 입력 모드입니다.
  ///   - isShifted: Shift 활성화 여부입니다.
  public init(mode: KeyboardMode = .hangul, isShifted: Bool = false) {
    self.mode = mode
    self.isShifted = isShifted
  }
  
  /// 입력 모드를 변경하고 Shift 상태를 해제합니다.
  /// - Parameter mode: 전환할 키보드 입력 모드입니다.
  public mutating func switchMode(to mode: KeyboardMode) {
    self.mode = mode
    isShifted = false
  }
  
  /// Shift 상태를 켜거나 끕니다.
  public mutating func toggleShift() {
    isShifted.toggle()
  }
}
