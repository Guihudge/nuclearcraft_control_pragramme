local component = require("component")
local gpu = component.gpu -- get primary gpu component
local w, h = gpu.getResolution()
gpu.fill(1, 1, w, h, " ") -- clears the screen
gpu.setForeground(0x000000)
gpu.setBackground(0xFF0000)
gpu.fill(1, 1, w/2, h/2, "X") -- fill top left quarter of screen
gpu.copy(1, 1, w/2, h/2, w/2, h/2)