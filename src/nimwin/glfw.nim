static:
  assert cshort.sizeof == int16.sizeof and cint.sizeof == int32.sizeof,
    "Not binary compatible with GLFW. Please report this."

import os

const BaseDir = currentSourcePath.parentDir()
const SrcDir = BaseDir / "private/glfw/src"
echo SrcDir

when defined(glfwJustCdecl):
  {.pragma: glfwImport, cdecl.}
elif not defined(glfwStaticLib):
  when defined(windows):
    const GlfwDll = "glfw3.dll"
  elif defined(macosx):
    const GlfwDll = "libglfw3.dylib"
  else:
    const GlfwDll = "libglfw.so.3"
  {.pragma: glfwImport, dynlib: GlfwDll.}
  {.deadCodeElim: on.}

else:
  when defined(windows):
    import strformat

    {.passC: fmt"-D_GLFW_WIN32 -I {BaseDir}/deps/mingw", passL: "-lopengl32 -lgdi32",
      compile: SrcDir / "win32_init.c",
      compile: SrcDir / "win32_joystick.c",
      compile: SrcDir / "win32_module.c",
      compile: SrcDir / "win32_monitor.c",
      compile: SrcDir / "win32_thread.c",
      compile: SrcDir / "win32_time.c",
      compile: SrcDir / "win32_window.c",
      compile: SrcDir / "wgl_context.c",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

  elif defined(macosx):
    {.passC: "-D_GLFW_COCOA",
      passL: "-framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo",
      compile: SrcDir / "cocoa_init.m",
      compile: SrcDir / "cocoa_joystick.m",
      compile: SrcDir / "cocoa_monitor.m",
      compile: SrcDir / "cocoa_window.m",
      compile: SrcDir / "cocoa_time.c",
      compile: SrcDir / "posix_module.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "nsgl_context.m",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

  elif defined(linux):
    # TODO untested
    {.passL: "-pthread -lGL -lX11 -lXrandr -lXxf86vm -lXi -lXcursor -lm -lXinerama".}

    when defined(wayland):
      {.passC: "-D_GLFW_WAYLAND",
      compile: SrcDir / "wl_init.c",
      compile: SrcDir / "wl_monitor.c",
      compile: SrcDir / "wl_window.c",
      compile: SrcDir / "posix_module.c",
      compile: SrcDir / "posix_time.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "xkb_unicode.c",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}
    else:
      {.passC: "-D_GLFW_X11",
      compile: SrcDir / "x11_init.c",
      compile: SrcDir / "x11_monitor.c",
      compile: SrcDir / "x11_window.c",
      compile: SrcDir / "xkb_unicode.c",
      compile: SrcDir / "posix_module.c",
      compile: SrcDir / "posix_time.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "glx_context.c",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

    {.compile: SrcDir / "src/linux_joystick.c".}

  else:
    # If unsupported/unknown OS, use null system
    # TODO untested
    {.compile: SrcDir / "posix_time.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "osmesa_context.c".}

  # Common
  {.compile: SrcDir / "context.c",
    compile: SrcDir / "init.c",
    compile: SrcDir / "null_init.c",
    compile: SrcDir / "null_monitor.c",
    compile: SrcDir / "null_window.c",
    compile: SrcDir / "null_joystick.c",
    compile: SrcDir / "input.c",
    compile: SrcDir / "monitor.c",
    compile: SrcDir / "platform.c",
    compile: SrcDir / "vulkan.c",
    compile: SrcDir / "window.c".}

  {.pragma: glfwImport.}


type
  ModifierKey* {.size: int32.sizeof, pure.} = enum
    Shift = (0x00000001, "shift")
    Ctrl = (0x00000002, "ctrl")
    Alt = (0x00000004, "alt")
    Super = (0x00000008, "super")
    CapsLock = (0x00000010, "capslock")
    NumLock = (0x00000020, "numlock")

type
  Key* {.size: int32.sizeof, pure.} = enum
    KeyUnknown = (-1, "unknown")
    KeySpace = (32, "space")
    KeyApostrophe = (39, "apostrophe")
    KeyComma = (44, "comma")
    KeyMinus = (45, "minus")
    KeyPeriod = (46, "period")
    KeySlash = (47, "slash")
    Key0 = (48, "0")
    Key1 = (49, "1")
    Key2 = (50, "2")
    Key3 = (51, "3")
    Key4 = (52, "4")
    Key5 = (53, "5")
    Key6 = (54, "6")
    Key7 = (55, "7")
    Key8 = (56, "8")
    Key9 = (57, "9")
    KeySemicolon = (59, "semicolon")
    KeyEqual = (61, "equal")
    KeyA = (65, "a")
    KeyB = (66, "b")
    KeyC = (67, "c")
    KeyD = (68, "d")
    KeyE = (69, "e")
    KeyF = (70, "f")
    KeyG = (71, "g")
    KeyH = (72, "h")
    KeyI = (73, "i")
    KeyJ = (74, "j")
    KeyK = (75, "k")
    Keyl = (76, "l")
    KeyM = (77, "m")
    KeyN = (78, "n")
    KeyO = (79, "o")
    KeyP = (80, "p")
    KeyQ = (81, "q")
    KeyR = (82, "r")
    KeyS = (83, "s")
    KeyT = (84, "t")
    KeyU = (85, "u")
    KeyV = (86, "v")
    KeyW = (87, "w")
    KeyX = (88, "x")
    KeyY = (89, "y")
    KeyZ = (90, "z")
    KeyLeftBracket = (91, "left bracket")
    KeyBackslash = (92, "backslash")
    KeyRightBracket = (93, "right bracket")
    KeyGraveAccent = (96, "grave accent")
    KeyWorld1 = (161, "world1")
    KeyWorld2 = (162, "world2")
    KeyEscape = (256, "escape")
    KeyEnter = (257, "enter")
    KeyTab = (258, "tab")
    KeyBackspace = (259, "backspace")
    KeyInsert = (260, "insert")
    KeyDelete = (261, "delete")
    KeyRight = (262, "right")
    KeyLeft = (263, "left")
    KeyDown = (264, "down")
    KeyUp = (265, "up")
    KeyPageUp = (266, "page up")
    KeyPageDown = (267, "page down")
    KeyHome = (268, "home")
    KeyEnd = (269, "end")
    KeyCapsLock = (280, "caps lock")
    KeyScrollLock = (281, "scroll lock")
    KeyNumLock = (282, "num lock")
    KeyPrintScreen = (283, "print screen")
    KeyPause = (284, "pause")
    KeyF1 = (290, "f1")
    KeyF2 = (291, "f2")
    KeyF3 = (292, "f3")
    KeyF4 = (293, "f4")
    KeyF5 = (294, "f5")
    KeyF6 = (295, "f6")
    KeyF7 = (296, "f7")
    KeyF8 = (297, "f8")
    KeyF9 = (298, "f9")
    KeyF10 = (299, "f10")
    KeyF11 = (300, "f11")
    KeyF12 = (301, "f12")
    KeyF13 = (302, "f13")
    KeyF14 = (303, "f14")
    KeyF15 = (304, "f15")
    KeyF16 = (305, "f16")
    KeyF17 = (306, "f17")
    KeyF18 = (307, "f18")
    KeyF19 = (308, "f19")
    KeyF20 = (309, "f20")
    KeyF21 = (310, "f21")
    KeyF22 = (311, "f22")
    KeyF23 = (312, "f23")
    KeyF24 = (313, "f24")
    KeyF25 = (314, "f25")
    KeyKp0 = (320, "kp0")
    KeyKp1 = (321, "kp1")
    KeyKp2 = (322, "kp2")
    KeyKp3 = (323, "kp3")
    KeyKp4 = (324, "kp4")
    KeyKp5 = (325, "kp5")
    KeyKp6 = (326, "kp6")
    KeyKp7 = (327, "kp7")
    KeyKp8 = (328, "kp8")
    KeyKp9 = (329, "kp9")
    KeyKpDecimal = (330, "kp decimal")
    KeyKpDivide = (331, "kp divide")
    KeyKpMultiply = (332, "kp multiply")
    KeyKpSubtract = (333, "kp subtract")
    KeyKpAdd = (334, "kp add")
    KeyKpEnter = (335, "kp enter")
    KeyKpEqual = (336, "kp equal")
    KeyLeftShift = (340, "left shift")
    KeyLeftControl = (341, "left control")
    KeyLeftAlt = (342, "left alt")
    KeyLeftSuper = (343, "left super")
    KeyRightShift = (344, "right shift")
    KeyRightControl = (345, "right control")
    KeyRightAlt = (346, "right alt")
    KeyRightSuper = (347, "right super")
    KeyMenu = (348, "menu")

  ElementState* {.size: int32.sizeof, pure.} = enum
    Pressed = (0, "up")
    Released = (1, "down")
    Repeated = (2, "repeat")

  GamepadButton* {.size: int32.sizeof.} = enum
    gbA           = (0, "A")
    gbB           = (1, "B")
    gbX           = (2, "X")
    gbY           = (3, "Y")
    gbLeftBumper  = (4, "left bumper")
    gbRightBumper = (5, "right bumper")
    gbBack        = (6, "back")
    gbStart       = (7, "start")
    gbGuide       = (8, "guide")
    gbLeftThumb   = (9, "left thumb")
    gbRightThumb  = (10, "right thumb")
    gbDpadUp      = (11, "dpad up")
    gbDpadRight   = (12, "dpad right")
    gbDpadDown    = (13, "dpad down")
    gbDpadLeft    = (14, "dpad left")

  Joystick* {.size: int32.sizeof} = enum
    joystick1 = (0, "joystick 0")
    joystick2 = (1, "joystick 1")
    joystick3 = (2, "joystick 2")
    joystick4 = (3, "joystick 3")
    joystick5 = (4, "joystick 4")
    joystick6 = (5, "joystick 5")
    joystick7 = (6, "joystick 6")
    joystick8 = (7, "joystick 6")
    joystick9 = (8, "joystick 7")
    joystick10 = (9, "joystick 9")
    joystick11 = (10, "joystick 10")
    joystick12 = (11, "joystick 11")
    joystick13 = (12, "joystick 12")
    joystick14 = (13, "joystick 13")
    joystick15 = (14, "joystick 14")
    joystick16 = (15, "joystick 15")

  JoystickHat* {.size: int32.sizeof} = enum
    # jhEnum or jhEnum = bitwise or between the values
    # FIXME: Find more idiomatic way to do or in enum
    jhCentered  = (0, "centered")
    jhUp        = (1, "up")
    jhRight     = (2, "right")
    jhRightUp   = (3, "right up")    # jhRight or jhUp
    jhDown      = (4, "down")
    jhRightDown = (6, "right down")  # jhRight or jhDown
    jhLeft      = (8, "left")
    jhLeftUp    = (9, "left up")     # jhLeft or jhUp
    jhLeftDown  = (12, "left down")  # jhLeft or jhDown

const 
  buttonLast* = gbDpadLeft
  joystickLast* = joystick16


type
  GamepadState* = object
    buttons: array[15, uint8]
    axes: array[6, float]

type
  Hint* {.size: int32.sizeof, pure.} = enum
    Focused                = 0x00020001
    Iconified              = 0x00020002
    Resizable              = 0x00020003
    Visible                = 0x00020004
    Decorated              = 0x00020005
    AutoIconify            = 0x00020006
    Floating               = 0x00020007
    Maximized              = 0x00020008
    CenterCursor           = 0x00020009
    TransparentFramebuffer = 0x0002000A
    Hovered                = 0x0002000B
    FocusOnShow            = 0x0002000C
    MousePassthrough       = 0x0002000D
    RedBits                = 0x00021001
    GreenBits              = 0x00021002
    BlueBits               = 0x00021003
    AlphaBits              = 0x00021004
    DepthBits              = 0x00021005
    StencilBits            = 0x00021006
    AccumRedBits           = 0x00021007
    AccumGreenBits         = 0x00021008
    AccumBlueBits          = 0x00021009
    AccumAlphaBits         = 0x0002100A
    AuxBuffers             = 0x0002100B
    Stereo                 = 0x0002100C
    Samples                = 0x0002100D
    SrgbCapable            = 0x0002100E
    RefreshRate            = 0x0002100F
    Doublebuffer           = 0x00021010
    ClientApi              = 0x00022001
    ContextVersionMajor    = 0x00022002
    ContextVersionMinor    = 0x00022003
    ContextRevision        = 0x00022004
    ContextRobustness      = 0x00022005
    OpenglForwardCompat    = 0x00022006
    OpenglDebugContext     = 0x00022007
    OpenglProfile          = 0x00022008
    ContextReleaseBehavior = 0x00022009
    ContextNoError         = 0x0002200A
    ContextCreationApi     = 0x0002200B
    ScaleToMonitor         = 0x0002200C
    CocoaRetinaFrameBuffer = 0x00023001
    CocoaFrameName         = 0x00023002
    CocoaGraphicsSwitching = 0x00023003
    X11ClassName           = 0x00024001
    X11InstanceName        = 0x00024002
    Win32KeyboardMenu      = 0x00025001

  InitHint* {.size: int32.sizeof.} = enum
    ihJoystickHatButtons = 0x00050001
    ihCocoaCHDir = 0x00051001
    ihCocoaMenuBar = 0x00051002

  ContextReleaseBehavior* {.size: int32.sizeof.} = enum
    crbAnyReleaseBehavior = 0
    crbReleaseBehaviorFlush = 0x00035001
    crbReleaseBehaviorNone = 0x00035002

  ClientApi* {.size: int32.sizeof.} = enum
    oaNoApi = 0
    oaOpenglApi = 0x00030001
    oaOpenglEsApi = 0x00030002

  ContextCreationApi* {.size: int32.sizeof.} = enum
    ccaNativeContextApi = 0x00036001
    ccaEglContextApi = 0x00036002
    ccaOSMesaContextApi = 0x00036003

  ContextRobustness* {.size: int32.sizeof.} = enum
    crNoRobustness = 0
    crNoResetNotification = 0x00031001
    crLoseContextOnReset = 0x00031002

  OpenglProfile* {.size: int32.sizeof.} = enum
    opAnyProfile = 0
    opCoreProfile = 0x00032001
    opCompatProfile = 0x00032002

  MonitorConnection* {.size: int32.sizeof.} = enum
    mcConnected = 0x00040001
    mcDisconnected = 0x00040002

converter toBool*(m: MonitorConnection): bool =
  case m
  of mcConnected:
    true
  of mcDisconnected:
    false

type
  CursorMode* {.size: int32.sizeof.} = enum
    cmNormal = 0x00034001
    cmHidden = 0x00034002
    cmDisabled = 0x00034003

const
  CursorModeConst* = 0x00033001'i32 # XXX
  StickyKeys* = 0x00033002'i32
  StickyMouseButtons* = 0x00033003'i32
  LockKeyMods* = 0x00033004'i32
  RawMouseMotion* = 0x00033005'i32
  DontCare* = - 1

type
  CursorShape* {.size: int32.sizeof.} = enum
    csArrow = 0x00036001
    csIBeam = 0x00036002
    csCrosshair = 0x00036003
    csHand = 0x00036004
    csHorizResize = 0x00036005
    csVertResize = 0x00036006

type
  WindowHandle* = ptr object
  Monitor* = ptr object
  Cursor* = ptr object
  VideoModeObj* {.bycopy.} = object
    width*: int32
    height*: int32
    redBits*: int32
    greenBits*: int32
    blueBits*: int32
    refreshRate*: int32
  VideoMode* = ptr VideoModeObj
  GammaRamp* {.bycopy.} = ptr object
    red*: ptr uint16
    green*: ptr uint16
    blue*: ptr uint16
    size*: cuint
  IconImageObj* {.bycopy.} = object
    width*: int32
    height*: int32
    pixels*: ptr uint8
  IconImage* = ptr IconImageObj

type
  GLFWGlProc* = proc () {.cdecl.}
  GLFWVkProc* = proc () {.cdecl.}
  GLFWErrorFun* = proc (a2: int32; a3: cstring)
  GLFWWindowPosFun* = proc (a2: WindowHandle; a3: int32; a4: int32)
  GLFWWindowSizeFun* = proc (a2: WindowHandle; a3: int32; a4: int32)
  GLFWWindowCloseFun* = proc (a2: WindowHandle) 
  GLFWWindowRefreshFun* = proc (a2: WindowHandle)
  GLFWWindowFocusFun* = proc (a2: WindowHandle; a3: bool)
  GLFWWindowMaximizeFun* = proc(a2: WindowHandle, a3: bool)
  GLFWWindowIconifyFun* = proc (a2: WindowHandle; a3: int32)
  GLFWFramebuffersizeFun* = proc (a2: WindowHandle; a3: int32; a4: int32)
  GLFWWindowContentScaleFun* = proc(a2: WindowHandle, a3, a4: float)
  GLFWMouseButtonFun* = proc (a2: WindowHandle; a3: int32; a4: int32; a5: int32)
  GLFWCursorPosFun* = proc (a2: WindowHandle; a3: cdouble; a4: cdouble)
  GLFWCursorEnterFun* = proc (a2: WindowHandle; a3: bool)
  GLFWScrollFun* = proc (a2: WindowHandle; a3: cdouble; a4: cdouble)
  GLFWKeyFun* = proc (a2: WindowHandle; a3: int32; a4: int32; a5: int32; a6: int32)
  GLFWCharFun* = proc (a2: WindowHandle; a3: cuint)
  GLFWCharmodsFun* = proc (a2: WindowHandle; a3: cuint; a4: int32)
  GLFWDropFun* = proc (a2: WindowHandle; a3: int32; a4: cstringArray)
  GLFWMonitorFun* = proc (a2: Monitor; a3: int32)
  GLFWJoystickFun* = proc (a2: int32; a3: int32)

proc modsBitsetToSet*(bitfield: int32): set[ModifierKey] =
  let mods = [ModifierKey.Shift, ModifierKey.Ctrl, ModifierKey.Alt,
              ModifierKey.Super, ModifierKey.CapsLock,
              ModifierKey.NumLock]
  for m in mods:
    let bit = (bitfield.int and m.int)
    if bit != 0:
      result.incl(bit.ModifierKey)

import macros
from strutils import toUpperAscii

proc renameProcs(n: NimNode) {.compileTime.} =
  template pragmas(n: string) = {.glfwImport, cdecl, importc: n.}
  for s in n:
    case s.kind
    of nnkProcDef:
      let oldName = $s.name
      let newName = "glfw" & (oldName[0]).toUpperAscii & oldName[1..^1]
      s.pragma = getAst(pragmas(newName))
    else:
      renameProcs(s)

macro generateProcs() =
  template getProcs {.dirty.} =
    proc init*(): bool
    proc terminate*()
    proc initHint*(hint, value: int32)
    proc getVersion*(major: ptr int32; minor: ptr int32; rev: ptr int32)
    proc getVersionString*(): cstring
    proc getError*(description: cstringArray): int32
    proc setErrorCallback*(cbfun: GLFWErrorFun): GLFWErrorFun
    proc getMonitors*(count: ptr int32): Monitor
    proc getPrimaryMonitor*(): Monitor
    proc getMonitorPos*(monitor: Monitor; xpos: ptr int32; ypos: ptr int32)
    proc getMonitorWorkarea*(monitor: Monitor, xpos, ypos, width, height: ptr int32)
    proc getMonitorPhysicalSize*(monitor: Monitor; widthMM: ptr int32;
      heightMM: ptr int32)
    proc getMonitorContentScale*()
    proc getMonitorName*(monitor: Monitor): cstring
    proc setMonitorUserPointer*(monitor: Monitor, pointerr: pointer)
    proc getMonitorUserPointer*(monitor: Monitor): pointer
    proc setMonitorCallback*(cbfun: GLFWMonitorFun): GLFWMonitorFun
    proc getVideoModes*(monitor: Monitor; count: ptr int32): VideoMode
    proc getVideoMode*(monitor: Monitor): VideoMode
    proc setGamma*(monitor: Monitor; gamma: cfloat)
    proc getGammaRamp*(monitor: Monitor): Gammaramp
    proc setGammaRamp*(monitor: Monitor; ramp: Gammaramp)
    proc defaultWindowHints*()
    proc windowHint*(hint: int32; value: int32)
    proc windowHintString*(hint: int32, value: cstring)
    proc createWindow*(width: int32; height: int32; title: cstring;
      monitor: Monitor; share: WindowHandle): WindowHandle
    proc destroyWindow*(window: WindowHandle)
    proc windowShouldClose*(window: WindowHandle): int32
    proc setWindowShouldClose*(window: WindowHandle; value: int32)
    proc setWindowTitle*(window: WindowHandle; title: cstring)
    proc setWindowIcon*(window: WindowHandle; count: int32; images: IconImage)
    proc getWindowPos*(window: WindowHandle; xpos: ptr int32; ypos: ptr int32)
    proc setWindowPos*(window: WindowHandle; xpos: int32; ypos: int32)
    proc getWindowSize*(window: WindowHandle; width: ptr int32; height: ptr int32)
    proc setWindowSizeLimits*(window: WindowHandle; minwidth: int32; minheight: int32;
      maxwidth: int32; maxheight: int32)
    proc setWindowAspectRatio*(window: WindowHandle; numer: int32; denom: int32)
    proc setWindowSize*(window: WindowHandle; width: int32; height: int32)
    proc getFramebufferSize*(window: WindowHandle; width: ptr int32; height: ptr int32)
    proc getWindowFrameSize*(window: WindowHandle; left: ptr int32; top: ptr int32;
      right: ptr int32; bottom: ptr int32)
    proc getWindowContentScale*(window: WindowHandle, xscale, yscale: ptr float)
    proc getWindowOpacity*(window: WindowHandle): float
    proc setWindowOpacity*(window: WindowHandle, opacity: float)
    proc iconifyWindow*(window: WindowHandle)
    proc restoreWindow*(window: WindowHandle)
    proc maximizeWindow*(window: WindowHandle)
    proc showWindow*(window: WindowHandle)
    proc hideWindow*(window: WindowHandle)
    proc focusWindow*(window: WindowHandle)
    proc requestWindowAttention*(window: WindowHandle)
    proc getWindowMonitor*(window: WindowHandle): Monitor
    proc setWindowMonitor*(window: WindowHandle; monitor: Monitor;
      xpos: int32; ypos: int32; width: int32; height: int32;
      refreshRate: int32)
    proc getWindowAttrib*(window: WindowHandle; attrib: int32): int32
    proc setWindowAttrib*(window: WindowHandle, attrib, value: int32)
    proc setWindowUserPointer*(window: WindowHandle; pointer: pointer)
    proc getWindowUserPointer*(window: WindowHandle): pointer
    proc setWindowPosCallback*(window: WindowHandle; cbfun: GLFWWindowPosFun): GLFWWindowPosFun
    proc setWindowSizeCallback*(window: WindowHandle; cbfun: GLFWWindowSizeFun): GLFWWindowSizeFun
    proc setWindowCloseCallback*(window: WindowHandle; cbfun: GLFWWindowCloseFun): GLFWWindowCloseFun
    proc setWindowRefreshCallback*(window: WindowHandle;
      cbfun: GLFWWindowRefreshFun): GLFWWindowRefreshFun
    proc setWindowFocusCallback*(window: WindowHandle; cbfun: GLFWWindowFocusFun): GLFWWindowFocusFun
    proc setWindowMaximizeCallback*(window: WindowHandle;
      cbfun: GLFWWindowMaximizeFun): GLFWWindowMaximizeFun
    proc setWindowIconifyCallback*(window: WindowHandle;
      cbfun: GLFWWindowIconifyFun): GLFWWindowIconifyFun
    proc setFramebufferSizeCallback*(window: WindowHandle;
      cbfun: GLFWFramebuffersizeFun): GLFWFramebuffersizeFun
    proc setWindowContentScaleCallback*(window: WindowHandle, cbfun: GLFWWindowContentScaleFun): GLFWWindowContentScaleFun
    proc pollEvents*()
    proc waitEvents*()
    proc waitEventsTimeout*(timeout: cdouble)
    proc postEmptyEvent*()
    proc getInputMode*(window: WindowHandle; mode: int32): int32
    proc setInputMode*(window: WindowHandle; mode: int32; value: int32)
    proc rawMouseMotionSupported*(): int32
    proc getKeyName*(key: int32; scancode: int32): cstring
    proc getKeyScancode*(key: int32): int32
    proc getKey*(window: WindowHandle; key: int32): int32
    proc getMouseButton*(window: WindowHandle; button: int32): int32
    proc getCursorPos*(window: WindowHandle; xpos: ptr cdouble; ypos: ptr cdouble)
    proc setCursorPos*(window: WindowHandle; xpos: cdouble; ypos: cdouble)
    proc createCursor*(image: IconImage; xhot: int32; yhot: int32): Cursor
    proc createStandardCursor*(shape: CursorShape): Cursor
    proc destroyCursor*(cursor: Cursor)
    proc setCursor*(window: WindowHandle; cursor: Cursor)
    proc setKeyCallback*(window: WindowHandle; cbfun: GLFWKeyFun): GLFWKeyFun
    proc setCharCallback*(window: WindowHandle; cbfun: GLFWCharFun): GLFWCharFun
    proc setCharModsCallback*(window: WindowHandle; cbfun: GLFWCharmodsfun): GLFWCharmodsfun
    proc setMouseButtonCallback*(window: WindowHandle; cbfun: GLFWMouseButtonFun): GLFWMouseButtonFun
    proc setCursorPosCallback*(window: WindowHandle; cbfun: GLFWCursorPosFun): GLFWCursorPosFun
    proc setCursorEnterCallback*(window: WindowHandle; cbfun: GLFWCursorEnterFun): GLFWCursorEnterFun
    proc setScrollCallback*(window: WindowHandle; cbfun: GLFWScrollFun): GLFWScrollFun
    proc setDropCallback*(window: WindowHandle; cbfun: GLFWDropFun): GLFWDropFun
    proc joystickPresent*(joy: int32): int32
    proc getJoystickAxes*(joy: int32; count: ptr int32): ptr cfloat
    proc getJoystickButtons*(joy: int32; count: ptr int32): ptr uint8
    proc getJoystickHats*(jid: int32, count: ptr int32): ptr uint8
    proc getJoystickName*(joy: int32): cstring
    proc getJoystickGUID*(jid: int32): cstring
    proc setJoystickUserPointer*(jid: int, pointerr: pointer)
    proc getJoystickUserPointer*(jid: int32): pointer
    proc joystickIsGamepad*(jid: int32): int32
    proc setJoystickCallback*(cbfun: GLFWJoystickFun): GLFWJoystickfun
    proc updateGamepadMappings*(str: cstring): int32
    proc getGamepadName*(jid: int32): cstring
    proc getGamepadState*(jid: int32, state: ptr GamepadState): int32
    proc setClipboardString*(window: WindowHandle; string: cstring)
    proc getClipboardString*(window: WindowHandle): cstring
    proc getTime*(): cdouble
    proc setTime*(time: cdouble)
    proc getTimerValue*(): uint64
    proc getTimerFrequency*(): uint64
    proc makeContextCurrent*(window: WindowHandle)
    proc getCurrentContext*(): WindowHandle
    proc swapBuffers*(window: WindowHandle)
    proc swapInterval*(interval: int32)
    proc extensionSupported*(extension: cstring): int32
    proc getProcAddress*(procname: cstring): GLFWGlProc
    proc vulkanSupported*(): int32
    proc getRequiredInstanceExtensions*(count: ptr uint32): cstringArray
    when defined(VK_VERSION_1_0):
      proc getInstanceProcAddress*(instance: VkInstance; procname: cstring): GLFWVkProc
      proc getPhysicalDevicePresentationSupport*(instance: VkInstance;
        device: VkPhysicalDevice; queuefamily: uint32): int32
      proc createWindowSurface*(instance: VkInstance; window: Window;
        allocator: ptr VkAllocationCallbacks;
        surface: ptr VkSurfaceKHR): VkResult

  result = getAst(getProcs())
  renameProcs(result)

generateProcs()