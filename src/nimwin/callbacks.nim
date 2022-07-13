import events, eventloop, glfw, common, tables, unicode

proc glfwWindowCloseCallback*(handle: WindowHandle) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: WindowCloseRequested))
  shared.eventQueue.send(event)

proc glfwWindowMoveCallback*(handle: WindowHandle, xpos, ypos: int32) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: WindowMoved, move: PhysicalPosition[int32](x: xpos, y: ypos)))
  shared.eventQueue.send(event)

proc glfwWindowResizeCallback*(handle: WindowHandle, width, height: int32) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: WindowResized, size: PhysicalSize[int32](width: width, height: height)))
  shared.eventQueue.send(event)

proc glfwWindowScaleCallback*(handle: WindowHandle, xScale, yScale: float) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: WindowScaleChange, scale: PhysicalSize[float](width: xScale, height: yScale)))
  shared.eventQueue.send(event)

proc glfwWindowMaximizeCallback*(handle: WindowHandle, max: bool) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: WindowMaximized, max: max))
  shared.eventQueue.send(event)

proc glfwWindowFocusCallback*(handle: WindowHandle, focus: bool) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: WindowFocused, focus: focus))
  shared.eventQueue.send(event)


proc glfwKeyCallback*(handle: WindowHandle, key, scancode, action, mods: int32) =
  let keyInput = KeyboardInput(
    key: key.Key,
    state: action.ElementState,
    mods: modsBitsetToSet(mods),
  )
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: KeyInput, key: keyInput))
  shared.eventQueue.send(event)

proc glfwMouseButtonCallback*(handle: WindowHandle, button, action, mods: int32) =
  let buttonKind = if button == 0: 
      MouseButtonKind.Left 
    elif button == 1: 
      MouseButtonKind.Right 
    elif button == 2:
      MouseButtonKind.Middle
    else: 
      MouseButtonKind.Other
  
  let mouseInput = MouseButtonInput(
    button: MouseButton(kind: buttonKind, raw: button),
    state: action.ElementState,
    mods: modsBitsetToSet(mods)
  )

  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseInput, button: mouseInput))
  shared.eventQueue.send(event)


proc glfwMouseMovedCallback*(handle: WindowHandle, xpos, ypos: float64) =
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseMoved, pos: PhysicalPosition[float64](x: xpos, y: ypos)))
  shared.eventQueue.send(event)

proc glfwCursorEnterCallback*(handle: WindowHandle, entered: bool) = 
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseEnter, entered: entered))
  shared.eventQueue.send(event)

proc glfwScrollCallback*(handle: WindowHandle, xoffset, yoffset: float64) = 
  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseScroll, scroll: (x: xoffset, y: yoffset)))
  shared.eventQueue.send(event)


proc glfwFilesDropCallback*(handle: WindowHandle, len: int32, rawPaths: cstringArray) =
  let paths = rawPaths.cstringArrayToSeq(len)

  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: FilesDrop, paths: paths))
  shared.eventQueue.send(event)


proc glfwCharCallback*(handle: WindowHandle, codepoint: uint32, mods: int32) =
  let charInput = RuneInput(
    rune: codepoint.Rune,
    mods: modsBitsetToSet(mods)
  )

  let shared = cast[ptr SharedState](handle.getWindowUserPointer())
  let id = shared.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: CharInput, rune: charInput))
  shared.eventQueue.send(event)