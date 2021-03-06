# To Do

## UI
  - [x] Show progress (based on atomic for CPU and on queue for GPU) (use stderr)
  - [x] Time taken

## Input
  - [x] Get input from stdin
  - [x] Get input from file(s)
  - [ ] *Accept multiple lengths and prefixes*

## OpenCL
  - [x] **GPU**
  - [x] Optimize SHA256 (make assumptions)
  - [x] ~~Share GLSL code between algorithms (structs, prepare, search)~~

## Design
  - [x] Make options/args self-contained
  - [ ] **Now that the algorithm is typed, go over the code and reduce the runtime dispatching**
  - [ ] print::io_* is printing colored and out of place (no section and for writes, it comes before Summary on -vv)
