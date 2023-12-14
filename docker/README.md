# Docker Tools

## Building

Currently each part of the tool-flow has its own builder (compiles to binary) and runner (copies binary from builder).
Additionally, the main image used is the `all` image, it copies the binaries from all runners together into one.

`make build` will build all tool-specific runners and then the `all` runner.

