import asyncdispatch

proc runInterval*(cb: proc, interval: int): proc() =
  var stop_run = false

  proc clearInterval() =
    stop_run = true

  proc runIntervalLoop() {.async.} =
    while not(stop_run):
      await sleepAsync(interval)
      cb()

  asyncCheck runIntervalLoop()

  return clearInterval