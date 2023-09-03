RelativePath = ""
TexApi = {}

local function logErrorOnModify(table, key, value)
	local message = {}
	Append(message, "Attempted to modify value with key \"")
	Append(message, key)
	Append(message, "\" in read-only table ")
	Append(message, DebugPrint(table))
	LogError(message)
end

function ReadonlyTable(table)
	if table == nil then
		table = {}
	end
	local proxy = {}
	local metaTable = {}
	metaTable.__index = table
	metaTable.__newindex = logErrorOnModify
	metaTable.__pairs = function() return pairs(table) end
	metaTable.__ipairs = function() return ipairs(table) end
	setmetatable(proxy, metaTable)
	return proxy
end

function Round(num)
	return math.floor(num + 0.5)
end

function RoundedNumString(num, decimals)
	local decimalFactor = 10 ^ decimals
	local rounded = Round(num * decimalFactor) / decimalFactor
	if decimals < 0 then
		decimals = 0
	end
	local formatString = string.format("%%.%df", decimals)
	return string.format(formatString, rounded)
end

function TexCmd(cmd, args, options)
	if type(args) ~= "table" then
		args = { args }
	end
	if type(options) ~= "table" then
		options = { options }
	end
	local out = {}
	Append(out, [[\]])
	Append(out, cmd)

	if options ~= nil then
		for key, option in pairs(options) do
			Append(out, [=[[]=])
			Append(out, option)
			Append(out, [=[]]=])
		end
	end

	if args ~= nil and #args > 0 then
		for key, arg in pairs(args) do
			Append(out, [[{]])
			Append(out, arg)
			Append(out, [[}]])
		end
	else
		Append(out, [[{}]])
	end
	return table.concat(out)
end

function IsIn(elem, list)
	if list == nil then
		LogError("List is nil!")
		return false
	end
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
		out[#out + 1] = processedContent
	end
	return out
end

function ListAll(list, processor)
	if #list == 0 then
		return {}
	end

	local processedList = processLabelList(list, processor)
	if #processedList == 0 then
		return {}
	end

	local out = {}
	Append(out, TexCmd("begin", "itemize"))
	for key, content in pairs(processedList) do
		if type(content) ~= "string" then
			LogError { "Trying to concat ", DebugPrint(content) }
		else
			Append(out, [[\item ]] .. content)
		end
	end
	Append(out, TexCmd("end", "itemize"))
	return out
end

function IsEmpty(obj)
	if obj == nil then
		return true
	elseif IsEntity(obj) then
		return false
	elseif type(obj) == "table" then
		for key, val in pairs(obj) do
			if not IsEmpty(val) then
				return false
			end
		end
		return true
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
	if type(src) == "table" and not IsEntity(src) then
		for key, elem in pairs(src) do
			Append(dest, elem)
		end
	else
		table.insert(dest, src)
	end
end

function UniqueAppend(dest, src)
	if type(src) == "table" and not IsEntity(src) then
		for key, elem in pairs(src) do
			UniqueAppend(dest, elem)
		end
	else
		if not IsIn(src, dest) then
			Append(dest, src)
		end
	end
end

function Replace(strOld, strNew, content)
	if type(content) == "string" then
		return string.gsub(content, strOld, strNew)
	elseif type(content) == "table" and not IsEntity(content) then
		for key, elem in pairs(content) do
			content[key] = Replace(strOld, strNew, elem)
		end
		return content
	elseif type(content) == "boolean" or type(content) == "number" then
		return content
	else
		LogError("Tried to make replacements in an object of type " .. type(content) .. "!")
		return content
	end
end

function Bind(func, arg1)
	return function(...)
		return func(arg1, ...)
	end
end

function DeepCopy(inp)
	local out = {}
	if type(inp) == "table" then
		for k, v in pairs(inp) do
			if IsEntity(v) then
				out[k] = v
			else
				out[k] = DeepCopy(v)
			end
		end
	else
		out = inp
	end
	return out
end

function IsArgOk(caller, arg, required, optional)
	if IsEmpty(arg) and #required > 0 then
		LogError("\"" .. caller .. "\" called without arguments.")
		return false
	end
	for key, requiredArg in pairs(required) do
		if IsEmpty(arg[requiredArg]) then
			LogError("\"" .. caller .. "\" called without required argument \"" .. requiredArg .. "\".")
			return false
		end
	end
	for key, val in pairs(arg) do
		if not IsIn(key, required) and not IsIn(key, optional) then
			LogError("\"" .. caller .. "\" called with obsolete argument \"" .. key .. "\".")
		end
	end
	return true
end

local function getKeysOfType(tableInput, keyType)
	local out = {}
	for key, elem in pairs(tableInput) do
		if type(key) == keyType then
			Append(out, key)
		end
	end
	Sort(out, "compareAlphanumerical")
	return out
end

function GetSortedKeys(tableInput)
	local out = {}
	Append(out, getKeysOfType(tableInput, "number"))
	Append(out, getKeysOfType(tableInput, "string"))
	return out
end
