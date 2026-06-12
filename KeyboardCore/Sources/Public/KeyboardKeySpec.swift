//
//  KeyboardKeySpec.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

/// 키 하나의 의미와 레이아웃 폭을 함께 담는 모델입니다.
public struct KeyboardKeySpec: Codable, Equatable, Hashable, Sendable {
  /// 키가 수행할 동작입니다.
  public let key: KeyboardKey
  
  /// 같은 행 안에서 차지할 상대 폭입니다.
  public let width: Double
  
  /// 키 스펙을 생성합니다.
  /// - Parameters:
  ///   - key: 키가 수행할 동작입니다.
  ///   - width: 같은 행 안에서 차지할 상대 폭입니다.
  public init(key: KeyboardKey, width: Double = 1) {
    self.key = key
    self.width = width
  }
}
