import events, eventloop, glfw, common, tables, unicode

proc glfwKeyCallback*(handle: WindowHandle, key, scancode, action, mods: int32) =
  let keyInput = KeyboardInput(
    key: key.Key,
    state: action.ElementState,
    mods: modsBitsetToSet(mods),
  )

  let id = glfwGlobals.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: KeyInput, key: keyInput))
  glfwGlobals.eventQueue.send(event)

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

  let id = glfwGlobals.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseInput, button: mouseInput))
  glfwGlobals.eventQueue.send(event)


proc glfwMouseMovedCallback*(handle: WindowHandle, xpos, ypos: float64) =
  let id = glfwGlobals.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseMoved, pos: PhysicalPosition[float64](x: xpos, y: ypos)))
  glfwGlobals.eventQueue.send(event)

proc glfwCursorEnterCallback*(handle: WindowHandle, entered: bool) = 
  let id = glfwGlobals.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseEnter, entered: entered))
  glfwGlobals.eventQueue.send(event)

proc glfwScrollCallback*(handle: WindowHandle, xoffset, yoffset: float64) = 
  let id = glfwGlobals.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: MouseScroll, scroll: (x: xoffset, y: yoffset)))
  glfwGlobals.eventQueue.send(event)


proc glfwFilesDropCallback*(handle: WindowHandle, len: int32, rawPaths: cstringArray) =
  let paths = rawPaths.cstringArrayToSeq(len)
  let id = glfwGlobals.windowHandleToId[handle]
  
  let event = newWindowEvent(id, WindowEvent(kind: FilesDrop, paths: paths))
  glfwGlobals.eventQueue.send(event)


proc glfwCharCallback*(handle: WindowHandle, codepoint: uint32, mods: int32) =

  let charInput = RuneInput(
    rune: codepoint.Rune,
    mods: modsBitsetToSet(mods)
  )

  let id = glfwGlobals.windowHandleToId[handle]
  let event = newWindowEvent(id, WindowEvent(kind: CharInput, rune: charInput))
  glfwGlobals.eventQueue.send(event)