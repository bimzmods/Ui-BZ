local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local POS_FIX = Vector3.new(43.09, 3.00, 135.95)
local POS_ESCAPE = Vector3.new(-13.70, 44.73, 140.52)

local gui = Instance.new("ScreenGui")
gui.Name = "TPMenu"
gui.ResetOnSpawn = false
local ok = pcall(function()
    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ok or not gui.Parent then
    gui.Parent = lp:WaitForChild("PlayerGui")
end

local function teleport(pos)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- drag: onTap hanya dipanggil kalau tidak bergeser
local function makeDraggable(handle, target, onTap)
    local dragging, moved = false, false
    local startPos, objStart
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            startPos = input.Position
            objStart = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onTap then onTap() end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - startPos
            if d.Magnitude > 8 then moved = true end
            if moved then
                target.Position = UDim2.new(
                    objStart.X.Scale, objStart.X.Offset + d.X,
                    objStart.Y.Scale, objStart.Y.Offset + d.Y)
            end
        end
    end)
end

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
end

-- Menu
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 190, 0, 130)
menu.Position = UDim2.new(0, 70, 0.4, 0)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
menu.Visible = false
menu.Parent = gui
corner(menu, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.Text = "Teleport Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = menu
corner(title, 10)

local function makeBtn(text, y, pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(70, 90, 200)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Parent = menu
    corner(b, 8)
    b.Activated:Connect(function() teleport(pos) end)
end
makeBtn("Fix Stuck", 40, POS_FIX)
makeBtn("Escape Preman", 84, POS_ESCAPE)

makeDraggable(title, menu, nil)

-- Tombol buka/tutup
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 46, 0, 46)
toggle.Position = UDim2.new(0, 10, 0.4, 0)
toggle.BackgroundColor3 = Color3.fromRGB(70, 90, 200)
toggle.Text = "TP"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
toggle.AutoButtonColor = false
toggle.Parent = gui
corner(toggle, 23)

makeDraggable(toggle, toggle, function()
    menu.Visible = not menu.Visible
end)
