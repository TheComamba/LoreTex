local ftInM = 0.3048
local inInCm = 2.54
local MiInKM = 1.609
local lbInKg = 0.4536
local gallonInLiter = 3.785
local quartInLiter = gallonInLiter * 0.25
local ouncesInLiter = 0.02957
local MCubedInLiter = 1000
local fahrenheitFactor = 5 / 9
local fahrenheitOffset = -32

function PrintFtToM(valInFt)
    if valInFt == nil or type(valInFt) ~= "number" then
        LogError("Called with " .. DebugPrint(valInFt))
        return
    end
    local str = RoundedNumString(valInFt * ftInM, 1)
    str = str .. " m ("
    str = str .. RoundedNumString(valInFt, 0)
    str = str .. " ft)"
    tex.print(str)
end

function PrintFtToMSquared(valInFtSq)
    if valInFtSq == nil or type(valInFtSq) ~= "number" then
        LogError("Called with " .. DebugPrint(valInFtSq))
        return
    end
    local str = RoundedNumString(valInFtSq * ftInM * ftInM, 1)
    str = str .. " m$^2$ ("
    str = str .. RoundedNumString(valInFtSq, 0)
    str = str .. " ft$^2$)"
    tex.print(str)
end

function PrintFtCubedToLiter(valInFtCubed)
    if valInFtCubed == nil or type(valInFtCubed) ~= "number" then
        LogError("Called with " .. DebugPrint(valInFtCubed))
        return
    end
    local str = RoundedNumString(valInFtCubed * ftInM * ftInM * ftInM * MCubedInLiter, -1)
    str = str .. " l ("
    str = str .. RoundedNumString(valInFtCubed, 0)
    str = str .. " ft$^3$)"
    tex.print(str)
end

function PrintMToFt(valInM)
    if valInM == nil or type(valInM) ~= "number" then
        LogError("Called with " .. DebugPrint(valInM))
        return
    end
    local str = RoundedNumString(valInM, 1)
    str = str .. " m ("
    str = str .. RoundedNumString(valInM / ftInM, 0)
    str = str .. " ft)"
    tex.print(str)
end

function PrintInToCM(valInIn)
    if valInIn == nil or type(valInIn) ~= "number" then
        LogError("Called with " .. DebugPrint(valInIn))
        return
    end
    local str = RoundedNumString(valInIn * inInCm, 0)
    str = str .. " cm ("
    str = str .. RoundedNumString(valInIn, 1)
    str = str .. " inch)"
    tex.print(str)
end

function PrintMiToKm(valInMi)
    if valInMi == nil or type(valInMi) ~= "number" then
        LogError("Called with " .. DebugPrint(valInMi))
        return
    end
    local str = RoundedNumString(valInMi * MiInKM, 1)
    str = str .. " km ("
    str = str .. RoundedNumString(valInMi, 1)
    str = str .. " mi)"
    tex.print(str)
end

function PrintLbToKg(valInLb)
    if valInLb == nil or type(valInLb) ~= "number" then
        LogError("Called with " .. DebugPrint(valInLb))
        return
    end
    local str = RoundedNumString(valInLb * lbInKg, 1)
    str = str .. " kg ("
    str = str .. RoundedNumString(valInLb, 0)
    str = str .. " lb)"
    tex.print(str)
end

function PrintGallonToLiter(valInGallons)
    if valInGallons == nil or type(valInGallons) ~= "number" then
        LogError("Called with " .. DebugPrint(valInGallons))
        return
    end
    local str = RoundedNumString(valInGallons * gallonInLiter, 1)
    str = str .. " l ("
    str = str .. RoundedNumString(valInGallons, 1)
    str = str .. " gallons)"
    tex.print(str)
end

function PrintOunceToLiter(valInOunces)
    if valInOunces == nil or type(valInOunces) ~= "number" then
        LogError("Called with " .. DebugPrint(valInOunces))
        return
    end
    local str = RoundedNumString(valInOunces * ouncesInLiter, 1)
    str = str .. " l ("
    str = str .. RoundedNumString(valInOunces, 1)
    str = str .. " fl oz)"
    tex.print(str)
end

function PrintQuartToLiter(valInQuart)
    if valInQuart == nil or type(valInQuart) ~= "number" then
        LogError("Called with " .. DebugPrint(valInQuart))
        return
    end
    local str = RoundedNumString(valInQuart * quartInLiter, 1)
    str = str .. " l ("
    str = str .. RoundedNumString(valInQuart, 1)
    str = str .. " qt)"
    tex.print(str)
end

function PrintFahrenheitToCelsius(valInFahrenheit)
    if valInFahrenheit == nil or type(valInFahrenheit) ~= "number" then
        LogError("Called with " .. DebugPrint(valInFahrenheit))
        return
    end
    local str = RoundedNumString((valInFahrenheit + fahrenheitOffset) * fahrenheitFactor, 0)
    str = str .. " deg. C ("
    str = str .. RoundedNumString(valInFahrenheit, 0)
    str = str .. " deg. F)"
    tex.print(str)
end
