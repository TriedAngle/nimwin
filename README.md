<div align="center">
  <h1> NimWin </h1>
  <p><b>Platform Agnostic Windowing Library</b> for Nim</p>
</div>

## Goal
Event based windowing library similar to Rust's winit library

Currently only GLFW is supported and web is planned.
Using native libraries like XLib and WinAPI are considered but not planned yet as GLFW implements almost everything needed. Once the abstraction over GLFW and Web is done, native libraries can be reconsidered
 
## Todo
- example with OpenGL
- vulkan integration and vulkan Example

## current missing features from glfw
- web / browser support -> fix: abstract over glfw and web
- hovering files over the window, currently only dropping is supported
