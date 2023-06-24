EntityRefCommand = "entityref"

function StringToDescription(descriptionString)
    local entityrefs = ScanStringForCmd(descriptionString, EntityRefCommand)
    if #entityrefs == 1 then
        return GetMutableEntityFromAll(entityrefs[1])
    else
        return descriptionString
    end
end

function EntitiesToColumns()
    return {}
end

function ColumnsToEntities()
    return {}
end
