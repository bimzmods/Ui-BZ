local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local guiName = "BZ_Menu_GUI"

local old = CoreGui:FindFirstChild(guiName)
if old then old:Destroy() end
old = player:WaitForChild("PlayerGui"):FindFirstChild(guiName)
if old then old:Destroy() end
for _, parent in ipairs({ CoreGui, player:WaitForChild("PlayerGui") }) do
    local oldPicker = parent:FindFirstChild(guiName .. "_Picker")
    if oldPicker then oldPicker:Destroy() end
end

local CFG = {
    Colors = {
        Bg        = Color3.fromRGB(22, 21, 27),
        Surface   = Color3.fromRGB(37, 35, 45),
        Surface2  = Color3.fromRGB(53, 51, 64),
        Accent    = Color3.fromRGB(191, 90, 242),
        Text      = Color3.fromRGB(245, 245, 247),
        TextDim   = Color3.fromRGB(150, 150, 162),
        Stroke    = Color3.fromRGB(66, 64, 80),
        On        = Color3.fromRGB(48, 209, 88),
        Off       = Color3.fromRGB(72, 70, 86),
    },
    Font      = Enum.Font.BuilderSans,
    FontBold  = Enum.Font.BuilderSansBold,
    MenuWDef  = 520,
    MenuHDef  = 720,
    MenuWMin  = 220,
    MenuHMin  = 240,
    MenuWMax  = 520,
    MenuHMax  = 720,
    HeaderH   = 52,
    LogoGap   = 12,
    ScreenPad = 10,
    LogoStart = UDim2.new(0, 40, 0.5, -28),
    ConfigDir = "BZ Menu",
    CacheDir = "BZ Menu/cache",
    ConfigFile = "BZ Menu/BZ_" .. tostring(game.GameId) .. "_Config.json",
}
local C = CFG.Colors
local Font, FontBold = CFG.Font, CFG.FontBold

local function palette(t)
    return {
        Bg = Color3.fromRGB(t[1][1], t[1][2], t[1][3]),
        Surface = Color3.fromRGB(t[2][1], t[2][2], t[2][3]),
        Surface2 = Color3.fromRGB(t[3][1], t[3][2], t[3][3]),
        Accent = Color3.fromRGB(t[4][1], t[4][2], t[4][3]),
        Text = Color3.fromRGB(t[5][1], t[5][2], t[5][3]),
        TextDim = Color3.fromRGB(t[6][1], t[6][2], t[6][3]),
        Stroke = Color3.fromRGB(t[7][1], t[7][2], t[7][3]),
        On = Color3.fromRGB(t[8][1], t[8][2], t[8][3]),
        Off = Color3.fromRGB(t[9][1], t[9][2], t[9][3]),
    }
end

local THEME_ORDER = { "Cyan", "Kuning", "Merah", "Ungu", "Sakura", "White", "Black" }
local THEMES = {
    Ungu   = palette({{22,21,27},{37,35,45},{53,51,64},{191,90,242},{245,245,247},{150,150,162},{66,64,80},{48,209,88},{72,70,86}}),
    Cyan   = palette({{18,24,28},{31,40,46},{45,57,65},{64,200,224},{245,247,248},{146,158,165},{58,72,80},{48,209,88},{66,80,89}}),
    Kuning = palette({{27,25,18},{43,40,29},{60,56,41},{255,214,10},{247,246,240},{160,156,140},{76,71,52},{48,209,88},{82,77,58}}),
    Merah  = palette({{28,19,20},{45,31,33},{63,44,46},{255,69,58},{248,243,243},{166,148,150},{80,56,58},{48,209,88},{88,62,64}}),
    Sakura = palette({{30,22,26},{48,36,42},{66,50,58},{255,138,180},{250,244,247},{170,150,160},{84,62,72},{48,209,88},{92,70,80}}),
    White  = palette({{242,242,247},{254,254,254},{229,229,234},{0,122,255},{28,28,30},{138,138,142},{214,214,219},{52,199,89},{200,200,206}}),
    Black  = palette({{4,4,5},{22,22,24},{40,40,43},{10,132,255},{245,245,247},{140,140,148},{52,52,56},{48,209,88},{64,64,69}}),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() screenGui.Parent = CoreGui end)
if not ok then screenGui.Parent = player:WaitForChild("PlayerGui") end

local LOGO_H = 44
local logo = Instance.new("Frame", screenGui)
logo.Name = "Logo"
logo.AnchorPoint = Vector2.new(0.5, 0)
logo.Position = UDim2.new(0.5, 0, 0, 14)
logo.Size = UDim2.new(0, 0, 0, LOGO_H)
logo.AutomaticSize = Enum.AutomaticSize.X
logo.BackgroundColor3 = C.Bg
logo.BorderSizePixel = 0
logo.Active = true
Instance.new("UICorner", logo).CornerRadius = UDim.new(1, 0)
local logoStroke = Instance.new("UIStroke", logo)
logoStroke.Color = C.Stroke
logoStroke.Thickness = 1

local logoPad = Instance.new("UIPadding", logo)
logoPad.PaddingLeft = UDim.new(0, 5)
logoPad.PaddingRight = UDim.new(0, 16)
local logoList = Instance.new("UIListLayout", logo)
logoList.FillDirection = Enum.FillDirection.Horizontal
logoList.VerticalAlignment = Enum.VerticalAlignment.Center
logoList.SortOrder = Enum.SortOrder.LayoutOrder
logoList.Padding = UDim.new(0, 10)

local logoBadge = Instance.new("Frame", logo)
logoBadge.Name = "Badge"
logoBadge.LayoutOrder = 1
logoBadge.Size = UDim2.fromOffset(LOGO_H - 10, LOGO_H - 10)
logoBadge.BackgroundColor3 = C.Accent
logoBadge.BorderSizePixel = 0
logoBadge.ClipsDescendants = true
Instance.new("UICorner", logoBadge).CornerRadius = UDim.new(1, 0)

local logoText = Instance.new("TextLabel", logoBadge)
logoText.Size = UDim2.fromScale(1, 1)
logoText.BackgroundTransparency = 1
logoText.Text = "BZ"
logoText.Font = FontBold
logoText.TextSize = 14
logoText.TextColor3 = C.Bg

local logoImage = Instance.new("ImageLabel", logoBadge)
logoImage.Name = "LogoImage"
logoImage.Size = UDim2.fromScale(1, 1)
logoImage.BackgroundTransparency = 1
logoImage.BorderSizePixel = 0
logoImage.ScaleType = Enum.ScaleType.Crop
logoImage.Image = ""
logoImage.Visible = false
Instance.new("UICorner", logoImage).CornerRadius = UDim.new(1, 0)

local logoStats = Instance.new("TextLabel", logo)
logoStats.Name = "Stats"
logoStats.LayoutOrder = 2
logoStats.Size = UDim2.new(0, 0, 1, 0)
logoStats.AutomaticSize = Enum.AutomaticSize.X
logoStats.BackgroundTransparency = 1
logoStats.Text = "FPS: 60 | Ping: 0ms"
logoStats.Font = FontBold
logoStats.TextSize = 17
logoStats.TextColor3 = C.Text
logoStats.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    local RunService = game:GetService("RunService")
    local frames, acc = 0, 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        frames = frames + 1
        acc = acc + dt
    end)
    while screenGui.Parent do
        task.wait(1.5)
        if logo.Visible and logoStats.Visible then
            local fps = acc > 0 and math.floor(frames / acc + 0.5) or 0
            frames, acc = 0, 0
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            end)
            logoStats.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
        else
            frames, acc = 0, 0
        end
    end
    conn:Disconnect()
end)

local menu = Instance.new("Frame", screenGui)
menu.Name = "Menu"
menu.Size = UDim2.fromOffset(CFG.MenuWDef, CFG.MenuHDef)
menu.Position = UDim2.fromOffset(40, 100)
menu.BackgroundColor3 = C.Bg
menu.BorderSizePixel = 0
menu.Visible = false
menu.ClipsDescendants = true
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 22)
local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = C.Stroke
menuStroke.Thickness = 1
local menuScale = Instance.new("UIScale", menu)
menuScale.Scale = 1

local header = Instance.new("Frame", menu)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, CFG.HeaderH)
header.BackgroundColor3 = C.Bg
header.BackgroundTransparency = 1
header.BorderSizePixel = 0
local headerLine = Instance.new("Frame", header)
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = C.Stroke
headerLine.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -60, 0, 22)
title.Position = UDim2.fromOffset(18, 8)
title.BackgroundTransparency = 1
title.Text = "BZ Menu"
title.Font = FontBold
title.TextSize = 17
title.TextColor3 = C.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.TextTruncate = Enum.TextTruncate.AtEnd

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -60, 0, 14)
subtitle.Position = UDim2.fromOffset(18, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "v3.9 · Studio The Clown"
subtitle.Font = Font
subtitle.TextSize = 11
subtitle.TextColor3 = C.TextDim
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.TextTruncate = Enum.TextTruncate.AtEnd

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 12)
closeBtn.BackgroundColor3 = C.Surface2
closeBtn.AutoButtonColor = false
closeBtn.Text = ""
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local closeIcon = Instance.new("TextLabel", closeBtn)
closeIcon.Size = UDim2.fromScale(1, 1)
closeIcon.BackgroundTransparency = 1
closeIcon.Text = "×"
closeIcon.Font = FontBold
closeIcon.TextSize = 20
closeIcon.TextColor3 = C.TextDim

local SIDE_W = 108
local SIDE_C = 44
local sideCollapsed = false

local tabBar = Instance.new("ScrollingFrame", menu)
tabBar.Name = "Sidebar"
tabBar.Size = UDim2.new(0, SIDE_W, 1, -CFG.HeaderH)
tabBar.Position = UDim2.fromOffset(0, CFG.HeaderH)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.ScrollBarThickness = 0
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabBar.ScrollingDirection = Enum.ScrollingDirection.Y
tabBar.Visible = false

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingTop = UDim.new(0, 8)
tabPad.PaddingBottom = UDim.new(0, 28)
tabPad.PaddingLeft = UDim.new(0, 8)
tabPad.PaddingRight = UDim.new(0, 8)

local collapseBtn = Instance.new("TextButton", tabBar)
collapseBtn.Name = "Collapse"
collapseBtn.LayoutOrder = 0
collapseBtn.Size = UDim2.new(1, 0, 0, 26)
collapseBtn.BackgroundColor3 = C.Surface2
collapseBtn.BackgroundTransparency = 1
collapseBtn.AutoButtonColor = false
collapseBtn.Text = ""
Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(0, 8)
for i = 0, 2 do
    local ln = Instance.new("Frame", collapseBtn)
    ln.AnchorPoint = Vector2.new(0.5, 0.5)
    ln.Position = UDim2.new(0.5, 0, 0.5, (i - 1) * 5)
    ln.Size = UDim2.fromOffset(14, 2)
    ln.BackgroundColor3 = C.TextDim
    ln.BorderSizePixel = 0
    Instance.new("UICorner", ln).CornerRadius = UDim.new(1, 0)
end

local sideLine = Instance.new("Frame", menu)
sideLine.Name = "SideLine"
sideLine.Size = UDim2.new(0, 1, 1, -CFG.HeaderH)
sideLine.Position = UDim2.fromOffset(SIDE_W, CFG.HeaderH)
sideLine.BackgroundColor3 = C.Stroke
sideLine.BorderSizePixel = 0
sideLine.Visible = false

local contentArea = Instance.new("Frame", menu)
contentArea.Name = "Content"
contentArea.Size = UDim2.new(1, 0, 1, -CFG.HeaderH)
contentArea.Position = UDim2.fromOffset(0, CFG.HeaderH)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true

local function makeBody()
    local b = Instance.new("ScrollingFrame", contentArea)
    b.Name = "Body"
    b.Size = UDim2.fromScale(1, 1)
    b.Position = UDim2.fromOffset(0, 0)
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.ScrollBarThickness = 3
    b.ScrollBarImageColor3 = C.TextDim
    b.ScrollBarImageTransparency = 0.5
    b.CanvasSize = UDim2.new(0, 0, 0, 0)
    b.AutomaticCanvasSize = Enum.AutomaticSize.Y
    b.ScrollingDirection = Enum.ScrollingDirection.Y
    b.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    b.Visible = false

    local layout = Instance.new("UIListLayout", b)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", b)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 28)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    return b
end

local resizeHandles = {}

local function addResizeHandle(frame, sx, sy)
    resizeHandles[#resizeHandles + 1] = { frame = frame, sx = sx, sy = sy }
end

local resizeHandle = Instance.new("Frame", menu)
resizeHandle.Name = "ResizeHandle"
resizeHandle.Position = UDim2.new(1, -28, 1, -28)
resizeHandle.Size = UDim2.fromOffset(28, 28)
resizeHandle.BackgroundTransparency = 1
resizeHandle.BorderSizePixel = 0
resizeHandle.Active = true
resizeHandle.ZIndex = 5

local arcClip = Instance.new("Frame", resizeHandle)
arcClip.Name = "ArcClip"
arcClip.Position = UDim2.new(1, -18, 1, -18)
arcClip.Size = UDim2.fromOffset(18, 18)
arcClip.BackgroundTransparency = 1
arcClip.BorderSizePixel = 0
arcClip.ClipsDescendants = true
arcClip.ZIndex = 6

local arc = Instance.new("Frame", arcClip)
arc.Name = "Arc"
arc.Position = UDim2.fromOffset(-21, -21)
arc.Size = UDim2.fromOffset(34, 34)
arc.BackgroundTransparency = 1
arc.BorderSizePixel = 0
arc.ZIndex = 6
Instance.new("UICorner", arc).CornerRadius = UDim.new(1, 0)
local arcStroke = Instance.new("UIStroke", arc)
arcStroke.Color = C.TextDim
arcStroke.Thickness = 2.5
arcStroke.Transparency = 0.2

resizeHandle.MouseEnter:Connect(function()
    TweenService:Create(arcStroke, TweenInfo.new(0.12), {Color = C.Text, Transparency = 0}):Play()
end)
resizeHandle.MouseLeave:Connect(function()
    TweenService:Create(arcStroke, TweenInfo.new(0.12), {Color = C.TextDim, Transparency = 0.2}):Play()
end)
addResizeHandle(resizeHandle, 1, 1)

local bottomEdge = Instance.new("Frame", menu)
bottomEdge.Name = "ResizeBottom"
bottomEdge.Position = UDim2.new(0, 22, 1, -14)
bottomEdge.Size = UDim2.new(1, -50, 0, 14)
bottomEdge.BackgroundTransparency = 1
bottomEdge.BorderSizePixel = 0
bottomEdge.Active = true
bottomEdge.ZIndex = 5

local grabber = Instance.new("Frame", bottomEdge)
grabber.Name = "Grabber"
grabber.AnchorPoint = Vector2.new(0.5, 0.5)
grabber.Position = UDim2.fromScale(0.5, 0.5)
grabber.Size = UDim2.fromOffset(96, 5)
grabber.BackgroundColor3 = C.Text
grabber.BackgroundTransparency = 0.45
grabber.BorderSizePixel = 0
grabber.ZIndex = 6
Instance.new("UICorner", grabber).CornerRadius = UDim.new(1, 0)
bottomEdge.MouseEnter:Connect(function()
    TweenService:Create(grabber, TweenInfo.new(0.12), {BackgroundTransparency = 0.15}):Play()
end)
bottomEdge.MouseLeave:Connect(function()
    TweenService:Create(grabber, TweenInfo.new(0.12), {BackgroundTransparency = 0.45}):Play()
end)
addResizeHandle(bottomEdge, 0, 1)

local registry = {}
local layoutCounter = 0

local function readConfig()
    if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then return nil end
    local okf, exists = pcall(isfile, CFG.ConfigFile)
    if not okf or not exists then return nil end
    local okr, raw = pcall(readfile, CFG.ConfigFile)
    if not okr then return nil end
    local okd, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if okd and type(data) == "table" and type(data.items) == "table" then
        return data.items
    end
    return nil
end

local pendingConfig = readConfig() or {}

local function applyPending(name)
    local v = pendingConfig[name]
    local e = registry[name]
    if v == nil or not e then return end
    local want = (e.kind == "toggle" and "boolean")
        or (e.kind == "slider" and "number")
        or (e.kind == "select" and "string")
        or (e.kind == "multiselect" and "table")
        or (e.kind == "keybind" and "string")
        or (e.kind == "color" and "string")
    if want and type(v) == want then e.set(v) end
end
local activeSlider = nil
local activeInput = nil
local activeBody = nil
local activeSelectClose = nil

local function nextOrder()
    layoutCounter = layoutCounter + 1
    return layoutCounter
end

local API = {}

local categories = {}
local categoryOrder = 0
local currentCat = nil
local selectedCat = nil

local LucideIcons = {}
pcall(function()
    LucideIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
end)

local ICON_ALIASES = {
    ["gear"] = "settings",
    ["cog"] = "settings",
    ["cogs"] = "settings",
    ["home"] = "house",
    ["bolt"] = "zap",
    ["lightning"] = "zap",
    ["flash"] = "zap",
    ["people"] = "users",
    ["user-group"] = "users",
    ["crosshairs"] = "crosshair",
    ["aim"] = "crosshair",
    ["location"] = "map-pin",
    ["map-marker"] = "map-pin",
    ["pin"] = "map-pin",
    ["teleport"] = "map-pin",
    ["tools"] = "wrench",
    ["gamepad"] = "gamepad-2",
    ["controller"] = "gamepad-2",
    ["magic"] = "sparkles",
    ["wand"] = "wand-sparkles",
    ["running"] = "person-standing",
    ["run"] = "person-standing",
    ["walk"] = "person-standing",
    ["money"] = "coins",
    ["coin"] = "coins",
    ["dollar"] = "dollar-sign",
    ["close"] = "x",
    ["times"] = "x",
    ["xmark"] = "x",
    ["warning"] = "triangle-alert",
    ["triangle-exclamation"] = "triangle-alert",
    ["check"] = "circle-check",
    ["search"] = "search",
    ["magnifying-glass"] = "search",
    ["save"] = "save",
    ["floppy-disk"] = "save",
    ["earth"] = "globe",
    ["paint-brush"] = "palette",
    ["paintbrush"] = "palette",
    ["face-ghost"] = "ghost",
    ["eye-slash"] = "eye-off",
    ["hide"] = "eye-off",
    ["sword"] = "sword",
    ["swords"] = "swords",
    ["dagger"] = "sword",
    ["terminal"] = "terminal",
    ["code"] = "code",
    ["laptop-code"] = "code",
    ["list"] = "list",
    ["unlock"] = "lock-open"
}

local function resolveIcon(icon)
    if icon == nil or icon == "" then return nil end
    if type(icon) == "number" then
        return "image", "rbxassetid://" .. tostring(icon)
    end
    local str = tostring(icon)
    if str:match("^%d+$") then
        return "image", "rbxassetid://" .. str
    end
    if str:match("^rbxassetid://") or str:match("^rbxasset://") then
        return "image", str
    end
    local key = str:lower():gsub("^lucide:", ""):match("([%w%-_]+)%s*$") or ""
    key = key:gsub("_", "-")
    key = key:gsub("^fa%-", "")
    key = ICON_ALIASES[key] or key
    if LucideIcons[key] then return "image", LucideIcons[key] end
    return "text", str
end

local function makeTabIcon(parent, icon)
    local kind, value = resolveIcon(icon)
    if not kind then return nil end
    local obj
    if kind == "image" then
        obj = Instance.new("ImageLabel", parent)
        obj.Size = UDim2.fromOffset(14, 14)
        obj.BackgroundTransparency = 1
        obj.Image = value
        obj.ImageColor3 = C.TextDim
    else
        obj = Instance.new("TextLabel", parent)
        obj.Size = UDim2.new(0, 18, 1, 0)
        obj.BackgroundTransparency = 1
        obj.Text = value
        obj.Font = FontBold
        obj.TextSize = 14
        obj.TextColor3 = C.TextDim
    end
    obj.Name = "Icon"
    obj.LayoutOrder = 1
    return obj
end

local function makeLetterIcon(parent, text)
    local ch = "•"
    if text and text ~= "" then
        local ok, cp = pcall(utf8.codepoint, text, 1)
        if ok then ch = string.upper(utf8.char(cp)) end
    end
    local obj = Instance.new("TextLabel", parent)
    obj.Name = "Icon"
    obj.LayoutOrder = 1
    obj.Size = UDim2.new(0, 18, 1, 0)
    obj.BackgroundTransparency = 1
    obj.Text = ch
    obj.Font = FontBold
    obj.TextSize = 14
    obj.TextColor3 = C.TextDim
    return obj
end

local function relayout(animate)
    local w = 0
    if tabBar.Visible then w = sideCollapsed and SIDE_C or SIDE_W end
    local sideSize = UDim2.new(0, w, 1, -CFG.HeaderH)
    local contentPos = UDim2.fromOffset(w, CFG.HeaderH)
    local contentSize = UDim2.new(1, -w, 1, -CFG.HeaderH)
    sideLine.Visible = tabBar.Visible
    if animate then
        local info = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
        TweenService:Create(tabBar, info, {Size = sideSize}):Play()
        TweenService:Create(contentArea, info, {Position = contentPos, Size = contentSize}):Play()
        TweenService:Create(sideLine, info, {Position = contentPos}):Play()
    else
        tabBar.Size = sideSize
        contentArea.Position = contentPos
        contentArea.Size = contentSize
        sideLine.Position = contentPos
    end
end

function API:SetSidebarCollapsed(collapsed)
    sideCollapsed = collapsed and true or false
    for _, cat in pairs(categories) do
        cat.layout.HorizontalAlignment = sideCollapsed and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
        cat.label.Visible = (cat.label.Text ~= "") and not sideCollapsed
    end
    relayout(true)
end

function API:ToggleSidebar()
    API:SetSidebarCollapsed(not sideCollapsed)
end

collapseBtn.MouseButton1Click:Connect(function() API:ToggleSidebar() end)

local animToken = 0
local SLIDE_TIME = 0.25

function API:SelectCategory(name)
    local target = categories[name]
    if not target or selectedCat == name then return end
    local prev = selectedCat and categories[selectedCat]
    selectedCat = name

    for n, cat in pairs(categories) do
        local on = (n == name)
        local info = TweenInfo.new(0.15)
        TweenService:Create(cat.button, info, {BackgroundTransparency = on and 0 or 1}):Play()
        TweenService:Create(cat.label, info, {TextColor3 = on and C.Text or C.TextDim}):Play()
        if cat.icon then
            local prop = cat.icon:IsA("ImageLabel") and "ImageColor3" or "TextColor3"
            TweenService:Create(cat.icon, info, {[prop] = on and C.Accent or C.TextDim}):Play()
        end
    end

    local y = target.body.Position.Y.Offset

    if not prev or not menu.Visible then
        animToken = animToken + 1
        for _, cat in pairs(categories) do
            cat.body.Visible = (cat == target)
            cat.body.Position = UDim2.new(0, 0, 0, y)
        end
        return
    end

    local dir = (target.button.LayoutOrder > prev.button.LayoutOrder) and 1 or -1

    animToken = animToken + 1
    local token = animToken

    for _, cat in pairs(categories) do
        if cat ~= prev and cat ~= target then
            cat.body.Visible = false
            cat.body.Position = UDim2.new(0, 0, 0, y)
        end
    end

    if not target.body.Visible then
        target.body.Position = UDim2.new(0, 0, dir, y)
        target.body.Visible = true
    end

    local info = TweenInfo.new(SLIDE_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(target.body, info, {Position = UDim2.new(0, 0, 0, y)}):Play()
    TweenService:Create(prev.body, info, {Position = UDim2.new(0, 0, -dir, y)}):Play()

    task.delay(SLIDE_TIME + 0.02, function()
        if token ~= animToken then return end
        prev.body.Visible = false
        prev.body.Position = UDim2.new(0, 0, 0, y)
    end)
end

local function createCategory(name, labelText, explicit, opts)
    if categories[name] then return categories[name] end
    categoryOrder = categoryOrder + 1

    local btn = Instance.new("TextButton", tabBar)
    btn.Name = name .. "_Tab"
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.Surface2
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = (opts and opts.order) or categoryOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local p = Instance.new("UIPadding", btn)
    p.PaddingLeft = UDim.new(0, 8)
    p.PaddingRight = UDim.new(0, 6)
    local tabLay = Instance.new("UIListLayout", btn)
    tabLay.FillDirection = Enum.FillDirection.Horizontal
    tabLay.Padding = UDim.new(0, 6)
    tabLay.SortOrder = Enum.SortOrder.LayoutOrder
    tabLay.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLay.HorizontalAlignment = sideCollapsed and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left

    local text = (labelText == nil) and name or labelText
    local cat = { body = makeBody(), button = btn, layout = tabLay }
    cat.icon = makeTabIcon(btn, opts and opts.icon) or makeLetterIcon(btn, text)

    local labelObj = Instance.new("TextLabel", btn)
    labelObj.Name = "Label"
    labelObj.LayoutOrder = 2
    labelObj.Size = UDim2.new(1, -24, 1, 0)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = text
    labelObj.Font = FontBold
    labelObj.TextSize = 12
    labelObj.TextColor3 = C.TextDim
    labelObj.TextXAlignment = Enum.TextXAlignment.Left
    labelObj.TextTruncate = Enum.TextTruncate.AtEnd
    labelObj.Visible = (text ~= "") and not sideCollapsed
    cat.label = labelObj
    categories[name] = cat
    btn.MouseButton1Click:Connect(function() API:SelectCategory(name) end)

    if explicit then tabBar.Visible = true end
    relayout()
    if not selectedCat and not (opts and opts.noSelect) then API:SelectCategory(name) end
    return cat
end

function API:AddCategory(name, labelText, icon)
    createCategory(name, labelText, true, { icon = icon })
    currentCat = name
    return categories[name]
end

function API:SetCategoryIcon(name, icon)
    local cat = categories[name]
    if not cat then return end
    if cat.icon then
        cat.icon:Destroy()
        cat.icon = nil
    end
    cat.icon = makeTabIcon(cat.button, icon) or makeLetterIcon(cat.button, cat.label.Text)
    if cat.icon then
        local fg = (selectedCat == name) and C.Accent or C.TextDim
        local prop = cat.icon:IsA("ImageLabel") and "ImageColor3" or "TextColor3"
        cat.icon[prop] = fg
    end
end

function API:UseCategory(name)
    if categories[name] then currentCat = name end
end

local function currentBody()
    if not currentCat then
        createCategory("main", "Main", false, { icon = "home" })
        currentCat = "main"
    end
    return categories[currentCat].body
end

function API:AddSection(text)
    local lbl = Instance.new("TextLabel", currentBody())
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.Font = Font
    lbl.TextSize = 12
    lbl.TextColor3 = C.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Bottom
    lbl.LayoutOrder = nextOrder()
    Instance.new("UIPadding", lbl).PaddingLeft = UDim.new(0, 6)
    return lbl
end

local TOGGLE_ALIASES = {
    switch = "switch", toggle = "switch",
    checkbox = "checkbox", check = "checkbox", box = "checkbox",
    radio = "radio", dot = "radio",
    pill = "pill", onoff = "pill",
    button = "button", fill = "button",
}
local defaultToggleStyle = "switch"

local function normalizeToggleStyle(style)
    return TOGGLE_ALIASES[string.lower(tostring(style or ""))]
end

function API:SetDefaultToggleStyle(style)
    local st = normalizeToggleStyle(style)
    if st then defaultToggleStyle = st end
end

function API:AddToggle(name, labelText, default, callback, style)
    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = C.Stroke
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("Frame", row)
    box.Name = "Indicator"
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -14, 0.5, 0)
    box.Size = UDim2.fromOffset(56, 32)
    box.BackgroundTransparency = 1

    local clickArea = Instance.new("TextButton", row)
    clickArea.Size = UDim2.fromScale(1, 1)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""

    local function put(inst, props, animate)
        if animate then
            TweenService:Create(inst, TweenInfo.new(0.18, Enum.EasingStyle.Quart), props):Play()
        else
            for k, v in pairs(props) do inst[k] = v end
        end
    end

    local builders = {}

    builders.switch = function()
        local track = Instance.new("Frame", box)
        track.AnchorPoint = Vector2.new(1, 0.5)
        track.Position = UDim2.new(1, 0, 0.5, 0)
        track.Size = UDim2.fromOffset(44, 24)
        track.BackgroundColor3 = C.Off
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame", track)
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.Position = UDim2.new(0, 3, 0.5, 0)
        knob.Size = UDim2.fromOffset(18, 18)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        return function(on, animate)
            put(track, {BackgroundColor3 = on and C.On or C.Off}, animate)
            put(knob, {Position = on and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, animate)
        end
    end

    builders.checkbox = function()
        local cb = Instance.new("Frame", box)
        cb.AnchorPoint = Vector2.new(1, 0.5)
        cb.Position = UDim2.new(1, 0, 0.5, 0)
        cb.Size = UDim2.fromOffset(22, 22)
        cb.BackgroundColor3 = C.Surface2
        cb.BorderSizePixel = 0
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 7)
        local st = Instance.new("UIStroke", cb)
        st.Color = C.Stroke
        st.Thickness = 1.5

        local fill = Instance.new("Frame", cb)
        fill.AnchorPoint = Vector2.new(0.5, 0.5)
        fill.Position = UDim2.fromScale(0.5, 0.5)
        fill.Size = UDim2.fromOffset(0, 0)
        fill.BackgroundColor3 = C.On
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        return function(on, animate)
            put(st, {Color = on and C.On or C.Stroke}, animate)
            put(fill, {Size = on and UDim2.fromOffset(12, 12) or UDim2.fromOffset(0, 0)}, animate)
        end
    end

    builders.radio = function()
        local ring = Instance.new("Frame", box)
        ring.AnchorPoint = Vector2.new(1, 0.5)
        ring.Position = UDim2.new(1, 0, 0.5, 0)
        ring.Size = UDim2.fromOffset(22, 22)
        ring.BackgroundColor3 = C.Surface2
        ring.BorderSizePixel = 0
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        local st = Instance.new("UIStroke", ring)
        st.Color = C.Stroke
        st.Thickness = 1.5
        local dot = Instance.new("Frame", ring)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.fromScale(0.5, 0.5)
        dot.Size = UDim2.fromOffset(0, 0)
        dot.BackgroundColor3 = C.On
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        return function(on, animate)
            put(st, {Color = on and C.On or C.Stroke}, animate)
            put(dot, {Size = on and UDim2.fromOffset(10, 10) or UDim2.fromOffset(0, 0)}, animate)
        end
    end

    builders.pill = function()
        local pill = Instance.new("Frame", box)
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, 0, 0.5, 0)
        pill.Size = UDim2.fromOffset(46, 22)
        pill.BackgroundColor3 = C.Off
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 8)
        local txt = Instance.new("TextLabel", pill)
        txt.Size = UDim2.fromScale(1, 1)
        txt.BackgroundTransparency = 1
        txt.Text = "OFF"
        txt.Font = FontBold
        txt.TextSize = 11
        txt.TextColor3 = C.TextDim
        return function(on, animate)
            txt.Text = on and "ON" or "OFF"
            put(pill, {BackgroundColor3 = on and C.On or C.Off}, animate)
            put(txt, {TextColor3 = on and C.Bg or C.TextDim}, animate)
        end
    end

    builders.button = function()
        return function(on, animate)
            put(row, {BackgroundColor3 = on and C.Accent or C.Surface}, animate)
            put(lbl, {TextColor3 = on and C.Bg or C.Text}, animate)
            put(rowStroke, {Color = on and C.Accent or C.Stroke}, animate)
        end
    end

    local state = default and true or false
    local update = nil

    local function setStyle(newStyle)
        local st = normalizeToggleStyle(newStyle) or defaultToggleStyle
        box:ClearAllChildren()
        row.BackgroundColor3 = C.Surface
        lbl.TextColor3 = C.Text
        rowStroke.Color = C.Stroke
        lbl.Size = (st == "button") and UDim2.new(1, -28, 1, 0) or UDim2.new(1, -80, 1, 0)
        update = builders[st]()
        update(state, false)
    end

    local function setState(v, silent)
        state = v and true or false
        update(state, true)
        if not silent and callback then pcall(callback, state) end
    end

    setStyle(style)
    clickArea.MouseButton1Click:Connect(function() setState(not state) end)

    registry[name] = {
        kind = "toggle",
        set = setState,
        get = function() return state end,
        row = row,
        setStyle = setStyle,
    }
    if default and callback then pcall(callback, true) end
    applyPending(name)
    return registry[name]
end

function API:SetToggleStyle(name, style)
    local e = registry[name]
    if e and e.kind == "toggle" and e.setStyle then e.setStyle(style) end
end

function API:AddNote(text, name)
    local order = nextOrder()
    local row = Instance.new("Frame", currentBody())
    row.Name = (name or ("note_" .. order)) .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1
    s.Transparency = 0.6

    local pad = Instance.new("UIPadding", row)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(text or "")
    lbl.Font = Font
    lbl.TextSize = 13
    lbl.TextColor3 = C.TextDim
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top

    local handle = { row = row, label = lbl }
    function handle:SetText(t) lbl.Text = tostring(t) end

    registry[name or ("note_" .. order)] = {
        kind = "note",
        set = function(t) lbl.Text = tostring(t) end,
        get = function() return lbl.Text end,
        row = row,
    }
    return handle
end

function API:AddTapToggleOneClick(name, labelText, callback)
    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1
    s.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -66, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local mouse = Instance.new("Frame", row)
    mouse.Name = "MouseIcon"
    mouse.AnchorPoint = Vector2.new(0.5, 0.5)
    mouse.Position = UDim2.new(1, -28, 0.5, 0)
    mouse.Size = UDim2.fromOffset(18, 26)
    mouse.BackgroundColor3 = C.Surface2
    mouse.BorderSizePixel = 0
    Instance.new("UICorner", mouse).CornerRadius = UDim.new(0, 9)
    local mouseStroke = Instance.new("UIStroke", mouse)
    mouseStroke.Color = C.Accent
    mouseStroke.Thickness = 1.5

    local leftBtn = Instance.new("Frame", mouse)
    leftBtn.Name = "LeftButton"
    leftBtn.Position = UDim2.fromOffset(1, 1)
    leftBtn.Size = UDim2.fromOffset(8, 11)
    leftBtn.BackgroundColor3 = C.Off
    leftBtn.BorderSizePixel = 0
    Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 7)

    local hLine = Instance.new("Frame", mouse)
    hLine.Name = "HLine"
    hLine.Position = UDim2.fromOffset(0, 12)
    hLine.Size = UDim2.new(1, 0, 0, 1)
    hLine.BackgroundColor3 = C.Accent
    hLine.BorderSizePixel = 0

    local vLine = Instance.new("Frame", mouse)
    vLine.Name = "VLine"
    vLine.Position = UDim2.fromOffset(9, 0)
    vLine.Size = UDim2.fromOffset(1, 12)
    vLine.BackgroundColor3 = C.Accent
    vLine.BorderSizePixel = 0

    local ripple = Instance.new("Frame", mouse)
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.fromOffset(5, 7)
    ripple.Size = UDim2.fromOffset(6, 6)
    ripple.BackgroundTransparency = 1
    ripple.BorderSizePixel = 0
    ripple.Visible = false
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    local rippleStroke = Instance.new("UIStroke", ripple)
    rippleStroke.Color = C.Accent
    rippleStroke.Thickness = 1.5

    local clickArea = Instance.new("TextButton", row)
    clickArea.Size = UDim2.fromScale(1, 1)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""

    local busy = false

    local function play()
        TweenService:Create(leftBtn, TweenInfo.new(0.08), {BackgroundColor3 = C.Accent}):Play()
        ripple.Size = UDim2.fromOffset(6, 6)
        rippleStroke.Transparency = 0
        ripple.Visible = true
        TweenService:Create(ripple, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
            Size = UDim2.fromOffset(28, 28)
        }):Play()
        TweenService:Create(rippleStroke, TweenInfo.new(0.35), {Transparency = 1}):Play()
    end

    local function reset()
        TweenService:Create(leftBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Off}):Play()
        ripple.Visible = false
    end

    local function fire()
        if busy then return end
        busy = true
        play()
        if callback then pcall(callback) end
        task.delay(0.35, function()
            reset()
            busy = false
        end)
    end

    clickArea.MouseButton1Click:Connect(fire)

    registry[name] = {
        kind = "tap",
        set = fire,
        get = function() return busy end,
        row = row,
    }
    return registry[name]
end

function API:AddSelectMenu(name, labelText, options, default, callback)
    options = options or {}
    local ROW_H, ITEM_H, GAP, PAD, VISIBLE = 46, 26, 3, 4, 4
    local PILL_W = 108
    local listH = #options * ITEM_H + math.max(#options - 1, 0) * GAP + PAD * 2
    local maxH = VISIBLE * ITEM_H + (VISIBLE - 1) * GAP + PAD * 2

    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1
    s.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -(PILL_W + 26), 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local pill = Instance.new("TextButton", row)
    pill.Size = UDim2.fromOffset(PILL_W, 28)
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -12, 0.5, 0)
    pill.BackgroundColor3 = C.Surface2
    pill.BorderSizePixel = 0
    pill.AutoButtonColor = false
    pill.Text = ""
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 8)

    local valLbl = Instance.new("TextLabel", pill)
    valLbl.Size = UDim2.new(1, -26, 1, 0)
    valLbl.Position = UDim2.fromOffset(10, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = FontBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = C.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Left
    valLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local arrow = Instance.new("TextLabel", pill)
    arrow.Size = UDim2.fromOffset(16, 28)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = FontBold
    arrow.TextSize = 9
    arrow.TextColor3 = C.TextDim

    local valid = {}
    for _, opt in ipairs(options) do valid[opt] = true end

    local selected = nil

    local function setSelected(v, silent)
        if not valid[v] then return end
        selected = v
        valLbl.Text = tostring(v)
        if not silent and callback then pcall(callback, v) end
    end

    local isOpen, popup, blocker = false, nil, nil

    local function closeSelect()
        if not isOpen then return end
        isOpen = false
        if activeSelectClose == closeSelect then activeSelectClose = nil end
        local pg, bl = popup, blocker
        popup, blocker = nil, nil
        if bl then bl:Destroy() end
        if pg then
            TweenService:Create(pg, TweenInfo.new(0.12, Enum.EasingStyle.Quart), {
                Size = UDim2.fromOffset(pg.Size.X.Offset, 0)
            }):Play()
            task.delay(0.14, function() pg:Destroy() end)
        end
        TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
    end

    local function openSelect()
        if #options == 0 then return end
        if activeSelectClose then activeSelectClose() end
        isOpen = true
        activeSelectClose = closeSelect

        local width = math.max(pill.AbsoluteSize.X, 130)
        local height = math.min(listH, maxH)
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local px = pill.AbsolutePosition.X + pill.AbsoluteSize.X - width
        px = math.clamp(px, 4, math.max(vp.X - width - 4, 4))
        local py = pill.AbsolutePosition.Y + pill.AbsoluteSize.Y + 4
        if py + height > vp.Y - 4 then
            py = pill.AbsolutePosition.Y - height - 4
        end
        py = math.max(py, 4)

        blocker = Instance.new("TextButton", screenGui)
        blocker.Name = "SelectBlocker"
        blocker.Size = UDim2.fromScale(1, 1)
        blocker.BackgroundTransparency = 1
        blocker.AutoButtonColor = false
        blocker.Text = ""
        blocker.ZIndex = 49
        blocker.MouseButton1Click:Connect(closeSelect)

        popup = Instance.new("Frame", screenGui)
        popup.Name = "SelectPopup"
        popup.ZIndex = 50
        popup.Position = UDim2.fromOffset(px, py)
        popup.Size = UDim2.fromOffset(width, 0)
        popup.BackgroundColor3 = C.Surface
        popup.BorderSizePixel = 0
        popup.ClipsDescendants = true
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)
        local ps = Instance.new("UIStroke", popup)
        ps.Color = C.Stroke
        ps.Thickness = 1

        local scroll = Instance.new("ScrollingFrame", popup)
        scroll.Size = UDim2.fromScale(1, 1)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = C.Accent
        scroll.CanvasSize = UDim2.fromOffset(0, listH)
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, GAP)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", scroll)
        pad.PaddingTop = UDim.new(0, PAD)
        pad.PaddingBottom = UDim.new(0, PAD)
        pad.PaddingLeft = UDim.new(0, PAD)
        pad.PaddingRight = UDim.new(0, PAD + 2)

        local selectedIndex = 1
        for i, opt in ipairs(options) do
            local sel = (opt == selected)
            if sel then selectedIndex = i end
            local b = Instance.new("TextButton", scroll)
            b.Name = "Opt_" .. tostring(opt)
            b.LayoutOrder = i
            b.Size = UDim2.new(1, 0, 0, ITEM_H)
            b.BackgroundColor3 = C.Surface2
            b.BackgroundTransparency = sel and 0 or 1
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Text = tostring(opt)
            b.Font = Font
            b.TextSize = 13
            b.TextColor3 = sel and C.Accent or C.Text
            b.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UIPadding", b).PaddingLeft = UDim.new(0, 10)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
            b.MouseButton1Click:Connect(function()
                closeSelect()
                setSelected(opt)
            end)
        end

        local maxScroll = math.max(listH - height, 0)
        scroll.CanvasPosition = Vector2.new(0, math.clamp((selectedIndex - 1) * (ITEM_H + GAP) - (ITEM_H + GAP), 0, maxScroll))

        TweenService:Create(popup, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
            Size = UDim2.fromOffset(width, height)
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 180}):Play()
    end

    pill.MouseButton1Click:Connect(function()
        if isOpen then closeSelect() else openSelect() end
    end)

    local initial = options[1]
    if default ~= nil and valid[default] then initial = default end
    if initial ~= nil then setSelected(initial, true) end

    registry[name] = {
        kind = "select",
        set = setSelected,
        get = function() return selected end,
        row = row,
    }
    if default ~= nil and callback and selected ~= nil then pcall(callback, selected) end
    applyPending(name)
    return registry[name]
end

function API:AddMultiSelectMenu(name, labelText, options, defaults, callback)
    options = options or {}
    local ROW_H, ITEM_H, GAP, PAD, VISIBLE = 46, 26, 3, 4, 4
    local PILL_W = 108
    local listH = #options * ITEM_H + math.max(#options - 1, 0) * GAP + PAD * 2
    local maxH = VISIBLE * ITEM_H + (VISIBLE - 1) * GAP + PAD * 2

    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, ROW_H)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1
    s.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -(PILL_W + 26), 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local pill = Instance.new("TextButton", row)
    pill.Size = UDim2.fromOffset(PILL_W, 28)
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -12, 0.5, 0)
    pill.BackgroundColor3 = C.Surface2
    pill.BorderSizePixel = 0
    pill.AutoButtonColor = false
    pill.Text = ""
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 8)

    local valLbl = Instance.new("TextLabel", pill)
    valLbl.Size = UDim2.new(1, -26, 1, 0)
    valLbl.Position = UDim2.fromOffset(10, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = FontBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = C.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Left
    valLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local arrow = Instance.new("TextLabel", pill)
    arrow.Size = UDim2.fromOffset(16, 28)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = FontBold
    arrow.TextSize = 9
    arrow.TextColor3 = C.TextDim

    local valid = {}
    for _, opt in ipairs(options) do valid[opt] = true end

    local chosen = {}
    local buttons = {}

    local function toList()
        local list = {}
        for _, opt in ipairs(options) do
            if chosen[opt] then list[#list + 1] = opt end
        end
        return list
    end

    local function updateSummary()
        local list = toList()
        if #list == 0 then
            valLbl.Text = "Pilih..."
        elseif #list == 1 then
            valLbl.Text = tostring(list[1])
        else
            valLbl.Text = #list .. " dipilih"
        end
    end

    local function paint(opt)
        local b = buttons[opt]
        if not b then return end
        local sel = chosen[opt] == true
        b.BackgroundColor3 = C.Surface2
        b.BackgroundTransparency = sel and 0 or 1
        b.TextColor3 = sel and C.Accent or C.Text
        b.Text = sel and ("✓  " .. tostring(opt)) or tostring(opt)
    end

    local function setSelected(list, silent)
        if type(list) ~= "table" then return end
        chosen = {}
        for _, v in ipairs(list) do
            if valid[v] then chosen[v] = true end
        end
        updateSummary()
        for opt in pairs(buttons) do paint(opt) end
        if not silent and callback then pcall(callback, toList()) end
    end

    local isOpen, popup, blocker = false, nil, nil

    local function closeSelect()
        if not isOpen then return end
        isOpen = false
        if activeSelectClose == closeSelect then activeSelectClose = nil end
        buttons = {}
        local pg, bl = popup, blocker
        popup, blocker = nil, nil
        if bl then bl:Destroy() end
        if pg then
            TweenService:Create(pg, TweenInfo.new(0.12, Enum.EasingStyle.Quart), {
                Size = UDim2.fromOffset(pg.Size.X.Offset, 0)
            }):Play()
            task.delay(0.14, function() pg:Destroy() end)
        end
        TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
    end

    local function openSelect()
        if #options == 0 then return end
        if activeSelectClose then activeSelectClose() end
        isOpen = true
        activeSelectClose = closeSelect

        local width = math.max(pill.AbsoluteSize.X, 130)
        local height = math.min(listH, maxH)
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local px = pill.AbsolutePosition.X + pill.AbsoluteSize.X - width
        px = math.clamp(px, 4, math.max(vp.X - width - 4, 4))
        local py = pill.AbsolutePosition.Y + pill.AbsoluteSize.Y + 4
        if py + height > vp.Y - 4 then
            py = pill.AbsolutePosition.Y - height - 4
        end
        py = math.max(py, 4)

        blocker = Instance.new("TextButton", screenGui)
        blocker.Name = "SelectBlocker"
        blocker.Size = UDim2.fromScale(1, 1)
        blocker.BackgroundTransparency = 1
        blocker.AutoButtonColor = false
        blocker.Text = ""
        blocker.ZIndex = 49
        blocker.MouseButton1Click:Connect(closeSelect)

        popup = Instance.new("Frame", screenGui)
        popup.Name = "SelectPopup"
        popup.ZIndex = 50
        popup.Position = UDim2.fromOffset(px, py)
        popup.Size = UDim2.fromOffset(width, 0)
        popup.BackgroundColor3 = C.Surface
        popup.BorderSizePixel = 0
        popup.ClipsDescendants = true
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 12)
        local ps = Instance.new("UIStroke", popup)
        ps.Color = C.Stroke
        ps.Thickness = 1

        local scroll = Instance.new("ScrollingFrame", popup)
        scroll.Size = UDim2.fromScale(1, 1)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = C.Accent
        scroll.CanvasSize = UDim2.fromOffset(0, listH)
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, GAP)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", scroll)
        pad.PaddingTop = UDim.new(0, PAD)
        pad.PaddingBottom = UDim.new(0, PAD)
        pad.PaddingLeft = UDim.new(0, PAD)
        pad.PaddingRight = UDim.new(0, PAD + 2)

        local firstIndex = 1
        local foundFirst = false
        for i, opt in ipairs(options) do
            if chosen[opt] and not foundFirst then
                firstIndex = i
                foundFirst = true
            end
            local b = Instance.new("TextButton", scroll)
            b.Name = "Opt_" .. tostring(opt)
            b.LayoutOrder = i
            b.Size = UDim2.new(1, 0, 0, ITEM_H)
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Text = tostring(opt)
            b.Font = Font
            b.TextSize = 13
            b.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UIPadding", b).PaddingLeft = UDim.new(0, 10)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            buttons[opt] = b
            paint(opt)
            b.MouseButton1Click:Connect(function()
                chosen[opt] = (not chosen[opt]) or nil
                paint(opt)
                updateSummary()
                if callback then pcall(callback, toList()) end
            end)
        end

        local maxScroll = math.max(listH - height, 0)
        scroll.CanvasPosition = Vector2.new(0, math.clamp((firstIndex - 1) * (ITEM_H + GAP) - (ITEM_H + GAP), 0, maxScroll))

        TweenService:Create(popup, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
            Size = UDim2.fromOffset(width, height)
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 180}):Play()
    end

    pill.MouseButton1Click:Connect(function()
        if isOpen then closeSelect() else openSelect() end
    end)

    if type(defaults) == "table" then
        setSelected(defaults, true)
    else
        updateSummary()
    end

    registry[name] = {
        kind = "multiselect",
        set = setSelected,
        get = toList,
        row = row,
    }
    if type(defaults) == "table" and callback then pcall(callback, toList()) end
    applyPending(name)
    return registry[name]
end

function API:GetMultiSelect(name)
    local e = registry[name]
    if e and e.kind == "multiselect" then return e.get() end
    return nil
end

function API:SetMultiSelect(name, list, silent)
    local e = registry[name]
    if e and e.kind == "multiselect" then e.set(list, silent) end
end

function API:GetSelect(name)
    local e = registry[name]
    if e and e.kind == "select" then return e.get() end
    return nil
end

function API:SetSelect(name, value, silent)
    local e = registry[name]
    if e and e.kind == "select" then e.set(value, silent) end
end

local keybinds = {}
local listeningBind = nil

local MODIFIER_GROUPS = {
    LeftControl = "Ctrl", RightControl = "Ctrl",
    LeftShift = "Shift", RightShift = "Shift",
    LeftAlt = "Alt", RightAlt = "Alt",
}
local KEY_LABELS = {
    Return = "Enter", Backquote = "`", LeftBracket = "[", RightBracket = "]", Semicolon = ";",
    Quote = "'", Comma = ",", Period = ".", Slash = "/", BackSlash = "\\", Minus = "-", Equals = "=",
    Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
    Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
}

local function normalizeKeyName(key)
    if key == nil then return nil end
    if typeof(key) == "EnumItem" then key = key.Name end
    key = tostring(key)
    local lower = string.lower(key)
    if key == "" or lower == "none" then return nil end
    if lower == "ctrl" or lower == "control" then return "Ctrl" end
    if lower == "shift" then return "Shift" end
    if lower == "alt" then return "Alt" end
    if MODIFIER_GROUPS[key] then return MODIFIER_GROUPS[key] end
    local ok, kc = pcall(function() return Enum.KeyCode[key] end)
    if ok and kc then return key end
    return nil
end

local function keyMatches(bound, keyCode)
    if not bound then return false end
    return (MODIFIER_GROUPS[keyCode.Name] or keyCode.Name) == bound
end

local function prettyKey(key)
    return KEY_LABELS[key] or key
end

UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if listeningBind then
        local code = input.KeyCode
        if code == Enum.KeyCode.Escape then
            listeningBind.cancel()
        elseif code == Enum.KeyCode.Backspace or code == Enum.KeyCode.Delete then
            listeningBind.assign(nil)
        else
            local k = normalizeKeyName(code)
            if k then listeningBind.assign(k) end
        end
        return
    end

    if processed then return end
    for _, e in pairs(keybinds) do
        if e.key and e.callback and keyMatches(e.key, input.KeyCode) then
            task.spawn(pcall, e.callback, e.key)
        end
    end
end)

function API:AddKeyBindInput(name, labelText, default, callback, onChange)
    local PILL_W = 108

    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1
    s.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -(PILL_W + 26), 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local pill = Instance.new("TextButton", row)
    pill.Size = UDim2.fromOffset(PILL_W, 28)
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -12, 0.5, 0)
    pill.BackgroundColor3 = C.Surface2
    pill.BorderSizePixel = 0
    pill.AutoButtonColor = false
    pill.Font = FontBold
    pill.TextSize = 13
    pill.Text = ""
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 8)

    local entry = { key = normalizeKeyName(default), callback = callback }
    keybinds[name] = entry
    local listening = false
    local ctl = {}

    local function refresh()
        if listening then
            pill.Text = "Tekan tombol…"
            pill.TextColor3 = C.TextDim
        elseif entry.key then
            pill.Text = prettyKey(entry.key)
            pill.TextColor3 = C.Accent
        else
            pill.Text = "Tidak ada"
            pill.TextColor3 = C.TextDim
        end
    end

    local function stopListening()
        listening = false
        if listeningBind == ctl then listeningBind = nil end
        refresh()
    end

    function ctl.cancel() stopListening() end
    function ctl.assign(k)
        entry.key = k
        stopListening()
        if onChange then pcall(onChange, k) end
    end

    pill.MouseButton1Click:Connect(function()
        if listening then
            stopListening()
            return
        end
        if listeningBind then listeningBind.cancel() end
        listening = true
        listeningBind = ctl
        refresh()
    end)

    refresh()

    registry[name] = {
        kind = "keybind",
        set = function(v, silent)
            entry.key = normalizeKeyName(v)
            refresh()
            if not silent and onChange then pcall(onChange, entry.key) end
        end,
        get = function() return entry.key or "None" end,
        row = row,
    }
    applyPending(name)
    return registry[name]
end
API.AddKeyBind = API.AddKeyBindInput

function API:GetKeyBind(name)
    local e = registry[name]
    if e and e.kind == "keybind" then return e.get() end
    return nil
end

function API:SetKeyBind(name, key, silent)
    local e = registry[name]
    if e and e.kind == "keybind" then e.set(key, silent) end
end

function API:SetMenuKey(key)
    API:SetKeyBind("ui_menu_key", key)
end

local COLOR_PRESETS = {
    {40, 70, 86}, {42, 157, 143}, {233, 196, 106}, {244, 162, 97}, {231, 111, 81}, {214, 40, 40},
    {0, 48, 135}, {0, 119, 182}, {0, 150, 199}, {0, 180, 216}, {72, 202, 228},
}

local function colorToHex(c)
    return string.format("%02X%02X%02X",
        math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function hexToColor(text)
    local h = tostring(text or ""):gsub("^%s*#", ""):gsub("%s", "")
    if #h == 3 then
        h = h:sub(1, 1):rep(2) .. h:sub(2, 2):rep(2) .. h:sub(3, 3):rep(2)
    end
    if not h:match("^%x%x%x%x%x%x$") then return nil end
    return Color3.fromRGB(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16))
end

local function noTheme(inst)
    inst:SetAttribute("NoTheme", true)
    return inst
end

local pickerGui = nil
local function getPickerGui()
    if pickerGui and pickerGui.Parent then return pickerGui end
    pickerGui = Instance.new("ScreenGui")
    pickerGui.Name = guiName .. "_Picker"
    pickerGui.ResetOnSpawn = false
    pickerGui.IgnoreGuiInset = false
    pickerGui.DisplayOrder = screenGui.DisplayOrder + 1
    pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local okp = pcall(function() pickerGui.Parent = screenGui.Parent end)
    if not okp or not pickerGui.Parent then pickerGui.Parent = player:WaitForChild("PlayerGui") end
    return pickerGui
end

function API:AddColorPicker(name, labelText, default, callback)
    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local rs = Instance.new("UIStroke", row)
    rs.Color = C.Stroke
    rs.Thickness = 1
    rs.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local color = (typeof(default) == "Color3") and default or Color3.fromRGB(255, 255, 255)
    local h, s, v = color:ToHSV()

    local swatch = noTheme(Instance.new("TextButton", row))
    swatch.AnchorPoint = Vector2.new(1, 0.5)
    swatch.Position = UDim2.new(1, -14, 0.5, 0)
    swatch.Size = UDim2.fromOffset(30, 30)
    swatch.BackgroundColor3 = color
    swatch.BorderSizePixel = 0
    swatch.AutoButtonColor = false
    swatch.Text = ""
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(1, 0)
    local ss = Instance.new("UIStroke", swatch)
    ss.Color = C.Stroke
    ss.Thickness = 2

    local ui = nil

    local function applyColor(silent)
        color = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = color
        if ui then
            ui.base.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            ui.marker.Position = UDim2.fromScale(s, 1 - v)
            ui.thumb.Position = UDim2.new(h, 0, 0.5, 0)
            ui.thumbFill.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            ui.preview.BackgroundColor3 = color
            if not ui.hex:IsFocused() then ui.hex.Text = "#" .. colorToHex(color) end
        end
        if not silent and callback then pcall(callback, color) end
    end

    local function setFromColor(c, silent)
        local nh, ns, nv = c:ToHSV()
        if ns > 0.001 and nv > 0.001 then h = nh end
        s, v = ns, nv
        applyColor(silent)
    end

    local isOpen, popup, blocker = false, nil, nil

    local function closePicker()
        if not isOpen then return end
        isOpen = false
        if activeSelectClose == closePicker then activeSelectClose = nil end
        ui = nil
        local pg, bl = popup, blocker
        popup, blocker = nil, nil
        if bl then bl:Destroy() end
        if pg then
            TweenService:Create(pg, TweenInfo.new(0.12, Enum.EasingStyle.Quart), {
                Size = UDim2.fromOffset(pg.Size.X.Offset, 0)
            }):Play()
            task.delay(0.14, function() pg:Destroy() end)
        end
    end

    local function openPicker()
        if activeSelectClose then activeSelectClose() end
        isOpen = true
        activeSelectClose = closePicker

        local W, H = 236, 302
        local pg = getPickerGui()

        local inset = math.max(screenGui.AbsoluteSize.Y - pg.AbsoluteSize.Y, 0)
        local vp = pg.AbsoluteSize

        local px = menu.AbsolutePosition.X + menu.AbsoluteSize.X + 10
        local py = menu.AbsolutePosition.Y - inset
        px = math.clamp(px, 4, math.max(vp.X - W - 4, 4))
        py = math.clamp(py, 4, math.max(vp.Y - H - 4, 4))

        blocker = Instance.new("TextButton", pg)
        blocker.Name = "ColorBlocker"
        blocker.Size = UDim2.fromScale(1, 1)
        blocker.BackgroundTransparency = 1
        blocker.AutoButtonColor = false
        blocker.Text = ""
        blocker.ZIndex = 49
        blocker.MouseButton1Click:Connect(closePicker)

        popup = Instance.new("Frame", pg)
        popup.Name = "ColorPopup"
        popup.ZIndex = 50
        popup.Position = UDim2.fromOffset(px, py)
        popup.Size = UDim2.fromOffset(W, 0)
        popup.BackgroundColor3 = C.Surface
        popup.BorderSizePixel = 0
        popup.ClipsDescendants = true
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 16)
        local ps = Instance.new("UIStroke", popup)
        ps.Color = C.Stroke
        ps.Thickness = 1

        local inner = W - 24

        local field = noTheme(Instance.new("Frame", popup))
        field.Position = UDim2.fromOffset(12, 12)
        field.Size = UDim2.fromOffset(inner, 120)
        field.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        field.BorderSizePixel = 0
        Instance.new("UICorner", field).CornerRadius = UDim.new(0, 10)

        local white = noTheme(Instance.new("Frame", field))
        white.Size = UDim2.fromScale(1, 1)
        white.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        white.BorderSizePixel = 0
        Instance.new("UICorner", white).CornerRadius = UDim.new(0, 10)
        local wg = Instance.new("UIGradient", white)
        wg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

        local black = noTheme(Instance.new("Frame", field))
        black.Size = UDim2.fromScale(1, 1)
        black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        black.BorderSizePixel = 0
        Instance.new("UICorner", black).CornerRadius = UDim.new(0, 10)
        local bg = Instance.new("UIGradient", black)
        bg.Rotation = 90
        bg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

        local marker = Instance.new("Frame", field)
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.Size = UDim2.fromOffset(16, 16)
        marker.Position = UDim2.fromScale(s, 1 - v)
        marker.BackgroundTransparency = 1
        marker.BorderSizePixel = 0
        marker.ZIndex = 3
        Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
        local ms = Instance.new("UIStroke", marker)
        ms.Color = Color3.fromRGB(255, 255, 255)
        ms.Thickness = 2

        local fieldHit = Instance.new("TextButton", field)
        fieldHit.Size = UDim2.fromScale(1, 1)
        fieldHit.BackgroundTransparency = 1
        fieldHit.Text = ""
        fieldHit.AutoButtonColor = false
        fieldHit.ZIndex = 4

        local track = noTheme(Instance.new("Frame", popup))
        track.Position = UDim2.fromOffset(12, 146)
        track.Size = UDim2.fromOffset(inner, 12)
        track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local hg = Instance.new("UIGradient", track)
        hg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        })

        local thumb = Instance.new("Frame", track)
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Size = UDim2.fromOffset(20, 20)
        thumb.Position = UDim2.new(h, 0, 0.5, 0)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.ZIndex = 3
        noTheme(thumb)
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
        local thumbFill = noTheme(Instance.new("Frame", thumb))
        thumbFill.AnchorPoint = Vector2.new(0.5, 0.5)
        thumbFill.Position = UDim2.fromScale(0.5, 0.5)
        thumbFill.Size = UDim2.fromOffset(14, 14)
        thumbFill.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        thumbFill.BorderSizePixel = 0
        thumbFill.ZIndex = 4
        Instance.new("UICorner", thumbFill).CornerRadius = UDim.new(1, 0)

        local hueHit = Instance.new("TextButton", popup)
        hueHit.Position = UDim2.fromOffset(12, 138)
        hueHit.Size = UDim2.fromOffset(inner, 28)
        hueHit.BackgroundTransparency = 1
        hueHit.Text = ""
        hueHit.AutoButtonColor = false
        hueHit.ZIndex = 4

        local preview = noTheme(Instance.new("Frame", popup))
        preview.Position = UDim2.fromOffset(12, 178)
        preview.Size = UDim2.fromOffset(32, 32)
        preview.BackgroundColor3 = color
        preview.BorderSizePixel = 0
        Instance.new("UICorner", preview).CornerRadius = UDim.new(1, 0)
        local pvs = Instance.new("UIStroke", preview)
        pvs.Color = C.Stroke
        pvs.Thickness = 1

        local hex = Instance.new("TextBox", popup)
        hex.Position = UDim2.fromOffset(54, 178)
        hex.Size = UDim2.fromOffset(W - 66, 32)
        hex.BackgroundColor3 = C.Surface2
        hex.BorderSizePixel = 0
        hex.ClearTextOnFocus = false
        hex.PlaceholderText = "#RRGGBB"
        hex.Text = "#" .. colorToHex(color)
        hex.Font = FontBold
        hex.TextSize = 14
        hex.TextColor3 = C.Text
        hex.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", hex).CornerRadius = UDim.new(1, 0)
        local hexPad = Instance.new("UIPadding", hex)
        hexPad.PaddingLeft = UDim.new(0, 14)
        hexPad.PaddingRight = UDim.new(0, 10)
        local hexStroke = Instance.new("UIStroke", hex)
        hexStroke.Color = C.Stroke
        hexStroke.Thickness = 1

        hex.FocusLost:Connect(function()
            local c = hexToColor(hex.Text)
            if c then
                setFromColor(c)
            else
                hex.Text = "#" .. colorToHex(color)
            end
        end)

        local gap = (inner - 6 * 26) / 5
        for i, rgb in ipairs(COLOR_PRESETS) do
            local rowIndex = (i <= 6) and 0 or 1
            local col = (i <= 6) and (i - 1) or (i - 7)
            local startX = 12
            if rowIndex == 1 then
                startX = 12 + (inner - (5 * 26 + 4 * gap)) / 2
            end
            local dot = noTheme(Instance.new("TextButton", popup))
            dot.Position = UDim2.fromOffset(startX + col * (26 + gap), 226 + rowIndex * 36)
            dot.Size = UDim2.fromOffset(26, 26)
            dot.BackgroundColor3 = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
            dot.BorderSizePixel = 0
            dot.AutoButtonColor = false
            dot.Text = ""
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            local dst = Instance.new("UIStroke", dot)
            dst.Color = C.Stroke
            dst.Thickness = 1
            dst.Transparency = 0.5
            dot.MouseButton1Click:Connect(function()
                setFromColor(Color3.fromRGB(rgb[1], rgb[2], rgb[3]))
            end)
        end

        local function fieldDrag(x, y)
            local yy = y
            local fx = math.clamp((x - field.AbsolutePosition.X) / math.max(field.AbsoluteSize.X, 1), 0, 1)
            local fy = math.clamp((yy - field.AbsolutePosition.Y) / math.max(field.AbsoluteSize.Y, 1), 0, 1)
            s, v = fx, 1 - fy
            applyColor()
        end
        local function hueDrag(x)
            h = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            applyColor()
        end

        fieldHit.InputBegan:Connect(function(input)
            if activeSlider then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                activeSlider = fieldDrag
                activeInput = input
                activeBody = nil
                fieldDrag(input.Position.X, input.Position.Y)
            end
        end)
        hueHit.InputBegan:Connect(function(input)
            if activeSlider then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                activeSlider = hueDrag
                activeInput = input
                activeBody = nil
                hueDrag(input.Position.X)
            end
        end)

        ui = { base = field, marker = marker, thumb = thumb, thumbFill = thumbFill, preview = preview, hex = hex }

        TweenService:Create(popup, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            Size = UDim2.fromOffset(W, H)
        }):Play()
    end

    swatch.MouseButton1Click:Connect(function()
        if isOpen then closePicker() else openPicker() end
    end)

    registry[name] = {
        kind = "color",
        set = function(value, silent)
            local c = (typeof(value) == "Color3") and value or hexToColor(value)
            if c then setFromColor(c, silent) end
        end,
        get = function() return colorToHex(color) end,
        getColor = function() return color end,
        row = row,
    }
    applyPending(name)
    return registry[name]
end

function API:GetColor(name)
    local e = registry[name]
    if e and e.kind == "color" then return e.getColor() end
    return nil
end

function API:SetColor(name, value, silent)
    local e = registry[name]
    if e and e.kind == "color" then e.set(value, silent) end
end

function API:SetTheme(themeName)
    local newT = THEMES[themeName]
    if not newT then return false end

    local keyOfHex = {}
    for k, v in pairs(C) do keyOfHex[v:ToHex()] = k end
    for k, v in pairs(newT) do C[k] = v end

    local function map(c)
        local k = keyOfHex[c:ToHex()]
        if k then return C[k] end
        return c
    end

    for _, inst in ipairs(screenGui:GetDescendants()) do
        if inst:IsA("GuiObject") and not inst:GetAttribute("NoTheme") then
            inst.BackgroundColor3 = map(inst.BackgroundColor3)
        end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            inst.TextColor3 = map(inst.TextColor3)
        end
        if inst:IsA("ScrollingFrame") then
            inst.ScrollBarImageColor3 = map(inst.ScrollBarImageColor3)
        end
        if inst:IsA("ImageLabel") then
            inst.ImageColor3 = map(inst.ImageColor3)
        end
        if inst:IsA("UIStroke") then
            inst.Color = map(inst.Color)
        end
        if inst:IsA("UIGradient") then
            local pts = {}
            for i, kp in ipairs(inst.Color.Keypoints) do
                pts[i] = ColorSequenceKeypoint.new(kp.Time, map(kp.Value))
            end
            inst.Color = ColorSequence.new(pts)
        end
    end
    return true
end

function API:SaveConfig()
    if typeof(writefile) ~= "function" then
        return false, "writefile tidak didukung executor"
    end
    local items = {}
    for name, e in pairs(registry) do
        if e.kind == "toggle" or e.kind == "slider" or e.kind == "select" or e.kind == "multiselect" or e.kind == "keybind" or e.kind == "color" then
            items[name] = e.get()
        end
    end
    local okj, json = pcall(function()
        return HttpService:JSONEncode({ version = 1, items = items })
    end)
    if not okj then return false, "gagal membuat JSON config" end

    if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        local okd, exists = pcall(isfolder, CFG.ConfigDir)
        if okd and not exists then pcall(makefolder, CFG.ConfigDir) end
    end
    local okw, err = pcall(writefile, CFG.ConfigFile, json)
    if not okw then return false, tostring(err) end
    return true
end

function API:LoadConfig()
    local items = readConfig()
    if not items then return false end
    pendingConfig = items
    for name in pairs(registry) do applyPending(name) end
    return true
end

function API:AddSlider(name, labelText, min, max, default, callback, step)
    min = min or 0
    max = max or 100
    if max <= min then max = min + 1 end
    local hasDefault = default ~= nil
    default = default or min

    if not step then
        local isInt = (min % 1 == 0) and (max % 1 == 0) and (default % 1 == 0)
        step = isInt and 1 or 0.01
    end
    local function decimalsOf(n)
        local s = string.format("%.6f", n):gsub("0+$", ""):gsub("%.$", "")
        local frac = s:match("%.(%d+)$")
        return frac and #frac or 0
    end
    local decimals = math.max(decimalsOf(step), decimalsOf(min))
    local pow = 10 ^ decimals
    local value = math.clamp(default, min, max)

    local parentBody = currentBody()
    local row = Instance.new("Frame", parentBody)
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1
    s.Transparency = 0.6

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -100, 0, 24)
    lbl.Position = UDim2.fromOffset(14, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextBox", row)
    valLbl.Size = UDim2.fromOffset(70, 24)
    valLbl.Position = UDim2.new(1, -84, 0, 6)
    valLbl.BackgroundColor3 = C.Surface2
    valLbl.BorderSizePixel = 0
    valLbl.ClearTextOnFocus = false
    valLbl.Font = FontBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = C.Text
    valLbl.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", valLbl).CornerRadius = UDim.new(0, 6)

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -28, 0, 4)
    track.Position = UDim2.new(0, 14, 0, 43)
    track.BackgroundColor3 = C.Off
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(22, 22)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = C.Stroke
    knobStroke.Thickness = 1

    local hit = Instance.new("TextButton", row)
    hit.Size = UDim2.new(1, -16, 0, 28)
    hit.Position = UDim2.new(0, 8, 0, 31)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.ZIndex = 3

    local function setValue(v, silent)
        v = math.clamp(v, min, max)
        v = min + math.floor((v - min) / step + 0.5) * step
        v = math.clamp(v, min, max)
        v = math.floor(v * pow + 0.5) / pow
        value = v
        local a = (v - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valLbl.Text = string.format("%." .. decimals .. "f", v)
        if not silent and callback then pcall(callback, v) end
    end

    local function updateFromX(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(min + a * (max - min))
    end

    hit.InputBegan:Connect(function(input)
        if activeSlider then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            activeSlider = updateFromX
            activeInput = input
            activeBody = parentBody
            parentBody.ScrollingEnabled = false
            updateFromX(input.Position.X)
        end
    end)

    valLbl.FocusLost:Connect(function()
        local n = tonumber(valLbl.Text)
        if n then setValue(n) else setValue(value, true) end
    end)

    setValue(value, true)
    if hasDefault and callback then pcall(callback, value) end

    registry[name] = {
        kind = "slider",
        set = setValue,
        get = function() return value end,
        row = row,
    }
    applyPending(name)
    return registry[name]
end

function API:GetToggle(name)
    local e = registry[name]
    if e and e.kind == "toggle" then return e.get() end
    return nil
end

function API:SetToggle(name, value, silent)
    local e = registry[name]
    if e and e.kind == "toggle" then e.set(value, silent) end
end

function API:GetSlider(name)
    local e = registry[name]
    if e and e.kind == "slider" then return e.get() end
    return nil
end

function API:SetSlider(name, value, silent)
    local e = registry[name]
    if e and e.kind == "slider" then e.set(value, silent) end
end

function API:RemoveItem(name)
    local e = registry[name]
    if e and e.row then e.row:Destroy() end
    registry[name] = nil
    keybinds[name] = nil
end

local VIP_STAR_COLOR = Color3.fromRGB(255, 200, 60)
local vipUser = false

local function vipLocked(v)
    return v.vip and not vipUser
end

local function refreshVIP(e)
    local v = e and e.vipState
    if not v then return end
    local row, lbl = v.row, v.lbl
    if not (row and row.Parent and lbl) then return end

    if not v.star then
        local kind, value = resolveIcon("star")
        local star
        if kind == "image" then
            star = noTheme(Instance.new("ImageLabel", row))
            star.Image = value
            star.ImageColor3 = VIP_STAR_COLOR
            star.Size = UDim2.fromOffset(14, 14)
        else
            star = noTheme(Instance.new("TextLabel", row))
            star.Text = "★"
            star.Font = FontBold
            star.TextSize = 16
            star.TextColor3 = VIP_STAR_COLOR
            star.Size = UDim2.fromOffset(18, 18)
        end
        star.Name = "VIPStar"
        star.AnchorPoint = Vector2.new(0, 0.5)
        star.BackgroundTransparency = 1
        star.ZIndex = 5
        v.star = star
    end

    if not v.lock then
        local lock = noTheme(Instance.new("TextButton", row))
        lock.Name = "VIPLock"
        lock.Size = UDim2.fromScale(1, 1)
        lock.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        lock.BackgroundTransparency = 0.6
        lock.BorderSizePixel = 0
        lock.AutoButtonColor = false
        lock.Active = true
        lock.Text = ""
        lock.ZIndex = 20
        local corner = row:FindFirstChildOfClass("UICorner")
        if corner then
            Instance.new("UICorner", lock).CornerRadius = corner.CornerRadius
        end
        v.lock = lock
    end

    local function place()
        if not v.vip then return end
        local w = lbl.TextBounds.X
        if lbl.AbsoluteSize.X > 0 then w = math.min(w, lbl.AbsoluteSize.X) end
        local x = lbl.Position.X.Offset + w + 6
        local y = (lbl.Size.Y.Scale > 0)
            and UDim2.new(0, x, 0.5, 0)
            or UDim2.new(0, x, 0, lbl.Position.Y.Offset + lbl.Size.Y.Offset / 2)
        v.star.Position = y
    end

    if v.vip and not v.reserved then

        lbl.Size = lbl.Size - UDim2.fromOffset(22, 0)
        v.reserved = true
        lbl:GetPropertyChangedSignal("TextBounds"):Connect(place)
        lbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
    elseif (not v.vip) and v.reserved then
        lbl.Size = lbl.Size + UDim2.fromOffset(22, 0)
        v.reserved = false
    end

    v.star.Visible = v.vip and true or false
    v.lock.Visible = vipLocked(v)
    place()
end

local VIP_SPECS = {
    AddToggle           = { n = 5, cb = {4} },
    AddTapToggleOneClick= { n = 3, cb = {3} },
    AddSelectMenu       = { n = 5, cb = {5} },
    AddMultiSelectMenu  = { n = 5, cb = {5} },
    AddKeyBindInput     = { n = 5, cb = {4, 5} },
    AddColorPicker      = { n = 4, cb = {4} },
    AddSlider           = { n = 7, cb = {6} },
}

for fname, spec in pairs(VIP_SPECS) do
    local orig = API[fname]
    API[fname] = function(self, ...)
        local args = table.pack(...)
        if fname == "AddToggle" and type(args[5]) == "boolean" then

            if args[6] == nil then args[6] = args[5] end
            args[5] = nil
            args.n = math.max(args.n, 6)
        end
        local opts = args[spec.n + 1]
        local isVip = (opts == true)
            or (type(opts) == "table" and (opts.VIP == true or opts.vip == true))

        local v = { vip = isVip }

        for _, idx in ipairs(spec.cb) do
            local fn = args[idx]
            if type(fn) == "function" then
                args[idx] = function(...)
                    if vipLocked(v) then return end
                    return fn(...)
                end
            end
        end

        local e = orig(self, table.unpack(args, 1, spec.n))
        if type(e) ~= "table" then return e end

        v.row = e.row
        v.lbl = e.row and e.row:FindFirstChildWhichIsA("TextLabel")
        e.vipState = v

        local origSet = e.set
        if origSet then
            e.set = function(...)
                if vipLocked(v) then return end
                return origSet(...)
            end

            if vipLocked(v) and e.kind == "toggle" then origSet(false, true) end
        end

        function e.setVIP(on)
            v.vip = on and true or false
            refreshVIP(e)
        end

        refreshVIP(e)
        return e
    end
end
API.AddKeyBind = API.AddKeyBindInput

function API:SetVIP(name, on)
    local e = registry[name]
    if e and e.vipState then e.setVIP(on) return true end
    return false
end

function API:IsVIP(name)
    local e = registry[name]
    return (e and e.vipState and e.vipState.vip) and true or false
end

function API:SetVIPUser(on)
    vipUser = on and true or false
    for _, e in pairs(registry) do refreshVIP(e) end
end

function API:IsVIPUser()
    return vipUser
end

local function computeMenuPos()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local lx, ly = logo.AbsolutePosition.X, logo.AbsolutePosition.Y
    local lsx, lsy = logo.AbsoluteSize.X, logo.AbsoluteSize.Y
    local mw, mh = menu.AbsoluteSize.X, menu.AbsoluteSize.Y

    if ly + lsy + CFG.LogoGap + mh <= vp.Y - CFG.ScreenPad then
        local cx = lx + lsx / 2 - mw / 2
        cx = math.clamp(cx, CFG.ScreenPad, math.max(vp.X - mw - CFG.ScreenPad, CFG.ScreenPad))
        return UDim2.fromOffset(cx, ly + lsy + CFG.LogoGap)
    end

    local px = lx + lsx + CFG.LogoGap
    if px + mw > vp.X - CFG.ScreenPad then
        px = lx - mw - CFG.LogoGap
    end
    if px < CFG.ScreenPad then px = CFG.ScreenPad end

    local py = ly + (lsy - mh) / 2
    if py < CFG.ScreenPad then py = CFG.ScreenPad end
    if py + mh > vp.Y - CFG.ScreenPad then py = vp.Y - mh - CFG.ScreenPad end

    return UDim2.fromOffset(px, py)
end

local function clampPos(pos, size)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local x = math.clamp(pos.X.Offset, 0, math.max(vp.X - size.X.Offset, 0))
    local y = math.clamp(pos.Y.Offset, 0, math.max(vp.Y - size.Y.Offset, 0))
    return UDim2.fromOffset(x, y)
end

local function menuMaxSize()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local w = math.max(math.min(CFG.MenuWMax, vp.X - CFG.ScreenPad * 2), CFG.MenuWMin)
    local h = math.max(math.min(CFG.MenuHMax, vp.Y - CFG.ScreenPad * 2), CFG.MenuHMin)
    return w, h
end

local function defaultMenuSize()
    local w, h = menuMaxSize()
    return UDim2.fromOffset(w, h)
end

local isOpen = false
local lastPos, lastSize = nil, nil
local closeToken = 0

function API:Open()
    if isOpen then return end
    isOpen = true
    closeToken = closeToken + 1
    if not selectedCat then
        if categories["ui"] then
            API:SelectCategory("ui")
        elseif categories["devtools"] then
            API:SelectCategory("devtools")
        end
    end
    logo.Visible = false

    local targetSize = lastSize or defaultMenuSize()
    menu.Size = targetSize
    if lastPos then
        menu.Position = clampPos(lastPos, targetSize)
    else
        menu.Position = computeMenuPos()
    end
    lastPos = menu.Position
    local basePos = lastPos

    local fromScale = 0.8
    menuScale.Scale = fromScale
    menu.Position = UDim2.new(
        basePos.X.Scale, basePos.X.Offset + (1 - fromScale) * targetSize.X.Offset / 2,
        basePos.Y.Scale, basePos.Y.Offset + (1 - fromScale) * targetSize.Y.Offset / 2
    )
    menu.Visible = true
    local info = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(menuScale, info, {Scale = 1}):Play()
    TweenService:Create(menu, info, {Position = basePos}):Play()
end

function API:Close()
    if not isOpen then return end
    isOpen = false
    if activeSelectClose then activeSelectClose() end
    local fullSize = lastSize or defaultMenuSize()
    local basePos = lastPos or menu.Position
    closeToken = closeToken + 1
    local token = closeToken

    local toScale = 0.85
    local info = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(menuScale, info, {Scale = toScale}):Play()
    TweenService:Create(menu, info, {Position = UDim2.new(
        basePos.X.Scale, basePos.X.Offset + (1 - toScale) * fullSize.X.Offset / 2,
        basePos.Y.Scale, basePos.Y.Offset + (1 - toScale) * fullSize.Y.Offset / 2
    )}):Play()
    task.delay(0.17, function()
        if token ~= closeToken or isOpen then return end
        menu.Visible = false
        menuScale.Scale = 1
        menu.Position = basePos
        menu.Size = fullSize
        logo.Visible = true
    end)
end

function API:Toggle()
    if isOpen then self:Close() else self:Open() end
end

function API:IsOpen()
    return isOpen
end

local dragLogo, logoStart, logoStartPos = false, nil, nil
logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragLogo = true
        logoStart = input.Position
        logoStartPos = logo.Position
    end
end)

local dragMenu, menuStart, menuStartPos = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragMenu = true
        menuStart = input.Position
        menuStartPos = menu.Position
    end
end)

local resizing, resizeStart, resizeStartSize, resizeStartPos = false, nil, nil, nil
local resizeSX, resizeSY = 1, 1
for _, rh in ipairs(resizeHandles) do
    rh.frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = menu.AbsoluteSize
            resizeStartPos = menu.Position
            resizeSX, resizeSY = rh.sx, rh.sy
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if activeSlider and activeInput then
            local sameTouch = (input == activeInput)
            local mouseMove = activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement
            if sameTouch or mouseMove then
                activeSlider(input.Position.X, input.Position.Y)
            end
        end
        if dragLogo and logoStart then
            local d = input.Position - logoStart
            logo.Position = UDim2.new(
                logoStartPos.X.Scale, logoStartPos.X.Offset + d.X,
                logoStartPos.Y.Scale, logoStartPos.Y.Offset + d.Y
            )
        end
        if dragMenu and menuStart then
            local d = input.Position - menuStart
            menu.Position = UDim2.new(
                menuStartPos.X.Scale, menuStartPos.X.Offset + d.X,
                menuStartPos.Y.Scale, menuStartPos.Y.Offset + d.Y
            )
        end
        if resizing and resizeStart then
            local d = input.Position - resizeStart
            local maxW, maxH = menuMaxSize()
            local w = math.clamp(resizeStartSize.X + resizeSX * d.X, CFG.MenuWMin, maxW)
            local h = math.clamp(resizeStartSize.Y + resizeSY * d.Y, CFG.MenuHMin, maxH)
            menu.Size = UDim2.fromOffset(w, h)

            local px = resizeStartPos.X.Offset + ((resizeSX == -1) and (resizeStartSize.X - w) or 0)
            local py = resizeStartPos.Y.Offset + ((resizeSY == -1) and (resizeStartSize.Y - h) or 0)
            menu.Position = UDim2.new(resizeStartPos.X.Scale, px, resizeStartPos.Y.Scale, py)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if activeSlider and activeInput and (input == activeInput
            or (activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1)) then
            activeSlider = nil
            activeInput = nil
            if activeBody then
                activeBody.ScrollingEnabled = true
                activeBody = nil
            end
        end
        if dragLogo then
            local d = input.Position - logoStart
            if math.abs(d.X) + math.abs(d.Y) < 6 then
                API:Open()
            end
            dragLogo = false
        end
        if dragMenu then
            lastPos = menu.Position
        end
        if resizing then
            lastSize = UDim2.fromOffset(menu.AbsoluteSize.X, menu.AbsoluteSize.Y)
            lastPos = menu.Position
        end
        dragMenu = false
        resizing = false
    end
end)

closeBtn.MouseButton1Click:Connect(function() API:Close() end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.Stroke}):Play()
    TweenService:Create(closeIcon, TweenInfo.new(0.12), {TextColor3 = C.Text}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.Surface2}):Play()
    TweenService:Create(closeIcon, TweenInfo.new(0.12), {TextColor3 = C.TextDim}):Play()
end)

logo.MouseEnter:Connect(function()
    TweenService:Create(logoStroke, TweenInfo.new(0.15), {Thickness = 2.5}):Play()
end)
logo.MouseLeave:Connect(function()
    TweenService:Create(logoStroke, TweenInfo.new(0.15), {Thickness = 1.5}):Play()
end)

function API:Destroy()
    if pickerGui then pickerGui:Destroy() end
    if screenGui then screenGui:Destroy() end
end

API.Instances = {
    ScreenGui = screenGui,
    Logo = logo,
    Menu = menu,
    Header = header,
    Categories = categories,
    TabBar = tabBar,
    ResizeHandle = resizeHandle,
    Colors = C,
}

local NOTIFY_TYPES = {
    info    = Color3.fromRGB(165, 165, 175),
    warn    = Color3.fromRGB(255, 204, 0),
    error   = Color3.fromRGB(255, 69, 58),
    success = Color3.fromRGB(48, 209, 88),
}
local NOTIFY_ALIASES = {
    information = "info", warning = "warn", err = "error", fail = "error",
    failed = "error", ok = "success", done = "success",
}

local NOTIFY_POSITIONS = {
    topright = {
        anchor = Vector2.new(1, 0), pos = UDim2.new(1, -16, 0, 16),
        halign = Enum.HorizontalAlignment.Right, valign = Enum.VerticalAlignment.Top,
        slide = Vector2.new(340, 0), reverse = false,
    },
    topleft = {
        anchor = Vector2.new(0, 0), pos = UDim2.new(0, 16, 0, 16),
        halign = Enum.HorizontalAlignment.Left, valign = Enum.VerticalAlignment.Top,
        slide = Vector2.new(-340, 0), reverse = false,
    },
    top = {
        anchor = Vector2.new(0.5, 0), pos = UDim2.new(0.5, 0, 0, 16),
        halign = Enum.HorizontalAlignment.Center, valign = Enum.VerticalAlignment.Top,
        slide = Vector2.new(0, -70), reverse = false,
    },
    bottom = {
        anchor = Vector2.new(0.5, 1), pos = UDim2.new(0.5, 0, 1, -16),
        halign = Enum.HorizontalAlignment.Center, valign = Enum.VerticalAlignment.Bottom,
        slide = Vector2.new(0, 70), reverse = true,
    },
}
local POSITION_ALIASES = {
    topright = "topright", tr = "topright", kananatas = "topright", right = "topright",
    topleft = "topleft", tl = "topleft", kiriatas = "topleft", left = "topleft",
    top = "top", atas = "top", topcenter = "top", center = "top",
    bottom = "bottom", bawah = "bottom", bottomcenter = "bottom",
}

local function normalizeNotifyPosition(p)
    local key = string.lower(tostring(p or "")):gsub("[%s_%-]", "")
    return POSITION_ALIASES[key]
end

local toastHolder = Instance.new("Frame", screenGui)
toastHolder.Name = "Toasts"
toastHolder.Size = UDim2.fromOffset(300, 0)
toastHolder.AutomaticSize = Enum.AutomaticSize.Y
toastHolder.BackgroundTransparency = 1
toastHolder.BorderSizePixel = 0
toastHolder.ZIndex = 100
local toastLayout = Instance.new("UIListLayout", toastHolder)
toastLayout.Padding = UDim.new(0, 8)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifyPos = "topright"

local function applyNotifyPosition()
    local spec = NOTIFY_POSITIONS[notifyPos]
    toastHolder.AnchorPoint = spec.anchor
    toastHolder.Position = spec.pos
    toastLayout.HorizontalAlignment = spec.halign
    toastLayout.VerticalAlignment = spec.valign
end
applyNotifyPosition()

function API:SetNotifyPosition(position)
    local key = normalizeNotifyPosition(position)
    if not key then return false end
    notifyPos = key
    applyNotifyPosition()
    return true
end

function API:GetNotifyPosition()
    return notifyPos
end

local toastOrder = 0
local toastEntries = {}

local function notifyBar(parent, cx, cy, w, h, rot, color)
    local f = Instance.new("Frame", parent)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.fromOffset(cx, cy)
    f.Size = UDim2.fromOffset(w, h)
    f.Rotation = rot or 0
    f.BackgroundColor3 = color
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    return f
end

local function makeNotifyIcon(parent, kind, color)
    local icon = Instance.new("Frame", parent)
    icon.Name = "Icon"
    icon.LayoutOrder = 1
    icon.Size = UDim2.fromOffset(26, 26)
    icon.BackgroundTransparency = 1

    if kind == "success" then

        notifyBar(icon, 7, 17, 9, 3, 45, color)
        notifyBar(icon, 16, 13.5, 18, 3, -47, color)
    elseif kind == "error" then

        notifyBar(icon, 13, 13, 20, 3, 45, color)
        notifyBar(icon, 13, 13, 20, 3, -45, color)
    elseif kind == "warn" then

        notifyBar(icon, 7.5, 12.5, 22, 2.5, -60, color)
        notifyBar(icon, 18.5, 12.5, 22, 2.5, 60, color)
        notifyBar(icon, 13, 22, 22, 2.5, 0, color)
        local bang = Instance.new("TextLabel", icon)
        bang.AnchorPoint = Vector2.new(0.5, 0.5)
        bang.Position = UDim2.fromOffset(13, 14.5)
        bang.Size = UDim2.fromOffset(10, 12)
        bang.BackgroundTransparency = 1
        bang.Text = "!"
        bang.Font = FontBold
        bang.TextSize = 11
        bang.TextColor3 = color
    else

        local ring = Instance.new("Frame", icon)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.Position = UDim2.fromOffset(13, 13)
        ring.Size = UDim2.fromOffset(22, 22)
        ring.BackgroundTransparency = 1
        ring.BorderSizePixel = 0
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        local ringStroke = Instance.new("UIStroke", ring)
        ringStroke.Color = color
        ringStroke.Thickness = 2
        notifyBar(icon, 13, 8.2, 3.2, 3.2, 0, color)
        notifyBar(icon, 13, 15.2, 3, 8, 0, color)
    end
    return icon
end

function API:Notify(data, kind, desc, duration)
    if type(data) ~= "table" then
        data = { Title = tostring(data or ""), Type = kind, Description = desc, Time = duration }
    end
    local kindName = string.lower(tostring(data.Type or data.type or data.Style or data.style or "info"))
    kindName = NOTIFY_ALIASES[kindName] or kindName
    if not NOTIFY_TYPES[kindName] then kindName = "info" end
    local color = NOTIFY_TYPES[kindName]

    local titleText = tostring(data.Title or data.title or "")
    local descText = tostring(data.Description or data.description or data.Content or data.content or "")
    local seconds = tonumber(data.Time or data.time or data.Duration or data.duration) or 4
    if titleText == "" and descText == "" then return end

    toastOrder = toastOrder + 1

    while #toastEntries >= 5 do
        local oldest = table.remove(toastEntries, 1)
        if oldest and oldest.dismiss then oldest.dismiss() end
    end

    local spec = NOTIFY_POSITIONS[notifyPos]
    local entry = {}
    table.insert(toastEntries, entry)

    local slot = Instance.new("Frame", toastHolder)
    slot.Name = "ToastSlot"
    slot.LayoutOrder = spec.reverse and -toastOrder or toastOrder
    slot.Size = UDim2.new(1, 0, 0, 0)
    slot.AutomaticSize = Enum.AutomaticSize.Y
    slot.BackgroundTransparency = 1
    slot.BorderSizePixel = 0

    local card = Instance.new("CanvasGroup", slot)
    card.Name = "Toast"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = C.Surface
    card.BorderSizePixel = 0
    card.GroupTransparency = 1
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = C.Stroke
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.4
    local scale = Instance.new("UIScale", card)
    scale.Scale = 0.9

    local content = Instance.new("Frame", card)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    local pad = Instance.new("UIPadding", content)
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    local rowLayout = Instance.new("UIListLayout", content)
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 12)
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local badge = Instance.new("Frame", content)
    badge.Name = "Badge"
    badge.LayoutOrder = 1
    badge.Size = UDim2.fromOffset(38, 38)
    badge.BackgroundColor3 = color
    badge.BackgroundTransparency = 0.84
    badge.BorderSizePixel = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
    local icon = makeNotifyIcon(badge, kindName, color)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)

    local textBox = Instance.new("Frame", content)
    textBox.LayoutOrder = 2
    textBox.Size = UDim2.new(1, -50, 0, 0)
    textBox.AutomaticSize = Enum.AutomaticSize.Y
    textBox.BackgroundTransparency = 1
    textBox.BorderSizePixel = 0
    local textLayout = Instance.new("UIListLayout", textBox)
    textLayout.Padding = UDim.new(0, 2)
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function addText(text, font, size, order, textColor)
        local l = Instance.new("TextLabel", textBox)
        l.LayoutOrder = order
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = font
        l.TextSize = size
        l.TextColor3 = textColor
        l.TextWrapped = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
    end
    if titleText ~= "" then addText(titleText, FontBold, 14, 1, C.Text) end
    if descText ~= "" then addText(descText, Font, 12, 2, titleText ~= "" and C.TextDim or C.Text) end

    local track = Instance.new("Frame", card)
    track.Name = "ProgressTrack"
    track.Size = UDim2.new(1, -28, 0, 3)
    track.Position = UDim2.new(0, 14, 1, -10)
    track.BackgroundColor3 = color
    track.BackgroundTransparency = 0.85
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", track)
    fill.Name = "ProgressFill"
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dismissed = false
    local progress = nil

    local function dismiss()
        if dismissed then return end
        dismissed = true
        local idx = table.find(toastEntries, entry)
        if idx then table.remove(toastEntries, idx) end
        if progress then progress:Cancel() end
        if not slot.Parent then return end

        local h = slot.AbsoluteSize.Y
        slot.AutomaticSize = Enum.AutomaticSize.None
        slot.Size = UDim2.new(1, 0, 0, h)

        local out = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(card, out, {
            Position = UDim2.fromOffset(spec.slide.X, spec.slide.Y),
            GroupTransparency = 1,
        }):Play()
        TweenService:Create(scale, out, {Scale = 0.95}):Play()

        task.delay(0.2, function()
            if not slot.Parent then return end
            TweenService:Create(slot, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
        end)
        task.delay(0.55, function()
            if slot.Parent then slot:Destroy() end
        end)
    end
    entry.dismiss = dismiss

    task.spawn(function()

        task.wait()
        if not slot.Parent or dismissed then return end
        local h = slot.AbsoluteSize.Y
        if h < 1 then
            task.wait()
            h = slot.AbsoluteSize.Y
        end
        if not slot.Parent or dismissed then return end
        slot.AutomaticSize = Enum.AutomaticSize.None
        slot.Size = UDim2.new(1, 0, 0, h)

        card.Position = UDim2.fromOffset(spec.slide.X, spec.slide.Y)
        local pop = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(card, pop, {Position = UDim2.fromOffset(0, 0)}):Play()
        TweenService:Create(scale, pop, {Scale = 1}):Play()
        TweenService:Create(card, TweenInfo.new(0.22), {GroupTransparency = 0}):Play()

        progress = TweenService:Create(fill, TweenInfo.new(seconds, Enum.EasingStyle.Linear), {
            Size = UDim2.fromScale(1, 1)
        })
        progress.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed then dismiss() end
        end)
        progress:Play()
    end)
end

function API:Info(title, desc, seconds) API:Notify({ Title = title, Description = desc, Type = "info", Time = seconds }) end
function API:Warn(title, desc, seconds) API:Notify({ Title = title, Description = desc, Type = "warn", Time = seconds }) end
function API:Error(title, desc, seconds) API:Notify({ Title = title, Description = desc, Type = "error", Time = seconds }) end
function API:Success(title, desc, seconds) API:Notify({ Title = title, Description = desc, Type = "success", Time = seconds }) end

local imageToken = 0
local MAX_IMAGE_BYTES = 8 * 1024 * 1024

local function hashString(str)
    local h = 5381
    for i = 1, #str do
        h = (h * 33 + string.byte(str, i)) % 4294967296
    end
    return string.format("%08x", h)
end

local function ensureFolder(path)
    if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        local ok, exists = pcall(isfolder, path)
        if ok and not exists then pcall(makefolder, path) end
    end
end

local function downloadBody(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return res end

    local req = nil
    if typeof(request) == "function" then
        req = request
    elseif typeof(http_request) == "function" then
        req = http_request
    elseif typeof(syn) == "table" and typeof(syn.request) == "function" then
        req = syn.request
    end
    if req then
        local ok2, r = pcall(req, { Url = url, Method = "GET" })
        if ok2 and type(r) == "table" and type(r.Body) == "string" and #r.Body > 0
            and (r.StatusCode == nil or r.StatusCode == 200) then
            return r.Body
        end
    end
    return nil
end

local function imageExtension(data)
    if data:sub(1, 4) == "\137PNG" then return "png" end
    if data:byte(1) == 0xFF and data:byte(2) == 0xD8 then return "jpg" end
    return nil
end

local function showLogoImage(asset)
    logoImage.Image = asset
    logoImage.Visible = true
    logoText.Visible = false
end

function API:ClearLogoImage()
    imageToken = imageToken + 1
    logoImage.Image = ""
    logoImage.Visible = false
    logoText.Visible = true
end

function API:SetLogoImage(url, callback)
    if url == nil or url == "" then
        API:ClearLogoImage()
        if callback then pcall(callback, true, "dihapus") end
        return
    end

    imageToken = imageToken + 1
    local token = imageToken
    local function finish(ok, info)
        if token ~= imageToken then return end
        if callback then pcall(callback, ok, info) end
    end

    local direct = tostring(url)
    if type(url) == "number" or direct:match("^%d+$") then
        direct = "rbxassetid://" .. direct
    end
    if direct:match("^rbxassetid://") or direct:match("^rbxasset://") then
        showLogoImage(direct)
        return finish(true, direct)
    end

    if not direct:match("^https?://") then
        return finish(false, "link harus diawali http:// atau https://")
    end

    task.spawn(function()
        local getAsset = nil
        if typeof(getcustomasset) == "function" then
            getAsset = getcustomasset
        elseif typeof(getsynasset) == "function" then
            getAsset = getsynasset
        end
        if not getAsset or typeof(writefile) ~= "function" or typeof(isfile) ~= "function" then
            return finish(false, "executor tidak mendukung writefile/isfile/getcustomasset")
        end

        ensureFolder(CFG.ConfigDir)
        ensureFolder(CFG.CacheDir)

        local base = CFG.CacheDir .. "/logo_" .. hashString(direct)
        local path = nil
        for _, ext in ipairs({ "png", "jpg" }) do
            local okf, exists = pcall(isfile, base .. "." .. ext)
            if okf and exists then
                path = base .. "." .. ext
                break
            end
        end

        if not path then
            local data = downloadBody(direct)
            if not data then
                return finish(false, "gagal download gambar dari link")
            end
            if #data > MAX_IMAGE_BYTES then
                return finish(false, "gambar terlalu besar (maksimal 8 MB)")
            end
            local ext = imageExtension(data)
            if not ext then
                return finish(false, "format tidak didukung, pakai PNG atau JPG")
            end
            local okw, err = pcall(writefile, base .. "." .. ext, data)
            if not okw then
                return finish(false, "gagal menyimpan cache: " .. tostring(err))
            end
            path = base .. "." .. ext
        end

        local oka, asset = pcall(getAsset, path)
        if not oka or not asset or asset == "" then
            return finish(false, "getcustomasset gagal membaca file cache")
        end
        if token ~= imageToken then return end
        showLogoImage(asset)
        finish(true, path)
    end)
end

local BZ_VERSION = "v4.0"
local TEXT_DEFAULTS = { Title = "BZ Menu", Logo = "BZ", Studio = "Studio The Clown" }
local logoSizeValue = 44
local studioText, studioShowVersion = TEXT_DEFAULTS.Studio, true

local function refreshLogoText()
    local len = utf8.len(logoText.Text) or #logoText.Text
    local size = (logoSizeValue - 10) * 0.42
    if len > 2 then size = size * 2 / len end
    logoText.TextSize = math.max(8, math.floor(size))
end

local function refreshStudio()
    if studioShowVersion then
        subtitle.Text = BZ_VERSION .. " · " .. studioText
    else
        subtitle.Text = studioText
    end
end

function API:SetTitle(text)
    if text == nil or tostring(text) == "" then text = TEXT_DEFAULTS.Title end
    title.Text = tostring(text)
end

function API:SetLogoText(text)
    if text == nil or tostring(text) == "" then text = TEXT_DEFAULTS.Logo end
    logoText.Text = tostring(text)
    refreshLogoText()
end

function API:SetStudio(text, showVersion)
    if text == nil or tostring(text) == "" then text = TEXT_DEFAULTS.Studio end
    studioText = tostring(text)
    if showVersion ~= nil then studioShowVersion = showVersion and true or false end
    refreshStudio()
end

function API:SetTexts(t)
    t = t or {}
    if t.Title ~= nil then API:SetTitle(t.Title) end
    if t.Logo ~= nil then API:SetLogoText(t.Logo) end
    if t.Studio ~= nil then API:SetStudio(t.Studio, t.ShowVersion) end
end

function API:ResetTexts()
    studioShowVersion = true
    API:SetTitle(nil)
    API:SetLogoText(nil)
    API:SetStudio(nil)
end

local function buildUICategory()
    local prev = currentCat
    createCategory("ui", "UI", true, { order = 9998, noSelect = true, icon = "palette" })
    currentCat = "ui"

    API:AddSection("Logo")
    API:AddSlider("ui_logo_size", "Logo Size", 32, 72, 44, function(v)
        logo.Size = UDim2.new(0, 0, 0, v)
        logoBadge.Size = UDim2.fromOffset(v - 10, v - 10)
        logoStats.TextSize = math.max(11, math.floor(v * 0.39))
        logoSizeValue = v
        refreshLogoText()
    end, 1)
    API:AddSlider("ui_logo_alpha", "Logo Transparan (%)", 0, 90, 0, function(v)
        local a = v / 100
        logo.BackgroundTransparency = a
        logoStroke.Transparency = a
        logoBadge.BackgroundTransparency = a
        logoText.TextTransparency = a
        logoImage.ImageTransparency = a
        logoStats.TextTransparency = a
    end, 5)
    API:AddToggle("ui_logo_stats", "Tampilkan FPS & Ping", true, function(on)
        logoStats.Visible = on
    end, "switch")

    API:AddSection("Thema")
    API:AddSelectMenu("ui_theme", "Thema", THEME_ORDER, "Ungu", function(v)
        API:SetTheme(v)
    end)

    API:AddSection("Notifikasi")
    API:AddSelectMenu("ui_notify_pos", "Posisi Notifikasi", {"Kanan Atas", "Kiri Atas", "Atas", "Bawah"}, "Kanan Atas", function(v)
        API:SetNotifyPosition(v)
        if isOpen then API:Info("Posisi notifikasi", v, 2) end
    end)

    API:AddSection("Keyboard")
    API:AddKeyBindInput("ui_menu_key", "Buka/Tutup Menu", "Ctrl", function()
        API:Toggle()
    end)
    API:AddNote("Klik kotak lalu tekan tombol baru.")

    API:AddSection("Config")
    local cfgStatus
    API:AddTapToggleOneClick("ui_save_config", "Save Config", function()
        local ok, err = API:SaveConfig()
        if cfgStatus then
            cfgStatus:SetText(ok and "✔ Config tersimpan" or ("✘ " .. tostring(err)))
        end
        if ok then
            API:Success("Config tersimpan", CFG.ConfigFile, 3)
        else
            API:Error("Gagal menyimpan config", tostring(err), 4)
        end
    end)
    cfgStatus = API:AddNote("Config tersimpan per Game ID.")

    currentCat = prev
end
buildUICategory()

local DEV_USERNAME = "BimzDnu"

local function copyText(text)
    local fn = (typeof(setclipboard) == "function" and setclipboard)
        or (typeof(toclipboard) == "function" and toclipboard)
    if not fn then return false end
    return (pcall(fn, text))
end

local function getPos()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position or nil
end

local function buildDevTools()
    if string.lower(player.Name) ~= string.lower(DEV_USERNAME) then return end

    local prev = currentCat
    createCategory("devtools", "Dev Tools", true, { order = 9999, noSelect = true, icon = "wrench" })
    currentCat = "devtools"

    local status
    local function report(ok, what)
        if not status then return end
        if ok then
            status:SetText("✔ Tersalin: " .. what)
            API:Success("Tersalin", what, 2)
        else
            status:SetText("✘ Executor tidak support clipboard")
            API:Error("Gagal menyalin", "Executor tidak support clipboard", 3)
        end
    end

    API:AddSection("Koordinat")
    local posNote = API:AddNote("Posisi: -")
    API:AddTapToggleOneClick("dev_copy_xyz", "Copy Coordinate", function()
        local p = getPos()
        if not p then status:SetText("✘ Karakter belum ada") return end
        local s = string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z)
        report(copyText(s), s)
    end)
    API:AddTapToggleOneClick("dev_copy_vec3", "Copy sebagai Vector3", function()
        local p = getPos()
        if not p then status:SetText("✘ Karakter belum ada") return end
        local s = string.format("Vector3.new(%.2f, %.2f, %.2f)", p.X, p.Y, p.Z)
        report(copyText(s), s)
    end)

    API:AddSection("Place / Game ID")
    API:AddNote("Place ID: " .. tostring(game.PlaceId) .. "\nGame ID: " .. tostring(game.GameId))
    API:AddTapToggleOneClick("dev_copy_place", "Copy Place ID", function()
        local s = tostring(game.PlaceId)
        report(copyText(s), s)
    end)
    API:AddTapToggleOneClick("dev_copy_game", "Copy Game ID", function()
        local s = tostring(game.GameId)
        report(copyText(s), s)
    end)

    status = API:AddNote("Status: siap")

    task.spawn(function()
        while screenGui.Parent do
            task.wait(0.25)
            local cat = categories["devtools"]
            if isOpen and cat and cat.body.Visible then
                local p = getPos()
                posNote:SetText(p
                    and string.format("Posisi: X %.2f  Y %.2f  Z %.2f", p.X, p.Y, p.Z)
                    or "Posisi: karakter belum ada")
            end
        end
    end)

    currentCat = prev
end
buildDevTools()

setmetatable(API, {__call = function(self) return self end})

print("[BZ] Menu UI v4.1 module ready.")
return API
