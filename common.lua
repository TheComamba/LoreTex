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

PrimaryRefs = {}
SecondaryRefs = {}
UnfoundRefs = {}
function AddRef(label, refs)
	if label ~= nil and not IsIn(label, refs) then
		refs[#refs + 1] = label
	end
end

IsAppendix = false
function AddRefPrimaryOrSecondary(label)
	if not IsAppendix then
		AddRef(label, PrimaryRefs)
	else
		AddRef(label, SecondaryRefs)
	end
end

function NamerefString(label)
	local str = TexCmd("nameref", label)
	str = str .. " (Ref. "
	str = str .. TexCmd("speech", label)
	str = str .. ")"
	return str
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

function ListAllRefs()
	tex.print(TexCmd("paragraph", "primaryRefs"))
	tex.print(ListAll(PrimaryRefs, NamerefString))
	tex.print(TexCmd("paragraph", "secondaryRefs"))
	tex.print(ListAll(SecondaryRefs, NamerefString))
end

function ScanForRefs(str)
	if str == nil then
		return
	end
	local refs = {}
	local keyword1 = [[\myref {]]
	local keyword2 = [[}]]
	local pos1 = string.find(str, keyword1)
	while pos1 ~= nil do
		local pos2 = string.find(str, keyword2, pos1)
		local ref = string.sub(str, pos1 + string.len(keyword1), pos2 - 1)
		if not IsIn(ref, refs) then
			refs[#refs + 1] = ref
		end
		pos1 = string.find(str, keyword1, pos2)
	end
	return refs
end

function ScanForSecondaryRefs(str)
	for key, ref in pairs(ScanForRefs(str)) do
		if not IsIn(ref, PrimaryRefs) then
			AddRef(ref, SecondaryRefs)
		end
	end
end

function ScanContentForSecondaryRefs(list)
	local primaryEntries = GetPrimaryRefEntities(list)
	for label, entry in pairs(primaryEntries) do
		for key, content in pairs(entry) do
			if type(content) == "string" then
				ScanForSecondaryRefs(content)
			elseif type(content) == "table" then
				for key2, subcontent in pairs(content) do
					if type(subcontent) == "string" then
						ScanForSecondaryRefs(subcontent)
					end
				end
			end
		end
	end
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

function AddAllRefsToPrimary()
	for label, elem in pairs(Entities) do
		AddRef(label, PrimaryRefs)
	end
end
