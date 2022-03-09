--import des libs
local component = require("component");
local gpu = component.gpu
local keyboard = require("keyboard")
local term = require("term")
local charts = require("charts")
local API = require("buttonAPI")
--local NCreactor = component.nc_fission_reactor

--varaibale global (Pas Bien!!)
local w, h = gpu.getResolution()
local basex = 3
local basey = 3
local maxBattLevel = 0.90
local minBattLevel = 0.05

--Mise en place des bouton(TODO)
function API.fillTable()
  
end

--Afficage du niveau de batterie
local batteryBar = charts.Container {
    x = w-8,
    y = basey+1,
    width = 7,
    height = h-6,
    payload = charts.ProgressBar {
      direction = charts.sides.TOP,
      value = 0,
      colorFunc = function(_, perc)
        if perc >= .9 then
          return 0x20afff
        elseif perc >= .75 then
          return 0x20ff20
        elseif perc >= .5 then
          return 0xafff20
        elseif perc >= .25 then
          return 0xffff20
        elseif perc >= .1 then
          return 0xffaf20
        else
          return 0xff2020
        end
      end
    }
  }

--afficahge de niveau de chaleur
local heatBar = charts.Container {
  x = w-17,
  y = basey+1,
  width = 7,
  height = h-6,
  payload = charts.ProgressBar {
    direction = charts.sides.TOP,
    value = 0,
    colorFunc = function(_, perc)
      if perc >= .9 then
        return 0xff2020
      elseif perc >= .75 then
        return 0xffaf20
      elseif perc >= .5 then
        return 0xffff20
      elseif perc >= .25 then
        return 0xafff20
      elseif perc >= .1 then
        return 0x20ff20
      else
        return 0x20afff
      end
    end
  }
}

--struct avec les valeur du reacteur
local reactor = {
    isLowOverheat = false,
    isHighOverheat = false,

    isActivate = true,

    BatteryCapacity = 4096000.0,
    Batterystate = 3400000.0,

    HeatCapacity = 500000,
    HeatState = 100000,

    automatic = false,
    autowait = false
}

function initStruct()
    reactor.isActivate = NCreactor.isReactorOn()
    ractor.HeatCapacity = NCreactor.getMaxHeat()
    reactor.BatteryCapacity = NCreactor.getMaxEnergyStored()
end

function updateVal()
  reactor.isActivate = NCreactor.isReactorOn()
  reactor.Batterystate = NCreactor.getEnergyStored()
  reactor.HeatState = NCreactor.getHeat()

    --TESTING ONLY
    --if reactor.isActivate then
    --  reactor.Batterystate = reactor.Batterystate + math.random(1,10)*500--random
    --  reactor.HeatState = reactor.HeatState + math.random(1,10)*100 --random
    --else
    --  reactor.Batterystate = reactor.Batterystate - math.random(1,10)*100 --random
    --  reactor.HeatState = reactor.HeatState - math.random(1,10)*500--random
    --end
end

function drawCadre()
    gpu.fill(1,1,w,h,"█")
    gpu.fill(2,2,w-2,h-2," ")
end

function drawInterface()
    --affichage du Overheat
    if reactor.isHighOverheat then
      gpu.setBackground(0xFF0000)
    else
      gpu.setBackground(0x4B4B4B)
    end

    --afficahe de base
    drawCadre()
    gpu.set(((w-22)/2),1,"Fission Reactor Status")
    gpu.set(basex,basey, "State: "..(reactor.isActivate and "ON " or "OFF"))
    gpu.set(basex,basey+1, "Battery: "..(reactor.Batterystate/1000).."/"..(reactor.BatteryCapacity/1000).." kRF (".. (reactor.Batterystate*100)/reactor.BatteryCapacity.."%)")
    gpu.set(basex,basey+2, "Heat: "..(reactor.HeatState/1000).."/"..(reactor.HeatCapacity/1000).." kH (".. (reactor.HeatState*100)/reactor.HeatCapacity.."%)")
    
    --cas du overheat
    if reactor.isHighOverheat then
      gpu.set(basex, basey+8, "ERROR: OVERHEAT DETECTED!!")
      gpu.set(basex, basey+9, " EMERGENCY MODE ENABLE!!")
    elseif reactor.isLowOverheat then
      gpu.set(basex, basey+8, "WARANING: HIGH TEMPERATURE!!")
    end

    gpu.set(w-8, basey, "Battery")
    batteryBar.payload.value = reactor.Batterystate/reactor.BatteryCapacity
    batteryBar:draw()

    gpu.set(w-16, basey, "Heat")
    heatBar.payload.value = reactor.HeatState/reactor.HeatCapacity
    heatBar:draw()

    if reactor.isHighOverheat then 
      gpu.set(basex,basey+4, "Mode: EMERGENCY")
    else
        gpu.set(basex,basey+4, "Mode: "..(reactor.automatic and "AUTO (WIP)" or "MANUAL"))
    end
end

function input()
  --gestions des inputs
  if keyboard.isKeyDown('a') then
      reactor.automatic = not reactor.automatic
  end
  if keyboard.isKeyDown('o') then
    reactor.isActivate = not reactor.isActivate
  end
  --Testing prupose!
  if keyboard.isKeyDown('h') then
    reactor.HeatState = reactor.HeatState+5000
  end
end

function checkContinue()
    return not keyboard.isKeyDown('q')
end

function checkOverheat()
  --Overheat activation
  if reactor.HeatState >= reactor.HeatCapacity*0.7 then
    reactor.isLowOverheat = true
  end
  if reactor.HeatState >= reactor.HeatCapacity*0.9 then
    reactor.isHighOverheat = true
  end
  
  --Overheat Desactivation
  if reactor.HeatState < reactor.HeatCapacity*0.7 and reactor.isHighOverheat then
    reactor.isHighOverheat = false
  end
  if reactor.HeatState < reactor.HeatCapacity*0.6 and reactor.isLowOverheat then
    reactor.isLowOverheat = false
  end
end

function switchON()
  --NCreactor.Activate()
  reactor.isActivate = true
end

function switchOFF()
  --NCreactor.deactivate()
  reactor.isActivate = false
end

function automatic()
  --Overheat case
  if reactor.HeatState >= reactor.HeatCapacity*0.7 and reactor.isActivate() then
    switchOFF()
  end

  --Battery
  if reactor.Batterystate > reactor.BatteryCapacity*maxBattLevel then
    switchOFF()
    reactor.autowait = true
  end

  if reactor.Batterystate < reactor.BatteryCapacity*minBattLevel then
    reactor.autowait = false
  end

  if reactor.Batterystate <= reactor.BatteryCapacity*maxBattLevel and not reactor.autowait then
     switchON()
  end

end

function main()
    term.clear()
    initStruct()


    local run = true

    while run do
        drawInterface()
        input()
        updateVal()
        if reactor.automatic then
          automatic()
        end
        checkOverheat()

        run = checkContinue()
        os.sleep(0.2)
    end

    term.clear()
end


main()