CurrentYear = 0
CurrentDay = 0
DaysPerYear = 364
IsShowFuture = true

YearFmtVin = "Vin"
YearFmtDjo = [[\'Et]]
YearFmtNar = "NM"
YearFmt = YearFmtVin

YearFmtTMP = {}
DateFmt = {}

function ResetDateFmt()
    DateFmt = {}
    YearFmtTMP = {}
end

function AddDateFmt(label)
    local calendar = GetEntity(label)
    if IsEmpty(calendar) then
        LogError("Could not find a calendar for label \"" .. label .. "\"")
        return
    end
    if IsEmpty(GetProtectedField(calendar, "monthsAndFirstDays")) then
        LogError("Calendar \"" .. label .. "\" has no months defined.")
        return
    end
    DateFmt[#DateFmt + 1] = calendar
end

function AddYearFmt(label)
    local calendar = GetEntity(label)
    if IsEmpty(calendar) then
        LogError("Could not find a calendar for label \"" .. label .. "\"")
        return
    end
    YearFmtTMP[#YearFmtTMP + 1] = calendar
end

function SetYearAbbreviation(entity, abbr)
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

function AddMonth(entity, month, firstDay)
    if IsEmpty(entity) then
        LogError("Called with empty entity and month:" .. DebugPrint(month))
        return
    end
    if IsEmpty(month) then
        LogError("Called with empty month for enitty:" .. DebugPrint(entity))
        return
    end
    if IsEmpty(firstDay) or type(firstDay) ~= "number" then
        LogError("Called without first day of month:" .. DebugPrint(month))
        return
    end
    AddToProtectedField(entity, "monthsAndFirstDays", { month, firstDay })
end

local function isCurrentDaySet()
    return CurrentDay > 0
end

local function isDaysPerYearSet()
    return DaysPerYear > 0
end

function ConvertYearToVin(year, fmt)
    if fmt == YearFmtVin then
        return year
    elseif fmt == YearFmtDjo then
        return year - 1566
    elseif fmt == YearFmtNar then
        return year - 5077
    else
        LogError("Called with fmt " .. DebugPrint(fmt))
        return 0
    end
end

function ConvertYearFromVin(year, fmt)
    if fmt == YearFmtVin then
        return year
    elseif fmt == YearFmtDjo then
        return year + 1566
    elseif fmt == YearFmtNar then
        return year + 5077
    else
        LogError("Called with fmt " .. DebugPrint(fmt))
        return 0
    end
end

local function daysAgo(historyItem)
    local year = historyItem["year"]
    local day = historyItem["day"]
    if isCurrentDaySet() and day ~= nil then
        return CurrentDay - day + (CurrentYear - year) * DaysPerYear
    else
        return (CurrentYear - year) * DaysPerYear
    end
end

local function timeDiffString(historyItem)
    local year = historyItem["year"]
    local day = historyItem["day"]
    local timeDiffInDays = daysAgo(historyItem)
    if not isDaysPerYearSet() then
        LogError("Cannot work with a year with 0 days.")
        return
    end
    local timeDiffInYears = timeDiffInDays / DaysPerYear
    if math.abs(timeDiffInYears) < 1 and isCurrentDaySet() and day ~= nil then
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
    return daysAgo(historyItem) < 0
end

function YearAndDateString(historyItem, fmt)
    local year = historyItem["year"]
    local day = historyItem["day"]
    if fmt == nil then
        fmt = YearFmt
    end
    year = ConvertYearFromVin(year, fmt)

    local out = {}
    Append(out, tostring(year))
    Append(out, " ")
    Append(out, fmt)
    if day ~= nil then
        Append(out, ", ")
        Append(out, Date(day))
    end
    Append(out, " (")
    Append(out, timeDiffString(historyItem))
    Append(out, ")")
    return table.concat(out)
end

function AnnoVin(yearIn)
    local year = tonumber(yearIn)
    if year == nil then
        LogError("Could  not convert year string \"" .. yearIn .. "\" to number.")
        return
    end
    local item = {}
    item["year"] = year
    tex.print(YearAndDateString(item))
end

function AnnoDjo(yearIn)
    local year = tonumber(yearIn)
    if year == nil then
        LogError("Could  not convert year string \"" .. yearIn .. "\" to number.")
        return
    end
    local item = {}
    item["year"] = ConvertYearToVin(year, YearFmtDjo)
    tex.print(YearAndDateString(item))
end

function AnnoNar(yearIn)
    local year = tonumber(yearIn)
    if year == nil then
        LogError("Could  not convert year string \"" .. yearIn .. "\" to number.")
        return
    end
    local item = {}
    item["year"] = ConvertYearToVin(year, YearFmtNar)
    tex.print(YearAndDateString(item))
end

local function monthAndDay(day, namesAndFirstDays)
    local firstDay = 1
    local month = "NoMonthFound"
    if day < namesAndFirstDays[1][2] then
        month = namesAndFirstDays[#namesAndFirstDays][1]
        firstDay = namesAndFirstDays[#namesAndFirstDays][2]
        firstDay = firstDay - DaysPerYear
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

function Date(day, fmt)
    if fmt == nil then
        fmt = DateFmt
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

function Anno(year, fmt)
    if fmt == nil then
        fmt = YearFmtTMP
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
