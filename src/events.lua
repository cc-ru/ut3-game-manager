local engine = require("aevent")()

local events = {}

events.Init = engine:event("init")
events.SendMessage = engine:event("send-message")

events.DebugMessage = engine:event("debug-message")

engine:stdEvent("debug_message", events.DebugMessage)

events.engine = engine

events.priority = {
  top = 0,
  high = 10,
  normal = 20,
  low = 30,
  bottom = 40
}

return events
