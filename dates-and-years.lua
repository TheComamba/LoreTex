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
    end
end

function ConvertYearFromVin(year, fmt)
    if fmt == YearFmtVin then
        return year
    elseif fmt == YearFmtDjo then
        return year + 1566
    elseif fmt == YearFmtNar then
        return year + 5077
    end
end

function AnnoString(year, fmt)
    if type(year) == "string" then
        year = tonumber(year)
    end
    local diff = CurrentYearVin - year

    if fmt == nil then
        fmt = YearFmt
    end
    year = ConvertYearFromVin(year, fmt)

    local str = tostring(year) .. " " .. fmt
    if diff == 0 then
        str = str .. " (dieses Jahr)"
    elseif diff == 1 then
        str = str .. " (letztes Jahr)"
    else
        str = str .. " (vor " .. diff .. " Jahren)"
    end
    return str
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

function AnnoAll(year)
    tex.print("(replace this deprecated tex command with annoVin.)")
    tex.print(year .. " Vin / " .. (year + 1566) .. [[ \'Et / ]] .. (year + 5077) .. " NM")
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
    { [[H\'is]], 337 } }

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
    { [[Dez]], 345 } }

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
    local dayOfMonth = day - firstDay + 1
    return month, dayOfMonth
end

function Date(day, fmt)
    if fmt == nil then
        fmt = DateFmt
    end
    local str = "" .. day
    for key, monthsAndFirstDays in pairs(fmt) do
        local month, dayOfMonth = MonthAndDay(day, monthsAndFirstDays)
        str = str .. [[ / ]] .. dayOfMonth .. [[.]] .. month
    end
    return str
end