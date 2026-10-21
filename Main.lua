local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
    MenuWDef  = 280,
    MenuHDef  = 380,
    MenuWMin  = 220,
    MenuHMin  = 240,
    MenuWMax  = 520,
    MenuHMax  = 720,
    HeaderH   = 52,
    LogoGap   = 12,
    ScreenPad = 10,
    LogoStart = UDim2.new(0, 40, 0.5, -28),
}
local C = CFG.Colors
local Font, FontBold = CFG.Font, CFG.FontBold

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
subtitle.Text = "v1.5 · Studio The Clown"
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

local body = Instance.new("ScrollingFrame", menu)
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -CFG.HeaderH)
body.Position = UDim2.fromOffset(0, CFG.HeaderH)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 6
body.ScrollBarImageColor3 = C.Accent
body.ScrollBarImageTransparency = 0.3
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.ScrollingDirection = Enum.ScrollingDirection.Y
body.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable

local bodyLayout = Instance.new("UIListLayout", body)
bodyLayout.Padding = UDim.new(0, 10)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local bodyPad = Instance.new("UIPadding", body)
bodyPad.PaddingTop = UDim.new(0, 16)
bodyPad.PaddingBottom = UDim.new(0, 28)
bodyPad.PaddingLeft = UDim.new(0, 16)
bodyPad.PaddingRight = UDim.new(0, 16)

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
local activeSlider = nil

local function nextOrder()
    layoutCounter = layoutCounter + 1
    return layoutCounter
end

local API = {}

function API:AddSection(text)
    local lbl = Instance.new("TextLabel", body)
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
    local row = Instance.new("Frame", body)
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
    return registry[name]
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

    local row = Instance.new("Frame", body)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            activeSlider = updateFromX
            body.ScrollingEnabled = false
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

local isOpen = false
local lastPos, lastSize = nil, nil
local closeToken = 0

function API:Open()
    if isOpen then return end
    isOpen = true
    closeToken = closeToken + 1
    logo.Visible = false

    local targetSize = lastSize or UDim2.fromOffset(CFG.MenuWDef, CFG.MenuHDef)
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
    lastPos = menu.Position
    local fullSize = lastSize or UDim2.fromOffset(CFG.MenuWDef, CFG.MenuHDef)
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
        if activeSlider then
            activeSlider(input.Position.X)
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
            local w = math.clamp(resizeStartSize.X + d.X, CFG.MenuWMin, CFG.MenuWMax)
            local h = math.clamp(resizeStartSize.Y + d.Y, CFG.MenuHMin, CFG.MenuHMax)
            menu.Size = UDim2.fromOffset(w, h)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if activeSlider then
            activeSlider = nil
            body.ScrollingEnabled = true
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
    if screenGui then screenGui:Destroy() end
end

API.Instances = {
    ScreenGui = screenGui,
    Logo = logo,
    Menu = menu,
    Header = header,
    Body = body,
    ResizeHandle = resizeHandle,
    Colors = C,
}

setmetatable(API, {__call = function(self) return self end})

print("[BZ] Menu UI v1.5 module ready.")
return API
