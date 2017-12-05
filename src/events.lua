local evtEngine = require("aevent")()

local events = {}

events.Init = evtEngine:event("init")

events.engine = evtEngine

events.priority = {
  top = 0,
  high = 10,
  normal = 20,
  low = 30,
  bottom = 40
}

return events
