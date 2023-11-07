local hook = {}

hook.Table = {}

function hookNew(Event, Name, Func)
    hook.Table[Event] = hook.Table[Event] or {}
    hook.Table[Event][Name] = Func
end

function hookCall(Event, ...)
    local et = hook.Table[Event]
    if ( not et ) then return end
    for _, f in pairs(et) do
        if f(...) then return true end
    end
    return false
end

function hookRemove(Event, Name)
    if ( not hook.Table[Event] ) then return end
    hook.Table[Event][Name] = nil
end

function hookTable()
    return hook.Table
end

retur
n hook
