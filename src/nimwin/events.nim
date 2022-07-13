import common

type
  EventKind* {.pure.} = enum
    WinEvent
    DeviceEvent
    Suspended
    Resumed
    MainEventsCleared
    RedrawRequested
    RedrawEventsCleared
    LoopDestroyed

  WindowEventKind* {.pure.} = enum
    KeyInput
    CharInput
    MouseMoved
    MouseEnter
    MouseInput
    MouseScroll
    FilesDrop

  WindowEvent* = object
    case kind*: WindowEventKind
    of KeyInput:
      key*: KeyboardInput
    of CharInput:
      rune*: RuneInput
    of MouseMoved:
      pos*: PhysicalPosition[float64]
    of MouseEnter:
      entered*: bool
    of MouseInput:
      button*: MouseButtonInput
    of MouseScroll:
      scroll*: tuple[x, y: float64]
    of FilesDrop:
      paths*: seq[string]

  Event* = object
    case kind*: EventKind
    of EventKind.WinEvent:
      windowId*: WindowId
      windowEvent*: WindowEvent
    of RedrawRequested:
      redrawWindowId*: WindowId
    else: discard


proc newWindowEvent*(id: WindowId, event: WindowEvent): Event =
  result = Event(
    kind: EventKind.WinEvent,
    windowId: id,
    windowEvent: event
  )