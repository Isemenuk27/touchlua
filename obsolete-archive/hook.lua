local hook = {}

hook.Table = {}

function hook:New(Event, Name, Func)
    self.Table[Event] =  self.Table[Event] or {}
    self.Table[Event][Name] = Func
end

hook.Add = hook.New

function hook:Call(Event, ...)
    local et = self.Table[Event]
    if not et then return end
    for _, f in pairs(et) do
        if f(...) then return true end
    end
    return false
end

function hook:Remove(Event, Name)
    if not self.Table[Event] then return end
    self.Table[Event][Name] = nil
end

function hook:GetTable()
    return self.Table
end

return hook
