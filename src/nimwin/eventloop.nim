import events, common, glfw, tables, times, options

type
  ControlFlowKind* {.pure.} = enum
    Poll
    Wait
    WaitUntil
    ExitWithCode

  ControlFlow* = object
    case kind: ControlFlowKind
    of Poll, Wait: discard
    of WaitUntil: time: Time
    of ExitWithCode: code: int

  SharedState* = ref object
    eventQueue*: Channel[Event]
    redrawQueue*: Channel[WindowId]
    windowHandleToId*: Table[WindowHandle, WindowId]

  EventLoopWindowTarget* = ref object

  EventLoop* = ref object
    shared*: SharedState

  EventLoopCallback* = proc(event: Event, target: EventLoopWindowTarget, controlFlow: var ControlFlow)

  GlfWCallBackGlobals* = ref object
    eventQueue*: Channel[Event]
    windowHandleToId*: Table[WindowHandle, WindowId]



var glfwGlobals* = GlfWCallBackGlobals()

proc newSharedState(): SharedState =
  new result

  result.eventQueue.open()
  result.redrawQueue.open()

proc init*(_: typedesc[EventLoop]): EventLoop =
  new result

  result.shared = newSharedState()

  glfwGlobals.eventQueue.open()


proc newEventLoop*(): EventLoop =
  EventLoop.init()


proc newControlFlow*(): ControlFlow =
  result.kind = Poll 

proc setPoll*(cf: var ControlFlow) =
  cf.kind = Poll 

proc setWait*(cf: var ControlFlow) =
  cf.kind = Wait

proc setWaitUntil*(cf: var ControlFlow, time: Time) =
  cf.kind = WaitUntil
  cf.time = time

proc setExit*(cf: var ControlFlow, code: int = 1) =
  cf.kind = ExitWithCode
  cf.code = code 

proc run*(el: EventLoop, callback: EventLoopCallback) =
  type IterResult = object
    exit: Option[int]
  proc singleIter(event: Event, cf: var ControlFlow): IterResult =
    case cf.kind:
    of ExitWithCode:
      result.exit = some cf.code
    of Poll:
      glfw.pollEvents()
    of Wait:
      glfw.waitEvents()
    of WaitUntil:
       quit("not implemented", 0)

    callback(event, nil, cf)


  var controlFlow = newControlFlow()
  var code: int
  var result: IterResult

  while true:
    while true:
      var (eventAvailable, event) = glfwGlobals.eventQueue.tryRecv()
      if not eventAvailable:
        (eventAvailable, event) = el.shared.eventQueue.tryRecv()
      if not eventAvailable: break
      result = singleIter(event, controlFlow)
      if result.exit.isSome(): break 

    if result.exit.isSome():
      code = result.exit.get() 
      break
      
    el.shared.eventQueue.send(Event(kind: MainEventsCleared))

    while true:
      let (redrawAvailable, redrawEvent) = el.shared.redrawQueue.tryRecv()
      if not redrawAvailable: break
      result = singleIter(Event(kind: RedrawRequested, redrawWindowId: redrawEvent), controlFlow)
      if result.exit.isSome(): break 

    if result.exit.isSome():
      code = result.exit.get() 
      break

    el.shared.eventQueue.send(Event(kind: RedrawEventsCleared))
    
  
  callback(Event(kind: LoopDestroyed), nil, controlFlow)

  for handle, id in el.shared.windowHandleToId.pairs():
    glfw.destroyWindow(handle)

  glfw.terminate()