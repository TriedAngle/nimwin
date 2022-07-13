import nimwin, unicode, times

proc main() =
  var eventLoop = EventLoop.init()

  var w = Window.builder()
    .withConfig(DefaultWindowConfig(transparentFramebuffer = true))
    .build(eventLoop)

  var start = now()

  eventLoop.run(proc(event: Event, target: EventLoopWindowTarget, controlFlow: var ControlFlow) =
    controlFlow.setPoll()
    
    case event.kind:
    of WinEvent:
      let windowId = event.windowId
      let event = event.windowEvent
      case event.kind:
      of KeyInput:
        let input = event.key
        if w.id() == windowId and input.key == KeyEscape:
          echo "exit!"
          controlFlow.setExit()
      else: discard

    of MainEventsCleared:
      w.requestRedraw()
      # echo "events done"

    of RedrawRequested:
      # Render code here
      discard
    of RedrawEventsCleared:
      # optional render cleanup here ?
      let now = now()
      echo start.between(now)
      start = now
      discard
    of LoopDestroyed:
      echo "byebye!"
    else: discard
  )

main()