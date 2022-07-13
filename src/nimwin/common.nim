import glfw, unicode

export glfw.Key
export glfw.ElementState
export glfw.GamepadButton
export glfw.Joystick
export glfw.JoystickHat

type
  WindowId* = distinct int64

  PhysicalPosition*[T] = object
    x*, y*: T

  PhysicalSize*[T] = object
    width*, height*: T

  MouseButtonKind* {.pure.} = enum
    Left
    Right
    Middle
    Other

  MouseButton* = object
    kind*: MouseButtonKind
    raw*: int32

type
  KeyboardInput* = object
    key*: Key
    state*: ElementState
    mods*: set[ModifierKey]

  RuneInput* = object
    rune*: Rune
    mods*: set[ModifierKey]

  MouseButtonInput* = object
    button*: MouseButton
    state*: ElementState
    mods*: set[ModifierKey]

proc `==`*(w1, w2: WindowId): bool {.borrow.}

proc `$`*(w1: WindowId): string {.borrow.}