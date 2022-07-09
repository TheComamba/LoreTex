local errorMessages = {}

function LogError(error)
	errorMessages[#errorMessages + 1] = error
end

function PrintErrors()
	local out = {}
	if not IsEmpty(errorMessages) then
		Append(out, TexCmd("chapter", "Error Messages"))
		Append(out, "DnDTex encountered " .. #errorMessages .. " errors:")
		Append(out, ListAll(errorMessages))
	end
	return out
end

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

	if args ~= nil and #args > 0 then
		for key, arg in pairs(args) do
			out = out .. [[{]] .. arg .. [[}]]
		end
	else
		out = out .. [[{}]]
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

function IdentityProcessor(content, additionalContent)
	return content
end

local function processLabelList(list, processor, additionalProcessorArg)
	if processor == nil then
		processor = IdentityProcessor
	end

	local out = {}
	for key, content in pairs(list) do
		local processedContent = processor(content, additionalProcessorArg)
		if not IsEmpty(processedContent) then
			out[#out + 1] = processedContent
		end
	end
	return out
end

function ListAll(list, processor, additionalProcessorArg)
	if #list == 0 then
		return ""
	end
	if type(list[1]) ~= "table" then
		table.sort(list)
	end

	local processedList = processLabelList(list, processor, additionalProcessorArg)
	if IsEmpty(processedList) then
		return ""
	end

	local str = TexCmd("begin", "itemize")
	for key, content in pairs(processedList) do
		str = str .. TexCmd("item") .. " "
		str = str .. content
	end
	str = str .. TexCmd("end", "itemize")
	return str
end

function ListAllFromMap(listOfThings)
	local allLabels = {}
	for label, elem in pairs(listOfThings) do
		allLabels[#allLabels + 1] = label
	end
	return ListAll(allLabels, NamerefString)
end

function IsEmpty(obj)
	if obj == nil then
		return true
	elseif type(obj) == "table" then
		local out = true
		for key, val in pairs(obj) do
			if not IsEmpty(val) then
				return false
			end
		end
		return out
	elseif type(obj) == "string" then
		return FirstNonWhitespaceChar(obj) == nil
	else
		return false
	end
end

function IsList(list)
	return type(list) == "table" and #list > 0
end

function IsMap(list)
	return type(list) == "table" and #list == 0
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

function Append(dest, src)
	if type(src) == "table" then
		for key, elem in pairs(src) do
			Append(dest, elem)
		end
	else
		table.insert(dest, src)
	end
end
