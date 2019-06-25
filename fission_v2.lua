local component = require("component")
local charts = require("charts")
local term = require("term")
local event = require("event")
local keyboard = require("keyboard")
local gpu = component.gpu
local reactor = component.nc_fission_reactor

local w, h = gpu.getResolution()

local RF = 0
local RF_max = reactor.getMaxEnergyStored()
local heat = 0
local heat_max = reactor.getMaxHeatLevel()
local auto_mode = 0
local userinput = ""
local event_ = ""
local etatx = 15
local etaty = 7
local overheat = false 


local barRF = charts.Container {
    x = 4,
    y = 2,
    width = 6,
    height = h-3,
    payload = charts.ProgressBar {
        direction = charts.sides.TOP,
        value = 0,
        max = RF_max
    }
}

function auto()
    auto_mode = 1
    term.clear()
end

function disp_etat(RF)
    -- effacer sans clignotement l'affichage
    if overheat then
        gpu.setBackground(0x0000FF)
        gpu.set((w/2-4), (h/2), "OVERHEAT!")
    else
        if auto_mode == 0 then
            gpu.set(15,6, "Générateur " .. (reactor.isProcessing() and "allumé" or "arrêté") .. ", appuyer sur O pour " .. (reactor.isProcessing() and "l'arrêter" or "l'allumer"))
        end
        gpu.set(15,1, "Appuyer sur A pour passer en mode " .. (auto_mode == 1 and "manuel" or "automatique"))
        gpu.set(etatx, etaty, "Générateur "..(reactor.isProcessing() and "ON " or "OFF"))
        gpu.set(15,5, "Batterie: "..RF.." RF")
    end
    
    barRF.payload.value = RF
    barRF:draw()
end

function checkON( RF )
    if RF < 1000 then
        reactor.activate()
    elseif RF > RF_max-1000 then
        reactor.deactivate()
    end
end

function user_input (RF)
    if auto_mode == 1 then
        if keyboard.isKeyDown(30) == true then
            auto_mode = 0
            term.clear()
        end
        checkON(RF)

    elseif auto_mode == 0 then
        if keyboard.isKeyDown(24) then
           if reactor.isProcessing() then
                reactor.deactivate()
                term.clear()
            else
                reactor.activate()
                term.clear()
            end
        end

        if keyboard.isKeyDown(30) then
            auto_mode = 1
            term.clear()
        end
    end
end

function heat_error()
    heat = reactor.getHeatLevel()
    if heat > heat_max-5000 then
        reactor.deactivate()
        overheat = true
    end
end

term.clear()

while true do
    heat_error()
    RF = reactor.getEnergyStored()
    if not overheat then
        user_input(RF)
    end
    disp_etat(RF)
    heat_error()
    os.sleep(0.1)
end


term.clear()

--test