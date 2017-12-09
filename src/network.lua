local com = require("component")

local debug = com.debug

local module = require("ut3-gm.module")

local config = module.load("config")
local events = module.load("events")

local engine = events.engine

engine:subscribe("debug-message", events.priority.high, function(hdr, evt)
  local data = evt:get()
  -- process messages here
end)

engine:subscribe("send-message", events.priority.low, function(hdr, evt)
  if evt.to == "drone" then
    -- send the message to the drone
  elseif evt.to == "checkpoint" then
    -- send the message to the checkpoint
  else
    local address
    if evt.to == "control" then
      address = config.addresses.control[evt.team]
    elseif evt.to == "infopanel" then
      address = config.addresses.infopanels[evt.infopanel]
    elseif evt.to == "glasses" then
      address = config.addresses.glasses
    elseif evt.to == "lamp" then
      address = config.addresses.lamp
    elseif evt.to == "radio" then
      address = config.addresses.radio
    end
    debug.sendToDebugCard(address, "ut3", "gm", table.unpack(evt:get()))
  end
end)
