-- ==========================================
--               НАСТРОЙКИ ПО УМОЛЧАНИЮ
-- ==========================================
local Settings = {
    SilentGrab = {
        Enabled = true,
        Radius = 150,
        Color = Color3.fromRGB(0, 255, 150),
        TargetPart = "HumanoidRootPart"
    },
    AntiGrab = {
        Enabled = true,
        Method = "DestroyWeld" -- "DestroyWeld" или "AutoSpace"
    }
}

-- ==========================================
--         ИНИЦИАЛИЗАЦИЯ И СЕРВИСЫ
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Создание визуального круга FOV (Строго по центру)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 2
FOV_Circle.NumSides = 60
FOV_Circle.Filled = false
FOV_Circle.Color = Settings.SilentGrab.Color
FOV_Circle.Visible = Settings.SilentGrab.Enabled

-- Обновление круга строго по центру экрана каждый кадр
RunService.RenderStepped:Connect(function()
    if Settings.SilentGrab.Enabled then
        -- Получаем центр экрана динамически
        local screenSize = Camera.ViewportSize
        FOV_Circle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        FOV_Circle.Radius = Settings.SilentGrab.Radius
        FOV_Circle.Visible = true
    else
        FOV_Circle.Visible = false
    end
end)

-- ==========================================
--    ЛОГИКА СХВАТЫВАНИЯ ИЗ ЦЕНТРА ЭКРАНА
-- ==========================================
local function getClosestPlayerToCenter()
    if not Settings.SilentGrab.Enabled then return nil end
    
    local closestTarget = nil
    local shortestDistance = Settings.SilentGrab.Radius
    local screenSize = Camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.SilentGrab.TargetPart) then
            local part = player.Character[Settings.SilentGrab.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local playerScreenPos = Vector2.new(pos.X, pos.Y)
                -- Считаем расстояние от ЦЕНТРА экрана до игрока
                local distance = (screenCenter - playerScreenPos).Magnitude

                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = part
                end
            end
        end
    end
    return closestTarget
end

-- Перехват метатаблицы мыши
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldIndex = gmt.__index

gmt.__index = newcclosure(function(self, key)
    if self == LocalPlayer:GetMouse() and (key == "Hit" or key == "Target") then
        local target = getClosestPlayerToCenter()
        if target then
            if key == "Hit" then return target.CFrame end
            if key == "Target" then return target end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(gmt, true)

-- ==========================================
--          ЛОГИКА ANTI-GRAB (ЗАЩИТА)
-- ==========================================
local function cleanGrabAttachments(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("WeldConstraint") then
            if part.Part0 and part.Part1 then
                local p0Owner = Players:GetPlayerFromCharacter(part.Part0.Parent)
                local p1Owner = Players:GetPlayerFromCharacter(part.Part1.Parent)
                if (p0Owner and p0Owner ~= LocalPlayer) or (p1Owner and p1Owner ~= LocalPlayer) then
                    part:Destroy()
                end
            end
        end
        if part:IsA("RopeConstraint") or part:IsA("SpringConstraint") or part:IsA("RodConstraint") then
            part:Destroy()
        end
    end
end

local isSpamming = false
local function autoSpaceEscape()
    if isSpamming then return end
    isSpamming = true
    for i = 1, 8 do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
    isSpamming = false
end

RunService.Heartbeat:Connect(function()
    if not Settings.AntiGrab.Enabled or not LocalPlayer.Character then return end
    if Settings.AntiGrab.Method == "DestroyWeld" then
        cleanGrabAttachments(LocalPlayer.Character)
    elseif Settings.AntiGrab.Method == "AutoSpace" then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and (humanoid:GetState() == Enum.HumanoidStateType.Physics or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll) then
            task.spawn(autoSpaceEscape)
        end
    end
end)

-- ==========================================
--         СОЗДАНИЕ UI МЕНЮ (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FTAP_MenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главный фрейм меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перетаскивать пальцем/мышкой
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "FTAP Проводник (Клавиша: K)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner") TitleCorner.CornerRadius = UDim.new(0, 10) TitleCorner.Parent = Title

-- Список элементов меню
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame
UIListLayout.Parent = Container

-- Функция для создания красивых кнопок-переключателей
local function createToggleButton(text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local function updateVisuals(state)
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            btn.Text = text .. ": ВКЛ"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            btn.Text = text .. ": ВЫКЛ"
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end
    end

    local state = defaultState
    updateVisuals(state)

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals(state)
        callback(state)
    end)

    btn.Parent = Container
end

-- Кнопка 1: Silent Grab
createToggleButton("Silent Grab (Центр)", Settings.SilentGrab.Enabled, function(state)
    Settings.SilentGrab.Enabled = state
end)

-- Кнопка 2: Настройка радиуса (Циклическое изменение)
local RadiusBtn = Instance.new("TextButton")
RadiusBtn.Size = UDim2.new(0, 220, 0, 40)
RadiusBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
RadiusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusBtn.Font = Enum.Font.SourceSans
RadiusBtn.TextSize = 16
RadiusBtn.Text = "Радиус FOV: " .. Settings.SilentGrab.Radius
RadiusBtn.Parent = Container
local RCorner = Instance.new("UICorner") RCorner.CornerRadius = UDim.new(0, 6) RCorner.Parent = RadiusBtn

RadiusBtn.MouseButton1Click:Connect(function()
    if Settings.SilentGrab.Radius == 100 then Settings.SilentGrab.Radius = 150
    elseif Settings.SilentGrab.Radius == 150 then Settings.SilentGrab.Radius = 220
    elseif Settings.SilentGrab.Radius == 220 then Settings.SilentGrab.Radius = 300
    else Settings.SilentGrab.Radius = 100 end
    RadiusBtn.Text = "Радиус FOV: " .. Settings.SilentGrab.Radius
end)

-- Кнопка 3: Anti-Grab
createToggleButton("Anti-Grab", Settings.AntiGrab.Enabled, function(state)
    Settings.AntiGrab.Enabled = state
end)

-- Кнопка 4: Метод защиты (Мгновенный сброс или Авто-пробел)
local MethodBtn = Instance.new("TextButton")
MethodBtn.Size = UDim2.new(0, 220, 0, 40)
MethodBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
MethodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MethodBtn.Font = Enum.Font.SourceSans
MethodBtn.TextSize = 16
MethodBtn.Text = "Обход: " .. (Settings.AntiGrab.Method == "DestroyWeld" and "Мгновенный" or "Легитный")
MethodBtn.Parent = Container
local MCorner = Instance.new("UICorner") MCorner.CornerRadius = UDim.new(0, 6) MCorner.Parent = MethodBtn

MethodBtn.MouseButton1Click:Connect(function()
    if Settings.AntiGrab.Method == "DestroyWeld" then
        Settings.AntiGrab.Method = "AutoSpace"
        MethodBtn.Text = "Обход: Легитный (Space)"
    else
        Settings.AntiGrab.Method = "DestroyWeld"
        MethodBtn.Text = "Обход: Мгновенный"
    end
end)

-- Открытие/Закрытие меню на кнопку K
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
