CurrentYearVin = 0

YearFmtVin = "Vin"
YearFmtDjo = [[\'Et]]
YearFmtNar = "NM"
YearFmt = YearFmtVin

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

function AnnoString(yearIn, fmt)
    local year = tonumber(yearIn)
    if year == nil then
        LogError("Could  not convert year string \"" .. yearIn .. "\" to number.")
    end
    local diff = CurrentYearVin - year

    if fmt == nil then
        fmt = YearFmt
    end
    year = ConvertYearFromVin(year, fmt)

    local out = {}
    Append(out, tostring(year))
    Append(out, " ")
    Append(out, fmt)
    if diff == 0 then
        Append(out, " (dieses Jahr)")
    elseif diff == 1 then
        Append(out, " (letztes Jahr)")
    else
        Append(out, " (vor ")
        Append(out, diff)
        Append(out, " Jahren)")
    end
    return table.concat(out)
end

function AnnoVin(year)
    tex.print(AnnoString(year))
end

function AnnoDjo(year)
    tex.print(AnnoString(ConvertYearToVin(year, YearFmtDjo)))
end

function AnnoNar(year)
    tex.print(AnnoString(ConvertYearToVin(year, YearFmtNar)))
end

DaysPerYear = 364

ElvenMonthsAndFirstDays = {
    { [[Rin]], 1 },
    { [[N\'en]], 29 },
    { [[Coi]], 57 },
    { [[L\'ot]], 85 },
    { [[Erd]], 113 },
    { [[N\'ar]], 141 },
    { [[Lo\"e]], 169 },
    { [[\'Uri]], 197 },
    { [[Yav]], 225 },
    { [[S\'ul]], 253 },
    { [[Las]], 281 },
    { [[Nqu]], 309 },
    { [[H\'is]], 337 }
}

RealworldMonthsAndFirstDays = {
    { [[Jan]], 11 },
    { [[Feb]], 42 },
    { [[Mär]], 70 },
    { [[Apr]], 101 },
    { [[Mai]], 131 },
    { [[Jun]], 162 },
    { [[Jul]], 192 },
    { [[Aug]], 225 },
    { [[Sep]], 254 },
    { [[Okt]], 284 },
    { [[Nov]], 315 },
    { [[Dez]], 345 }
}

DefaultDateFmt = { ElvenMonthsAndFirstDays, RealworldMonthsAndFirstDays }
DateFmt = DefaultDateFmt

function MonthAndDay(day, namesAndFirstDays)
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
    Append(out, day)
    for key, monthsAndFirstDays in pairs(fmt) do
        local month, dayOfMonth = MonthAndDay(day, monthsAndFirstDays)
        Append(out, [[ / ]])
        Append(out, dayOfMonth)
        Append(out, [[.]])
        Append(out, month)
    end
    return table.concat(out)
end
