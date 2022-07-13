import options, glfw, eventloop, tables, common, callbacks

type
  WindowObj* = object
    windowId*: WindowId
    handle*: WindowHandle
    config*: WindowConfig
    shared*: SharedState

  Window* = ref WindowObj

  MonitorHandle = glfw.Monitor
  Monitor* = object
    handle*: MonitorHandle
  
  WindowConfig* = object
    size*: tuple[w, h: int32]
    title*: string
    fullscreenMonitor: Option[Monitor]
    share*: Option[Window]
    resizable*, visible*, decorated*, focused*, autoIconify*, floating*, maximized*,
      centerCursor*, transparentFramebuffer*, focusOnShow*, scaleToMonitor*, mousePassthrough*,
      stereo*, srgbCapable*, doubleBuffer*: bool
    samples*, refreshRate*: Option[int32]
    bits*: tuple[r, g, b, a, depth, stencil: Option[int32]]

  WindowBuilder* = object
    config*: WindowConfig

proc id*(w: Window): WindowId =
  w.windowId

proc builder*(_: typedesc[Window]): WindowBuilder =
  result = WindowBuilder()

proc withConfig*(builder: WindowBuilder, config: WindowConfig): WindowBuilder =
  result = builder
  result.config = config

proc requestRedraw*(w: Window) =
  w.shared.redrawQueue.send(w.windowId)

proc init*(_: typedesc[Window], eventLoop: EventLoop, config: WindowConfig): Window = 
  new result

  result.shared = eventLoop.shared
  result.config = config
  template h(hint: Hint, val: untyped) =
    glfw.windowHint(hint.int32, val.int32)
  
  template h(hint: Hint, val: Option[untyped]) =
    if val.isSome():
      glfw.windowHint(hint.int32, val.get().int32)
    else:
      glfw.windowHint(hint.int32, -1)

  doAssert glfw.init()

  h(Hint.Resizable, config.resizable)
  h(Hint.Visible, config.visible)
  h(Hint.Decorated, config.decorated)
  h(Hint.Focused, config.focused)
  h(Hint.AutoIconify, config.autoIconify)
  h(Hint.Floating, config.floating)
  h(Hint.Maximized, config.maximized)
  h(Hint.CenterCursor, config.centerCursor)
  h(Hint.TransparentFramebuffer, config.transparentFramebuffer)
  h(Hint.FocusOnShow, config.focusOnShow)
  h(Hint.ScaleToMonitor, config.scaleToMonitor)
  h(Hint.MousePassthrough, config.mousePassthrough)
  h(Hint.Stereo, config.stereo)
  h(Hint.SrgbCapable, config.srgbCapable)
  h(Hint.Doublebuffer, config.doubleBuffer)
  h(Hint.RedBits, config.bits.r)
  h(Hint.GreenBits, config.bits.g)
  h(Hint.BlueBits, config.bits.b)
  h(Hint.AlphaBits, config.bits.a)
  h(Hint.DepthBits, config.bits.depth)
  h(Hint.StencilBits, config.bits.stencil)
  h(Hint.Samples, config.samples)
  h(Hint.RefreshRate, config.refreshRate)

  let shareHandle = if config.share.isSome(): config.share.get().handle else: nil
  let monitorHandle = if config.fullscreenMonitor.isSome(): config.fullscreenMonitor.get().handle else: nil

  result.handle = glfw.createWindow(config.size.w, config.size.h, cstring(config.title), monitorHandle, shareHandle)
  let id = WindowId(windowIdCounter)
  result.windowId = id
  result.shared.windowHandleToId[result.handle] = id
  glfwGlobals.windowHandleToId[result.handle] = id
  windowIdCounter += 1

  glfw.makeContextCurrent(result.handle)

  discard result.handle.setMouseButtonCallback(callbacks.glfwMouseButtonCallback)
  discard result.handle.setCursorPosCallback(callbacks.glfwMouseMovedCallback)
  discard result.handle.setCursorEnterCallback(callbacks.glfwCursorEnterCallback)
  discard result.handle.setScrollCallback(callbacks.glfwScrollCallback)
  discard result.handle.setKeyCallback(callbacks.glfwKeyCallback)
  discard result.handle.setCharModsCallback(callbacks.glfwCharCallback)
  discard result.handle.setDropCallback(callbacks.glfwFilesDropCallback)


proc build*(builder: WindowBuilder, eventLoop: EventLoop): Window =
  result = Window.init(eventLoop, builder.config)


proc newWindow*(eventLoop: EventLoop, config: WindowConfig): Window =
  result = Window.init(eventLoop, config)


proc DefaultWindowConfig*(
  size = (w: 1280.int32, h: 720.int32),
  title = "Nim-GPU",
  fullscreenMonitor = none Monitor,
  share = none Window,
  resizable = false,
  visible = true,
  decorated = true,
  focused = true,
  autoIconify = true,
  floating = false,
  maximized = false,
  centerCursor = false,
  transparentFramebuffer = false,
  focusOnShow = true,
  scaleToMonitor = false,
  mousePassthrough = false,
  stereo = false,
  srgbCapable = false,
  doubleBuffer = true,
  samples = some 0.int32,
  refreshRate = none int32,
  bits = (r: some 8.int32, g: some 8.int32, b: some 8.int32, a: some 8.int32, depth: some 24.int32, stencil: some 8.int32),
): WindowConfig =
  WindowConfig(
    size: size,
    title: title,
    fullscreenMonitor: fullscreenMonitor ,
    resizable: resizable,
    visible: visible,
    decorated: decorated,
    focused: focused,
    autoIconify: autoIconify,
    floating: floating,
    maximized: maximized,
    centerCursor: centerCursor,
    transparentFramebuffer: transparentFramebuffer,
    focusOnShow: focusOnShow,
    scaleToMonitor: scaleToMonitor,
    mousePassthrough: mousePassthrough,
    stereo: stereo,
    srgbCapable: srgbCapable,
    doubleBuffer: doubleBuffer,
    samples: samples,
    refreshRate: refreshRate,
    bits: bits,
  )