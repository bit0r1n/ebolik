import asyncdispatch

proc runInterval*(cb: proc(): Future[void], interval: int): proc() =
  var stop_run = false

  proc clearInterval() =
    stop_run = true

  proc runIntervalLoop() {.async.} =
    while not(stop_run):
      await sleepAsync(interval)
      await cb()

  asyncCheck runIntervalLoop()

  return clearInterval