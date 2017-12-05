local module = require("ut3-gm.module")
module.clearCache()

local events = module.load("events")

local evtEngine = events.engine
evtEngine:push(events.Init())

evtEngine:__gc()
module.clearCache()
