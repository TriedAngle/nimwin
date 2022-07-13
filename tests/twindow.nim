import unicode, unittest
import nimdow/[window, eventloop, events, common]

test "InputDefaults":
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
        if w.id() == windowId and input.key == Key.Escape:
          controlFlow.setExit(1)
        echo input
      
      of CharInput:
        echo event.rune

      of MouseInput:
        let input = event.button
        echo input
      
      of MouseMoved:
        let pos = event.pos
        echo pos

      of MouseEnter:
        echo event.entered

      of MouseScroll:
        echo event.scroll

      of FilesDrop:
        echo event.paths
    
    else: discard
  )
