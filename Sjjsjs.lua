-- ==========================================
--               НАСТРОЙКИ СКРИПТА
-- ==========================================
local Settings = {
    -- Настройки Silent Grab (Тихого захвата)
    SilentGrab = {
        Enabled = true,             -- Включить автоматический захват (true/false)
        Radius = 180,               -- Радиус круга захвата в пикселях
        Visible = true,             -- Показывать ли круг на экране (true/false)
        Color = Color3.fromRGB(0, 255, 150), -- Цвет круга (зеленовато-голубой)
        TargetPart = "HumanoidRootPart" -- Куда магнитить захват (центр тела)
    },
    
    -- Настройки Anti-Grab (Защиты от взятия)
    AntiGrab = {
        Enabled = true,             -- Мгновенно отпускать, если вас схватили (true/false)
        Method = "DestroyWeld"       -- Метод защиты: "DestroyWeld" (быстрый) или "AutoSpace" (легитный)
    }
}

-- ==========================================
--         ИНИЦИАЛИЗАЦИЯ И СЕРВИСЫ
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Создание визуального круга FOV на экране
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 2
FOV_Circle.NumSides = 60
FOV_Circle.Radius = Settings.SilentGrab.Radius
FOV_Circle.Filled = false
FOV_Circle.Color = Settings.SilentGrab.Color
FOV_Circle.Visible = Settings.SilentGrab.Visible

-- Обновление позиции и размера круга под курсором каждый кадр
RunService.RenderStepped:Connect(function()
    if Settings.SilentGrab.Enabled and Settings.SilentGrab.Visible then
        FOV_Circle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- Коррекция смещения мыши в Roblox
        FOV_Circle.Radius = Settings.SilentGrab.Radius
        FOV_Circle.Visible = true
    else
        FOV_Circle.Visible = false
    end
end)

-- ==========================================
--         ЛОГИКА SILENT GRAB (КРУГ)
-- ==========================================
local function getClosestPlayerInCircle()
    if not Settings.SilentGrab.Enabled then return nil end
    
    local closestTarget = nil
    local shortestDistance = Settings.SilentGrab.Radius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.SilentGrab.TargetPart) then
            local part = player.Character[Settings.SilentGrab.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local playerScreenPos = Vector2.new(pos.X, pos.Y)
                local distance = (mousePos - playerScreenPos).Magnitude

                -- Проверка: находится ли цель внутри радиуса круга
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = part
                end
            end
        end
    end
    return closestTarget
end

-- Перехват метатаблицы мыши для подмены вектора клика
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldIndex = gmt.__index

gmt.__index = newcclosure(function(self, key)
    if self == Mouse and (key == "Hit" or key == "Target") then
        local target = getClosestPlayerInCircle()
        if target then
            if key == "Hit" then
                return target.CFrame
            elseif key == "Target" then
                return target
            end
        end
    end
    return oldIndex(self, key)
end)
setreadonly(gmt, true)

-- ==========================================
--          ЛОГИКА ANTI-GRAB (ЗАЩИТА)
-- ==========================================
-- Метод 1: Полное удаление соединений физики
local function cleanGrabAttachments(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        -- Удаление Welds (жестких связок рук)
        if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("WeldConstraint") then
            if part.Part0 and part.Part1 then
                local p0Owner = Players:GetPlayerFromCharacter(part.Part0.Parent)
                local p1Owner = Players:GetPlayerFromCharacter(part.Part1.Parent)
                if (p0Owner and p0Owner ~= LocalPlayer) or (p1Owner and p1Owner ~= LocalPlayer) then
                    part:Destroy()
                end
            end
        end
        -- Удаление веревок и натяжителей
        if part:IsA("RopeConstraint") or part:IsA("SpringConstraint") or part:IsA("RodConstraint") then
            part:Destroy()
        end
    end
end

-- Метод 2: Симуляция легального освобождения через Пробел
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

-- Отслеживание захвата персонажа
RunService.Heartbeat:Connect(function()
    if not Settings.AntiGrab.Enabled or not LocalPlayer.Character then return end
    
    if Settings.AntiGrab.Method == "DestroyWeld" then
        cleanGrabAttachments(LocalPlayer.Character)
    elseif Settings.AntiGrab.Method == "AutoSpace" then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local state = humanoid:GetState()
            -- Если персонаж упал в Ragdoll или перешел в режим физики (вас тащат)
            if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll then
                task.spawn(autoSpaceEscape)
            end
        end
    end
end)
