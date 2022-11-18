IsShowFuture = true

local currentYear = 0
IsCurrentYearSet = false
local currentDay = 0
IsCurrentDaySet = false
local daysPerYear = 1
IsDaysPerYearSet = false

YearFmt = {}
DayFmt = {}

function ResetDates()
    currentYear = 0
    IsCurrentYearSet = false
    currentDay = 0
    IsCurrentDaySet = false
    daysPerYear = 1
    IsDaysPerYearSet = false
    DayFmt = {}
    YearFmt = {}
end

TexApi.setCurrentYear = function(year)
    if year == nil or type(year) ~= "number" then
        LogError("Called with " .. DebugPrint(year))
        return
    end
    currentYear = year
    IsCurrentYearSet = true
end

TexApi.setCurrentDay = function(day)
    if day == nil or type(day) ~= "number" then
        LogError("Called with " .. DebugPrint(day))
        return
    end
    currentDay = day
    IsCurrentDaySet = true
end

TexApi.setDaysPerYear = function(days)
    if days == nil or type(days) ~= "number" then
        LogError("Called with " .. DebugPrint(days))
        return
    end
    daysPerYear = days
    IsDaysPerYearSet = true
end

function GetCurrentYear()
    if not IsCurrentYearSet then
        LogError("Current year not set!")
        return 0
    else
        return currentYear
    end
end

function GetCurrentDay()
    if not IsCurrentDaySet then
        LogError("Current day not set!")
        return 0
    else
        return currentDay
    end
end

function GetDaysPerYear()
    if not IsDaysPerYearSet then
        LogError("Days per year not set!")
        return 1
    else
        return daysPerYear
    end
end

local function addDayFmt(label)
    local calendar = GetMutableEntityFromAll(label)
    DayFmt[#DayFmt + 1] = calendar
end

TexApi.addDayFmt = addDayFmt

local function addYearFmt(label)
    local calendar = GetMutableEntityFromAll(label)
    YearFmt[#YearFmt + 1] = calendar
end

TexApi.addYearFmt = addYearFmt

local function setYearAbbreviation(entity, abbr)
    if IsEmpty(entity) then
        LogError("Called with empty entity and abbreviation:" .. DebugPrint(abbr))
        return
    end
    if IsEmpty(abbr) then
        LogError("Called with empty abbreviation for entity:" .. DebugPrint(entity))
        return
    end
    SetProtectedField(entity, "yearAbbreviation", abbr)
end

TexApi.setYearAbbreviation = function(abbr)
    setYearAbbreviation(CurrentEntity, abbr)
end

local function setYearOffset(entity, offset)
    if IsEmpty(entity) then
        LogError("Called with empty entity!")
        return
    end
    if IsEmpty(offset) or type(offset) ~= "number" then
        LogError("Called with invalid offset for entity:" .. DebugPrint(entity))
        return
    end
    SetProtectedField(entity, "yearOffset", offset)
end

TexApi.setYearOffset = function(offset)
    setYearOffset(CurrentEntity, offset)
end

local function addMonth(arg)
    if not IsArgOk("addMonth", arg, { "entity", "month", "firstDay" }) then
        return
    end
    AddToProtectedField(arg.entity, "monthsAndFirstDays", { arg.month, arg.firstDay })
end

TexApi.addMonth = function(arg)
    arg.entity = CurrentEntity
    addMonth(arg)
end

function RemoveYearOffset(year, fmt)
    local offset = GetProtectedField(fmt, "yearOffset")
    if offset == nil then
        return year
    else
        return year - offset
    end
end

function AddYearOffset(year, fmt)
    local offset = GetProtectedField(fmt, "yearOffset")
    if offset == nil then
        return year
    else
        return year + offset
    end
end

local function daysAgo(historyItem)
    local year = GetProtectedField(historyItem, "year")
    local day = GetProtectedField(historyItem, "day")
    if IsCurrentDaySet and day ~= nil then
        return GetCurrentDay() - day + (GetCurrentYear() - year) * GetDaysPerYear()
    else
        return (GetCurrentYear() - year) * GetDaysPerYear()
    end
end

local function yearsAgo(historyItem)
    if IsCurrentDaySet then
        return daysAgo(historyItem) / GetDaysPerYear()
    else
        return GetCurrentYear() - GetProtectedField(historyItem, "year")
    end
end

local function timeDiffString(historyItem)
    local year = GetProtectedField(historyItem, "year")
    local day = GetProtectedField(historyItem, "day")
    local timeDiffInYears = yearsAgo(historyItem)
    if math.abs(timeDiffInYears) < 1 and IsCurrentDaySet and day ~= nil then
        local timeDiffInDays = daysAgo(historyItem)
        if timeDiffInDays == 0 then
            return Tr("today")
        elseif timeDiffInDays == 1 then
            return Tr("yesterday")
        elseif timeDiffInDays == -1 then
            return Tr("tomorrow")
        elseif timeDiffInDays > 1 then
            return Tr("days-ago", { timeDiffInDays })
        else
            return Tr("in-days", { math.abs(timeDiffInDays) })
        end
    else
        timeDiffInYears = Round(timeDiffInYears)
        if timeDiffInYears == 0 then
            return Tr("this-year")
        elseif timeDiffInYears == 1 then
            return Tr("last-year")
        elseif timeDiffInYears == -1 then
            return Tr("next-year")
        elseif timeDiffInYears > 1 then
            return Tr("years-ago", { timeDiffInYears })
        else
            return Tr("in-years", { math.abs(timeDiffInYears) })
        end
    end
end

function IsFutureEvent(historyItem)
    if IsCurrentDaySet then
        return daysAgo(historyItem) < 0
    else
        return yearsAgo(historyItem) < 0
    end
end

function IsHasHappened(entity, keyword, onNil)
    if entity == nil then
        return onNil
    end
    if not IsCurrentYearSet then
        return onNil
    end
    local year = GetProtectedField(entity, keyword)
    if year == nil then
        return onNil
    else
        year = tonumber(year)
        if year == nil then
            LogError("Entry with key \"" .. keyword .. "\" of is not a number:" .. DebugPrint(entity))
            return onNil
        end
        return year <= GetCurrentYear()
    end
end

function YearAndDayString(historyItem)
    local year = GetProtectedField(historyItem, "year")
    local day = GetProtectedField(historyItem, "day")
    local out = {}
    Append(out, YearString(year))
    if day ~= nil then
        Append(out, ", ")
        Append(out, DayString(day))
    end
    Append(out, " (")
    Append(out, timeDiffString(historyItem))
    Append(out, ")")
    return table.concat(out)
end

local function monthAndDay(day, namesAndFirstDays)
    local firstDay = 1
    local month = "NoMonthFound"
    if day < namesAndFirstDays[1][2] then
        --LogError("day " .. day .. ", first day " .. DebugPrint(namesAndFirstDays[1]))
        month = namesAndFirstDays[#namesAndFirstDays][1]
        firstDay = namesAndFirstDays[#namesAndFirstDays][2]
        firstDay = firstDay - GetDaysPerYear()
    else
        for i = #(namesAndFirstDays), 1, -1 do
            local thisMonth = namesAndFirstDays[i][1]
            local thisFirstDay = namesAndFirstDays[i][2]
            if day >= thisFirstDay then
                month = thisMonth
                firstDay = thisFirstDay
                break
            end
        end
    end
    if month == "NoMonthFound" then
        LogError("Could not find month for day " .. day .. ".")
    end
    local dayOfMonth = day - firstDay + 1
    return month, dayOfMonth
end

function DayString(day, fmt)
    if fmt == nil then
        fmt = DayFmt
    end
    local out = {}
    Append(out, Tr("day") .. " ")
    Append(out, day)
    for key, calendar in pairs(fmt) do
        local monthsAndDays = GetProtectedField(calendar, "monthsAndFirstDays")
        local month, dayOfMonth = monthAndDay(day, monthsAndDays)
        Append(out, [[ / ]])
        Append(out, dayOfMonth)
        Append(out, [[.]])
        Append(out, month)
    end
    return table.concat(out)
end

function YearString(year, fmt)
    if fmt == nil then
        fmt = YearFmt
    end
    if IsEmpty(fmt) then
        return tostring(year)
    end
    local out = {}
    for key, calendar in pairs(fmt) do
        if key > 1 then
            Append(out, [[ / ]])
        end
        local offset = GetProtectedField(calendar, "yearOffset")
        if offset == nil then
            offset = 0
        end
        Append(out, year + offset)
        local abbr = GetProtectedField(calendar, "yearAbbreviation")
        if abbr ~= nil then
            Append(out, " ")
            Append(out, abbr)
        end
    end
    return table.concat(out)
end
