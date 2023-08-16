-- bleached-test.
-- @eigen
--
--              O  O  O
--
--          O  O  O  O
--
--


-- ------------------------------------------------------------------------
-- deps

local UI = require "ui"

bleached = include("lib/bleached")


-- ------------------------------------------------------------------------
-- consts

local SCREEN_W = 128
local SCREEN_H = 64

local nb_rows = 2


-- ------------------------------------------------------------------------
-- state

local initialized = false
local dials = {}


-- ------------------------------------------------------------------------
-- main

function bleached_control_callback(midi_msg)
  if not initialized then
    for i=1,bleached.nb_pots() do
      local nb_row_pots = 4
      local row_i = i
      if i > 4 then row_i = i - 4 end
      local x_ofsfet = (i<=4) and -(SCREEN_W/5)/2 or 2 * (SCREEN_W/5)/2
      local x = row_i * SCREEN_W/(nb_row_pots+1) + x_ofsfet
      local row_h = SCREEN_H/(nb_rows+1)
      local y = (i>4) and row_h or row_h*2
      dials[i] = UI.Dial.new(x, y,
                             20, -- dial width
                             0, -- start v
                             0, 127, -- min / max
                             nil, -- rounding (increments)
                             0, -- fill start v
                             {}, -- markers
                             nil, -- unit
                             "" -- title
      )
    end

    initialized = true
  end

  local pot = bleached.cc_to_pot(midi_msg.cc)

  dials[pot]:set_value(midi_msg.val)

  redraw()
end


midi.add = function(dev)
  if initialized then
    return
  end

  if dev.name == "bleached" then
    print("new bleached got plugged in")
    bleached.init(bleached_control_callback)
    redraw()
  end
end

midi.remove = function(dev)
  if not initialized then
    return
  end

  if dev ~= nil and dev.name == "bleached" then
    print("bleached got removed")
    initialized = false
    redraw()
  end

  if dev == nil then
    for _,dev in pairs(midi.devices) do
      if dev.name~=nil and dev.name == "bleached" then
        print("bleached got removed")
        initialized = false
        redraw()
        break
      end
    end
  end
end

function init()
  screen.aa(1)
  -- screen.line_width(1)

  bleached.init(bleached_control_callback)
end

function redraw()
  screen.clear()

  if initialized then
    for _, d in ipairs(dials) do
      d:redraw()
    end
  else
    screen.move(SCREEN_W/2, SCREEN_H/2)
    screen.text("not connected")
  end
  screen.update()
end
