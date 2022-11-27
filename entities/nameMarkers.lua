local function markName(entity, condition, marker)
    local name = GetName(entity)
    if condition(entity) then
        if IsEmpty(GetProtectedStringField(entity, "shortname")) then
            SetProtectedField(entity, "shortname", name)
        end
        SetProtectedField(entity, "name", name .. " " .. marker)
    end
end

function AddNameMarkers(entity)
    markName(entity, IsDead, [[\textdied{}]])
    markName(entity, IsEntitySecret, "(" .. CapFirst(Tr("secret")) .. ") ")
end
