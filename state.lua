StateResetters = {}

IsThrowOnError = false

function ResetState()
    for key, resetFunction in pairs(StateResetters) do
        resetFunction()
    end
end