import nimwin

proc main() =
  var eventLoop = EventLoop.init()

  var w = Window.builder()
    .withConfig(DefaultWindowConfig(transparentFramebuffer = true))
    .build(eventLoop)

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
        echo input
      else: discard

    of MainEventsCleared:
      w.requestRedraw()
    
    of RedrawRequested:
      # Render code here
      discard
    of LoopDestroyed:
      echo "byebye!"
    else: discard
  )

main()