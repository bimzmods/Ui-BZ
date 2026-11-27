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

-- =========================================================
-- Daftar keyword deteksi (diperluas, tetap konsisten)
-- =========================================================
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

local function containsAny(str, tags)
    if not str then return false end
    local low = str:lower()
    for i = 1, #tags do
        if low:find(tags[i], 1, true) then return true end
    end
    return false
end

-- =========================================================
-- 1) Hook __namecall
-- =========================================================
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
            if ok and containsAny(name, REMOTE_TAGS) then
                return
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

-- =========================================================
-- 2) Nuke connections + destroy remote AC + hook __index
-- =========================================================
do
    local function nukeConnections()
        if not getconnections then return end
        pcall(function()
            for _, conn in ipairs(getconnections(LocalPlayer.CharacterAdded)) do
                if not checkcaller() then
                    conn:Disable()
                end
            end
        end)
        pcall(function()
            for _, conn in ipairs(getconnections(LocalPlayer.PlayerGui.ChildAdded)) do
                if not checkcaller() then
                    conn:Disable()
                end
            end
        end)
        -- tambahan: putus koneksi DescendantAdded milik PlayerGui & Character
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

    -- destroy remote AC yang muncul (ReplicatedStorage)
    ReplicatedStorage.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if containsAny(obj.Name, REMOTE_TAGS) then
                pcall(function() obj:Destroy() end)
            end
        end
    end)

    -- destroy remote AC yang muncul (Workspace & CoreGui, beberapa game taruh di sini)
    pcall(function()
        workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if containsAny(obj.Name, REMOTE_TAGS) then
                    pcall(function() obj:Destroy() end)
                end
            end
        end)
    end)

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

-- =========================================================
-- 3) setmetatable bypass + disable AC scripts + NetworkClient + LocalScript3
-- =========================================================
task.spawn(function()
    -- 3a) setmetatable bypass (MiscellaneousController)
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

    -- 3b) disable LocalScript/ModuleScript bernama AC (diperluas)
    pcall(function()
        local function _procAC(o)
            pcall(function()
                if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                    if containsAny(o.Name, SCRIPT_TAGS) then
                        pcall(function() o.Disabled = true end)
                    end
                end
            end)
        end

        pcall(function()
            for _, o in ipairs(game:GetDescendants()) do
                _procAC(o)
            end
        end)

        pcall(function() game.DescendantAdded:Connect(_procAC) end)
    end)

    -- 3c) NetworkClient: destroy child bernama AC (diperluas)
    pcall(function()
        local _nc = game:GetService("NetworkClient")
        if not _nc then return end
        _nc.ChildAdded:Connect(function(ch)
            pcall(function()
                if containsAny(ch.Name, REMOTE_TAGS) then
                    pcall(function() ch:Destroy() end)
                end
            end)
        end)
        -- scan awal
        for _, ch in ipairs(_nc:GetChildren()) do
            if containsAny(ch.Name, REMOTE_TAGS) then
                pcall(function() ch:Destroy() end)
            end
        end
    end)

    -- 3d) hook fungsi di LocalScript3 yang mengandung TakeTheL/ban/kick
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
                    if _c:find("TakeTheL") or containsAny(_c, {
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
end)
