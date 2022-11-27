local function markName(entity, condition, marker)
    local name = GetProtectedStringField(entity, "name")
    if IsEmpty(name) then
        LogError("Entity has no name: " .. DebugPrint(entity))
    elseif condition(entity) then
        if IsEmpty(GetProtectedStringField(entity, "shortname")) then
            SetProtectedField(entity, "shortname", name)
        end
        SetProtectedField(entity, "name", name .. " " .. marker)
    end
end

function AddNameMarkers(entity)
    markName(entity, IsDead, [[\textdied{}]])
    markName(entity, IsEntitySecret, "(" .. CapFirst(Tr("secret")) .. ") ")
    -- markDead(entity)
    -- markSecret(entity)
end
