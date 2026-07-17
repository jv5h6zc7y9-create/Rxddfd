-- ==========================================
--               НАСТРОЙКИ ХАБА
-- ==========================================
local Settings = {
    SilentGrab = {
        Enabled = true,
        Radius = 180,                         -- Радиус круга аима в пикселях
        Color = Color3.fromRGB(255, 0, 100),   -- Цвет круга (Розовый)
    },
    ESP = {
        Enabled = true,                        -- ВХ (Подсветка игроков через стены)
        Boxes = true,                          -- Квадраты вокруг игроков
        Names = true,                          -- Никнеймы игроков
        Color = Color3.fromRGB(0, 255, 255)    -- Цвет подсветки ВХ (Голубой)
    },
    SuperFling = {
        Enabled = true,
        Power = 600                            -- Сила броска за карту
    },
    AntiGrab = {
        Enabled = true                         -- Защита от чужих рук
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

-- Создание визуального круга Аима строго по центру
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 2
FOV_Circle.NumSides = 60
FOV_Circle.Filled = false
FOV_Circle.Color = Settings.SilentGrab.Color
FOV_Circle.Visible = Settings.SilentGrab.Enabled

RunService.RenderStepped:Connect(function()
    if Settings.SilentGrab.Enabled then
        local screenSize = Camera.ViewportSize
        FOV_Circle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        FOV_Circle.Radius = Settings.SilentGrab.Radius
        FOV_Circle.Visible = true
    else
        FOV_Circle.Visible = false
    end
end)

-- ==========================================
--    ЛОГИКА АИМА (ПОИСК ЦЕЛИ В КРУГЕ)
-- ==========================================
local function getTargetInCenter()
    if not Settings.SilentGrab.Enabled then return nil end
    local closestTarget = nil
    local shortestDistance = Settings.SilentGrab.Radius
    local screenSize = Camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local distance = (screenCenter - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = player.Character
                end
            end
        end
    end
    return closestTarget
end

-- ==========================================
--   РАБОТА АИМА, ЗАХВАТА И СУПЕР-БРОСКА
-- ==========================================
local currentGrabbedCharacter = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Клик мыши или тач на экране активирует захват цели в круге аима
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local targetCharacter = getTargetInCenter()
        
        if targetCharacter and not currentGrabbedCharacter then
            -- МГНОВЕННЫЙ ЗАХВАТ (АИМ МАГНИТ): Телепортирует цель из круга к твоей руке
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                currentGrabbedCharacter = targetCharacter
                targetCharacter.HumanoidRootPart.CFrame = myRoot.CFrame + (myRoot.CFrame.LookVector * 4)
            end
        elseif currentGrabbedCharacter then
            -- ДАЛЁКИЙ БРОСОК (СУПЕР ФЛИНГ): Второй клик запускает цель в космос по направлению камеры
            local targetRoot = currentGrabbedCharacter:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local throwDirection = Camera.CFrame.LookVector
                targetRoot.Velocity = (throwDirection * Settings.SuperFling.Power) + Vector3.new(0, Settings.SuperFling.Power / 2, 0)
                targetRoot.RotVelocity = Vector3.new(math.random(-120, 120), math.random(-120, 120), math.random(-120, 120))
            end
            currentGrabbedCharacter = nil
        end
    end
end)

-- Фиксация цели перед собой во время удержания
RunService.Heartbeat:Connect(function()
    if currentGrabbedCharacter and currentGrabbedCharacter:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            currentGrabbedCharacter.HumanoidRootPart.CFrame = myRoot.CFrame + (myRoot.CFrame.LookVector * 5)
            currentGrabbedCharacter.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        else
            currentGrabbedCharacter = nil
        end
    end
end)

-- ==========================================
--         ЛОГИКА ВХ (ESP / ПОДСВЕТКА)
-- ==========================================
local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Settings.ESP.Color
    box.Visible = false

    local nameLabel = Drawing.new("Text")
    nameLabel.Text = player.Name
    nameLabel.Size = 14
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Visible = false

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not Settings.ESP.Enabled or not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            nameLabel.Visible = false
            if not player.Parent then conn:Disconnect() box:Remove() nameLabel:Remove() end
            return
        end

        local root = player.Character.HumanoidRootPart
        local head = player.Character:FindFirstChild("Head")
        if not head then return end

        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

        if rootOnScreen then
            -- Расчет размеров квадрата ВХ
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height / 1.5

            if Settings.ESP.Boxes then
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                box.Visible = true
            else
                box.Visible = false
            end

            if Settings.ESP.Names then
                nameLabel.Position = Vector2.new(rootPos.X, rootPos.Y - height / 2 - 15)
                nameLabel.Visible = true
            else
                nameLabel.Visible = false
            end
        else
            box.Visible = false
            nameLabel.Visible = false
        end
    end)
end

-- Авто-подключение ВХ ко всем игрокам
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)

-- ==========================================
--                ANTI-GRAB
-- ==========================================
RunService.Heartbeat:Connect(function()
    if not Settings.AntiGrab.Enabled or not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("WeldConstraint") or part:IsA("RopeConstraint") then
            part:Destroy()
        end
    end
end)
