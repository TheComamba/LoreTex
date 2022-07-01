function TexCmd(cmd, args, options)
	if type(args) ~= "table" then
		args = { args }
	end
	if type(options) ~= "table" then
		options = { options }
	end
	local out = ""
	out = out .. [[\]]
	out = out .. cmd

	if options ~= nil then
		for key, option in pairs(options) do
			out = out .. [=[[]=] .. option .. [=[]]=]
		end
	end

	if args ~= nil then
		for key, arg in pairs(args) do
			out = out .. [[{]] .. arg .. [[}]]
		end
	end
	return out
end

function IsIn(elem, list)
	for key, val in pairs(list) do
		if val == elem then
			return true
		end
	end
	return false
end

function UnknownProcessor(content)
	return "UNKNOWN PROCESSOR"
end

function ListAll(list, processor, additionalProcessorArg)
	local str = ""

	if type(list[1]) ~= "table" then
		table.sort(list)
	end

	if processor == nil then
		processor = UnknownProcessor
	end

	local isContainsAtLeastOneItem = false

	str = str .. TexCmd("begin", "itemize")
	for key, label in pairs(list) do
		local content = processor(label, additionalProcessorArg)
		if content ~= nil and content ~= "" then
			str = str .. TexCmd("item") .. " "
			str = str .. content

			isContainsAtLeastOneItem = true
		end
	end
	str = str .. TexCmd("end", "itemize")

	if isContainsAtLeastOneItem then
		return str
	else
		return ""
	end
end

function ListAllFromMap(listOfThings)
	local allLabels = {}
	for label, elem in pairs(listOfThings) do
		allLabels[#allLabels + 1] = label
	end
	return ListAll(allLabels, NamerefString)
end

function IsStringEmpty(str)
	if type(str) == "table" then
		local out = true
		for key, val in pairs(str) do
			if not IsStringEmpty(val) then
				return false
			end
		end
		return out
	end

	if str == nil then
		return true
	else
		return FirstNonWhitespaceChar(str) == nil
	end
end

function PrintAllChars(str)
	for i = 1, #str do
		tex.print(str:sub(i, i))
	end
end

function FirstNonWhitespaceChar(str)
	local KEYWORD = [[\par]]
	local out = str:find("%S")
	local nextPar = str:find(KEYWORD)
	while out ~= nil and out == nextPar do
		nextPar = str:find(KEYWORD, out + #KEYWORD)
		out = str:find("%S", out + #KEYWORD)
	end
	return out
end
