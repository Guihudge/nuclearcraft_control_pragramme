local component = require("component")
local charts = require("charts")
local term = require("term")
local gpu = component.gpu
local reactor = component.nc_fission_reactor

local w, h = gpu.getResolution()

local RF = 0
local RF_max = reactor.getMaxEnergyStored()
local etat = 0


local barRF = charts.Container {
    x = 4,
    y = 2,
    width = 6,
    height = h-3,
    payload = charts.ProgressBar{
        direction = charts.sides.TOP,
        value = 0,
        max = RF_max
    }
}

function checkON( RF )
    if RF < 1000 then
        gpu.set(15,7, "Générateur ON")
        etat = 1 
        reactor.activate()
    elseif RF > RF_max-1000 then
        gpu.set(15,7, "Générateur OFF")
        etat = 0
        reactor.deactivate()
    elseif etat == 1 then
        gpu.set(15,7, "Générateur ON")
    elseif etat == 0 then
        gpu.set(15,7, "Générateur OFF")
    end
end


--print("rien")

term.clear()

while true do
    RF= reactor.getEnergyStored()
    checkON(RF)
    --if RF == 10 then
    --    term.clear()
    --elseif RF == 100 then
    --    term.clear()
    --end
    barRF.payload.value = RF
    barRF:draw()
    
    gpu.set(15,5, "Batterie: "..RF.." RF")

    os.sleep(0.5)
end


term.clear()