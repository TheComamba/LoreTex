function texCmd(cmd,args,options)
	if type(args) ~= "table" then
		args = {args}
	end
	if type(options) ~= "table" then
		options = {options}
	end
	local out = ""
	out = out..[[\]]
	out = out..cmd
	
	if options ~= nil then
		for key,option in pairs(options) do
			out = out..[=[[]=]..option..[=[]]=]
		end
	end
	
	if args ~= nil then
		for key,arg in pairs(args) do
			out = out..[[{]]..arg..[[}]]
		end
	end
	return out
end

function isIn(elem, list)
	for key,val in pairs(list) do
		if val == elem then
			return true
		end
	end
	return false
end

primaryRefs = {}
secondaryRefs = {}
unfoundRefs = {}
function addRef(label, refs)
	if label ~= nil and not isIn(label, refs) then
		refs[#refs+1] = label
	end
end

isAppendix = false
function addRefPrimaryOrSecondary(label)
	if not isAppendix then
		addRef(label, primaryRefs)
	else
		addRef(label, secondaryRefs)
	end
end

function namerefString(label)
	local str = texCmd("nameref", label)
	str = str.." (Ref. "
	str = str..texCmd("speech", label)
	str = str..")"
	return str
end

function unknownProcessor(content)
	return "UNKNOWN PROCESSOR"
end

function listAll(list, processor, additionalProcessorArg)
	local str = ""
	
	if type(list[1]) ~= "table" then
		table.sort(list)
	end
	
	if processor == nil then
		processor = unknownProcessor
	end
	
	local isContainsAtLeastOneItem = false
	
	str = str..texCmd("begin","itemize")
	for key,label in pairs(list) do
		local content = processor(label, additionalProcessorArg)
		if content ~= nil and content ~= "" then
			str = str..texCmd("item").." "
			str = str..content
			
			isContainsAtLeastOneItem = true
		end
	end
	str = str..texCmd("end","itemize")
	
	if isContainsAtLeastOneItem then
		return str
	else
		return ""
	end
end

function listAllRefs()
	tex.print(texCmd("paragraph", "primaryRefs"))
	tex.print(listAll(primaryRefs, namerefString))
	tex.print(texCmd("paragraph", "secondaryRefs"))
	tex.print(listAll(secondaryRefs, namerefString))
end

function scanForRefs(str)
	if str == nil then
		return
	end
	local refs = {}
	local keyword1 = [[\myref {]]
	local keyword2 = [[}]]	
	local pos1 = string.find(str, keyword1)
	while pos1 ~= nil do
		local pos2 = string.find(str, keyword2, pos1)
		local ref = string.sub(str, pos1+string.len(keyword1), pos2-1)
		if not isIn(ref, refs) then
			refs[#refs+1] = ref
		end
		pos1 = string.find(str, keyword1, pos2)
	end
	return refs
end

function scanForSecondaryRefs(str)
	for key, ref in pairs(scanForRefs(str)) do
		if not isIn(ref, primaryRefs) then
			addRef(ref, secondaryRefs)
		end
	end
end

function isStringEmpty(str)
	if type(str) == "table" then
		local out = true
		for key, val in pairs(str) do
			if not isStringEmpty(val) then
				return false
			end
		end
		return out
	end
	
	if str == nil then
		return true
	else
		return firstNonWhitespaceChar(str) == nil
	end	
end

function printAllChars(str)
	for i=1,#str do
		tex.print(str:sub(i,i))
	end
end

function firstNonWhitespaceChar(str)
	local KEYWORD = [[\par]]
	local out = str:find("%S")
	local nextPar = str:find(KEYWORD)
	while out ~= nil and out == nextPar do
		nextPar = str:find(KEYWORD, out+#KEYWORD)
		out = str:find("%S", out+#KEYWORD)
	end
	return out
end