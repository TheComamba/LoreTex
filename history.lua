Histories = {}
HistoryCaption = "Histori\\\"e"

function AddHistory(label, year, event, day)
	if label == nil or label == "" then
		return
	end
	if event == nil or event == "" then
		return
	end

	if day == nil or day == "" then
		day = 0
	end
	year = tonumber(year)
	day = tonumber(day)

	if year == nil or day == nil then
		tex.print("Trying to print uninterpretable year or day to label " .. label)
		return
	end

	local labels = ScanForRefs(event)
	if not IsIn(label, labels) then
		labels[#labels + 1] = label
	end
	for key, label in pairs(labels) do
		if Histories[label] == nil then
			Histories[label] = {}
		end
		if Histories[label][year] == nil then
			Histories[label][year] = {}
		end
		if Histories[label][year][day] == nil then
			Histories[label][year][day] = event
		else
			Histories[label][year][day] = Histories[label][year][day] .. [[\\]] .. event
		end
	end
end

function HistoryEventString(yearAndDay, history)
	local year = yearAndDay[1]
	local day = yearAndDay[2]
	local out = AnnoString(year)
	if day > 0 then
		out = out .. ", Tag " .. Date(day, {})
	end
	return out .. ": " .. history[year][day]
end

function ListHistory(history)
	local years = {}
	for year, daysAndEvents in pairs(history) do
		if year <= CurrentYearVin then
			years[#years + 1] = year
		end
	end
	table.sort(years)
	local yearsAndDays = {}
	for key1, year in pairs(years) do
		local days = {}
		for day, event in pairs(history[year]) do
			days[#days + 1] = day
		end
		table.sort(days)
		for key2, day in pairs(days) do
			yearsAndDays[#yearsAndDays + 1] = { year, day }
		end
	end

	return ListAll(yearsAndDays, HistoryEventString, history)
end

function ScanHistoryForSecondaryRefs(history)
	for year, dayAndEvent in pairs(history) do
		if year <= CurrentYearVin then
			for day, event in pairs(dayAndEvent) do
				ScanForSecondaryRefs(event)
			end
		end
	end
end
