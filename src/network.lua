local com = require("component")

local debug = com.debug
local modem = com.modem

local module = require("ut3-gm.module")

local config = module.load("config")
local events = module.load("events")
local store = module.load("store")

local engine = events.engine

modem.setStrength(400)

engine:subscribe("debug-message", events.priority.high, function(hdr, evt)
  local data = evt:get()
  -- process messages here
end)

engine:subscribe("send-message", events.priority.low, function(hdr, evt)
  if evt.to == "drone" then
    local addresses
    if evt.addresses then
      addresses = evt.addresses
    else
      addresses = {}
      for k, v in pairs(store.drones) do
        if (not v.team or v.team == evt.team) and
            (not evt.aliveOnly or v.alive) then
          table.insert(addresses, v.address)
        end
      end
    end
    for k, v in pairs(addresses) do
      modem.send(v, config.network.port, "gm", table.unpack(evt:get()))
    end
  elseif evt.to == "checkpoint" then
    -- send the message to the checkpoint
  elseif not evt.to then
    -- broadcast
    modem.broadcast(config.network.port, "gm", table.unpack(evt:get()))
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
    debug.sendToDebugCard(address, "gm", table.unpack(evt:get()))
  end
end)
