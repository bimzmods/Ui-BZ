local CollectionService  = game:GetService("CollectionService")
local player = game:GetService("Players").LocalPlayer

local BZ
do
	local ok, res = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/bimzmods/Ui-BZ/refs/heads/main/Main.lua"))()
	end)
	if not ok or not res then
		report("error", "Failed to load BZ-UI: " .. tostring(res))
		return
	end
	BZ = res
end

BZ:SetTexts({Title = "STTK", Logo = "BZ", Studio = "Version v1.6", ShowVersion = false})
BZ:SetLogoImage("https://raw.githubusercontent.com/bimzmods/Ui-BZ/main/Asset/Logo.png", function(ok, info)
	print(ok, info)
end)

if game.PlaceId ~= 77709018585862 then BZ:Error("Save the Krusty Krab", "This place is not supported", 4) return end

local interactables = workspace:FindFirstChild("_INTERACTABLES", true)
if not interactables then BZ:Error("Auto Cook", "_INTERACTABLES tidak ketemu", 4) return end

local function module(path)
    local object = game:GetService("ReplicatedStorage"):WaitForChild("src", 15)
    for part in path:gmatch("[^.]+") do object = object and object:WaitForChild(part, 10) end
    assert(object, "Game module unavailable: " .. path)
    return require(object)
end

local restaurant, restaurantController, restaurantToolkit, cycle, cycleController,
      nightlyTasks, workstation, registerSlice, tableToolkit, npcToolkit, grouperToolkit,
      planktonToolkit, orbToolkit, dennisToolkit, upgradeToolkit,
      dutchman, dutchmanController, customPlayers, backpack, backpackSlice,
      inventoryController, cameraController, cameraSlice,
      newspaper, newspaperSlice, guiViews, dialogSlice

do
local loadOk, loadErr = pcall(function()
    restaurant            = module("Systems.Restaurant.RestaurantStore")
    restaurantController  = module("Systems.Restaurant.RestaurantController")
    restaurantToolkit     = module("Systems.Restaurant.RestaurantToolkit")
    cycle                 = module("Systems.GameCycle.GameCycleStore")
    cycleController       = module("Systems.GameCycle.GameCycleController")
    nightlyTasks          = module("Systems.NightlyTasks.NightlyTaskStore")
    workstation           = module("Systems.Workstation.WorkstationStore")
    registerSlice         = module("Systems.Register.RegisterSlice")
    tableToolkit          = module("Systems.Table.TableToolkit")
    npcToolkit            = module("Systems.NPC.NPCToolkit")
    grouperToolkit        = module("Systems.NPC.DonGrouperToolkit")
    planktonToolkit       = module("Systems.NPC.PlanktonBallToolkit")
    orbToolkit            = module("Systems.Workstation.OrbOfConfusionToolkit")
    dennisToolkit         = module("Systems.NPC.DennisToolkit")
    module("Systems.NPC.DirtyBubbleToolkit")
    upgradeToolkit        = module("Systems.Upgrade.UpgradeToolkit")
    dutchman              = module("Systems.Dutchman.DutchmanStore")
    dutchmanController    = module("Systems.Dutchman.DutchmanController")
    customPlayers         = module("Systems.CustomPlayer.CustomPlayerHandler_ClientClass")
    backpack              = module("Systems.Backpack.BackpackHandler")
    backpackSlice         = module("Systems.Backpack.BackpackSlice")
    inventoryController   = module("Systems.Inventory.InventoryController")
    module("Shared.Item.ItemToolkit")
    module("Packages.Charm")
    cameraController      = module("Systems.Camera.CameraController")
    cameraSlice           = module("Systems.Camera.CameraSlice")
    newspaper             = module("Systems.Newspaper.NewspaperStore")
    newspaperSlice        = module("Systems.Newspaper.NewspaperSlice")
    guiViews              = module("Systems.UI.GuiViewManager")
    dialogSlice           = module("Systems.NPC.CharacterDialogSlice")
end)
if not loadOk then BZ:Error("Init", "Module load failed: " .. tostring(loadErr), 6) return end
end

local components = {}
for _, name in {"Grill", "Fryer", "SodaMachine", "MilkShakeMachine", "AssemblingTable", "TrayCounter", "KelpShakeMachine", "OrbOfConfusionMachine"} do
    local ok, mod = pcall(module, "Systems.Workstation.Components." .. name .. "_ClientComponent")
    if ok then components[name] = mod end
end
for name, path in {
    Register = "Register.Components.Register", Customer = "NPC.Components.Customer", Table = "Table.Components.Table",
    TrashBin = "Workstation.Components.TrashBin", Dumpster = "Workstation.Components.Dumpster",
    ShiftClock = "Restaurant.Components.ShiftClock", Tray = "Restaurant.Components.Tray",
    OrderBoard = "Restaurant.Components.RestaurantOrderBoard", MopGiver = "Trash.Components.MopGiver", Puddle = "Trash.Components.Puddle",
    Plankton = "NPC.Components.Plankton",
    Villain = "NPC.Components.Villain", DirtyBubble = "NPC.Components.DirtyBubble", Dennis = "NPC.Components.Dennis",
    UpgradeTable = "Upgrade.Components.UpgradeTable", DutchmanVendor = "Dutchman.Components.DutchmanVendor",
    Extinguisher = "Fire.Components.FireExtinguisher", ExtinguisherVendor = "Fire.Components.FireExtinguisherVendor",
} do
    local ok, mod = pcall(module, "Systems." .. path .. "_ClientComponent")
    if ok then components[name] = mod end
end
do
    local okConch, MagicConch = pcall(module, "Components.MagicConch_ClientComponent")
    if okConch then components.MagicConch = MagicConch end
end

local function all(name) local c = components[name]; return c and c:GetAll() or {} end

local state = {
    Accept=false, Assemble=false, Bosses=false, Plankton=false, Troublemakers=false,
    Fire=false, Energy=false, Skip=false, NextShift=false,
    Upgrades=false, DutchmanDeals=true, Repair=false,
    EnergyThreshold = 50,
}
local session = {
    Generation=0, PendingTeleport=nil, PendingSip=nil, PendingClock=nil,
    PendingOrbClaim=nil, ManualUntil=0, CleaningRelease=nil,
    UpgradeBudget=nil, RepairBudget=nil,
}
local cooldowns = setmetatable({}, {__mode="k"})
local cleaningBoss, cleaningStarted, activeExtinguisher
local fireActive
local tickles = setmetatable({}, {__mode="k"})
local bossPayments = setmetatable({}, {__mode="k"})
local planktonShots = setmetatable({}, {__mode="k"})
local pendingRepairs = setmetatable({}, {__mode="k"})
local kickedPath, lastWarning = nil, 0

local function due(object, key) local t = cooldowns[object]; return not t or (t[key] or 0) <= os.clock() end
local function ready(object, key, delay)
    local t = cooldowns[object]; if not t then t = {} cooldowns[object] = t end
    if (t[key] or 0) > os.clock() then return false end
    t[key] = os.clock() + (delay or 0.8); return true
end
local function report(message)
    if os.clock() - lastWarning < 5 then return end
    lastWarning = os.clock(); warn("[STKK] " .. tostring(message))
end
local function awaitResult(callback)
    local ok, success, result = pcall(function()
        local promise = callback()
        if type(promise) == "table" and type(promise.await) == "function" then return promise:timeout(3):await() end
        return true, promise
    end)
    if not ok then report(success); return false end
    if success == false then report(result); return false end
    return result ~= false, result
end
local function invoke(object, key, callback, delay)
    if not ready(object, key, delay) then return false end
    return awaitResult(callback)
end
local function alive()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end
local function usable(component)
    if not component or component:IsDestroyed() then return false end
    local obj = component.Instance
    return obj and obj:IsDescendantOf(workspace) and obj:GetAttribute("Locked") ~= true
        and obj:GetAttribute("Disabled") ~= true and obj:GetAttribute("MischiefBlocked") ~= true
end

local function moveTo(target, standoff)
    local root = alive()
    if not root or not target or not target.Parent then return false end
    local part = target:IsA("Model") and (target:FindFirstChild("ProximityPart") or target.PrimaryPart) or target
    if not part then return false end
    local zone, zoneSize
    local zoneOwner = target
    for _ = 1, 4 do
        if zoneOwner and zoneOwner.GetAttribute then
            zone = zoneOwner:GetAttribute("ReachZoneCFrame")
            zoneSize = zoneOwner:GetAttribute("ReachZoneSize")
            if typeof(zone) == "CFrame" and typeof(zoneSize) == "Vector3" then break end
        end
        zoneOwner = zoneOwner and zoneOwner.Parent
    end
    local hasZone = typeof(zone) == "CFrame" and typeof(zoneSize) == "Vector3"
    local position = part:IsA("Attachment") and part.WorldPosition or part.Position
    local distance = (root.Position - position).Magnitude
    local localRoot = hasZone and zone:PointToObjectSpace(root.Position)
    local outsideZone = hasZone and (math.abs(localRoot.X) > zoneSize.X / 2 or math.abs(localRoot.Z) > zoneSize.Z / 2)
    if distance > (standoff and standoff + 2 or 4) or (standoff and distance < standoff - 1) or outsideZone then
        local desired = position + Vector3.new(0, 2, standoff or 3)
        if hasZone then
            local pt = zone:PointToObjectSpace(desired)
            local hX, hZ = math.max(0, zoneSize.X/2 - 0.5), math.max(0, zoneSize.Z/2 - 0.5)
            desired = zone:PointToWorldSpace(Vector3.new(math.clamp(pt.X,-hX,hX), pt.Y, math.clamp(pt.Z,-hZ,hZ)))
        end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {player.Character, target}
        local ground = workspace:Raycast(desired + Vector3.new(0,5,0), Vector3.new(0,-18,0), params)
        if ground then desired = Vector3.new(desired.X, ground.Position.Y + player.Character.Humanoid.HipHeight + root.Size.Y/2, desired.Z) end
        root.CFrame = CFrame.lookAt(desired, Vector3.new(position.X, desired.Y, position.Z) + Vector3.new(0.001,0,0))
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.12)
    end
    return alive() ~= nil
end

local moveLock, acceptWanted = false, false

local prompts = {}
for _, obj in workspace:GetDescendants() do if obj:IsA("ProximityPrompt") then prompts[obj] = true end end
workspace.DescendantAdded:Connect(function(o) if o:IsA("ProximityPrompt") then prompts[o] = true end end)
workspace.DescendantRemoving:Connect(function(o) prompts[o] = nil end)

local function firePrompt(prompt, validate)
    if not prompt.Parent or not ready(prompt, "Prompt", 1) then return false end
    local target = prompt.Parent:IsA("Attachment") and prompt.Parent.Parent or prompt.Parent
    local model = target:FindFirstAncestorOfClass("Model")
    if not moveTo(model and model:GetAttribute("ReachZoneCFrame") and model or target) then return false end
    local deadline = os.clock() + 0.3
    while prompt.Parent and not prompt.Enabled and os.clock() < deadline do task.wait(0.05) end
    if not prompt.Parent or not prompt.Enabled then return false end
    if validate and not validate() then return false end
    local ok, err = pcall(function() assert(type(fireproximityprompt)=="function","Prompt unavailable"); fireproximityprompt(prompt, prompt.HoldDuration) end)
    if not ok then report(err) end
    return ok
end

local function tools()
    local result, seen = {}, {}
    for _, c in {player.Character, player:FindFirstChildOfClass("Backpack")} do
        if c then for _, t in c:GetChildren() do if t:IsA("Tool") then seen[t]=true; table.insert(result,t) end end end
    end
    for _, list in {backpackSlice.State.HotbarContents(), backpackSlice.State.InventoryContents()} do
        for _, t in list do if typeof(t)=="Instance" and t:IsA("Tool") and not seen[t] then seen[t]=true; table.insert(result,t) end end
    end
    return result
end
local function findTool(reference)
    for _, t in tools() do
        if (t:GetAttribute("ReferenceName") or t.Name:match("^([%w]+)_[%x%-]+$") or t.Name) == reference then return t end
    end
end
local function hasInventoryRoom(amount)
    local inv = inventoryController:GetMatchInventory()
    return not inv or inv:CanAddItem(amount or 1)
end
local function equip(tool)
    if not tool or not alive() then return false end
    if tool.Parent ~= player.Character then backpack:EquipTool(tool); task.wait(0.08) end
    return tool.Parent == player.Character
end
local function energyValues()
    local cp = customPlayers:GetCustomPlayer()
    return cp and cp:GetAttribute("Energy"), cp and cp:GetAttribute("MaxEnergy")
end

local function ordered()
    local list, ranks = table.clone(restaurant.Actions.sortRestaurantOrders()), {}
    for i, o in list do ranks[o] = i end
    table.sort(list, function(a,b)
        local f, s = a.CustomerReference == grouperToolkit.Constants.ReferenceName, b.CustomerReference == grouperToolkit.Constants.ReferenceName
        if f ~= s then return f end
        return ranks[a] < ranks[b]
    end)
    return list
end
local function customer(id)
    for _, c in all("Customer") do if c.Instance:GetAttribute("NPCUid") == id then return c end end
end

local teleportLocations = {
    {"Cash Register", "Register", "EmployeeTarget"}, {"Kitchen", "AssemblingTable"}, {"Order Counter", "TrayCounter"},
    {"Free Kelp Shake", "KelpShakeMachine"}, {"Mop Rack", "MopGiver"}, {"Dumpster", "Dumpster"},
    {"Shift Clock", "ShiftClock"}, {"Upgrade Shop", "UpgradeTable"}, {"Flying Dutchman", "DutchmanVendor"},
}
local function queueTeleport(name)
    session.Generation += 1
    session.PendingTeleport = name
    session.ManualUntil = 0
    BZ:Notify({Title="Save the Krusty Krab", Content="Teleport queued: "..name, Duration=3})
end
local function teleportQueued()
    local name = session.PendingTeleport
    local root = alive()
    if not name or not root then return false end
    session.PendingTeleport = nil
    local origin, target, returning = root.CFrame, nil, name == "Previous Position"
    if returning then
        local saved = session.ReturnPosition
        if saved and saved.Character == player.Character then target = saved.CFrame end
    else
        for _, entry in teleportLocations do
            if entry[1] ~= name then continue end
            if entry[2] == "Dumpster" then
                for _, obj in CollectionService:GetTagged("Dumpster") do if obj:IsDescendantOf(workspace) then target = obj break end end
            else
                for _, comp in all(entry[2]) do
                    local obj = comp.Instance
                    if not obj:IsDescendantOf(workspace) or comp:IsDestroyed() then continue end
                    if entry[2] == "UpgradeTable" and obj:GetAttribute("Open") ~= true then continue end
                    if entry[2] == "DutchmanVendor" and obj:GetAttribute("Mode") ~= "Vendor" then continue end
                    target = entry[3] and obj:FindFirstChild(entry[3]) or obj
                    break
                end
            end
            break
        end
    end
    if not target then return false end
    if returning then
        root.CFrame = target
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    else
        if not moveTo(target) then return false end
    end
    session.ReturnPosition = {Character = player.Character, CFrame = origin}
    session.ManualUntil = os.clock() + 5
    return true
end

local WORK_COOLDOWN = 4
local function startWorking(obj)
    if registerSlice.State.WorkingRegisterId() ~= nil then return false end
    if not ready(obj, "StartWork", WORK_COOLDOWN) then return false end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and d.ActionText:lower():find("work") then
            return firePrompt(d)
        end
    end
    return false
end

local function runAccept(register)
    local obj = register.Instance
    local function working() return registerSlice.State.WorkingRegisterId() == obj:GetAttribute("RegisterUID") end
    if not working() then
        if registerSlice.State.WorkingRegisterId() ~= nil or not startWorking(obj) then return false end
        task.wait(0.3)
        if not working() then return false end
    end
    if not moveTo(obj:FindFirstChild("EmployeeTarget") or obj) or not working() then return false end
    local deadline, sent = os.clock() + 3, false
    while state.Accept and os.clock() < deadline and tableToolkit.AreSeatsAvailable() do
        local correct = registerSlice.State.CorrectMenuItem()
        if correct and working() then
            registerSlice.Signals.MenuItemSelected:Fire(correct)
            sent = true
            task.wait(0.06)
        elseif sent then break
        else task.wait(0.05) end
    end
    return sent
end

local function acceptOrder()
    if not tableToolkit.AreSeatsAvailable() then acceptWanted = false return false end
    for _, register in all("Register") do
        local obj = register.Instance
        if usable(register) and obj:GetAttribute("HasCustomers") and due(register, "Accept") then
            local workingId = registerSlice.State.WorkingRegisterId()
            if workingId ~= nil and workingId ~= obj:GetAttribute("RegisterUID") then continue end
            if workingId == nil and not due(obj, "StartWork") then continue end
            if moveLock then acceptWanted = true return false end
            acceptWanted = false
            ready(register, "Accept", 0.3)
            moveLock = true
            local ok, sent = pcall(runAccept, register)
            moveLock = false
            if not ok then report(sent) return false end
            return sent
        end
    end
    acceptWanted = false
    return false
end

local function autoAssemble()
    if not alive() then return false end
    for _, order in ordered() do
        if order.OrderStatus ~= "Pending" and order.OrderStatus ~= "Preparing" then continue end
        if order.WorkingPlayerId and order.WorkingPlayerId ~= player.UserId then continue end
        local stock = workstation.State.AssemblingTableStash()
        local canMake, items = true, {}
        for _, item in order.OrderItems do
            for _, ref in item.Ingredients or {item.ReferenceName} do
                if not restaurantToolkit.isInfiniteIngredient(ref) and (stock[ref] or 0) < 1 then canMake = false end
            end
            table.insert(items, {
                ReferenceName = item.ReferenceName, Finished = true,
                Metadata = {Ingredients = item.Ingredients and table.clone(item.Ingredients)}
            })
        end
        if not canMake then continue end
        for _, station in all("AssemblingTable") do
            if usable(station) and station:IsClean() and (station.Instance:GetAttribute("AvailableSlots") or 0) > 0 and due(station, "Assemble") then
                if not state.Assemble then return false end
                local live = restaurant.State.RestaurantOrders()[order.OrderId]
                if not live or (live.OrderStatus ~= "Pending" and live.OrderStatus ~= "Preparing") then return false end
                if live.WorkingPlayerId and live.WorkingPlayerId ~= player.UserId then return false end
                if not order.WorkingPlayerId then
                    local board = all("OrderBoard")[1]
                    if board and not invoke(board, order.OrderId, function() return board.Server:DeclareRestaurantOrderIntention(order.OrderId) end) then return false end
                end
                return invoke(station, "Assemble", function() return station.Server:AttemptToAssemble(items, order.OrderId) end, 0.3)
            end
        end
    end
    return false
end

local function bossModel(boss) return boss._visualModel or boss.Instance:FindFirstChild("VisualModel") or boss.Instance end
local function bossEnded(obj) return obj:GetAttribute("Defeated")==true or obj:GetAttribute("Departing")==true or obj:GetAttribute("Stopped")==true or obj:GetAttribute("IsCleaned")==true or obj:GetAttribute("Confused")==true end

local function stopBossCleaning()
    local boss = cleaningBoss; cleaningBoss, cleaningStarted = nil, nil
    if boss and not boss:IsDestroyed() then
        local token = {}; session.CleaningRelease = token
        task.spawn(function()
            awaitResult(function() return boss.Server:SetCleaning(false) end)
            if session.CleaningRelease == token then session.CleaningRelease = nil end
        end)
    end
end
local function stopExtinguishing()
    local item = activeExtinguisher; activeExtinguisher = nil
    if item and not item:IsDestroyed() then
        item:RemoveTask("ShootTask")
        local tool = item:GetTool(); if tool then tool:Deactivate() end
    end
end

local function escapeBosses()
    for _, boss in all("DirtyBubble") do
        if usable(boss) and boss.Instance:GetAttribute("CapturedPlayerId") == player.UserId then
            stopBossCleaning(); stopExtinguishing()
            invoke(boss, "EscapeBoss", function() return boss.Server:EscapeBubble() end, 0.5)
            return true
        end
    end
    return false
end

local function useBossOrb(boss)
    local orb = findTool("OrbOfConfusion")
    if not orb and orbToolkit.isRecharged(player:GetAttribute("OrbOfConfusionReadyDay")) then orb = findTool("RechargingOrbOfConfusion") end
    if orb then
        session.PendingOrbClaim = nil
        if ready(orb, "UseBossOrb", 3) and equip(orb) and moveTo(bossModel(boss), 8) and state.Bosses then
            if usable(boss) and not bossEnded(boss.Instance) then orb:Activate(); return true, true end
        end
        return false, true
    end
    local claim = session.PendingOrbClaim
    if claim then
        local machine = claim.Machine
        local occupant = not machine:IsDestroyed() and machine.Instance:GetAttribute("OccupantId")
        if not machine:IsDestroyed() and (occupant == player.UserId or not occupant and os.clock() - claim.SentAt < 5) then return false, true end
        session.PendingOrbClaim = nil
    end
    for _, machine in all("OrbOfConfusionMachine") do
        local pending = cooldowns[machine]
        if usable(machine) and machine.Instance:GetAttribute("OccupantId") == player.UserId
            and orbToolkit.isRecharged(player:GetAttribute("OrbOfConfusionReadyDay")) and orbToolkit.isRecharged(machine._remotes.ReadyDay:Get())
            and pending and (pending.ClaimBossOrb or 0) > os.clock() then return false, true end
        if hasInventoryRoom() and usable(machine) and machine.Instance:GetAttribute("Unlocked") == true and not machine.Instance:GetAttribute("OccupantId")
            and orbToolkit.isRecharged(machine._remotes.ReadyDay:Get()) and due(machine, "ClaimBossOrb") and moveTo(machine.Instance) then
            if not ready(machine, "ClaimBossOrb", 3) then return false, false end
            session.PendingOrbClaim = {Machine = machine, SentAt = os.clock()}
            local claimed, result = awaitResult(function() return machine._remotes:AttemptClaimOrb() end)
            if not claimed and result == false then session.PendingOrbClaim = nil end
            return claimed, session.PendingOrbClaim ~= nil
        end
    end
    return false, false
end

session.Gun = {Name = nil, Start = setmetatable({}, {__mode="k"}), Blocked = setmetatable({}, {__mode="k"})}
session.Gun.Words = {"watergun", "water", "squirt", "soak", "splash", "hose", "pistol", "blaster"}
session.Gun.Price = 150

session.Gun.IsUpgrade = function(reference, data)
    local text = (tostring(reference) .. " " .. tostring(data and (data.DisplayName or data.Name) or "")):lower()
    return (text:find("water", 1, true) and text:find("gun", 1, true)) ~= nil or text:find("squirt", 1, true) ~= nil
end

session.Gun.Find = function()
    local G = session.Gun
    for _, t in tools() do
        local ref = tostring(t:GetAttribute("ReferenceName") or t.Name)
        if G.Name and ref == G.Name then return t end
        local vm = t:FindFirstChild("VisualModel")
        if vm and vm:FindFirstChild("pCylinder7", true) then return t end
        if not G.Name then
            local hay = {ref:lower()}
            for _, v in t:GetAttributes() do
                if type(v) == "string" then table.insert(hay, v:lower()) end
            end
            for _, text in hay do
                for _, w in G.Words do
                    if text:find(w, 1, true) then return t end
                end
            end
        end
    end
end

session.Gun.Use = function(boss)
    local G = session.Gun
    local gun = G.Find()
    if not gun then return false, false end
    local now = os.clock()
    if (G.Blocked[boss] or 0) > now then return false, false end
    local started = G.Start[boss]
    if started and now - started > 15 then
        G.Start[boss] = nil
        G.Blocked[boss] = now + 20
        return false, false
    end
    if not ready(gun, "UseBossGun", 0.35) then return false, true end
    local model = bossModel(boss)
    if not equip(gun) or not moveTo(model, 8) or not state.Bosses then return false, true end
    if not usable(boss) or bossEnded(boss.Instance) then return false, false end
    local pos = model:IsA("Model") and model:GetPivot().Position or (model:IsA("BasePart") and model.Position)
    local cam = workspace.CurrentCamera
    if not pos or not cam then return false, false end

    local v, onScreen = cam:WorldToViewportPoint(pos)
    if not onScreen then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos)
        v = cam:WorldToViewportPoint(pos)
    end
    local size = cam.ViewportSize
    local x, y = math.clamp(v.X, 1, size.X - 1), math.clamp(v.Y, 1, size.Y - 1)
    G.Start[boss] = G.Start[boss] or now
    local okInput = pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseMoveEvent(x, y, game)
        vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
        vim:SendTouchEvent(77, 0, x, y)
        task.wait(0.05)
        vim:SendTouchEvent(77, 2, x, y)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
    if not okInput then gun:Activate() end
    return true, true
end

local function defeatBosses(quickOnly)
    if not state.Bosses then return false end
    if quickOnly then
        local orbTarget, orbPriority = nil, -1
        for _, boss in all("Villain") do
            if usable(boss) and not bossEnded(boss.Instance) then
                local name = boss.Instance:GetAttribute("ReferenceName")
                if name == "HashSlingingSlasher" then continue end
                if name == "TattletaleStrangler" then
                    for _, officer in CollectionService:GetTagged("PoliceOfficer") do
                        local target = officer:FindFirstChild("Strangler")
                        local prompt = officer:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if officer:IsDescendantOf(workspace) and target and target.Value == boss.Instance and prompt and prompt.Enabled and due(prompt, "Prompt") then
                            if firePrompt(prompt) then return true end
                        end
                    end
                end
                if name ~= "Plankton" and name ~= "DirtyBubble" and name ~= "MiniDirtyBubble" then
                    local priority = name == "ManRay" and 3 or name == "Dennis" and 2 or 1
                    if priority > orbPriority then orbTarget, orbPriority = boss, priority end
                end
            end
        end
        local orbAvailable = false
        if orbTarget then
            local used; used, orbAvailable = useBossOrb(orbTarget)
            if used then return true end
            if not orbAvailable then
                local shot, gunAvailable = session.Gun.Use(orbTarget)
                if shot then return true end
                orbAvailable = gunAvailable
            end
        end
        if not orbAvailable then
            for _, boss in all("Dennis") do
                if not bossPayments[boss] and usable(boss) and not bossEnded(boss.Instance)
                    and workspace:GetServerTimeNow() >= (boss.Instance:GetAttribute("BribeableAt") or math.huge)
                    and restaurant.Actions.getBalance(player) >= dennisToolkit.getBounty() and due(boss, "DennisPayoff") and moveTo(bossModel(boss), 9) then
                    local bounty = dennisToolkit.getBounty()
                    if not state.Bosses or not usable(boss) or bossEnded(boss.Instance) then return false end
                    bossPayments[boss] = true
                    local success, paid = awaitResult(function() return boss.Server:AttemptPayOff() end)
                    if not success and paid == false then bossPayments[boss] = nil end
                    return success
                end
            end
        end
        return false
    end
    if cleaningBoss then
        local boss = cleaningBoss
        local obj = boss.Instance
        if not usable(boss) or bossEnded(obj) or obj:GetAttribute("Airborne") == true or os.clock() - cleaningStarted > 20 then
            stopBossCleaning()
        else
            local mop = findTool("Mop") or findTool("InstaMop")
            if not mop or not equip(mop) or not moveTo(bossModel(boss), 8) then stopBossCleaning() return false end
            if obj:GetAttribute("BeingCleaned") ~= true then invoke(boss, "CleanBoss", function() return boss.Server:SetCleaning(true) end, 1) end
            return true
        end
    end
    for _, boss in all("DirtyBubble") do
        local obj = boss.Instance
        if usable(boss) and not bossEnded(obj) and obj:GetAttribute("Settled") == true and obj:GetAttribute("Airborne") ~= true then
            local mop = findTool("Mop") or findTool("InstaMop")
            if not mop then
                local giver = all("MopGiver")[1]
                if giver and hasInventoryRoom() and due(giver, "BossMop") and moveTo(giver.Instance) then return invoke(giver, "BossMop", function() return giver.Server:TakeMop() end) end
            elseif due(boss, "CleanBoss") and equip(mop) and moveTo(bossModel(boss), 8) then
                if invoke(boss, "CleanBoss", function() return boss.Server:SetCleaning(true) end, 1) then
                    cleaningBoss, cleaningStarted = boss, os.clock()
                    return true
                end
            end
        end
    end
    return false
end

local function mopNeeded()
    for _, p in all("Puddle") do if usable(p) then return true end end
    if state.Bosses then for _, b in all("DirtyBubble") do if usable(b) and not bossEnded(b.Instance) then return true end end end
    return false
end
local function busyCleaning()
    for _, n in {"Table","Puddle","Grill","Fryer","SodaMachine","MilkShakeMachine","AssemblingTable","TrayCounter"} do
        for _, c in all(n) do if c.Instance:GetAttribute("CleaningPlayer") == player.UserId then return true end end
    end
    return false
end
local function returnMop(force)
    if not (force or state.Clean or state.Bosses) then return false end
    local mop = findTool("Mop") or findTool("InstaMop")
    if not mop or mopNeeded() or cleaningBoss or session.CleaningRelease or busyCleaning() then session.MopIdleSince = nil return false end
    session.MopIdleSince = session.MopIdleSince or os.clock()
    if os.clock() - session.MopIdleSince < 0.5 then return false end
    for _, giver in all("MopGiver") do
        if not usable(giver) or giver._processingRequest or not due(giver, "MopReturn") then continue end
        if not moveTo(giver.Instance) or mopNeeded() or busyCleaning() then return false end
        if not findTool("Mop") and not findTool("InstaMop") then return false end
        return invoke(giver, "MopReturn", function() return giver.Server:ReturnMop() end, 3)
    end
    return false
end

local exitNodes = {}
do
    local folder = workspace:FindFirstChild("_PERSISTENT")
    for _, n in {"Villains","Plankton","PlanktonExitNodes"} do folder = folder and folder:FindFirstChild(n) end
    if folder then for _, n in folder:GetDescendants() do if n:IsA("BasePart") then table.insert(exitNodes, n) end end end
end
local PK = {Goal = Vector3.new(38.68, 3.00, 137.78)}
function PK.goalPosition(goal)
    if goal then
        local ok, box = pcall(planktonToolkit.getGoalBox, goal)
        if ok and box then return box.Position end
    end
    return PK.Goal
end
function PK.route(position, goalPos)
    local points = {position}
    if not kickedPath then kickedPath = game:GetService("PathfindingService"):CreatePath({AgentRadius=1.6, AgentHeight=3, AgentCanJump=false, WaypointSpacing=8}) end
    local ok = pcall(function() kickedPath:ComputeAsync(position, goalPos) end)
    if ok and kickedPath.Status == Enum.PathStatus.Success then
        for _, step in kickedPath:GetWaypoints() do
            table.insert(points, Vector3.new(step.Position.X, position.Y, step.Position.Z))
        end
    end
    table.insert(points, Vector3.new(goalPos.X, position.Y, goalPos.Z))
    local suffix = table.create(#points, 0)
    for i = #points - 1, 1, -1 do suffix[i] = suffix[i + 1] + (points[i + 1] - points[i]).Magnitude end
    return {points = points, suffix = suffix}
end
function PK.cost(route, point)
    local flat, best = Vector3.new(1, 0, 1), nil
    for i = 1, #route.points - 1 do
        local a = route.points[i]
        local ab = (route.points[i + 1] - a) * flat
        local len2 = ab:Dot(ab)
        local t = len2 > 0 and math.clamp(((point - a) * flat):Dot(ab) / len2, 0, 1) or 0
        local lateral = ((point - (a + ab * t)) * flat).Magnitude
        local cost = (1 - t) * math.sqrt(len2) + route.suffix[i + 1] + lateral * 2
        if not best or cost < best then best = cost end
    end
    return best or 0
end
local function planktonClear(position, target, params)
    local lift = Vector3.new(0, 0.15, 0)
    local hit = workspace:Spherecast(position + lift, planktonToolkit.Constants.Diameter/2 - 0.08, target - position, params)
    return not hit or hit.Normal.Y > 0.7
end
local function planktonTarget(position, goal, params)
    local goalPos = PK.goalPosition(goal)
    local target = Vector3.new(goalPos.X, position.Y, goalPos.Z)
    if planktonClear(position, target, params) then return target end
    if not kickedPath then kickedPath = game:GetService("PathfindingService"):CreatePath({AgentRadius=1.6, AgentHeight=3, AgentCanJump=false, WaypointSpacing=8}) end
    local ok = pcall(function() kickedPath:ComputeAsync(position, goalPos) end)
    local waypoint
    if ok and kickedPath.Status == Enum.PathStatus.Success then
        for _, step in kickedPath:GetWaypoints() do
            local point = Vector3.new(step.Position.X, position.Y, step.Position.Z)
            if (point - position).Magnitude > 3 then
                if not planktonClear(position, point, params) then break end
                waypoint = point
            end
        end
    end
    if waypoint then return waypoint end
    local best, score
    for _, node in exitNodes do
        if node.Parent then
            local point = Vector3.new(node.Position.X, position.Y, node.Position.Z)
            local distance = (point - position).Magnitude
            local cost = (point - target).Magnitude + distance * 0.05
            if distance > 4 and (not score or cost < score) and planktonClear(position, point, params) then best, score = point, cost end
        end
    end
    return best or target
end
local function standForPlankton(npc, direction, range)
    local root = alive()
    if not root then return false end
    local obj, position = npc.Instance, npc.Instance.PrimaryPart.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {obj, player.Character, workspace.CurrentCamera}
    params.RespectCanCollide = true; params.CollisionGroup = root.CollisionGroup
    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = params.FilterDescendantsInstances
    overlap.RespectCanCollide = true; overlap.CollisionGroup = root.CollisionGroup; overlap.MaxParts = 1
    for _, distance in {range > 5 and 4.5 or 3, 3.5} do
        for _, angle in {0,-40,40,-80,80} do
            local away = CFrame.Angles(0, math.rad(angle), 0):VectorToWorldSpace(direction)
            local stand = position - away * distance
            local ground = workspace:Raycast(stand + Vector3.new(0,7,0), Vector3.new(0,-24,0), params)
            if not ground then continue end
            stand = Vector3.new(stand.X, ground.Position.Y + player.Character.Humanoid.HipHeight + root.Size.Y/2, stand.Z)
            if (stand - position).Magnitude > range - 0.3 then continue end
            local facing = CFrame.lookAt(stand, stand + direction)
            if #workspace:GetPartBoundsInBox(facing, Vector3.new(2.2,2.5,2.2), overlap) > 0 then continue end
            root.CFrame = facing
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.12)
            return root == alive() and usable(npc) and (root.Position - obj.PrimaryPart.Position).Magnitude <= range
        end
    end
    return false
end
local function planktonOpenness(point, params)
    local blocked = 0
    for i = 0, 5 do
        local a = math.rad(i * 60)
        if not planktonClear(point, point + Vector3.new(math.cos(a), 0, math.sin(a)) * 3.5, params) then blocked += 1 end
    end
    return blocked
end
local function planktonShot(position, target, goal, params, failures, route)
    local base = planktonToolkit.getKickDirection(target - position); if not base then return nil end
    local list = {}
    for _, angle in {0,-40,40,-80,80,-120,120,180} do
        local direction = CFrame.Angles(0, math.rad(angle), 0):VectorToWorldSpace(base)
        for _, power in {0,0.25,0.5,0.75,1} do
            local velocity = planktonToolkit.getKickVelocity(direction, power)
            local points = planktonToolkit.predictPath(position, velocity, params)
            local last, scored = points[#points], false
            if goal then for _, p in points do if planktonToolkit.isInGoal(goal, p) then scored = true break end end end
            local landing = Vector3.new(last.X, position.Y, last.Z)
            local moved = (landing - position).Magnitude
            local score = (route and PK.cost(route, landing) or (landing - target).Magnitude) + math.abs(last.Y - position.Y) * 0.3
            if moved < 2 then score += 40 end
            if scored then score -= 200 end
            for _, f in failures do if direction:Dot(f.Direction) > 0.9 and power <= f.Power + 0.15 then score += 300 end end
            if scored and #failures == 0 then return {{Power = power, Direction = direction, Score = score}} end
            if not scored and moved >= 2 then
                local blocked = planktonOpenness(landing, params)
                score += blocked * 10
                if blocked >= 3 then score += 60 end
                if planktonClear(landing, target, params) then score -= 20 end
            end
            table.insert(list, {Power = power, Direction = direction, Score = score})
        end
        task.wait()
    end
    table.sort(list, function(x, y) return x.Score < y.Score end)
    local top = {}
    for i = 1, math.min(4, #list) do top[i] = list[i] end
    return top
end
local function kickPlankton(urgentOnly)
    if not (state.Plankton or state.Bosses) then return false end
    local goal = planktonToolkit.findGoal()
    for _, npc in all("Plankton") do
        local obj, part = npc.Instance, npc.Instance.PrimaryPart
        if not usable(npc) or not part or obj:GetAttribute("EscapedWithFormula") == true then continue end
        local rec = planktonShots[npc]; if not rec then rec = {Failures={}} planktonShots[npc] = rec end
        local scored = obj:GetAttribute("GoalScoredAt")
        if type(scored)=="number" and scored > 0 then continue end
        if obj:GetAttribute("Kicked") == true then continue end
        local ball = obj:GetAttribute("Ball") == true
        local escaping = obj:GetAttribute("HasFormula") == true and obj:GetAttribute("Stopped") ~= true
        if urgentOnly and (ball or not escaping) then continue end
        if not ball then
            if escaping and ready(npc, "StopAim", 1) then
                local target = PK.goalPosition(goal)
                local direction = planktonToolkit.getKickDirection(target - part.Position)
                if direction and standForPlankton(npc, direction, 4.8) then
                    return invoke(npc, "Stop", function() return npc.Server:Kick(nil, direction) end, 1)
                end
            end
            continue
        end
        local position, now = part.Position, os.clock()
        local velocity = part.AssemblyLinearVelocity
        local speed = (velocity * Vector3.new(1,0,1)).Magnitude
        if rec.LastPosition and now > rec.LastTime then
            speed = math.max(speed, ((position - rec.LastPosition) * Vector3.new(1,0,1)).Magnitude / (now - rec.LastTime))
        end
        rec.LastPosition, rec.LastTime = position, now
        local route
        local shot = rec.Shot
        if shot then
            shot.Moved = math.max(shot.Moved, ((position - shot.Position) * Vector3.new(1,0,1)).Magnitude)
            if now - shot.Time < 1 or speed > 5 or math.abs(velocity.Y) > 7 then continue end
            route = PK.route(position, PK.goalPosition(goal))
            local progressed = shot.Remain and PK.cost(route, position) < shot.Remain - 2
            if ((position - shot.Position) * Vector3.new(1,0,1)).Magnitude < 2 or not progressed then
                table.insert(rec.Failures, {Direction=shot.Direction, Power=shot.Power})
                if #rec.Failures > 4 then table.remove(rec.Failures, 1) end
            else table.clear(rec.Failures) end
            rec.Shot = nil
        end
        if speed > 5 or math.abs(velocity.Y) > 7 or not ready(npc, "Aim", 0.8) then continue end
        local params = planktonToolkit.newRayParams({obj, player.Character, workspace.CurrentCamera})
        local target = planktonTarget(position, goal, params)
        route = route or PK.route(position, PK.goalPosition(goal))
        local shots = planktonShot(position, target, goal, params, rec.Failures, route)
        if not shots or #shots == 0 or not (state.Plankton or state.Bosses) then return false end
        local power, direction
        for _, shot in shots do
            if (part.Position - position).Magnitude > 2 then break end
            if standForPlankton(npc, shot.Direction, 7.5) then power, direction = shot.Power, shot.Direction break end
        end
        if direction then
            rec.NoStand = 0
        else
            rec.NoStand = (rec.NoStand or 0) + 1
            local root = alive()
            if rec.NoStand >= 3 and root and (root.Position - part.Position).Magnitude <= 7.5 then
                power, direction = shots[1].Power, shots[1].Direction
            else
                continue
            end
        end
        if not (state.Plankton or state.Bosses) or obj:GetAttribute("Ball") ~= true or obj:GetAttribute("Kicked") == true then return false end
        if not ready(npc, "Kick", 1) then continue end
        rec.Shot = {Position=part.Position, Time=os.clock(), Count=obj:GetAttribute("BallKicks") or 0, Direction=direction, Power=power, Moved=0, Remain=PK.cost(route, part.Position)}
        awaitResult(function() return npc.Server:Kick(power, direction) end)
        return true
    end
    return false
end

local function removalAction(obj)
    local action = obj:GetAttribute("CustomerAction")
    if action == "Leaving" then return nil end
    if obj:GetAttribute("ReferenceName") == "BubbleBass" and action == "TickleReady" and (obj:GetAttribute("TickleChances") or 1) > 0 then return "Tickle" end
    if action == "Squatting" then return "KickOutSquatter" end
    if npcToolkit.isNuisance(obj) then return "Shoo" end
end
local function removeTroublemakers()
    for _, npc in all("Customer") do
        if not usable(npc) then tickles[npc] = nil continue end
        local action, pending = removalAction(npc.Instance), tickles[npc]
        if pending then
            local phase = npc.Instance:GetAttribute("CustomerAction")
            if phase == "Tickling" and due(npc, "FinishTickle") and moveTo(npc:GetVisualModel() or npc.Instance) then
                invoke(npc, "FinishTickle", function() return npc.Server:BehaviorAction("FinishTickle", true) end, 2)
                return true
            elseif phase ~= "Tickling" and phase ~= "TickleReady" then
                tickles[npc] = nil
            elseif os.clock() - pending > 5 and phase == "TickleReady" then tickles[npc] = nil end
        elseif action == "Tickle" and ready(npc, "Tickle", 3) then
            if not moveTo(npc:GetVisualModel() or npc.Instance) or removalAction(npc.Instance) ~= "Tickle" then continue end
            tickles[npc] = os.clock()
            local success, started = awaitResult(function() return npc.Server:BehaviorAction("StartTickle") end)
            if not success and started == false then tickles[npc] = nil end
            if success and started == true and state.Troublemakers then
                if ready(npc, "FinishTickle", 2) then awaitResult(function() return npc.Server:BehaviorAction("FinishTickle", true) end) end
            end
            return true
        elseif action and action ~= "Tickle" and due(npc, "Remove") and type(npc.Server[action]) == "function" then
            if moveTo(npc:GetVisualModel() or npc.Instance) and removalAction(npc.Instance) == action then
                return invoke(npc, "Remove", function() return npc.Server[action](npc.Server) end, 2)
            end
        end
    end
    return false
end

local fires = {}
for _, o in CollectionService:GetTagged("Fire") do fires[o] = true end
CollectionService:GetInstanceAddedSignal("Fire"):Connect(function(o) fires[o] = true end)
CollectionService:GetInstanceRemovedSignal("Fire"):Connect(function(o) fires[o] = nil end)

local function firePosition(object)
    if object:IsA("BasePart") then return object, object.Position end
    if object:IsA("Attachment") then return object, object.WorldPosition end
    if object:IsA("Model") then return object, object:GetPivot().Position end
    local parent = object:FindFirstAncestorWhichIsA("BasePart") or object:FindFirstAncestorOfClass("Model")
    if parent then return parent, parent:IsA("Model") and parent:GetPivot().Position or parent.Position end
end
local function ownedExtinguisher()
    local blue
    for _, item in all("Extinguisher") do
        if item:IsDestroyed() or item:GetOwner() ~= player or not item:GetTool() then continue end
        if item:GetBaseData().ReferenceName == "FireExtinguisher" then return item end
        if (item:GetAttribute("Charge") or 0) >= 1 then blue = item end
    end
    return blue
end
local function aimAtFire(object, point, distance)
    local root = alive(); if not root then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, object, workspace.CurrentCamera}
    params.RespectCanCollide = true; params.CollisionGroup = root.CollisionGroup
    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = params.FilterDescendantsInstances
    overlap.RespectCanCollide = true; overlap.CollisionGroup = root.CollisionGroup; overlap.MaxParts = 1
    local best, score
    local reach = math.min(14, distance * 0.7)
    for _, offset in {Vector3.new(0,0,reach),Vector3.new(0,0,-reach),Vector3.new(reach,0,0),Vector3.new(-reach,0,0)} do
        local stand = point + offset
        local ground = workspace:Raycast(stand + Vector3.new(0,7,0), Vector3.new(0,-24,0), params)
        if not ground then continue end
        stand = Vector3.new(stand.X, ground.Position.Y + player.Character.Humanoid.HipHeight + root.Size.Y/2, stand.Z)
        if math.abs(stand.Y - point.Y) > 6 or (stand - point).Magnitude > distance - 2 then continue end
        local obstruction = workspace:Raycast(stand, point - stand, params)
        if obstruction and (obstruction.Position - point).Magnitude > 6 then continue end
        local facing = CFrame.lookAt(stand, Vector3.new(point.X, stand.Y, point.Z))
        if #workspace:GetPartBoundsInBox(facing, Vector3.new(2.2,2.5,2.2), overlap) > 0 then continue end
        local gap = (root.Position - stand).Magnitude
        if not score or gap < score then best, score = facing, gap end
    end
    if not best then return false end
    root.CFrame = best
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    if score > 1 then task.wait(0.12) end
    return root == alive()
end
local function extinguishFires(activeOnly)
    if not state.Fire then return false end
    local root = alive(); if not root then return false end
    local target, targetFire, point, nearest, burning
    for obj in fires do
        if not obj:IsDescendantOf(workspace) or obj:GetAttribute("Extinguished") == true or (obj:IsA("Fire") and not obj.Enabled) then continue end
        burning = true
        local anchor, position = firePosition(obj)
        if not position then continue end
        local gap = (position - root.Position).Magnitude
        if not nearest or gap < nearest then target, targetFire, point, nearest = anchor, obj, position, gap end
    end
    local ownedVendor, availableVendor
    for _, v in all("ExtinguisherVendor") do
        if not usable(v) then continue end
        local occ = v.Instance:GetAttribute("OccupantId")
        if occ == player.UserId then ownedVendor = v end
        if not occ and (v.Instance:GetAttribute("CurrentCharge") or 0) >= 1 then availableVendor = v end
    end
    if not burning then
        if fireActive then fireActive = false end
        local prevTool = activeExtinguisher and not activeExtinguisher:IsDestroyed() and activeExtinguisher:GetTool()
        stopExtinguishing()
        if prevTool and prevTool.Parent == player.Character then backpack:UnequipTools() end
        if activeOnly then return false end
        return false
    end
    if not target then return false end
    stopBossCleaning()
    local item = ownedExtinguisher()
    if not item then
        if not hasInventoryRoom() or ownedVendor or not availableVendor or not ready(availableVendor, "FireTake", 2) or not moveTo(availableVendor.Instance)
            or not state.Fire or availableVendor.Instance:GetAttribute("OccupantId") then return false end
        local success = awaitResult(function() return availableVendor.Server:TakeExtinguisher() end)
        local deadline = os.clock() + 2
        while state.Fire and success and not ownedExtinguisher() and os.clock() < deadline do task.wait(0.1) end
        return ownedExtinguisher() ~= nil
    end
    if (item:GetAttribute("Charge") or 0) < 1 then stopExtinguishing() return false end
    if not due(item, "FireShot") or not item:_CanShoot() then return fireActive end
    local tool = item:GetTool()
    if not tool or not equip(tool) then return false end
    activeExtinguisher = item
    item:RemoveTask("ShootTask")
    local data = item:GetBaseData()
    if not aimAtFire(target, point, data.FireDistance or 20) or not target.Parent or not state.Fire then return false end
    if not fires[targetFire] or not targetFire:IsDescendantOf(workspace) or targetFire:GetAttribute("Extinguished") == true then return false end
    if not item:_CanShoot() then return true end
    invoke(item, "FireShot", function() return item.Server:Shoot() end, math.max(0.2, data.FireRate or 0.2))
    return true
end
local function fireThreat(nearOnly)
    if not state.Fire then return false end
    local root = alive(); if not root then return false end
    local burning = false
    for obj in fires do
        if obj:IsDescendantOf(workspace) and obj:GetAttribute("Extinguished") ~= true and (not obj:IsA("Fire") or obj.Enabled) then
            local _, point = firePosition(obj)
            if point and (not nearOnly or (point - root.Position).Magnitude <= 12) then burning = true break end
        end
    end
    if not burning then return false end
    local item = ownedExtinguisher()
    if item and (item:GetAttribute("Charge") or 0) >= 1 then return true end
    if not hasInventoryRoom() then return false end
    for _, v in all("ExtinguisherVendor") do
        if usable(v) and not v.Instance:GetAttribute("OccupantId") and (v.Instance:GetAttribute("CurrentCharge") or 0) >= 1 and due(v, "FireTake") then return true end
    end
    return false
end

local PRIORITY_STUCK = 60
local PRIORITY_RELEASE = 8
local function priorityThreat(skipBosses)
    if state.Bosses and not skipBosses then
        for _, boss in all("Villain") do
            if usable(boss) and boss.Instance:GetAttribute("ReferenceName") ~= "HashSlingingSlasher" and not bossEnded(boss.Instance) then return true end
        end
        for _, boss in all("DirtyBubble") do
            if usable(boss) and not bossEnded(boss.Instance) then return true end
        end
    end
    if (state.Plankton or state.Bosses) and not skipBosses then
        for _, npc in all("Plankton") do
            local obj = npc.Instance
            if usable(npc) and obj:GetAttribute("EscapedWithFormula") ~= true and obj:GetAttribute("Kicked") ~= true and (obj:GetAttribute("GoalScoredAt") or 0) <= 0
                and (obj:GetAttribute("Ball") == true or (obj:GetAttribute("HasFormula") == true and obj:GetAttribute("Stopped") ~= true)) then return true end
        end
    end
    if state.Troublemakers then
        for _, npc in all("Customer") do
            if usable(npc) and (tickles[npc] or removalAction(npc.Instance)) then return true end
        end
    end
    if state.Fire then
        for obj in fires do
            if obj:IsDescendantOf(workspace) and obj:GetAttribute("Extinguished") ~= true and (not obj:IsA("Fire") or obj.Enabled) then return true end
        end
    end
    return false
end

session.PriorityCaches = {}
local function priorityBusy(skipBosses)
    local now = os.clock()
    local idx = skipBosses and 2 or 1
    local cache = session.PriorityCaches[idx]
    if not cache then cache = {t = 0, v = false}; session.PriorityCaches[idx] = cache end
    if now - cache.t < 0.1 then return cache.v end
    cache.t = now
    local sinceKey = skipBosses and "PrioritySinceNB" or "PrioritySince"
    local releaseKey = skipBosses and "PriorityReleaseUntilNB" or "PriorityReleaseUntil"
    local busy = false
    if session[releaseKey] and now < session[releaseKey] then
        busy = false
    else
        local ok, threat = pcall(priorityThreat, skipBosses)
        if not ok then report(threat); threat = false end
        if not threat then
            session[sinceKey] = nil
        else
            session[sinceKey] = session[sinceKey] or now
            if now - session[sinceKey] > PRIORITY_STUCK then
                session[sinceKey] = nil
                session[releaseKey] = now + PRIORITY_RELEASE
            else busy = true end
        end
    end
    cache.v = busy
    return busy
end
local function priorityProgress() session.PrioritySince = os.clock() return true end

local function canRefillEnergy(critical)
    if not state.Energy then return false end
    local energy, maximum = energyValues()
    local threshold = critical and math.min(state.EnergyThreshold, 15) or state.EnergyThreshold
    if type(energy) ~= "number" or type(maximum) ~= "number" or maximum <= 0 or energy >= maximum or energy > maximum * threshold / 100 then return false end
    local drink = findTool("KelpShake")
    if drink then return due(drink, "Drink") end
    if not hasInventoryRoom() then return false end
    for _, m in all("KelpShakeMachine") do
        local ts = m._remotes.ReadyTimestamp:Get()
        if usable(m) and type(ts)=="number" and ts <= workspace:GetServerTimeNow() and due(m, "Claim") then return true end
    end
    return false
end
local function refillEnergy()
    local energy, maximum = energyValues()
    if type(energy) ~= "number" or type(maximum) ~= "number" or maximum <= 0 then return false end
    local pending = session.PendingSip
    if pending then
        if energy > pending.Energy or not pending.Tool.Parent or pending.Tool.Parent ~= player.Character or os.clock() >= pending.Deadline then
            session.PendingSip = nil
        else return true end
    end
    if energy >= maximum or energy > maximum * state.EnergyThreshold / 100 then return false end
    local drink = findTool("KelpShake")
    if drink then
        if due(drink, "Drink") and equip(drink) and state.Energy and ready(drink, "Drink", 2) then
            session.PendingSip = {Tool=drink, Energy=energy, Deadline=os.clock()+0.9}
            drink:Activate()
            return true
        end
        return false
    end
    if not hasInventoryRoom() then return false end
    for _, m in all("KelpShakeMachine") do
        local ts = m._remotes.ReadyTimestamp:Get()
        if usable(m) and type(ts)=="number" and workspace:GetServerTimeNow() >= ts and due(m, "Claim") and moveTo(m.Instance) then
            return invoke(m, "Claim", function() return m._remotes:AttemptClaimKelpShake() end, 2)
        end
    end
    return false
end

local skippedCutscene
local function closePopups()
    if not state.Skip or not ready(session, "Popups", 0.5) then return end
    local phase, day = cycle.State.CurrentPhase(), cycle.State.CurrentDay()
    local issue = newspaper.State.Today()
    if issue and issue.Event and issue.Day == day and phase == "DayShift" and not cycle.State.SpecialDay() then
        local key = tostring(issue.Day)..":"..tostring(issue.Event)
        if newspaperSlice.State.DismissedKey() ~= key then newspaperSlice.Actions.dismiss(key) end
    end
    if phase == "EndOfDayReport" then
        if session.DismissedReportDay ~= day then
            session.DismissedReportDay = day
            cycleController.Server.DismissReport:Fire()
        end
    else
        local name = guiViews:GetCurrentView()
        guiViews:CloseDismissibleViews()
    end
    local dialog = dialogSlice.State.Active()
    if dialog and dialog.Skippable then dialogSlice.Actions.skipActive() end
end
local function skipCutscene()
    if not state.Skip then return false end
    closePopups()
    local scene = cameraController._activeCutscene
    if not scene or scene == skippedCutscene or type(scene.Skip) ~= "function" then return false end
    if not ready(scene, "Skip", 1) then return false end
    cameraController:VoteSkipCutscene()
    if cameraController._activeCutscene == scene then
        skippedCutscene = scene
        local ok, err = pcall(scene.Skip)
        if not ok then skippedCutscene = nil report(err) return false end
        return true
    end
    return false
end

local function slasherActive()
    if cycle.State.CurrentPhase() == "NightShift" then
        if nightlyTasks.Actions.getActiveTask("SlasherTrash") or session.SlasherNight then
            session.SlasherNight = session.SlasherNight or {}
            return true
        end
    else session.SlasherNight = nil end
    for _, obj in CollectionService:GetTagged("HashSlingingSlasher") do
        if obj:IsDescendantOf(workspace) and obj:GetAttribute("Departing") ~= true and obj:GetAttribute("Defeated") ~= true then
            if cycle.State.CurrentPhase() == "NightShift" then session.SlasherNight = session.SlasherNight or {} end
            return true
        end
    end
    return false
end
local function shiftClockState()
    local available = false
    for _, clock in all("ShiftClock") do
        if not usable(clock) then continue end
        if (clock.Instance:GetAttribute("DayStartTimestamp") or 0) > workspace:GetServerTimeNow() then return "Countdown" end
        if clock.Instance:GetAttribute("Interactable") == true then available = true end
    end
    local pending = session.PendingClock
    if pending and pending.Day == cycle.State.CurrentDay() and os.clock() - pending.SentAt < 8 then return "Pending" end
    return available and "Ready" or "Locked"
end
local function unresolvedThreat()
    if state.Bosses then for _, boss in all("Villain") do
        if usable(boss) and boss.Instance:GetAttribute("ReferenceName") ~= "HashSlingingSlasher" and not bossEnded(boss.Instance) then return true end
    end end
    if state.Plankton or state.Bosses then for _, npc in all("Plankton") do
        local obj = npc.Instance
        if usable(npc) and obj:GetAttribute("EscapedWithFormula") ~= true and obj:GetAttribute("Kicked") ~= true and (obj:GetAttribute("GoalScoredAt") or 0) <= 0
            and (obj:GetAttribute("Ball") == true or (obj:GetAttribute("HasFormula") == true and obj:GetAttribute("Stopped") ~= true)) then return true end
    end end
    if state.Fire then
        for obj in fires do
            if obj:IsDescendantOf(workspace) and obj:GetAttribute("Extinguished") ~= true and (not obj:IsA("Fire") or obj.Enabled) then return true end
        end
    end
    return false
end
local function nextShift()
    local phase = cycle.State.CurrentPhase()
    local pending = session.PendingClock
    if pending then
        if phase ~= "NightShift" or pending.Day ~= cycle.State.CurrentDay() then session.PendingClock = nil
        elseif not pending.Clock:IsDestroyed() and (pending.Clock.Instance:GetAttribute("Interactable") ~= true
            or (pending.Clock.Instance:GetAttribute("DayStartTimestamp") or 0) > workspace:GetServerTimeNow()
            or os.clock() - pending.SentAt < 8) then return false
        else session.PendingClock = nil end
    end
    if phase == "EndOfDayReport" then
        local day = cycle.State.CurrentDay()
        if session.DismissedReportDay ~= day then
            session.DismissedReportDay = day
            cycleController.Server.DismissReport:Fire()
            return true
        end
    elseif phase == "NightShift" and (slasherActive() or not unresolvedThreat()) and not busyCleaning() and not session.CleaningRelease then
        for _, clock in all("ShiftClock") do
            if usable(clock) and clock.Instance:GetAttribute("Interactable") == true and due(clock, "Clock")
                and (clock.Instance:GetAttribute("DayStartTimestamp") or 0) <= workspace:GetServerTimeNow() and moveTo(clock.Instance) then
                if not ready(clock, "Clock", 2) then return false end
                session.PendingClock = {Clock=clock, Day=cycle.State.CurrentDay(), SentAt=os.clock()}
                local success, result = awaitResult(function() return clock.Server:PunchClock() end)
                if not success and result == false then session.PendingClock = nil end
                return success
            end
        end
    end
    return false
end

local function upgradeScore(reference)
    local data = upgradeToolkit.getUpgradeData(reference)
    if data and session.Gun.IsUpgrade(reference, data) then
        if data.Available == false or upgradeToolkit.isUpgradeOwnedByPlayer(player, reference) or upgradeToolkit.isSuperseded(reference, player)
            or not upgradeToolkit.meetsPreRequisites(reference, player) or session.Gun.Find()
            or os.clock() - (session.Gun.BoughtAt or -100) < 12 then return 0 end
        return 1500
    end
    if not data or data.Available == false or not (data.IsUnique or data.IsUniquePerPlayer)
        or upgradeToolkit.isUpgradeOwnedByPlayer(player, reference) or upgradeToolkit.isSuperseded(reference, player)
        or not upgradeToolkit.meetsPreRequisites(reference, player) or not upgradeToolkit.isTargetUnlocked(reference) then return 0 end
    local advanced = cycle.State.CurrentDay() >= upgradeToolkit.Constants.AdvancedTierDay
    if (data.Tier or 1) > 2 and not advanced then return 0 end
    local target = data.Metadata and data.Metadata.TargetWorkstation
    if target and target ~= "TrayCounter" then
        if reference:match("^Auto") then return 0 end
        local slots = 0
        for _, s in all(target) do if usable(s) then slots = math.max(slots, s.Instance:GetAttribute("UnlockedSlots") or 1) end end
        if slots == 0 then return 0 end
        if reference:match("^Insta") then return 130 end
        if reference:find("Speed", 1, true) then return 100 end
        if reference:find("Capacity", 1, true) and (slots < 3 or advanced) then return slots < 2 and 110 or 55 end
    elseif reference:match("^MoppingSpeed") or reference == "InstaMop" then return 95
    elseif reference:match("^CleaningSpeed") or reference == "InstaClean" then return 85
    elseif reference:match("^TrashCapacity") then return 50
    elseif advanced then
        if reference:match("^Jukebox") then return 75 end
        if reference:match("^MoreTables") or reference:match("^Metronome") then return 65 end
        if reference:match("^KelpShakeObsessed") then return 45 end
        if target == "TrayCounter" then return 30 end
        if reference == "InventoryCapacity1" then return 25 end
    end
    return 0
end
local function smartUpgrades()
    if not state.Upgrades or cycle.State.CurrentPhase() ~= "NightShift" then return false end
    local balance, day = restaurant.Actions.getBalance(player), cycle.State.CurrentDay()
    local budget = session.UpgradeBudget
    if not budget or budget.Day ~= day or budget.Server ~= game.JobId then
        budget = {Day=day, Server=game.JobId, Opening=balance, Limit=math.floor(balance*0.3), Spent=0, Attempted={}, Started=os.clock()}
        session.UpgradeBudget = budget
    end
    local visit = dutchman.State.Visit()
    local waiting = os.clock() - (budget.Started or 0) < 8
    if state.DutchmanDeals and dutchman.State.Arriving() and waiting then return true end
    local dealKey = visit and ("Deal:"..tostring(visit.Day)..":"..tostring(visit.Tier))
    if state.DutchmanDeals and visit and visit.TakenBy == nil and #visit.Items > 0 and not budget.Attempted[dealKey] then
        for _, vendor in all("DutchmanVendor") do
            if usable(vendor) and vendor.Instance:GetAttribute("Mode") == "Vendor" then
                local prompt = vendor.Instance:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled and moveTo(prompt.Parent) and state.Upgrades and state.DutchmanDeals
                    and cycle.State.CurrentPhase() == "NightShift" and dutchman.State.Visit() == visit then
                    budget.Attempted[dealKey] = true
                    awaitResult(function() return dutchmanController.Server:TakeDeal() end)
                    local deadline = os.clock() + 3
                    while os.clock() < deadline do
                        local latest = dutchman.State.Visit()
                        if not latest or latest.TakenBy ~= nil then break end
                        task.wait(0.1)
                    end
                    return true
                end
            end
        end
        if waiting then return true end
    end
    local freeItems = {}
    if state.DutchmanDeals and visit and visit.TakenBy == nil then
        for _, item in visit.Items do if item.Upgrade then freeItems[item.Upgrade] = true end end
    end
    local cp = customPlayers:GetCustomPlayer()
    local discount = cp and cp:GetAttribute("UpgradeShopDiscount") or 0
    local shop, selected, selectedCost, bestScore
    for _, vendor in all("UpgradeTable") do
        if not usable(vendor) then continue end
        if vendor.Instance:GetAttribute("Open") ~= true or vendor._purchaseRequest then continue end
        for _, offer in vendor:GetAvailableUpgrades() or {} do
            local ref = offer.ReferenceName
            if offer.Amount <= 0 or budget.Attempted[ref] or freeItems[ref] then continue end
            local score = upgradeScore(ref)
            local data = upgradeToolkit.getUpgradeData(ref)
            local cost = data and upgradeToolkit.getDiscountedCost(data.Cost, discount)
            local isGun = data and session.Gun.IsUpgrade(ref, data)
            if score > 0 and cost and cost >= 0 and balance - cost >= 50
                and (isGun and cost <= session.Gun.Price or budget.Spent + cost <= budget.Limit) then
                local value = score / math.max(cost, 10)
                if not bestScore or value > bestScore then shop, selected, selectedCost, bestScore = vendor, offer, cost, value end
            end
        end
    end
    if not selected then return false end
    local display = (shop._upgradeDisplays or {})[selected.Slot]
    if not display or not moveTo(display.Model) or not state.Upgrades or cycle.State.CurrentPhase() ~= "NightShift" then return false end
    local latest = (shop:GetAvailableUpgrades() or {})[selected.Slot]
    if not latest or latest.ReferenceName ~= selected.ReferenceName or latest.Amount <= 0 then return false end
    local selData = upgradeToolkit.getUpgradeData(selected.ReferenceName)
    if selData and session.Gun.IsUpgrade(selected.ReferenceName, selData) then

        if session.Gun.Find() then return false end
        session.Gun.BoughtAt = os.clock()
    end
    budget.Attempted[selected.ReferenceName] = true
    budget.Spent += selectedCost
    local success, result = awaitResult(function() return shop._remotes:AttemptPurchaseUpgrade(selected.Slot) end)
    if not success and result == false then budget.Spent -= selectedCost end
    return true
end

local function reconcileRepairs()
    for obj, rec in pendingRepairs do
        if obj.Parent and obj:GetAttribute("Destroyed") ~= true then
            pendingRepairs[obj] = nil
        elseif not obj.Parent or os.clock() - rec.SentAt > 10 then pendingRepairs[obj] = nil end
    end
end
local function smartRepair(emergencyOnly)
    if not state.Repair then return false end
    for _, boss in all("Villain") do
        local name = boss.Instance:GetAttribute("ReferenceName")
        if usable(boss) and not bossEnded(boss.Instance) and (name == "Dennis" or name == "ManRay") then return false end
    end
    local phase = cycle.State.CurrentPhase()
    if phase ~= "NightShift" and phase ~= "DayShift" then return false end
    local used, seats = tableToolkit.getSeatUsage()
    local urgent = seats == 0 or used >= seats
    if emergencyOnly and not urgent then return false end
    if phase == "DayShift" and not urgent then return false end
    local selected, cost = nil, math.huge
    local existing = session.RepairBudget
    for _, item in all("Table") do
        if not usable(item) or item.Instance:GetAttribute("Destroyed") ~= true then continue end
        if existing and existing.Day == cycle.State.CurrentDay() and existing.Server == game.JobId and existing.Attempted[item.Instance] then continue end
        local price = tableToolkit.getRepairCost(item.Instance:GetAttribute("DestroyedStyle"))
        if type(price) == "number" and price >= 0 and price < cost then selected, cost = item, price end
    end
    if not selected then return false end
    local balance, day = restaurant.Actions.getBalance(player), cycle.State.CurrentDay()
    local budget = session.RepairBudget
    if not budget or budget.Day ~= day or budget.Server ~= game.JobId then
        budget = {Day=day, Server=game.JobId, Opening=balance, Spent=0, Attempted={}}
        session.RepairBudget = budget
    end
    budget.Limit = math.floor(budget.Opening * (urgent and 0.5 or 0.25))
    for obj in budget.Attempted do if not obj.Parent or obj:GetAttribute("Destroyed") ~= true then budget.Attempted[obj] = nil end end
    local obj = selected.Instance
    if budget.Attempted[obj] or balance - cost < 50 or budget.Spent + cost > budget.Limit
        or not ready(selected, "Repair", 8) or not moveTo(obj) then return false end
    cost = tableToolkit.getRepairCost(obj:GetAttribute("DestroyedStyle"))
    if not state.Repair or not usable(selected) or obj:GetAttribute("Destroyed") ~= true
        or restaurant.Actions.getBalance(player) - cost < 50 or budget.Spent + cost > budget.Limit then return false end
    budget.Attempted[obj] = true
    budget.Spent += cost
    pendingRepairs[obj] = {Budget=budget, Cost=cost, SentAt=os.clock()}
    local success, result = awaitResult(function() return selected.Server:AttemptRepair() end)
    if not success and result == false then budget.Spent -= cost budget.Attempted[obj] = nil pendingRepairs[obj] = nil end
    return true
end

BZ:AddCategory("farm", "Auto", "zap")
BZ:AddBanner("banner_status", "Save the Krusty Krab", "All toggles are flat — enable what you need", "zap")

local running, stopCook, startCook
do
running = false
local cache = {}
local cookConnections = {}
local STATIONS = {
    {name="Grill",            actions={"Grill Patties","Finish Patties"}, keys={"patty","patties"}},
    {name="SodaMachine",      actions={"Pour","Finish Pouring"},          keys={"soda","drink","cola"}},
    {name="Fryer",            actions={"Fry Fries","Finish Fries"},       keys={"fries","fry"}},
    {name="MilkShakeMachine", actions={"Shake","Finish Shaking"},         keys={"shake","milkshake"}},
}

local MAX_STOCK = 99
local AUTO_INSTANT_WAIT = 1.2
local finishCount, countKey = {}, nil
local startWatch = setmetatable({}, {__mode="k"})
local function resetCountIfNewPhase()
    local ok, key = pcall(function() return tostring(cycle.State.CurrentPhase()) .. "|" .. tostring(cycle.State.CurrentDay()) end)
    if not ok then return end
    if key ~= countKey then countKey = key; table.clear(finishCount) end
end
local function matches(prompt, actions)
    local action, pname = prompt.ActionText:lower(), prompt.Name:lower()
    for _, a in ipairs(actions) do a = a:lower() if action == a or pname == a then return true end end
    return false
end
local function refreshCache()
    local list = {}
    for _, def in ipairs(STATIONS) do
        for _, station in ipairs(interactables:GetChildren()) do
            if station.Name == def.name then
                for _, d in ipairs(station:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and matches(d, def.actions) then
                        table.insert(list, {prompt=d, finish={def.actions[2]}, last=0, def=def, station=station})
                    end
                end
            end
        end
    end
    cache = list
end
function stopCook()
    for _, c in ipairs(cookConnections) do c:Disconnect() end
    table.clear(cookConnections)
end
function startCook()
    stopCook()
    table.clear(finishCount)
    local lastRefresh, lastStart = 0, 0
    table.insert(cookConnections, interactables.DescendantAdded:Connect(function(d)
        if d:IsA("ProximityPrompt") then lastRefresh = 0 end
    end))
    table.insert(cookConnections, game:GetService("RunService").Heartbeat:Connect(function()
        if not running then return end
        local now = os.clock()
        if now - lastRefresh >= 0.5 then refreshCache() lastRefresh = now end
        local startDue = now - lastStart >= 0.3
        resetCountIfNewPhase()
        local finishNow = {}
        for _, entry in ipairs(cache) do
            if entry.prompt.Parent and matches(entry.prompt, entry.finish) then finishNow[entry.station] = true end
        end
        for station, watch in pairs(startWatch) do
            local p = watch.prompt
            if not p.Parent then
                startWatch[station] = nil
            elseif finishNow[station] or matches(p, watch.finish) then
                startWatch[station] = nil
            elseif not (p.Enabled and matches(p, watch.start)) then
                watch.busy = true
            elseif watch.busy or now - watch.t >= AUTO_INSTANT_WAIT then
                if (finishCount[watch.def] or 0) < MAX_STOCK then finishCount[watch.def] = (finishCount[watch.def] or 0) + 1 end
                startWatch[station] = nil
            end
        end
        for _, entry in ipairs(cache) do
            local p, station = entry.prompt, entry.station
            if p.Parent and p.Enabled and (finishCount[entry.def] or 0) < MAX_STOCK then
                local isFinish = matches(p, entry.finish)
                local due = isFinish and (now - entry.last >= 0.1) or (not isFinish and startDue and not startWatch[station])
                if due then
                    entry.last = now
                    if isFinish then
                        finishCount[entry.def] = (finishCount[entry.def] or 0) + 1
                    else
                        startWatch[station] = {prompt = p, t = now, busy = false, def = entry.def, start = {entry.def.actions[1]}, finish = entry.finish}
                    end
                    p.RequiresLineOfSight = false
                    p.HoldDuration = 0
                    fireproximityprompt(p)
                end
            end
        end
        if startDue then lastStart = now end
    end))
end
end

BZ:AddGroup("grp_kitchen", "Kitchen & Orders", "utensils", true)
BZ:AddToggle("auto_cook", "Auto Cook", false, function(s)
    running = s
    if s then startCook() else stopCook() end
end, "switch")

BZ:AddToggle("auto_accept", "Auto Accept Orders", false, function(s)
    state.Accept = s
    if not s then acceptWanted = false end
end, "switch")
BZ:AddToggle("auto_assemble", "Auto Assemble", false, function(s)
    state.Assemble = s
end, "switch")
BZ:EndGroup()

BZ:AddGroup("grp_threats", "Bosses & Hazards", "shield", true)
BZ:AddToggle("auto_bosses", "Auto Defeat Bosses", false, function(s)
    state.Bosses = s
    if not s then stopBossCleaning() end
end, "switch")
BZ:AddToggle("auto_plankton", "Auto Kick Plankton", false, function(s) state.Plankton = s end, "switch")
BZ:AddToggle("auto_troublemakers", "Auto Remove Troublemakers", false, function(s) state.Troublemakers = s end, "switch")
BZ:AddToggle("auto_fire", "Auto Extinguish Fires", false, function(s)
    state.Fire = s
    if not s then stopExtinguishing() end
end, "switch")
BZ:EndGroup()

BZ:AddGroup("grp_player", "Player & Shift", "user", true)
BZ:AddToggle("auto_energy", "Auto Refill Energy", false, function(s) state.Energy = s end, "switch")
BZ:AddSlider("energy_threshold", "Energy Threshold", 1, 100, 50, function(v)
    state.EnergyThreshold = v
end, 1, false)

BZ:AddToggle("auto_skip", "Auto Skip Cutscenes", false, function(s) state.Skip = s end, "switch")
BZ:AddToggle("auto_next_shift", "Auto Next Shift", false, function(s) state.NextShift = s end, "switch")
BZ:EndGroup()

BZ:AddGroup("grp_upgrades", "Upgrades & Repair", "wrench", true)
BZ:AddToggle("auto_upgrades", "Smart Auto Upgrades", false, function(s) state.Upgrades = s end, "switch")
BZ:AddToggle("auto_dutchman", "Flying Dutchman Deals", true, function(s) state.DutchmanDeals = s end, "switch")
BZ:AddToggle("auto_repair", "Smart Auto Repair", false, function(s) state.Repair = s end, "switch")
BZ:EndGroup()

local mopToken, releaseAnchor, stationToken, wipeToken, takeoutToken, serveToken, collectToken
do
mopToken = 0
local function getRoot() local c = player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function findToolByPart(partName)
    local char = player.Character
    for _, cont in ipairs({char, player.Backpack}) do
        if cont then for _, t in ipairs(cont:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild(partName, true) then return t end
        end end
    end
end
local function findMop() return findToolByPart("Mop") end
local function takeMop()
    local giver = interactables:FindFirstChild("MopAndBucket", true)
    local remote = giver and giver:FindFirstChild("TakeMop", true)
    if remote and remote:IsA("RemoteFunction") then pcall(function() remote:InvokeServer() end) end
end
local function holdMop()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local mop = findMop()
    if not mop then takeMop()
        local started = os.clock()
        repeat task.wait(0.1) mop = findMop() until mop or os.clock() - started > 2
    end
    if mop and mop.Parent ~= char then hum:EquipTool(mop) end
end
local function findPuddles()
    local list, misc = {}, workspace:FindFirstChild("Miscellaneous", true)
    if misc then for _, c in ipairs(misc:GetChildren()) do
        if c.Name:find("^Puddle") and c:FindFirstChild("Core") then table.insert(list, c) end
    end end
    return list
end
local function findMopPrompt(puddle)
    local fallback
    for _, d in ipairs(puddle:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            if d.ActionText:lower() == "mop" then return d end
            fallback = fallback or d
        end
    end
    return fallback
end
local function mopPuddle(puddle, token)
    local root = getRoot()
    local core = puddle:FindFirstChild("Core")
    local prompt = findMopPrompt(puddle)
    if not (root and core and prompt) then return end
    holdMop()
    root.CFrame = core.CFrame * CFrame.new(0, 3, 0)
    root.Anchored = true
    local started = os.clock()
    while mopToken == token and puddle.Parent and os.clock() - started < 4 do
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        fireproximityprompt(prompt)
        task.wait(0.15)
    end
end
function releaseAnchor() local r = getRoot(); if r then r.Anchored = false end end
local function promptCFrame(prompt)
    local p = prompt.Parent
    if p:IsA("BasePart") then return p.CFrame end
    if p:IsA("Attachment") then return p.WorldCFrame end
    local model = p:FindFirstAncestorOfClass("Model")
    return model and model:GetPivot()
end
local function sameText(text, expected) return (text:lower():gsub("%s","")) == expected end
local function onlyTrash(tray)
    if not tray or not tray:IsA("Instance") then return false end
    local ref = tray:GetAttribute("ReferenceName")
    local knownTrashTray = tray.Name:match("^TrashTray")
        or (type(ref) == "string" and ref:match("^TrashTray"))
    if tray:IsA("Tool") and knownTrashTray then return true end
    local items = tray:FindFirstChild("TrayItems", true)
    if not items then return false end
    local children = items:GetChildren()
    if #children == 0 then return false end
    for _, item in ipairs(children) do
        local itemRef = item:GetAttribute("ReferenceName")
        local isTrashItem = item.Name:match("^Trash") or (type(itemRef) == "string" and itemRef:match("^Trash"))
        if not isTrashItem then return false end
    end
    return true
end

local function toolRef(t)
    local ref = t:GetAttribute("ReferenceName")
    if type(ref) == "string" and ref ~= "" then return ref end
    return t.Name:match("^([%w]+)_[%x%-]+$") or t.Name
end
local function isTrashTool(tool)
    if not tool or not tool:IsA("Tool") or not tool.Parent then return false end
    for _, c in all("Tray") do
        local ok, t = pcall(function() return c:GetTool() end)
        if ok and t == tool then return false end
    end
    if toolRef(tool):lower():find("trash", 1, true) then return true end
    if tool:FindFirstChild("TrayItems", true) then return onlyTrash(tool) end
    return false
end

local function findHeldTrashTray()
    local char = player.Character
    for _, cont in ipairs({char, player.Backpack}) do
        if cont then for _, t in ipairs(cont:GetChildren()) do
            if t:IsA("Tool") and onlyTrash(t) and isTrashTool(t) then return t end
        end end
    end
end
local function toolSet()
    local set = {}
    for _, cont in ipairs({player.Character, player.Backpack}) do
        if cont then for _, t in ipairs(cont:GetChildren()) do if t:IsA("Tool") then set[t] = true end end end
    end
    return set
end
local function newTool(before)
    for t in pairs(toolSet()) do if not before[t] and isTrashTool(t) then return t end end
end
local function findTrayPrompts()
    local list, misc = {}, workspace:FindFirstChild("Miscellaneous", true)
    if not misc then return list end
    for _, tray in ipairs(misc:GetChildren()) do
        if tray.Name:find("^TrashTray") and onlyTrash(tray) then
            for _, d in ipairs(tray:GetDescendants()) do
                if d:IsA("ProximityPrompt") and sameText(d.ActionText, "pickup") then table.insert(list, d) end
            end
        end
    end
    return list
end
local TRASH_SPOTS = {
    Vector3.new(-29.17,3,160.45), Vector3.new(29.21,3,154.89),
    Vector3.new(-23.33,3,104.09), Vector3.new(-56.62,3,121.56),
}
local function sortedSpots(from)
    local list = table.clone(TRASH_SPOTS)
    table.sort(list, function(x,y) return (x-from).Magnitude < (y-from).Magnitude end)
    return list
end
local function nearestTrashCan(pos)
    local best, bd
    for _, c in ipairs(interactables:GetChildren()) do
        if (c.Name:lower():gsub("%s","")) == "trashcan" then
            local d = (c:GetPivot().Position - pos).Magnitude
            if not bd or d < bd then best, bd = c, d end
        end
    end
    return best
end
local function findThrowPrompt(can)
    for _, d in ipairs(can:GetDescendants()) do
        if d:IsA("ProximityPrompt") and sameText(d.ActionText, "throwaway") then return d end
    end
end
local function withLock(fn, skipBosses)
    if priorityBusy(skipBosses) then return true, false end
    local waitStart = os.clock()
    while moveLock or (acceptWanted and os.clock() - waitStart < 1) do task.wait(0.05) end
    moveLock = true
    local ok, result = pcall(fn)
    releaseAnchor()
    moveLock = false
    return ok, result
end
local function waitFor(check, timeout, aliveFn)
    local started = os.clock()
    while aliveFn() and os.clock() - started < timeout do
        local v = check()
        if v then return v end
        task.wait(0.1)
    end
end
local function triggerPrompt(prompt, attempt)
    prompt.RequiresLineOfSight = false
    if attempt % 2 == 1 then fireproximityprompt(prompt)
    else prompt:InputHoldBegin(); task.wait(prompt.HoldDuration + 0.05); prompt:InputHoldEnd() end
end
local function ensureHeld(tool)
    local char = player.Character
    if not tool or not tool.Parent then return false end
    if tool.Parent == char then return true end
    if equip(tool) then return true end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and tool.Parent == player.Backpack then hum:EquipTool(tool); task.wait(0.08) end
    return tool.Parent == char
end
local function fireAt(prompt, target, aliveFn, isDone, timeout, hold)
    local root = getRoot(); if not root then return false end
    root.CFrame = target
    task.wait(0.4)
    ensureHeld(hold)
    local started = os.clock()
    local lastTeleport = started
    local attempt = 0
    while aliveFn() and not isDone() and os.clock() - started < (timeout or 8) do
        if os.clock() - lastTeleport >= 1.5 then
            root.CFrame = target
            lastTeleport = os.clock()
        end
        ensureHeld(hold)
        if prompt.Parent and prompt.Enabled then
            attempt += 1
            pcall(triggerPrompt, prompt, attempt)
        end
        local w = os.clock()
        while aliveFn() and not isDone() and os.clock() - w < 0.6 do task.wait(0.05) end
    end
    return isDone()
end
local function toolHeld(t) return t.Parent ~= nil and (t.Parent == player.Character or t.Parent == player.Backpack) end
local function throwAway(token, tool)
    local root, char = getRoot(), player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (root and hum and toolHeld(tool)) then return end
    if not isTrashTool(tool) then return end
    if not ensureHeld(tool) or not isTrashTool(tool) then return end
    local aliveFn = function() return mopToken == token end
    for _, spot in ipairs(sortedSpots(root.Position)) do
        if not aliveFn() or not toolHeld(tool) or not isTrashTool(tool) then return end
        local target = CFrame.new(spot)
        root.CFrame = target
        ensureHeld(tool)
        local prompt = waitFor(function()
            local can = nearestTrashCan(spot)
            return can and findThrowPrompt(can)
        end, 8, aliveFn)
        if prompt and fireAt(prompt, target, aliveFn, function() return not toolHeld(tool) end, 3, tool) then return end
    end
end
local trashTrayTool
local function heldTrashTray()
    if trashTrayTool and toolHeld(trashTrayTool) then return trashTrayTool end
    trashTrayTool = findHeldTrashTray()
    return trashTrayTool
end
local function deliverTray(token)
    local tray = heldTrashTray()
    if tray then throwAway(token, tray) end
end
local function findPromptByText(root, expected)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ProximityPrompt") and sameText(d.ActionText, expected) then return d end
    end
end
local function mopStep(token, skipped)
    for _, puddle in ipairs(findPuddles()) do
        if puddle.Parent and not skipped[puddle] then
            mopPuddle(puddle, token)
            if puddle.Parent then skipped[puddle] = true end
            return true
        end
    end
    return false
end
local function trayStep(token, skipped)
    if heldTrashTray() then
        deliverTray(token)
        return heldTrashTray() == nil
    end
    for _, prompt in ipairs(findTrayPrompts()) do
        if not skipped[prompt] then
            local cframe = promptCFrame(prompt)
            if cframe then
                local before, picked = toolSet(), nil
                fireAt(prompt, cframe + Vector3.new(0,3,0),
                    function() return mopToken == token end,
                    function() picked = newTool(before); return picked ~= nil or not prompt.Parent end, 6)
                picked = picked or newTool(before) or findHeldTrashTray()
                if picked then
                    trashTrayTool = picked
                    deliverTray(token)
                    return heldTrashTray() == nil
                end
                skipped[prompt] = true
                return true
            end
        end
    end
    return false
end
local looseTool
local function findLoosePrompts()
    local list, misc = {}, workspace:FindFirstChild("Miscellaneous", true)
    if not misc then return list end
    for _, item in ipairs(misc:GetChildren()) do
        if item.Name:find("^Trash_") then
            for _, d in ipairs(item:GetDescendants()) do
                if d:IsA("ProximityPrompt") and sameText(d.ActionText, "clean") then table.insert(list, d) end
            end
        end
    end
    return list
end
local function looseStep(token, skipped)
    if looseTool and toolHeld(looseTool) then throwAway(token, looseTool); return not toolHeld(looseTool) end
    looseTool = nil
    for _, prompt in ipairs(findLoosePrompts()) do
        if not skipped[prompt] then
            local cframe = promptCFrame(prompt)
            if cframe then
                local before, picked = toolSet(), nil
                fireAt(prompt, cframe + Vector3.new(0,3,0),
                    function() return mopToken == token end,
                    function() picked = newTool(before); return picked ~= nil or not prompt.Parent end, 6)
                picked = picked or newTool(before)
                if picked then looseTool = picked throwAway(token, picked) return not toolHeld(picked) end
                skipped[prompt] = true
                return true
            end
        end
    end
    return false
end
local function mopReturnStep()
    if next(findPuddles()) or not findMop() then return false end
    return returnMop(true) == true
end
BZ:AddGroup("grp_clean", "Clean & Service", "trash-2", true)
BZ:AddToggle("auto_clean", "Auto Clean Trash", false, function(s)
    mopToken += 1
    local token = mopToken
    if not s then releaseAnchor() return end
    task.spawn(function()
        local skipped = {}
        while mopToken == token do
            local ok, didWork = withLock(function() return mopStep(token, skipped) or trayStep(token, skipped) or looseStep(token, skipped) or mopReturnStep() end)
            releaseAnchor()
            if ok and didWork then task.wait(0.1) else skipped = {} task.wait(0.5) end
        end
    end)
end, "switch")

stationToken = 0
local CLEAN_STATIONS = {
    {name="AssemblingTable", spot=Vector3.new(-53.67,3,146.94)},
    {name="Grill",           spot=Vector3.new(-32.92,3,137.84)},
    {name="Fryer",           spot=Vector3.new(-34.88,3,143.62)},
    {name="MilkShakeMachine",spot=Vector3.new(-42.04,3,149.75)},
    {name="SodaMachine",     spot=Vector3.new(-48,3,151.45)},
    {name="TrayCounter",     spot=Vector3.new(-55.62,3,136.54)},
}
local function cleanStationStep(token, skipped)
    local aliveFn = function() return stationToken == token end
    for _, def in ipairs(CLEAN_STATIONS) do
        if not skipped[def.name] then
            local st = interactables:FindFirstChild(def.name)
            local prompt = st and findPromptByText(st, "cleanup")
            local hl = st and st:FindFirstChild("Highlight")
            if prompt and prompt.Enabled and not (hl and not hl.Enabled) then
                fireAt(prompt, CFrame.new(def.spot), aliveFn, function()
                    return not prompt.Parent or not prompt.Enabled or (hl ~= nil and not hl.Enabled)
                end, 4)
                if prompt.Parent and prompt.Enabled and not (hl and not hl.Enabled) then skipped[def.name] = true end
                return true
            end
        end
    end
    return false
end
BZ:AddToggle("auto_clean_station", "Auto Clean Workstation", false, function(s)
    stationToken += 1
    local token = stationToken
    if not s then return end
    task.spawn(function()
        local skipped = {}
        while stationToken == token do
            local ok, didWork = withLock(function() return cleanStationStep(token, skipped) end)
            if ok and didWork then task.wait(0.1) else skipped = {} task.wait(0.5) end
        end
    end)
end, "switch")

wipeToken = 0
local function findWipePrompts()
    local list = {}
    local persistent = workspace:FindFirstChild("_PERSISTENT", true)
    local tables = persistent and persistent:FindFirstChild("Tables")
    if not tables then return list end
    for _, t in ipairs(tables:GetChildren()) do
        local core = t:FindFirstChild("Core")
        if core then for _, d in ipairs(core:GetDescendants()) do
            if d:IsA("ProximityPrompt") and sameText(d.ActionText, "wipetable") then table.insert(list, d) end
        end end
    end
    return list
end
local function wipeStep(token, skipped)
    for _, prompt in ipairs(findWipePrompts()) do
        if prompt.Enabled and not skipped[prompt] then
            local cframe = promptCFrame(prompt)
            if cframe then
                fireAt(prompt, cframe + Vector3.new(0,3,0),
                    function() return wipeToken == token end,
                    function() return not prompt.Parent or not prompt.Enabled end, 3)
                if prompt.Parent and prompt.Enabled then skipped[prompt] = true end
                return true
            end
        end
    end
    return false
end
BZ:AddToggle("auto_wipe", "Auto Wipe Table", false, function(s)
    wipeToken += 1
    local token = wipeToken
    if not s then return end
    task.spawn(function()
        local skipped = {}
        while wipeToken == token do
            local ok, didWork = withLock(function() return wipeStep(token, skipped) end)
            if ok and didWork then task.wait(0.1) else skipped = {} task.wait(0.5) end
        end
    end)
end, "switch")

takeoutToken = 0
local BAG_PART = "polySurface10"
local DUMPSTER_SPOT = Vector3.new(-72.67,3,158.89)
local function binCount(can)
    for _, d in ipairs(can:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text:lower():find("bin") then
            local n = d.Text:match("(%d+)%s*/%s*%d+")
            if n then return tonumber(n) end
        end
    end
end
local function findEmptyPrompt(can)
    for _, d in ipairs(can:GetDescendants()) do
        if d:IsA("ProximityPrompt") and sameText(d.ActionText, "emptytrash") then return d end
    end
end
local function findDumpsterPrompt(d)
    d = d or interactables:FindFirstChild("Dumpster"); if not d then return end
    for _, p in ipairs(d:GetDescendants()) do
        if p:IsA("ProximityPrompt") and sameText(p.ActionText, "throwaway") then return p end
    end
end
local function findV2Dumpster()
    local env = workspace:FindFirstChild("HashSlingingSlasher_Environment", true)
    return env and env:FindFirstChild("Dumpster", true)
end
local function dumpsterTarget(d)
    local pos, topY
    if d and d:IsA("Model") then
        local cf, size = d:GetBoundingBox()
        pos, topY = cf.Position, cf.Position.Y + size.Y / 2
    elseif d and d:IsA("BasePart") then
        pos, topY = d.Position, d.Position.Y + d.Size.Y / 2
    else
        return nil
    end
    return CFrame.new(pos.X, topY + 3, pos.Z)
end
local function pickDumpster(preferV2)
    local v1, v2 = interactables:FindFirstChild("Dumpster"), findV2Dumpster()
    if preferV2 then return v2 or v1 end
    return v1 or v2
end
local function dumpBag(token)
    local aliveFn = function() return takeoutToken == token end
    local root = getRoot()
    local bag = findToolByPart(BAG_PART)
    if not (root and bag) then return false end
    ensureHeld(bag)
    local dumpster = pickDumpster(false)
    local target = dumpsterTarget(dumpster)
    if not target then return false end
    root.CFrame = target
    local prompt = waitFor(function() return findDumpsterPrompt(dumpster) end, 8, aliveFn)
    if not prompt then return false end
    return fireAt(prompt, target, aliveFn, function() return findToolByPart(BAG_PART) == nil end, 4, bag)
end
local function takeoutStep(token, skipped)
    local aliveFn = function() return takeoutToken == token end
    if findToolByPart(BAG_PART) then return dumpBag(token) end
    for _, can in ipairs(interactables:GetChildren()) do
        if (can.Name:lower():gsub("%s","")) == "trashcan" and not skipped[can] and binCount(can) ~= 0 then
            local prompt = findEmptyPrompt(can)
            if prompt and prompt.Enabled then
                local spot = sortedSpots(can:GetPivot().Position)[1]
                local took = fireAt(prompt, CFrame.new(spot), aliveFn, function() return findToolByPart(BAG_PART) ~= nil end, 5)
                if took then dumpBag(token) else skipped[can] = true end
                return true
            end
        end
    end
    return false
end
session.TakeoutV2Count, session.TakeoutV2Phase = 0, nil
local TAKEOUT_V2_MAX = 4
local function findTakeBagPrompt(skipped)
    for p in pairs(prompts) do
        if p.Parent and p.Enabled and not skipped[p] and sameText(p.ActionText, "taketrashbag") and sameText(p.ObjectText, "trashbin") then return p end
    end
end
local function newAnyTool(before)
    for t in pairs(toolSet()) do if not before[t] then return t end end
end
local function takeoutV2Step(token, skipped)
    local aliveFn = function() return takeoutToken == token end
    local phase = cycle.State.CurrentPhase()
    if session.TakeoutV2Phase ~= phase then session.TakeoutV2Phase, session.TakeoutV2Count = phase, 0 end
    if session.TakeoutV2Count >= TAKEOUT_V2_MAX then return false end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = getRoot()
    if not (hum and root) then return false end
    local bag = findToolByPart(BAG_PART)
    if not bag then
        local prompt = findTakeBagPrompt(skipped)
        if not prompt then return false end
        local cframe = promptCFrame(prompt)
        if not cframe then skipped[prompt] = true return true end
        local before = toolSet()
        fireAt(prompt, cframe + Vector3.new(0,3,0), aliveFn, function()
            return findToolByPart(BAG_PART) ~= nil or newAnyTool(before) ~= nil or not prompt.Parent
        end, 5)
        bag = findToolByPart(BAG_PART) or newAnyTool(before)
        if not bag then skipped[prompt] = true return true end
    end
    ensureHeld(bag)
    local dumpster = pickDumpster(true)
    local target = dumpsterTarget(dumpster)
    if not target then return true end
    root.CFrame = target
    local throw = waitFor(function() return findDumpsterPrompt(dumpster) end, 8, aliveFn)
    if not throw then return true end
    if fireAt(throw, target, aliveFn, function() return not toolHeld(bag) end, 4, bag) then
        session.TakeoutV2Count += 1
    end
    return true
end
BZ:AddToggle("auto_takeout", "Auto Take Out Trash", false, function(s)
    takeoutToken += 1
    local token = takeoutToken
    if not s then return end
    task.spawn(function()
        local skipped = {}
        while takeoutToken == token do
            local ok, didWork = withLock(function() return takeoutStep(token, skipped) or takeoutV2Step(token, skipped) end)
            if ok and didWork then task.wait(0.1) else skipped = {} task.wait(0.5) end
        end
    end)
end, "switch")

local Inspector = {}
function Inspector.inspectorCustomers()
    if not (Inspector.container and Inspector.container.Parent) then
        local container = workspace:FindFirstChild("NPC_Container", true)
        Inspector.container = container and container:FindFirstChild("Customers")
    end
    return Inspector.container
end
function Inspector.isInspector(order, npc)
    if order and order.CustomerReference == "HealthInspector" then return true end
    local obj = npc and npc.Instance
    if not obj then return false end
    if obj:GetAttribute("ReferenceName") == "HealthInspector" then return true end
    local customers = Inspector.inspectorCustomers()
    return customers ~= nil and obj:IsDescendantOf(customers) and obj.Name:lower():find("healthinspector", 1, true) ~= nil
end
function Inspector.findSwapPrompt()
    local dumpster = interactables:FindFirstChild("Dumpster")
    if not dumpster then return end
    for _, d in ipairs(dumpster:GetDescendants()) do
        if d:IsA("ProximityPrompt") and sameText(d.ActionText, "swapfornastypatty") then return d end
    end
end
function Inspector.traySig(tool)
    local parts = {}
    for _, d in ipairs(tool:GetDescendants()) do parts[#parts+1] = d.Name .. ":" .. tostring(d:GetAttribute("ReferenceName")) end
    return table.concat(parts, "|")
end
function Inspector.anyNewTool(before)
    for t in pairs(toolSet()) do if not before[t] then return t end end
end
serveToken = 0
Inspector.state = {}

function Inspector.prune()
    local orders = restaurant.State.RestaurantOrders()
    for id in pairs(Inspector.state) do
        local o = orders[id]
        if not o or o.OrderStatus == "Delivered" or o.OrderStatus == "Cancelled" then Inspector.state[id] = nil end
    end
end

function Inspector.findTray(st)
    if st.Tray and toolHeld(st.Tray) then return st.Tray end
    if st.SwapSig then
        for _, t in tools() do
            if t.Parent and Inspector.traySig(t) == st.SwapSig then return t end
        end
    end
    for _, t in tools() do
        if t.Parent and Inspector.traySig(t):lower():find("nasty", 1, true) then return t end
    end
end

function Inspector.equip(tool)
    for _ = 1, 4 do
        if tool and tool.Parent and equip(tool) then return true end
        task.wait(0.1)
    end
    return false
end
function Inspector.findInspectorOrder()
    for _, order in ordered() do
        if order.OrderStatus ~= "Delivered" and order.OrderStatus ~= "Cancelled" then
            local npc = customer(order.CustomerId)
            if npc and usable(npc) and Inspector.isInspector(order, npc) then return order, npc end
        end
    end
end
function Inspector.inspectorStep(token)
    local aliveFn = function() return serveToken == token end
    local order, npc = Inspector.findInspectorOrder()
    if not order then Inspector.prune() return false end
    if not due(npc, "Inspector") then return false end
    local npcId = npc.Instance:GetAttribute("NPCUid")
    if npcId ~= order.CustomerId then return false end
    local st = Inspector.state[order.OrderId]
    if not st then Inspector.prune(); st = {Fails = 0}; Inspector.state[order.OrderId] = st end
    local function abort(seconds) ready(npc, "Inspector", seconds or 3) return false end
    local didWork = false

    for _ = 1, 8 do
        if not aliveFn() or priorityBusy(true) then return didWork end
        local live = restaurant.State.RestaurantOrders()[order.OrderId]
        if not live or live.OrderStatus == "Delivered" or live.OrderStatus == "Cancelled" then
            Inspector.state[order.OrderId] = nil
            return didWork
        end

        if not (st.Tray and toolHeld(st.Tray)) then
            st.Tray = nil
            if st.Swapped then
                st.Tray = Inspector.findTray(st)
            else
                for _, comp in all("Tray") do
                    local t = comp:GetTool()
                    if t and toolHeld(t) and comp:_IsTrayCorrectForOrder(live) then st.Tray = t break end
                end
                if not st.Tray then

                    local lost = Inspector.findTray(st)
                    if lost then st.Tray, st.Swapped, st.SwapSig = lost, true, Inspector.traySig(lost) end
                end
            end
            if not st.Tray then
                if st.Swapped then Inspector.state[order.OrderId] = nil return abort(5) end
                if live.OrderStatus ~= "Prepared" or not hasInventoryRoom() then return didWork end
                local picked = false
                for _, counter in all("TrayCounter") do
                    for _, model in counter.Instance:GetChildren() do
                        if not picked and model:IsA("Model") and model:GetAttribute("OrderId") == order.OrderId then
                            local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and prompt.Enabled and due(prompt, "Prompt") then
                                picked = firePrompt(prompt, function()
                                    local l = restaurant.State.RestaurantOrders()[order.OrderId]
                                    return hasInventoryRoom() and l ~= nil and l.OrderStatus == "Prepared" and l.CustomerId == order.CustomerId
                                end)
                            end
                        end
                    end
                end
                if not picked then return didWork end
                didWork = true
                task.wait(0.3)
                continue
            end
        end

        if not st.Swapped then
            if not Inspector.equip(st.Tray) then return abort() end
            local root = getRoot(); if not root then return didWork end
            local target = CFrame.new(DUMPSTER_SPOT)
            root.CFrame = target
            local prompt = waitFor(function() local p = Inspector.findSwapPrompt(); return p and p.Enabled and p end, 6, aliveFn)
            if not prompt then
                st.Fails += 1
                if st.Fails >= 3 then Inspector.state[order.OrderId] = nil end
                return abort(5)
            end
            local tray, before, sig = st.Tray, toolSet(), Inspector.traySig(st.Tray)
            local swapped = fireAt(prompt, target, aliveFn, function()
                return not prompt.Parent or not prompt.Enabled or not toolHeld(tray)
                    or Inspector.traySig(tray) ~= sig or Inspector.anyNewTool(before) ~= nil
            end, 5)
            didWork = true
            if not swapped then
                st.Fails += 1
                if st.Fails >= 3 then Inspector.state[order.OrderId] = nil end
                return abort(5)
            end
            st.Swapped = true
            if not toolHeld(tray) then st.Tray = Inspector.anyNewTool(before) end
            if not st.Tray then Inspector.state[order.OrderId] = nil return abort(5) end
            st.SwapSig = Inspector.traySig(st.Tray)
            task.wait(0.2)
            continue
        end

        if not Inspector.equip(st.Tray) then return abort(1) end
        if not npc.Instance or not npc.Instance.Parent or not moveTo(npc.Instance) then return abort(1) end
        if not aliveFn() then return didWork end

        if st.Tray.Parent ~= player.Character and not Inspector.equip(st.Tray) then return abort(1) end
        local l2 = restaurant.State.RestaurantOrders()[order.OrderId]
        if not l2 or l2.CustomerId ~= order.CustomerId or npc.Instance:GetAttribute("NPCUid") ~= npcId then return abort() end
        local success = invoke(npc, "Deliver", function() return restaurantController.Server:DeliverOrder(npcId) end, 0.8)
        didWork = true
        local deadline = os.clock() + 2
        while aliveFn() and success and os.clock() < deadline do
            local latest = restaurant.State.RestaurantOrders()[order.OrderId]
            if not latest or latest.OrderStatus == "Delivered" then
                Inspector.state[order.OrderId] = nil
                return true
            end
            task.wait(0.05)
        end
        return abort(2)
    end
    return didWork
end

local function serveStep(token, heldOnly)
    local aliveFn = function() return serveToken == token end
    local carried = {}
    for _, tool in tools() do
        if tool.Parent then carried[tool] = true end
    end

    for _, order in ordered() do
        if order.OrderStatus == "Delivered" or order.OrderStatus == "Cancelled" then continue end
        local npc = customer(order.CustomerId)
        if not npc or not usable(npc) or not due(npc, "Deliver") then continue end
        local npcId = npc.Instance:GetAttribute("NPCUid")
        if npcId ~= order.CustomerId then continue end
        if Inspector.isInspector(order, npc) then continue end

        local comp, tray
        for _, c in all("Tray") do
            local t = c:GetTool()
            if not t or not carried[t] then continue end
            if heldOnly == true and t.Parent ~= player.Character then continue end
            if not c:_IsTrayCorrectForOrder(order) then continue end
            if not comp or (t.Parent == player.Character and tray.Parent ~= player.Character) then comp, tray = c, t end
        end
        if not comp then continue end

        local customerModel = npc.Instance
        if not customerModel or not customerModel.Parent then continue end
        local function skipNpc() ready(npc, "Deliver", 1.5) end

        if not moveTo(customerModel) then skipNpc() continue end
        if not aliveFn() then return false end
        if tray.Parent ~= player.Character and not equip(tray) then skipNpc() continue end

        local live = restaurant.State.RestaurantOrders()[order.OrderId]
        local liveNpc = customer(live and live.CustomerId)
        if not live or live.OrderStatus == "Delivered"
            or live.CustomerId ~= order.CustomerId
            or not liveNpc or liveNpc ~= npc or not usable(liveNpc)
            or liveNpc.Instance:GetAttribute("NPCUid") ~= live.CustomerId
            or not comp:_IsTrayCorrectForOrder(live) then
            skipNpc()
            continue
        end

        local success = invoke(npc, "Deliver", function()
            local latest = restaurant.State.RestaurantOrders()[order.OrderId]
            if not latest or latest.OrderStatus == "Delivered"
                or latest.CustomerId ~= npcId
                or not comp:_IsTrayCorrectForOrder(latest) then
                return false
            end
            return restaurantController.Server:DeliverOrder(npcId)
        end, 0.8)

        local deadline = os.clock() + 2
        while aliveFn() and success and os.clock() < deadline do
            local latest = restaurant.State.RestaurantOrders()[order.OrderId]
            if not latest or latest.OrderStatus == "Delivered" then return true end
            task.wait(0.05)
        end
        return false
    end

    if heldOnly then return false end
    if not hasInventoryRoom() then return false end
    for _, order in ordered() do
        if order.OrderStatus ~= "Prepared" then continue end
        if Inspector.isInspector(order, customer(order.CustomerId)) then continue end
        for _, counter in all("TrayCounter") do
            for _, model in counter.Instance:GetChildren() do
                if model:IsA("Model") and model:GetAttribute("OrderId") == order.OrderId then
                    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and prompt.Enabled and due(prompt, "Prompt") then
                        return firePrompt(prompt, function()
                            local live = restaurant.State.RestaurantOrders()[order.OrderId]
                            return hasInventoryRoom() and live ~= nil
                                and live.OrderStatus == "Prepared"
                                and live.CustomerId == order.CustomerId
                        end)
                    end
                end
            end
        end
    end
    return false
end

BZ:AddToggle("auto_serve", "Auto Deliver Order", false, function(s)
    serveToken += 1
    local token = serveToken
    if not s then return end
    task.spawn(function()
        while serveToken == token do
            local ok, didWork = withLock(function()
                return Inspector.inspectorStep(token) or serveStep(token, true) or serveStep(token, false)
            end, true)
            if ok and didWork then task.wait(0.1) else task.wait(0.5) end
        end
    end)
end, "switch")

collectToken = 0
local function collectMoney()
    for prompt in prompts do
        if prompt.Parent and prompt.Enabled
            and prompt.ObjectText == "Money"
            and prompt.ActionText == "Collect"
            and due(prompt, "Prompt") then
            return firePrompt(prompt)
        end
    end
    return false
end

BZ:AddToggle("auto_collect_money", "Auto Collect Money", false, function(s)
    collectToken += 1
    local token = collectToken
    if not s then return end
    task.spawn(function()
        while collectToken == token do
            local ok, didWork = withLock(function() return collectMoney() end)
            if ok and didWork then task.wait(0.1) else task.wait(0.5) end
        end
    end)
end, "switch")
end

BZ:EndGroup()

BZ:AddCategory("teleport", "Teleport", "map-pin")
for _, entry in ipairs(teleportLocations) do
    local name = entry[1]
    BZ:AddTapToggleOneClick("tp_" .. name:gsub("%s", "_"), name, function() queueTeleport(name) end)
end
BZ:AddTapToggleOneClick("tp_previous", "Previous Position", function() queueTeleport("Previous Position") end)

task.spawn(function()
    while true do
        task.wait(0.15)
        local success, err = pcall(function()

            if session.PendingTeleport then
                local cp = customPlayers:GetCustomPlayer()
                if cp and cp:CanPerformAction() and not busyCleaning() and not cameraSlice.State.InCutscene() then
                    teleportQueued()
                end
                return
            end

            if state.Skip then
                local s, e = pcall(skipCutscene); if not s then report(e) end
            end

            if session.ManualUntil > os.clock() then return end
            if not cycle.State.Running() or cameraSlice.State.InCutscene() then return end
            local cp = customPlayers:GetCustomPlayer()
            if not cp or not cp:CanPerformAction() or busyCleaning() then return end

            if state.NextShift and cycle.State.CurrentPhase() == "NightShift" and slasherActive() then
                if nextShift() then return end
            end

            if state.Bosses and escapeBosses() then return priorityProgress() end

            if (state.Plankton or state.Bosses) and kickPlankton(true) then return priorityProgress() end

            if state.Bosses and defeatBosses(true) then return priorityProgress() end

            if state.Energy and session.PendingSip then if refillEnergy() then return end end

            if state.Fire and fireThreat(true) and extinguishFires(true) then return priorityProgress() end

            if state.Bosses and defeatBosses(false) then return priorityProgress() end

            if (state.Plankton or state.Bosses) and kickPlankton(false) then return priorityProgress() end

            if state.Troublemakers and removeTroublemakers() then return priorityProgress() end

            if state.Fire and extinguishFires(true) then return priorityProgress() end

            if priorityBusy() then return end

            if state.Energy and refillEnergy() then return end

            if (state.Clean or state.Bosses) and returnMop() then return end

            local phase = cycle.State.CurrentPhase()
            if phase == "DayShift" then
                if state.Repair and smartRepair(true) then return end
                if state.Accept and acceptOrder() then return end
            end

            if state.Fire and extinguishFires(false) then return end
            if state.Repair and smartRepair(false) then return end
            if state.Upgrades and smartUpgrades() then return end
            if state.NextShift and nextShift() then return end
        end)
        if not success then
            report(err)
            stopBossCleaning(); stopExtinguishing()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if state.Assemble and not priorityBusy(true) and cycle.State.Running() and cycle.State.CurrentPhase() == "DayShift" and not cameraSlice.State.InCutscene() then
            local ok, err = pcall(autoAssemble)
            if not ok then report(err) end
        end
    end
end)

BZ:AddCategory("setting", "Setting", "setting")
BZ:AddTapToggleOneClick("stop_all", "Stop All Features", function()
    for k in pairs(state) do
        if type(state[k]) == "boolean" then state[k] = false end
    end
    state.DutchmanDeals = false
    running = false
    stopCook()
    stopBossCleaning(); stopExtinguishing()
    mopToken += 1; stationToken += 1; wipeToken += 1; takeoutToken += 1
    serveToken += 1; collectToken += 1
    releaseAnchor()
end)

session.AntiAfk = true
player.Idled:Connect(function()
    if not session.AntiAfk then return end
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)
BZ:AddToggle("anti_afk", "Anti AFK", true, function(s) session.AntiAfk = s end, "switch")
