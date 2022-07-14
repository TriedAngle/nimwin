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
    nextId*: int64
    windowHandleToId*: Table[WindowHandle, WindowId]
    eventQueue*: Channel[Event]
    redrawQueue*: Channel[WindowId]

  EventLoopWindowTarget* = ref object
    shared*: SharedState

  EventLoop* = ref object
    shared*: SharedState

  EventLoopCallback* = proc(event: Event, target: EventLoopWindowTarget, controlFlow: var ControlFlow)


proc newSharedState(): SharedState =
  new result
  result.nextId = 0
  result.eventQueue.open()
  result.redrawQueue.open()

proc cleanUp(shared: SharedState) =
  shared.eventQueue.close()
  shared.redrawQueue.close()


proc init*(_: typedesc[EventLoop]): EventLoop =
  new result

  result.shared = newSharedState()


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

proc setExit*(cf: var ControlFlow, code: int = 0) =
  cf.kind = ExitWithCode
  cf.code = code 

proc run*(el: EventLoop, callback: EventLoopCallback) =
  type IterResult = object
    exit: Option[int]

  proc singleIter(event: Event, target: EventLoopWindowTarget, cf: var ControlFlow): IterResult =
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


  var target = new EventLoopWindowTarget
  target.shared = el.shared

  var controlFlow = newControlFlow()
  var code: int
  var result: IterResult

  while true:
    while true:
      let (eventAvailable, event) = el.shared.eventQueue.tryRecv()
      if not eventAvailable: break
      result = singleIter(event, target, controlFlow)
      if result.exit.isSome(): break 

    if result.exit.isSome():
      code = result.exit.get() 
      break
      
    result = singleIter(Event(kind: MainEventsCleared), target, controlFlow)

    if result.exit.isSome():
      code = result.exit.get() 
      break
      

    while true:
      let (redrawAvailable, redrawEvent) = el.shared.redrawQueue.tryRecv()
      if not redrawAvailable: break
      result = singleIter(Event(kind: RedrawRequested, redrawWindowId: redrawEvent), target, controlFlow)
      for handle, id in target.shared.windowHandleToId.pairs():
        handle.swapBuffers()
      if result.exit.isSome(): break 

    if result.exit.isSome():
      code = result.exit.get()
      break

    let result = singleIter(Event(kind: RedrawEventsCleared), target, controlFlow)

    if result.exit.isSome():
      code = result.exit.get() 
      break
    
  
  callback(Event(kind: LoopDestroyed), nil, controlFlow)

  for handle, id in el.shared.windowHandleToId.pairs():
    glfw.destroyWindow(handle)

  el.shared.cleanUp()
  glfw.terminate()

  quit(code)