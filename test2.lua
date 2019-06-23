local side = "left"
local userinput = ""
local event = ""

redstone.setOutput(side, false)

while true do
    term.clear()
    term.setCursorPos(1,1)
    print("pour allumer la lampe appuyer sur L")
    print("Pour quitter sur n'importe quel autre touche")

    event, userinput = os.pullEvent("char")
    userinput = string.upper( userinput )

    if userinput == "L" then
        redstone.setOutput(side, true)
    else 
        term.clear()
        break
    end

    term.clear()
    term.setCursorPos(1,1)
    print("pour enteindre la lampe appuyer sur L")
    print("Pour quitter sur n'importe quel autre touche")

    event, userinput = os.pullEvent("char")
    userinput = string.upper( userinput )

    if userinput == "L" then
        redstone.setOutput(side, true)
    else 
        term.clear()
        break
    end
end


