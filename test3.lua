local component = require("component")
local gpu = component.gpu
local w, h = gpu.getResolution()

gpu.setBackground(0xFF0000)
gpu.fill(1, 1, 2, 4)
 
