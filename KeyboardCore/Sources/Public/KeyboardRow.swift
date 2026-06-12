//
//  KeyboardRow.swift
//  KoreanKeyboardCore
//
//  Created by SwiftMan on 6/13/26.
//

/// 키보드의 한 행을 구성하는 키 목록과 좌우 여백 정보입니다.
public struct KeyboardRow: Codable, Equatable, Hashable, Sendable {
  /// 행에 표시할 키 목록입니다.
  public let keys: [KeyboardKeySpec]
  
  /// 행 앞쪽에 적용할 상대 여백입니다.
  public let horizontalInset: Double
  
  /// 키보드 행을 생성합니다.
  /// - Parameters:
  ///   - keys: 행에 표시할 키 목록입니다.
  ///   - horizontalInset: 행 앞쪽에 적용할 상대 여백입니다.
  public init(keys: [KeyboardKeySpec], horizontalInset: Double = 0) {
    self.keys = keys
    self.horizontalInset = horizontalInset
  }
}
