local hookmetamethod  = hookmetamethod
local getrawmetatable = getrawmetatable
local setreadonly     = setreadonly
local checkcaller     = checkcaller
local getnamecallmethod = getnamecallmethod
local getconnections  = getconnections
local hookfunction    = hookfunction
local newcclosure     = newcclosure
local getrenv         = getrenv
local getgc           = getgc
local getfenv         = getfenv
local debug           = debug
local typeof          = typeof

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer

if not LocalPlayer then
    pcall(function() LocalPlayer = Players.PlayerAdded:Wait() end)
end
if not LocalPlayer then
    repeat task.wait(0.1) until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

getgenv().Players           = Players
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer       = LocalPlayer
_G.Players           = Players
_G.ReplicatedStorage = ReplicatedStorage
_G.LocalPlayer       = LocalPlayer

local REMOTE_TAGS = {
    "exploit","cheat","detect","ban","kick","flag",
    "validate","integrity","security","anticheat","ac_",
    "guard","watch","monitor","shield","protect","verify",
    "check","report","punish","violation","suspect","audit",
    "scan","auth","token","session","client","server",
    "eye","spy","track","log","record","trace","moderation",
    "kek","warn","strike","appeal","restrict","sandbox"
}

local SCRIPT_TAGS = {
    "anticheat","ac","detection","detect","ban","kick",
    "security","moderation","guard","watch","monitor",
    "shield","protect","verify","check","audit","scan",
    "auth","session","spy","track","log","record","trace",
    "sandbox","restrict","strike","appeal","admin","staff"
}

local function matchName(name, tags)
    if not name or type(name) ~= "string" then return false end
    local low = name:lower()
    for i = 1, #tags do
        if low:find(tags[i], 1, true) then return true end
    end
    return false
end

local nameCache = setmetatable({}, { __mode = "k" })
local function matchObj(obj, tags, key)
    if not obj then return false end
    local per = nameCache[obj]
    if not per then
        per = {}
        nameCache[obj] = per
    end
    local entry = per[key]
    local currentName = obj.Name
    if entry and entry.name == currentName then
        return entry.value
    end
    local r = matchName(currentName, tags)
    per[key] = { name = currentName, value = r }
    return r
end

local fnCache = setmetatable({}, { __mode = "k" })
local function isACFunction(fn)
    if type(fn) ~= "function" then return false end
    local c = fnCache[fn]
    if c ~= nil then return c end
    local ok, src = pcall(debug.info, fn, "s")
    local r = ok and src and matchName(src, SCRIPT_TAGS) or false
    fnCache[fn] = r
    return r
end

do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()

        if method == "Kick" and self == LocalPlayer then
            return
        end

        if method == "FireServer" or method == "InvokeServer" then
            local ok, name = pcall(function() return self.Name end)
            if ok and matchName(name, REMOTE_TAGS) then
                return
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

do
    local function nukeConnections()
        if not getconnections then return end
        pcall(function()
            for _, conn in ipairs(getconnections(LocalPlayer.CharacterAdded)) do
                if not checkcaller() then conn:Disable() end
            end
        end)
        pcall(function()
            for _, conn in ipairs(getconnections(LocalPlayer.PlayerGui.ChildAdded)) do
                if not checkcaller() then conn:Disable() end
            end
        end)
        pcall(function()
            if LocalPlayer.Character then
                for _, conn in ipairs(getconnections(LocalPlayer.Character.DescendantAdded)) do
                    if not checkcaller() then conn:Disable() end
                end
            end
        end)
        pcall(function()
            if LocalPlayer:FindFirstChild("PlayerGui") then
                for _, conn in ipairs(getconnections(LocalPlayer.PlayerGui.DescendantAdded)) do
                    if not checkcaller() then conn:Disable() end
                end
            end
        end)
    end
    nukeConnections()

    local function destroyIfAC(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if matchName(obj.Name, REMOTE_TAGS) then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    ReplicatedStorage.DescendantAdded:Connect(destroyIfAC)
    pcall(function() workspace.DescendantAdded:Connect(destroyIfAC) end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        nukeConnections()
    end)

    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if checkcaller() and key == "Kick" and self == LocalPlayer then
            return function() end
        end
        return oldIndex(self, key)
    end)
end

task.spawn(function()

    pcall(function()
        local _stbl
        _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
            if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
                local tr = debug.traceback()
                if tr:find("MiscellaneousController") then
                    return _stbl({1,2,3}, {})
                end
            end
            return _stbl(tbl, mt)
        end))
    end)

    local lockedScripts = setmetatable({}, { __mode = "k" })
    local function lockScript(o)
        if not o then return end
        local cls = o.ClassName
        if cls ~= "LocalScript" and cls ~= "ModuleScript" then return end
        if not matchObj(o, SCRIPT_TAGS, "script") then return end
        pcall(function() o.Disabled = true end)
        if not lockedScripts[o] then
            lockedScripts[o] = true
            pcall(function()
                o:GetPropertyChangedSignal("Disabled"):Connect(function()
                    if not o.Disabled then
                        pcall(function() o.Disabled = true end)
                    end
                end)
            end)
        end
    end

    local function processObj(o)
        if not o or not o.Parent then return end
        local cls = o.ClassName
        if cls == "LocalScript" or cls == "ModuleScript" then
            lockScript(o)
        elseif cls == "RemoteEvent" or cls == "RemoteFunction" then
            if matchObj(o, REMOTE_TAGS, "remote") then
                pcall(function() o:Destroy() end)
            end
        end
    end

    for _, o in ipairs(game:GetDescendants()) do
        processObj(o)
    end
    game.DescendantAdded:Connect(processObj)

    pcall(function()
        local _nc = game:GetService("NetworkClient")
        if not _nc then return end
        local function destroyAC(ch)
            if matchName(ch.Name, REMOTE_TAGS) then
                pcall(function() ch:Destroy() end)
            end
        end
        _nc.ChildAdded:Connect(destroyAC)
        for _, ch in ipairs(_nc:GetChildren()) do
            destroyAC(ch)
        end
    end)

    pcall(function()
        local _rf = game:GetService("ReplicatedFirst")
        local _tgt = _rf:WaitForChild("LocalScript3", 10)
        if not _tgt then return end

        local _gc = getgc(false)
        for _i = 1, #_gc do
            local _fn = _gc[_i]
            if type(_fn) ~= "function" then continue end
            local _ok1, _env = pcall(getfenv, _fn)
            if not _ok1 or type(_env) ~= "table" then continue end
            local _ok2, _scr = pcall(function() return rawget(_env, "script") end)
            if not _ok2 or not _scr or typeof(_scr) ~= "Instance" then continue end
            if _scr ~= _tgt then continue end
            local _ok4, _consts = pcall(debug.getconstants, _fn)
            if not _ok4 or type(_consts) ~= "table" then continue end
            for _j = 1, #_consts do
                local _c = _consts[_j]
                if type(_c) == "string" then
                    if _c:find("TakeTheL") or matchName(_c, {
                        "ban","kick","anticheat","detect","violation",
                        "punish","report","flag","strike","restrict"
                    }) then
                        pcall(function() hookfunction(_fn, function() end) end)
                        break
                    end
                end
            end
        end
    end)

    pcall(function()
        local oldSpawn = task.spawn
        local oldDefer = task.defer
        local oldDelay = task.delay

        task.spawn = newcclosure(function(fn, ...)
            if isACFunction(fn) then return end
            return oldSpawn(fn, ...)
        end)
        task.defer = newcclosure(function(fn, ...)
            if isACFunction(fn) then return end
            return oldDefer(fn, ...)
        end)
        task.delay = newcclosure(function(t, fn, ...)
            if isACFunction(fn) then return end
            return oldDelay(t, fn, ...)
        end)
    end)

    pcall(function()
        local oldResume = coroutine.resume
        local oldWrap   = coroutine.wrap
        coroutine.resume = newcclosure(function(co, ...)
            local ok, fn = pcall(function() return debug.info(co, "f") end)
            if ok and isACFunction(fn) then return false end
            return oldResume(co, ...)
        end)
        coroutine.wrap = newcclosure(function(fn)
            if isACFunction(fn) then
                return function() end
            end
            return oldWrap(fn)
        end)
    end)

    pcall(function()
        local oldNew = Instance.new
        Instance.new = newcclosure(function(className, parent)
            local inst = oldNew(className, parent)
            if className == "LocalScript" or className == "ModuleScript" then
                if matchName(inst.Name, SCRIPT_TAGS) then
                    pcall(function() inst.Disabled = true end)
                end
            elseif className == "RemoteEvent" or className == "RemoteFunction" then
                if matchName(inst.Name, REMOTE_TAGS) then
                    pcall(function() inst:SetAttribute("_grief_ac", true) end)
                end
            end
            return inst
        end)
    end)

    local scanQueue = {}
    local scanIdx = 1
    local SCAN_BUDGET = 150
    local nextRebuild = 0

    local function rebuildQueue()
        scanQueue = game:GetDescendants()
        scanIdx = 1
    end
    rebuildQueue()

    RunService.Heartbeat:Connect(function()
        if scanIdx > #scanQueue then
            if tick() < nextRebuild then return end
            rebuildQueue()
            nextRebuild = tick() + 3
            return
        end
        local budget = SCAN_BUDGET
        while budget > 0 and scanIdx <= #scanQueue do
            local o = scanQueue[scanIdx]
            scanIdx = scanIdx + 1
            processObj(o)
            budget = budget - 1
        end
    end)

    task.spawn(function()
        if not getconnections then return end
        local deadline = tick() + 15
        local function filterSignal(sig)
            for _, conn in ipairs(getconnections(sig)) do
                pcall(function()
                    local fn = conn.Function
                    if fn and isACFunction(fn) then conn:Disable() end
                end)
            end
        end
        while tick() < deadline do
            pcall(function()
                filterSignal(RunService.Heartbeat)
                filterSignal(RunService.RenderStepped)
                filterSignal(RunService.Stepped)
            end)
            task.wait(2)
        end
    end)
end)
