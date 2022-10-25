ScopedVariables = { {} }

function PushScopedVariables()
    ScopedVariables[#ScopedVariables + 1] = DeepCopy(ScopedVariables[#ScopedVariables])
end

function PopScopedVariables()
    ScopedVariables[#ScopedVariables] = nil
end

function SetScopedVariable(key, value)
    ScopedVariables[#ScopedVariables][key] = value
end

function GetScopedVariable(key)
    return ScopedVariables[#ScopedVariables][key]
end

function LoadChildFile(subfolder, filename)
    PushScopedVariables()
    if not IsEmpty(subfolder) then
        local oldFilepath = GetScopedVariable("FilepathToEntities")
        if oldFilepath == nil then
            LogError("FilepathToEntities is not yet set!")
            return
        else
            local newFolderpath = oldFilepath .. [[/]] .. subfolder
            SetScopedVariable("FilepathToEntities", newFolderpath)
        end
    end
    local filepath = GetScopedVariable("FilepathToEntities") .. [[/]] .. filename
    tex.print(TexCmd("input", filepath))
end
