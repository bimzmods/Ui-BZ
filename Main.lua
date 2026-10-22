local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local guiName = "BZ_Menu_GUI"

local old = CoreGui:FindFirstChild(guiName)
if old then old:Destroy() end
old = player:WaitForChild("PlayerGui"):FindFirstChild(guiName)
if old then old:Destroy() end

local CFG = {
    Colors = {
        Bg        = Color3.fromRGB(18, 13, 28),
        Surface   = Color3.fromRGB(28, 21, 43),
        Surface2  = Color3.fromRGB(41, 31, 62),
        Accent    = Color3.fromRGB(157, 90, 255),
        Text      = Color3.fromRGB(240, 235, 252),
        TextDim   = Color3.fromRGB(165, 152, 190),
        Stroke    = Color3.fromRGB(78, 56, 118),
        On        = Color3.fromRGB(170, 100, 255),
        Off       = Color3.fromRGB(70, 58, 95),
    },
    Font      = Enum.Font.GothamMedium,
    FontBold  = Enum.Font.GothamBold,
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
    Ungu   = palette({{18,13,28},{28,21,43},{41,31,62},{157,90,255},{240,235,252},{165,152,190},{78,56,118},{170,100,255},{70,58,95}}),
    Cyan   = palette({{10,20,26},{16,32,42},{24,46,60},{0,200,230},{232,248,252},{140,175,188},{30,80,98},{30,220,240},{50,72,84}}),
    Kuning = palette({{24,21,10},{38,33,14},{54,47,20},{250,204,21},{252,248,230},{190,178,140},{104,88,28},{255,215,60},{84,76,48}}),
    Merah  = palette({{26,12,14},{40,18,22},{58,26,32},{239,68,68},{252,236,236},{192,148,150},{110,40,46},{248,90,90},{88,56,60}}),
    Sakura = palette({{36,22,30},{50,31,42},{68,42,57},{255,143,184},{255,240,246},{205,160,180},{120,70,96},{255,166,200},{100,70,86}}),
    White  = palette({{245,245,248},{232,232,238},{218,218,226},{37,99,235},{30,30,38},{110,110,125},{200,200,210},{70,190,110},{180,180,190}}),
    Black  = palette({{8,8,8},{18,18,18},{32,32,32},{230,230,230},{245,245,245},{140,140,140},{58,58,58},{125,125,132},{64,64,64}}),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() screenGui.Parent = CoreGui end)
if not ok then screenGui.Parent = player:WaitForChild("PlayerGui") end

local logo = Instance.new("Frame", screenGui)
logo.Name = "Logo"
logo.Size = UDim2.fromOffset(56, 56)
logo.Position = CFG.LogoStart
logo.BackgroundColor3 = C.Bg
logo.BorderSizePixel = 0
logo.Active = true
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 14)
local logoStroke = Instance.new("UIStroke", logo)
logoStroke.Color = C.Accent
logoStroke.Thickness = 1.5

local logoText = Instance.new("TextLabel", logo)
logoText.Size = UDim2.fromScale(1, 1)
logoText.BackgroundTransparency = 1
logoText.Text = "BZ"
logoText.Font = FontBold
logoText.TextSize = 22
logoText.TextColor3 = C.Accent

local menu = Instance.new("Frame", screenGui)
menu.Name = "Menu"
menu.Size = UDim2.fromOffset(CFG.MenuWDef, CFG.MenuHDef)
menu.Position = UDim2.fromOffset(40, 100)
menu.BackgroundColor3 = C.Bg
menu.BorderSizePixel = 0
menu.Visible = false
menu.ClipsDescendants = true
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 16)
local menuStroke = Instance.new("UIStroke", menu)
menuStroke.Color = C.Stroke
menuStroke.Thickness = 1.5

local header = Instance.new("Frame", menu)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, CFG.HeaderH)
header.BackgroundColor3 = C.Surface
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
local headerFix = Instance.new("Frame", header)
headerFix.Size = UDim2.new(1, 0, 0, 16)
headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = C.Surface
headerFix.BorderSizePixel = 0
local headerLine = Instance.new("Frame", header)
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 1, -2)
headerLine.BackgroundColor3 = C.Accent
headerLine.BorderSizePixel = 0
local lineGrad = Instance.new("UIGradient", headerLine)
lineGrad.Color = ColorSequence.new(C.Accent, C.Surface)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.fromOffset(18, 0)
title.BackgroundTransparency = 1
title.Text = "BZ Menu"
title.Font = FontBold
title.TextSize = 18
title.TextColor3 = C.Text
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -60, 0, 14)
subtitle.Position = UDim2.new(0, 18, 1, -22)
subtitle.BackgroundTransparency = 1
subtitle.Text = "v2.2 · Studio The Clown"
subtitle.Font = Font
subtitle.TextSize = 11
subtitle.TextColor3 = C.TextDim
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 12)
closeBtn.BackgroundColor3 = C.Surface2
closeBtn.AutoButtonColor = false
closeBtn.Text = ""
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local closeIcon = Instance.new("TextLabel", closeBtn)
closeIcon.Size = UDim2.fromScale(1, 1)
closeIcon.BackgroundTransparency = 1
closeIcon.Text = "×"
closeIcon.Font = FontBold
closeIcon.TextSize = 20
closeIcon.TextColor3 = C.TextDim

local TAB_H = 38
local tabBar = Instance.new("ScrollingFrame", menu)
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, TAB_H)
tabBar.Position = UDim2.fromOffset(0, CFG.HeaderH)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0
tabBar.ScrollBarThickness = 0
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
tabBar.ScrollingDirection = Enum.ScrollingDirection.X
tabBar.Visible = false

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingLeft = UDim.new(0, 16)
tabPad.PaddingRight = UDim.new(0, 16)

local function makeBody()
    local b = Instance.new("ScrollingFrame", menu)
    b.Name = "Body"
    b.Size = UDim2.new(1, 0, 1, -CFG.HeaderH)
    b.Position = UDim2.fromOffset(0, CFG.HeaderH)
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.ScrollBarThickness = 6
    b.ScrollBarImageColor3 = C.Accent
    b.ScrollBarImageTransparency = 0.3
    b.CanvasSize = UDim2.new(0, 0, 0, 0)
    b.AutomaticCanvasSize = Enum.AutomaticSize.Y
    b.ScrollingDirection = Enum.ScrollingDirection.Y
    b.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    b.Visible = false

    local layout = Instance.new("UIListLayout", b)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", b)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 28)
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 16)
    return b
end

local resizeHandle = Instance.new("Frame", menu)
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.fromOffset(16, 16)
resizeHandle.Position = UDim2.new(1, -16, 1, -16)
resizeHandle.BackgroundColor3 = C.Accent
resizeHandle.BackgroundTransparency = 0.55
resizeHandle.BorderSizePixel = 0
resizeHandle.Active = true
resizeHandle.ZIndex = 5
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 4)
local resizeIcon = Instance.new("TextLabel", resizeHandle)
resizeIcon.Size = UDim2.fromScale(1, 1)
resizeIcon.BackgroundTransparency = 1
resizeIcon.Text = "◢"
resizeIcon.Font = FontBold
resizeIcon.TextSize = 11
resizeIcon.TextColor3 = C.Text
resizeIcon.ZIndex = 6

resizeHandle.MouseEnter:Connect(function()
    TweenService:Create(resizeHandle, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
end)
resizeHandle.MouseLeave:Connect(function()
    TweenService:Create(resizeHandle, TweenInfo.new(0.12), {BackgroundTransparency = 0.55}):Play()
end)

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

local function relayout()
    local top = CFG.HeaderH + (tabBar.Visible and TAB_H or 0)
    for _, cat in pairs(categories) do
        cat.body.Position = UDim2.new(cat.body.Position.X.Scale, 0, 0, top)
        cat.body.Size = UDim2.new(1, 0, 1, -top)
    end
end

local animToken = 0
local SLIDE_TIME = 0.25

function API:SelectCategory(name)
    local target = categories[name]
    if not target or selectedCat == name then return end
    local prev = selectedCat and categories[selectedCat]
    selectedCat = name

    for n, cat in pairs(categories) do
        local on = (n == name)
        TweenService:Create(cat.button, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.Accent or C.Surface2,
            TextColor3 = on and C.Bg or C.TextDim,
        }):Play()
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
        target.body.Position = UDim2.new(dir, 0, 0, y)
        target.body.Visible = true
    end

    local info = TweenInfo.new(SLIDE_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(target.body, info, {Position = UDim2.new(0, 0, 0, y)}):Play()
    TweenService:Create(prev.body, info, {Position = UDim2.new(-dir, 0, 0, y)}):Play()

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
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.Size = UDim2.fromOffset(0, 28)
    btn.BackgroundColor3 = C.Surface2
    btn.AutoButtonColor = false
    btn.Text = labelText or name
    btn.Font = FontBold
    btn.TextSize = 12
    btn.TextColor3 = C.TextDim
    btn.LayoutOrder = (opts and opts.order) or categoryOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local p = Instance.new("UIPadding", btn)
    p.PaddingLeft = UDim.new(0, 14)
    p.PaddingRight = UDim.new(0, 14)

    local cat = { body = makeBody(), button = btn }
    categories[name] = cat
    btn.MouseButton1Click:Connect(function() API:SelectCategory(name) end)

    if explicit then tabBar.Visible = true end
    relayout()
    if not selectedCat and not (opts and opts.noSelect) then API:SelectCategory(name) end
    return cat
end

function API:AddCategory(name, labelText)
    createCategory(name, labelText, true)
    currentCat = name
    return categories[name]
end

function API:UseCategory(name)
    if categories[name] then currentCat = name end
end

local function currentBody()
    if not currentCat then
        createCategory("main", "Main", false)
        currentCat = "main"
    end
    return categories[currentCat].body
end

function API:AddSection(text)
    local lbl = Instance.new("TextLabel", currentBody())
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.Font = FontBold
    lbl.TextSize = 11
    lbl.TextColor3 = C.Accent
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = nextOrder()
    return lbl
end

function API:AddToggle(name, labelText, default, callback)
    local row = Instance.new("Frame", currentBody())
    row.Name = name .. "_Row"
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = nextOrder()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size = UDim2.fromOffset(46, 24)
    track.Position = UDim2.new(1, -60, 0.5, -12)
    track.BackgroundColor3 = C.Off
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = C.Text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickArea = Instance.new("TextButton", row)
    clickArea.Size = UDim2.fromScale(1, 1)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""

    local state = default and true or false

    local function applyVisual()
        track.BackgroundColor3 = state and C.On or C.Off
        knob.Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
    end

    local function setState(v, silent)
        state = v and true or false
        TweenService:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and C.On or C.Off
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)
        }):Play()
        if not silent and callback then pcall(callback, state) end
    end

    applyVisual()
    clickArea.MouseButton1Click:Connect(function() setState(not state) end)

    registry[name] = {
        kind = "toggle",
        set = setState,
        get = function() return state end,
        row = row,
    }
    if default and callback then pcall(callback, true) end
    applyPending(name)
    return registry[name]
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
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1

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
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or name
    lbl.Font = Font
    lbl.TextSize = 14
    lbl.TextColor3 = C.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local icon = Instance.new("Frame", row)
    icon.Size = UDim2.fromOffset(22, 22)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(1, -26, 0.5, 0)
    icon.BackgroundColor3 = C.Surface2
    icon.BorderSizePixel = 0
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
    local iconStroke = Instance.new("UIStroke", icon)
    iconStroke.Color = C.Accent
    iconStroke.Thickness = 1.25

    local dot = Instance.new("Frame", icon)
    dot.Size = UDim2.fromOffset(6, 6)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = UDim2.fromScale(0.5, 0.5)
    dot.BackgroundColor3 = C.Accent
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local ripple = Instance.new("Frame", icon)
    ripple.Size = UDim2.fromOffset(6, 6)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.fromScale(0.5, 0.5)
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
        TweenService:Create(icon, TweenInfo.new(0.1), {BackgroundColor3 = C.Accent}):Play()
        TweenService:Create(dot, TweenInfo.new(0.1), {BackgroundColor3 = C.Bg}):Play()
        ripple.Size = UDim2.fromOffset(6, 6)
        rippleStroke.Transparency = 0
        ripple.Visible = true
        TweenService:Create(ripple, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
            Size = UDim2.fromOffset(26, 26)
        }):Play()
        TweenService:Create(rippleStroke, TweenInfo.new(0.35), {Transparency = 1}):Play()
    end

    local function reset()
        TweenService:Create(icon, TweenInfo.new(0.2), {BackgroundColor3 = C.Surface2}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent}):Play()
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
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1

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
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 10)
        local ps = Instance.new("UIStroke", popup)
        ps.Color = C.Accent
        ps.Thickness = 1.25

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
            b.BackgroundColor3 = sel and C.Accent or C.Surface2
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Text = tostring(opt)
            b.Font = Font
            b.TextSize = 13
            b.TextColor3 = sel and C.Bg or C.Text
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

function API:GetSelect(name)
    local e = registry[name]
    if e and e.kind == "select" then return e.get() end
    return nil
end

function API:SetSelect(name, value, silent)
    local e = registry[name]
    if e and e.kind == "select" then e.set(value, silent) end
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
        if inst:IsA("GuiObject") then
            inst.BackgroundColor3 = map(inst.BackgroundColor3)
        end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            inst.TextColor3 = map(inst.TextColor3)
        end
        if inst:IsA("ScrollingFrame") then
            inst.ScrollBarImageColor3 = map(inst.ScrollBarImageColor3)
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
        if e.kind == "toggle" or e.kind == "slider" or e.kind == "select" then
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
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row)
    s.Color = C.Stroke
    s.Thickness = 1

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
    valLbl.TextColor3 = C.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", valLbl).CornerRadius = UDim.new(0, 6)

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 42)
    track.BackgroundColor3 = C.Off
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(16, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = C.Text
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = C.Accent
    knobStroke.Thickness = 2

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
end

local function computeMenuPos()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local lx, ly = logo.AbsolutePosition.X, logo.AbsolutePosition.Y
    local lsx, lsy = logo.AbsoluteSize.X, logo.AbsoluteSize.Y
    local mw, mh = menu.AbsoluteSize.X, menu.AbsoluteSize.Y

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
    menu.Visible = true

    menu.Size = UDim2.fromOffset(targetSize.X.Offset, 0)
    TweenService:Create(menu, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end

function API:Close()
    if not isOpen then return end
    isOpen = false
    if activeSelectClose then activeSelectClose() end
    lastPos = menu.Position
    local fullSize = lastSize or defaultMenuSize()
    closeToken = closeToken + 1
    local token = closeToken
    TweenService:Create(menu, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
        Size = UDim2.fromOffset(fullSize.X.Offset, 0)
    }):Play()
    task.delay(0.18, function()
        if token ~= closeToken or isOpen then return end
        menu.Visible = false
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

local resizing, resizeStart, resizeStartSize = false, nil, nil
resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        resizeStartSize = menu.AbsoluteSize
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if activeSlider and activeInput then
            local sameTouch = (input == activeInput)
            local mouseMove = activeInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement
            if sameTouch or mouseMove then
                activeSlider(input.Position.X)
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
            local w = math.clamp(resizeStartSize.X + d.X, CFG.MenuWMin, maxW)
            local h = math.clamp(resizeStartSize.Y + d.Y, CFG.MenuHMin, maxH)
            menu.Size = UDim2.fromOffset(w, h)
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
        end
        dragMenu = false
        resizing = false
    end
end)

closeBtn.MouseButton1Click:Connect(function() API:Close() end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.Accent}):Play()
    TweenService:Create(closeIcon, TweenInfo.new(0.12), {TextColor3 = C.Bg}):Play()
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

local BZ_VERSION = "v2.2"
local TEXT_DEFAULTS = { Title = "BZ Menu", Logo = "BZ", Studio = "Studio The Clown" }
local logoSizeValue = 56
local studioText, studioShowVersion = TEXT_DEFAULTS.Studio, true

local function refreshLogoText()
    local len = utf8.len(logoText.Text) or #logoText.Text
    local size = logoSizeValue * 0.39
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
    createCategory("ui", "UI", true, { order = 9998, noSelect = true })
    currentCat = "ui"

    API:AddSection("Logo")
    API:AddSlider("ui_logo_size", "Logo Size", 36, 96, 56, function(v)
        logo.Size = UDim2.fromOffset(v, v)
        logoSizeValue = v
        refreshLogoText()
        local corner = logo:FindFirstChildOfClass("UICorner")
        if corner then corner.CornerRadius = UDim.new(0, math.floor(v * 0.25)) end
    end, 1)
    API:AddSlider("ui_logo_alpha", "Logo Transparan (%)", 0, 90, 0, function(v)
        local a = v / 100
        logo.BackgroundTransparency = a
        logoStroke.Transparency = a
        logoText.TextTransparency = a
    end, 5)

    API:AddSection("Thema")
    API:AddSelectMenu("ui_theme", "Thema", THEME_ORDER, "Ungu", function(v)
        API:SetTheme(v)
    end)

    API:AddSection("Config")
    local cfgStatus
    API:AddTapToggleOneClick("ui_save_config", "Save Config", function()
        local ok, err = API:SaveConfig()
        if cfgStatus then
            cfgStatus:SetText(ok and "✔ Config tersimpan" or ("✘ " .. tostring(err)))
        end
    end)
    cfgStatus = API:AddNote("Save Config menyimpan semua toggle, slider, dan pilihan ke folder \"BZ Menu\" sesuai Game ID (BZ_GameID_Config.json). Otomatis dimuat saat script dijalankan.")

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
    createCategory("devtools", "Dev Tools", true, { order = 9999, noSelect = true })
    currentCat = "devtools"

    local status
    local function report(ok, what)
        if not status then return end
        if ok then
            status:SetText("✔ Tersalin: " .. what)
        else
            status:SetText("✘ Executor tidak support clipboard")
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

print("[BZ] Menu UI v2.2 module ready.")
return API
