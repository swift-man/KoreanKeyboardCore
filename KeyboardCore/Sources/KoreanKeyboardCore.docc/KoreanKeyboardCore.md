# ``KoreanKeyboardCore``

한글 커스텀 키보드의 조합 로직과 키보드 레이아웃 모델을 제공하는 Swift 패키지입니다.

## Overview

`KoreanKeyboardCore`는 UI 계층과 분리된 한글 입력 코어입니다. 앱 또는 키보드 확장 타깃은 `HangulComposer`로 자모 입력을 완성형 음절 편집 명령으로 변환하고, `KoreanKeyboardLayoutProvider`로 한글, 영문, 숫자 레이아웃을 구성할 수 있습니다.

## Topics

### Hangul Composition

- ``HangulComposer``
- ``HangulComposing``
- ``ComposerEdit``

### Keyboard Layout

- ``KoreanKeyboardLayoutProvider``
- ``KeyboardLayoutProviding``
- ``KeyboardState``
- ``KeyboardMode``
- ``KeyboardRow``
- ``KeyboardKeySpec``
- ``KeyboardKey``
