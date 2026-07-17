--[[
    ================================================================================
    👑 BROSA SYSTEM v6.0 — CYBERPUNK MONOLITHIC HYBRID EXPLOIT HUB
    🎨 UI ENGINE: NEO-GLOW CYBERPUNK INTERFACE v3 (ELITE EDITION)
    🔒 TARGET GAME: FLING THINGS AND PEOPLE (FTAP) & UNIVERSAL
    🚀 BYPASS STATUS: ACTIVE | FULLY OPTIMIZED FOR DELTA EXECUTOR (MOBILE/PC)
    ================================================================================
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================================
-- [1. СИСТЕМНЫЕ СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ ИДЕНТИФИКАТОРОВ]
-- ============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")

local lp = Players.LocalPlayer
if not lp.Character then 
    lp.CharacterAdded:Wait() 
end
local camera = workspace.CurrentCamera

-- Защита от дублирования потоков выполнения
if _G.BrosaHubGlobal and _G.BrosaHubGlobal.Loaded then
    warn("[Brosa System]: Скрипт уже запущен! Повторная инициализация заблокирована.")
    return
end

-- Глобальная структура состояния (Brosa Core State Architecture)
_G.BrosaHubGlobal = {
    Loaded = true,
    Flags = {
        -- Раздел: Движение
        WalkSpeedEnabled = false,
        WalkSpeedValue = 16,
        JumpPowerEnabled = false,
        JumpPowerValue = 50,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        AntiFling = false,
        
        -- Раздел: FTAP Бой & Специфика
        SilentAim = false,
        SilentAimFOV = 120,
        ShowFOV = false,
        MegaThrow = false,
        ThrowForce = 500000,
        InstantGrabBreak = false,
        CounterAttack = false,
        CounterMode = "В небо", -- "В небо" или "В подкарту"
        CounterAngle = 70,
        VehicleKillAll = false,
        UnlockToyShop = false,
        ForceThirdPerson = false,
        CustomFOV = 70,
        
        -- Раздел: Вредительство & Троллинг
        FlingAura = false,
        ClickFling = false,
        FlingAll = false,
        KillAura = false,
        BringAll = false,
        PropsFling = false,
        OrbitPlayer = false,
        TargetPlayer = "",
        OrbitSpeed = 5,
        OrbitDistance = 5,
        MassWeld = false,
        LobbyFreeze = false,
        
        -- Раздел: Визуалы & ESP
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,
        
        -- Обходы & Безопасность
        BypassMetatable = true,
        ChatSpam = false,
        ChatSpamMessage = "Brosa System v6.0 (Cyberpunk Edition) Управляет Сервером!"
    },
    Cache = {
        OriginalLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows
        },
        Connections = {},
        EspBoxes = {},
        EspTracers = {},
        EspNames = {},
        EspHealth = {},
        OriginalMaterials = {},
        PreviousCoords = Vector3.new(0, 0, 0)
    }
}

local Hub = _G.BrosaHubGlobal

-- Безопасный менеджер соединений для предотвращения утечек памяти
local function SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Hub.Cache.Connections, connection)
    return connection
end

-- Поиск игрока по частичному совпадению юзернейма/дисплейнейма
local function FindPlayerByName(name)
    if not name or name == "" then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

-- ============================================================================
-- [2. КРОСС ПЛАТФОРМЕННЫЙ КРУГ FOV И СИСТЕМА ФИЛЬТРАЦИИ ЦЕЛЕЙ]
-- ============================================================================
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "Brosa_FOV_Core"
FOVGui.ResetOnSpawn = false
pcall(function() FOVGui.Parent = CoreGui end)
if not FOVGui.Parent then FOVGui.Parent = lp:WaitForChild("PlayerGui") end

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVFrame"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.new(0, Hub.Flags.SilentAimFOV * 2, 0, Hub.Flags.SilentAimFOV * 2)
FOVCircle.Visible = false
FOVCircle.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(0, 255, 240)
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVCircle

-- Обновление геометрии круга захвата в реальном времени
SafeConnect(RunService.RenderStepped, function()
    if Hub.Flags.SilentAim and Hub.Flags.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Size = UDim2.new(0, Hub.Flags.SilentAimFOV * 2, 0, Hub.Flags.SilentAimFOV * 2)
    else
        FOVCircle.Visible = false
    end
end)

-- Функция поиска ближайшего противника внутри радиуса FOV
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Hub.Flags.SilentAimFOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local mouseLocation = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ============================================================================
-- [3. МОЩНЫЙ ФИЗИЧЕСКИЙ ДВИЖОК И ИСПРАВЛЕННЫЕ ФУНКЦИИ ХАБАРОВ]
-- ============================================================================

-- Корректный Noclip без конфликтов с гравитацией
SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    if Hub.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Исправленный и усиленный Anti-Fling (Анти-отброс)
SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if Hub.Flags.AntiFling and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                if not Hub.Flags.Fly then
                    local velocity = part.AssemblyLinearVelocity
                    if velocity.Magnitude > 80 then
                        part.AssemblyLinearVelocity = Vector3.new(math.clamp(velocity.X, -25, 25), math.clamp(velocity.Y, -40, 40), math.clamp(velocity.Z, -25, 25))
                    end
                end
            end
        end
    end
end)

-- Камера-ориентированный Полет (Fly Engine v3) — Движение строго за взглядом камеры
SafeConnect(RunService.RenderStepped, function()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Hub.Flags.Fly and root and hum then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        local camCFrame = camera.CFrame
        local flyVel = Vector3.new(0, 0, 0)
        
        -- Анализ клавиатурного и мобильного смещения вектора движения
        if moveDir.Magnitude > 0 then
            -- Проекция направления движения вперед/назад на вектор взгляда камеры
            flyVel = camCFrame.LookVector * (moveDir.Z * -Hub.Flags.FlySpeed) + camCFrame.RightVector * (moveDir.X * Hub.Flags.FlySpeed)
            -- Корректировка по вертикальной оси при взгляде вверх/вниз
            flyVel = flyVel + Vector3.new(0, camCFrame.LookVector.Y * (moveDir.Z * -Hub.Flags.FlySpeed), 0)
        end
        
        -- Ручной подъем / спуск
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyVel = flyVel + Vector3.new(0, Hub.Flags.FlySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyVel = flyVel - Vector3.new(0, Hub.Flags.FlySpeed, 0)
        end
        
        root.AssemblyLinearVelocity = flyVel
        root.CFrame = CFrame.new(root.Position, root.Position + camCFrame.LookVector)
    elseif hum and hum.PlatformStand and not Hub.Flags.Fly then
        hum.PlatformStand = false
    end
end)

-- Бесконечный прыжок
SafeConnect(UserInputService.JumpRequest, function()
    if Hub.Flags.InfiniteJump then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================================
-- [4. РЕАЛИЗАЦИЯ ИСПРАВЛЕННЫХ ТЕХНИЧЕСКИХ ФУНКЦИЙ ДЛЯ ИГРЫ FTAP]
-- ============================================================================

-- 1. Мега-Далекий Бросок за карту (Out of Map Fling)
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if Hub.Flags.MegaThrow and not processed then
        if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
            -- Поиск персонажей, находящихся в захвате (находящихся на сверхблизком расстоянии к нашему вектору удержания)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = player.Character.HumanoidRootPart
                    local distance = (lp.Character.HumanoidRootPart.Position - targetRoot.Position).Magnitude
                    if distance < 25 then
                        pcall(function()
                            targetRoot.AssemblyLinearVelocity = camera.CFrame.LookVector * Hub.Flags.ThrowForce
                        end)
                    end
                end
            end
        end
    end
end)

-- 2. Анти-Взятие Себя (Instant Grab Break) + Спам Побега
SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if Hub.Flags.InstantGrabBreak and char then
        -- Уничтожение любых связей, созданных чужими лучами захвата
        for _, instance in ipairs(char:GetDescendants()) do
            if instance:IsA("Weld") or instance:IsA("Constraint") or instance:IsA("WeldConstraint") then
                local creatorModel = instance.Parent
                if creatorModel and creatorModel ~= char and not creatorModel:IsDescendantOf(char) then
                    pcall(function() instance:Destroy() end)
                end
            end
        end
        -- Симуляция быстрого спама кнопкой прыжка для автоматического сброса контроля
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- 3. Авто-Отброс в Небо и Телепорт под Карту (Контратака)
SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if Hub.Flags.CounterAttack and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local enemyRoot = player.Character.HumanoidRootPart
                local dist = (root.Position - enemyRoot.Position).Magnitude
                
                -- Если противник подошел в радиус атаки луча и направляет на нас захват
                if dist < 18 then
                    Hub.Cache.PreviousCoords = root.Position
                    
                    -- Смещение нашего вектора для уклонения
                    root.CFrame = root.CFrame * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15))
                    
                    task.wait(0.05)
                    if Hub.Flags.CounterMode == "В небо" then
                        -- Контратака Режим А: Запуск в стратосферу под углом
                        pcall(function()
                            local angleRad = math.rad(Hub.Flags.CounterAngle)
                            local launchVector = Vector3.new(math.cos(angleRad), math.sin(angleRad), 0) * 80000
                            enemyRoot.AssemblyLinearVelocity = launchVector
                        end)
                    elseif Hub.Flags.CounterMode == "В подкарту" then
                        -- Контратака Режим Б: Телепортация в Void с авто-возвратом
                        pcall(function()
                            enemyRoot.CFrame = CFrame.new(enemyRoot.Position.X, -500, enemyRoot.Position.Z)
                            enemyRoot.AssemblyLinearVelocity = Vector3.new(0, -50000, 0)
                            task.wait(0.1)
                            root.CFrame = CFrame.new(Hub.Cache.PreviousCoords)
                        end)
                    end
                end
            end
        end
    end
end)

-- 4. Машины: Функция "Убить Всех" (Vehicle Kill All)
SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.VehicleKillAll then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
            local vehicleModel = hum.SeatPart.Parent
            local primaryPart = vehicleModel and (vehicleModel.PrimaryPart or hum.SeatPart)
            
            if primaryPart then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyRoot = player.Character.HumanoidRootPart
                        -- Высокоскоростное физическое вращение и телепортация хитбокса транспорта сквозь игроков
                        pcall(function()
                            primaryPart.CFrame = enemyRoot.CFrame * CFrame.new(0, 2, 0)
                            primaryPart.AssemblyAngularVelocity = Vector3.new(50000, 50000, 50000)
                            primaryPart.AssemblyLinearVelocity = Vector3.new(5000, 0, 5000)
                        end)
                        task.wait(0.02)
                    end
                end
            end
        end
    end
end)

-- 5. Разблокировка скрытых предметов Toy Shop (Unlock All Items)
local function ExecuteUnlockToyShop()
    pcall(function()
        local shopStorage = ReplicatedStorage:FindFirstChild("ToyShopItems") or ReplicatedStorage:FindFirstChild("Items")
        if shopStorage then
            for _, item in ipairs(shopStorage:GetChildren()) do
                if item:IsA("BoolValue") and item.Name == "Locked" then
                    item.Value = false
                elseif item:FindFirstChild("Locked") then
                    item.Locked.Value = false
                end
            end
        end
    end)
end

SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.UnlockToyShop then
        ExecuteUnlockToyShop()
    end
end)

-- 6. Рабочее 3-е лицо с авто-возвратом
SafeConnect(RunService.RenderStepped, function()
    if Hub.Flags.ForceThirdPerson then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 40
        lp.CameraMinZoomDistance = 10
    end
end)

-- 7. Настраиваемый Растяг Экрана (FOV Changer)
SafeConnect(RunService.RenderStepped, function()
    if workspace.CurrentCamera.FieldOfView ~= Hub.Flags.CustomFOV then
        workspace.CurrentCamera.FieldOfView = Hub.Flags.CustomFOV
    end
end)

-- ============================================================================
-- [5. ВРЕДИТЕЛЬСТВО, ТРОЛЛИНГ И СИСТЕМЫ ПЕРЕМЕЩЕНИЯ]
-- ============================================================================

local function ExecuteFling(target)
    if not target or target == lp then return end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tchar = target.Character
    local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
    
    if root and troot then
        local oldCFrame = root.CFrame
        local flingActive = true
        
        local tempNoclip = RunService.Stepped:Connect(function()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        
        local flingLoop = RunService.Heartbeat:Connect(function()
            if not tchar or not troot or not troot.Parent or not flingActive then return end
            root.AssemblyLinearVelocity = Vector3.new(0, 200000, 0)
            root.AssemblyAngularVelocity = Vector3.new(200000, 200000, 200000)
            root.CFrame = troot.CFrame * CFrame.new(math.random(-1, 1)/5, 0, math.random(-1, 1)/5)
        end)
        
        task.delay(2.2, function()
            flingActive = false
            tempNoclip:Disconnect()
            flingLoop:Disconnect()
            task.wait(0.05)
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.CFrame = oldCFrame
            end
        end)
    end
end

SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.FlingAura then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = player.Character.HumanoidRootPart
                    local dist = (root.Position - targetRoot.Position).Magnitude
                    if dist <= 16 then
                        ExecuteFling(player)
                    end
                end
            end
        end
    end
end)

SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and Hub.Flags.ClickFling and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {lp.Character}
            
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1200, raycastParams)
            if result and result.Instance then
                local model = result.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local clickedPlayer = Players:GetPlayerFromCharacter(model)
                    if clickedPlayer and clickedPlayer ~= lp then
                        ExecuteFling(clickedPlayer)
                    end
                end
            end
        end
    end
end)

local orbitAngle = 0
SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.OrbitPlayer and Hub.Flags.TargetPlayer ~= "" then
        local target = FindPlayerByName(Hub.Flags.TargetPlayer)
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local tchar = target and target.Character
        local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
        
        if root and troot then
            orbitAngle = orbitAngle + (Hub.Flags.OrbitSpeed / 100)
            local offset = Vector3.new(
                math.cos(orbitAngle) * Hub.Flags.OrbitDistance,
                0,
                math.sin(orbitAngle) * Hub.Flags.OrbitDistance
            )
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(troot.Position + offset, troot.Position)
        end
    end
end)

local function RunMassWeld()
    local char = lp.Character
    if not char then return end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(char) then
            pcall(function()
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = part
                weld.Part1 = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("Part")
                weld.Parent = part
                part.CanCollide = false
            end)
        end
    end
end

SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.LobbyFreeze then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for i = 1, 35 do
                root.CFrame = root.CFrame * CFrame.new(0, 500000, 0)
                root.CFrame = root.CFrame * CFrame.new(0, -500000, 0)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3.5) do
        if Hub.Flags.ChatSpam and Hub.Loaded then
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = TextChatService.TextChannels.RBXGeneral
                    channel:SendAsync(Hub.Flags.ChatSpamMessage)
                else
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Hub.Flags.ChatSpamMessage, "All")
                end
            end)
        end
    end
end)

-- ============================================================================
-- [6. ПОЛНАЯ РЕАЛИЗАЦИЯ И РЕНДЕРИНГ ESP И ВИЗУАЛОВ]
-- ============================================================================
local function DrawESP(player)
    if player == lp then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 240)
    box.Thickness = 1.5
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 0, 128)
    tracer.Thickness = 1
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 13
    name.Center = true
    name.Outline = true
    
    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 130)
    healthBar.Thickness = 2
    
    Hub.Cache.EspBoxes[player.UserId] = box
    Hub.Cache.EspTracers[player.UserId] = tracer
    Hub.Cache.EspNames[player.UserId] = name
    Hub.Cache.EspHealth[player.UserId] = healthBar
    
    local function UpdateESP()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not Hub.Loaded or not (Hub.Flags.ESP_Boxes or Hub.Flags.ESP_Tracers or Hub.Flags.ESP_Names or Hub.Flags.ESP_Health) then
                box.Visible = false
                tracer.Visible = false
                name.Visible = false
                healthBar.Visible = false
                return
            end
            
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local sizeY = (camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y)
                    local sizeX = sizeY * 0.6
                    
                    if Hub.Flags.ESP_Boxes then
                        box.Size = Vector2.new(sizeX, sizeY)
                        box.Position = Vector2.new(rootPos.X - sizeX / 2, rootPos.Y - sizeY / 2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                    
                    if Hub.Flags.ESP_Tracers then
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                    
                    if Hub.Flags.ESP_Names then
                        name.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                        name.Position = Vector2.new(rootPos.X, (rootPos.Y - sizeY / 2) - 15)
                        name.Visible = true
                    else
                        name.Visible = false
                    end
                    
                    if Hub.Flags.ESP_Health then
                        local healthPercent = hum.Health / hum.MaxHealth
                        local barHeight = sizeY * healthPercent
                        healthBar.From = Vector2.new((rootPos.X - sizeX / 2) - 6, rootPos.Y + sizeY / 2)
                        healthBar.To = Vector2.new((rootPos.X - sizeX / 2) - 6, (rootPos.Y + sizeY / 2) - barHeight)
                        healthBar.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
                        healthBar.Visible = true
                    else
                        healthBar.Visible = false
                    end
                else
                    box.Visible = false
                    tracer.Visible = false
                    name.Visible = false
                    healthBar.Visible = false
                end
            else
                box.Visible = false
                tracer.Visible = false
                name.Visible = false
                healthBar.Visible = false
            end
        end)
        table.insert(Hub.Cache.Connections, connection)
    end
    task.spawn(UpdateESP)
end

Players.PlayerAdded:Connect(DrawESP)
for _, p in ipairs(Players:GetPlayers()) do DrawESP(p) end

local function ApplyPotatoPC(state)
    Hub.Flags.PotatoPC = state
    if state then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(lp.Character) then
                Hub.Cache.OriginalMaterials[obj] = {obj.Material, obj.Reflectance}
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end
    else
        for obj, data in pairs(Hub.Cache.OriginalMaterials) do
            if obj and obj.Parent then
                obj.Material = data[1]
                obj.Reflectance = data[2]
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
            end
        end
        table.clear(Hub.Cache.OriginalMaterials)
    end
end

-- ============================================================================
-- [7. СЛЕДУЮЩЕЕ ПОКОЛЕНИЕ UI: NEO-GLOW CYBERPUNK ENGINE (ПОВНОЕ ИСПОЛНЕНИЕ)]
-- ============================================================================
local CyberUI = {}
CyberUI.__index = CyberUI

local CYBER_THEME = {
    MainBg       = Color3.fromRGB(10, 11, 16),
    PanelBg      = Color3.fromRGB(18, 20, 28),
    BorderCyan   = Color3.fromRGB(0, 255, 240),
    BorderPink   = Color3.fromRGB(255, 0, 128),
    MainText     = Color3.fromRGB(255, 255, 255),
    DimText      = Color3.fromRGB(130, 135, 150),
    AccentGlow   = Color3.fromRGB(0, 255, 200),
    ToggleOff    = Color3.fromRGB(40, 43, 56)
}

local UI_EASE = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenUI(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function CyberUI.new(config)
    local self = setmetatable({}, CyberUI)
    self.Title = config.Title or "CYBER CORE"
    self.Version = config.Version or "v1.0"
    self.ActiveTab = nil
    self.Tabs = {}
    self:BuildCoreFrame()
    return self
end

function CyberUI:BuildCoreFrame()
    local screen = Instance.new("ScreenGui")
    screen.Name = "Brosa_CyberPro_" .. HttpService:GenerateGUID(false):sub(1,6)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screen.Parent = CoreGui end)
    if not screen.Parent then screen.Parent = lp:WaitForChild("PlayerGui") end
    self.Screen = screen

    -- Плавающий неоновый лаунчер для мобильных устройств
    local launcher = Instance.new("TextButton")
    launcher.Size = UDim2.new(0, 55, 0, 55)
    launcher.Position = UDim2.new(0.02, 0, 0.2, 0)
    launcher.BackgroundColor3 = CYBER_THEME.PanelBg
    launcher.Text = "⚡"
    launcher.TextColor3 = CYBER_THEME.BorderCyan
    launcher.Font = Enum.Font.FredokaOne
    launcher.TextSize = 25
    launcher.Parent = screen

    local lCor = Instance.new("UICorner")
    lCor.CornerRadius = UDim.new(1, 0)
    lCor.Parent = launcher

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = CYBER_THEME.BorderCyan
    lStroke.Thickness = 2
    lStroke.Parent = launcher

    self.Launcher = launcher

    -- Обработчик перетаскивания лаунчера
    local dragStart, startPos, dragging = nil, nil, false
    launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = launcher.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    launcher.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            launcher.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Главный Контейнер Интерфейса
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 640, 0, 420)
    frame.Position = UDim2.new(0.5, -320, 0.5, -210)
    frame.BackgroundColor3 = CYBER_THEME.MainBg
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screen
    self.Frame = frame

    local fCor = Instance.new("UICorner")
    fCor.CornerRadius = UDim.new(0, 12)
    fCor.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = CYBER_THEME.BorderPink
    fStroke.Thickness = 2
    fStroke.Parent = frame

    -- Сайдбар навигации
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = CYBER_THEME.PanelBg
    sidebar.Parent = frame

    local sCor = Instance.new("UICorner")
    sCor.CornerRadius = UDim.new(0, 12)
    sCor.Parent = sidebar

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = CYBER_THEME.BorderCyan
    sStroke.Thickness = 1
    sStroke.Parent = sidebar

    -- Шапка Сайдбара
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 75)
    header.BackgroundTransparency = 1
    header.Parent = sidebar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 32)
    title.Position = UDim2.new(0, 15, 0, 15)
    title.Text = self.Title
    title.TextColor3 = CYBER_THEME.MainText
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = header

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, -20, 0, 18)
    version.Position = UDim2.new(0, 15, 0, 42)
    version.Text = self.Version
    version.TextColor3 = CYBER_THEME.BorderCyan
    version.Font = Enum.Font.SourceSansBold
    version.TextSize = 13
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.BackgroundTransparency = 1
    version.Parent = header

    -- Скролл контейнер вкладок
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1, 0, 1, -85)
    tabScroll.Position = UDim2.new(0, 0, 0, 80)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 0
    tabScroll.Parent = sidebar

    local tsLayout = Instance.new("UIListLayout")
    tsLayout.Padding = UDim.new(0, 5)
    tsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tsLayout.Parent = tabScroll

    self.TabList = tabScroll

    -- Основной контейнер страниц контента
    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -200, 1, -20)
    pageContainer.Position = UDim2.new(0, 190, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = frame
    self.PageContainer = pageContainer

    -- Переключатель видимости меню по клику на лаунчер
    local menuState = false
    launcher.MouseButton1Click:Connect(function()
        menuState = not menuState
        if menuState then
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = launcher.Position
            frame.Visible = true
            tweenUI(frame, UI_EASE, {
                Size = UDim2.new(0, 640, 0, 420),
                Position = UDim2.new(0.5, -320, 0.5, -210)
            })
            tweenUI(launcher, UI_EASE, {Rotation = 90, TextColor3 = CYBER_THEME.BorderPink})
            lStroke.Color = CYBER_THEME.BorderPink
        else
            tweenUI(frame, UI_EASE, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = launcher.Position
            })
            tweenUI(launcher, UI_EASE, {Rotation = 0, TextColor3 = CYBER_THEME.BorderCyan})
            lStroke.Color = CYBER_THEME.BorderCyan
            task.wait(0.25)
            if not menuState then frame.Visible = false end
        end
    end)
end

function CyberUI:CreateTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = CYBER_THEME.BorderCyan
    page.Visible = false
    page.Parent = self.PageContainer

    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding = UDim.new(0, 8)
    pLayout.Parent = page

    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 15)
    end)

    -- Кнопка вкладки в боковой панели
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.92, 0, 0, 36)
    tabBtn.BackgroundColor3 = CYBER_THEME.MainBg
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabList

    local tbCor = Instance.new("UICorner")
    tbCor.CornerRadius = UDim.new(0, 6)
    tbCor.Parent = tabBtn

    local tbLabel = Instance.new("TextLabel")
    tbLabel.Size = UDim2.new(1, -15, 1, 0)
    tbLabel.Position = UDim2.new(0, 15, 0, 0)
    tbLabel.Text = name
    tbLabel.TextColor3 = CYBER_THEME.DimText
    tbLabel.Font = Enum.Font.SourceSansBold
    tbLabel.TextSize = 15
    tbLabel.TextXAlignment = Enum.TextXAlignment.Left
    tbLabel.BackgroundTransparency = 1
    tbLabel.Parent = tabBtn

    local tabData = {Page = page, Button = tabBtn, Label = tbLabel}

    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    if not self.ActiveTab then
        self:SelectTab(tabData)
    end

    local ElementAPI = {}
    ElementAPI.Page = page

    -- Добавление Секционного Заголовка
    function ElementAPI:AddSection(titleText)
        local secText = Instance.new("TextLabel")
        secText.Size = UDim2.new(0.96, 0, 0, 24)
        secText.Text = "• " .. titleText:upper() .. " •"
        secText.TextColor3 = CYBER_THEME.BorderCyan
        secText.Font = Enum.Font.SourceSansBold
        secText.TextSize = 12
        secText.TextXAlignment = Enum.TextXAlignment.Left
        secText.BackgroundTransparency = 1
        secText.Parent = page
    end

    -- Добавление Неонового Переключателя (Toggle)
    function ElementAPI:AddToggle(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 50)
        card.BackgroundColor3 = CYBER_THEME.PanelBg
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 52)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(0.7, 0, 0, 24)
        titleL.Position = UDim2.new(0, 12, 0, 4)
        titleL.Text = cfg.Name
        titleL.TextColor3 = CYBER_THEME.MainText
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local descL = Instance.new("TextLabel")
        descL.Size = UDim2.new(0.7, 0, 0, 18)
        descL.Position = UDim2.new(0, 12, 0, 24)
        descL.Text = cfg.Description or ""
        descL.TextColor3 = CYBER_THEME.DimText
        descL.Font = Enum.Font.SourceSans
        descL.TextSize = 12
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.BackgroundTransparency = 1
        descL.Parent = card

        local swBtn = Instance.new("TextButton")
        swBtn.Size = UDim2.new(0, 44, 0, 22)
        swBtn.Position = UDim2.new(0.96, -44, 0.5, -11)
        swBtn.BackgroundColor3 = CYBER_THEME.ToggleOff
        swBtn.Text = ""
        swBtn.Parent = card

        local sCor = Instance.new("UICorner")
        sCor.CornerRadius = UDim.new(1, 0)
        sCor.Parent = swBtn

        local node = Instance.new("Frame")
        node.Size = UDim2.new(0, 16, 0, 16)
        node.Position = UDim2.new(0, 3, 0.5, -8)
        node.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        node.Parent = swBtn

        local nCor = Instance.new("UICorner")
        nCor.CornerRadius = UDim.new(1, 0)
        nCor.Parent = node

        local activeState = cfg.Default or false
        local function updateToggle(st)
            activeState = st
            if activeState then
                tweenUI(swBtn, TweenInfo.new(0.2), {BackgroundColor3 = CYBER_THEME.BorderCyan})
                tweenUI(node, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0.5, -8)})
            else
                tweenUI(swBtn, TweenInfo.new(0.2), {BackgroundColor3 = CYBER_THEME.ToggleOff})
                tweenUI(node, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)})
            end
            pcall(cfg.Callback, activeState)
        end

        updateToggle(activeState)
        swBtn.MouseButton1Click:Connect(function()
            updateToggle(not activeState)
        end)
    end

    -- Добавление Ползунка (Slider)
    function ElementAPI:AddSlider(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 58)
        card.BackgroundColor3 = CYBER_THEME.PanelBg
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 52)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(0.7, 0, 0, 22)
        titleL.Position = UDim2.new(0, 12, 0, 6)
        titleL.Text = cfg.Name
        titleL.TextColor3 = CYBER_THEME.MainText
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local valL = Instance.new("TextLabel")
        valL.Size = UDim2.new(0.25, 0, 0, 22)
        valL.Position = UDim2.new(0.7, 0, 0, 6)
        valL.Text = tostring(cfg.Default)
        valL.TextColor3 = CYBER_THEME.BorderPink
        valL.Font = Enum.Font.FredokaOne
        valL.TextSize = 14
        valL.TextXAlignment = Enum.TextXAlignment.Right
        valL.BackgroundTransparency = 1
        valL.Parent = card

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(0.92, 0, 0, 6)
        track.Position = UDim2.new(0.04, 0, 0.72, 0)
        track.BackgroundColor3 = CYBER_THEME.ToggleOff
        track.Text = ""
        track.Parent = card

        local tCor = Instance.new("UICorner")
        tCor.CornerRadius = UDim.new(1, 0)
        tCor.Parent = track

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((cfg.Default - cfg.Min)/(cfg.Max - cfg.Min), 0, 1, 0)
        fill.BackgroundColor3 = CYBER_THEME.BorderPink
        fill.Parent = track

        local fCor = Instance.new("UICorner")
        fCor.CornerRadius = UDim.new(1, 0)
        fCor.Parent = fill

        local isSliding = false
        local function processSlide(input)
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local currentVal = math.floor(cfg.Min + (cfg.Max - cfg.Min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valL.Text = tostring(currentVal)
            pcall(cfg.Callback, currentVal)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                processSlide(input)
            end
        end)
        SafeConnect(UserInputService.InputChanged, function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                processSlide(input)
            end
        end)
        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)
    end

    -- Добавление Поля Ввода (TextBox)
    function ElementAPI:AddTextBox(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 50)
        card.BackgroundColor3 = CYBER_THEME.PanelBg
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 52)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(0.4, 0, 1, 0)
        titleL.Position = UDim2.new(0, 12, 0, 0)
        titleL.Text = cfg.Name
        titleL.TextColor3 = CYBER_THEME.MainText
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local tBox = Instance.new("TextBox")
        tBox.Size = UDim2.new(0.54, 0, 0.68, 0)
        tBox.Position = UDim2.new(0.42, 0, 0.16, 0)
        tBox.BackgroundColor3 = CYBER_THEME.MainBg
        tBox.Text = cfg.Default or ""
        tBox.TextColor3 = CYBER_THEME.MainText
        tBox.PlaceholderText = cfg.Placeholder or "Ввод данных..."
        tBox.PlaceholderColor3 = CYBER_THEME.DimText
        tBox.Font = Enum.Font.SourceSansSemibold
        tBox.TextSize = 14
        tBox.ClipsDescendants = true
        tBox.Parent = card

        local tbCor = Instance.new("UICorner")
        tbCor.CornerRadius = UDim.new(0, 6)
        tbCor.Parent = tBox

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Color = Color3.fromRGB(55, 58, 76)
        tbStroke.Thickness = 1
        tbStroke.Parent = tBox

        tBox.FocusLost:Connect(function()
            pcall(cfg.Callback, tBox.Text)
        end)
    end

    -- Добавление Функциональной Кнопки (Button)
    function ElementAPI:AddButton(cfg)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.96, 0, 0, 40)
        btn.BackgroundColor3 = CYBER_THEME.BorderCyan
        btn.Text = cfg.Name
        btn.TextColor3 = CYBER_THEME.MainBg
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 15
        btn.AutoButtonColor = true
        btn.Parent = page

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 8)
        bCor.Parent = btn

        local bGrad = Instance.new("UIGradient")
        bGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CYBER_THEME.BorderCyan),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        })
        bGrad.Parent = btn

        btn.MouseButton1Click:Connect(function()
            pcall(cfg.Callback)
        end)
    end

    return ElementAPI
end

function CyberUI:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tweenUI(self.ActiveTab.Button, UI_EASE, {BackgroundTransparency = 1})
        tweenUI(self.ActiveTab.Label, UI_EASE, {TextColor3 = CYBER_THEME.DimText})
    end
    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tweenUI(tabData.Button, UI_EASE, {BackgroundTransparency = 0.88})
    tweenUI(tabData.Label, UI_EASE, {TextColor3 = CYBER_THEME.BorderCyan})
end

-- Инициализация Неонового Графического Интерфейса Hub
local CyberHubMenu = CyberUI.new({ Title = "BROSA SYSTEM", Version = "v6.0 • FTAP HYBRID" })

-- ============================================================================
-- [8. КОМПЛЕКТАЦИЯ ДИНАМИЧЕСКИХ ВКЛАДОК И СВЯЗЕЙ С ИНТЕРФЕЙСОМ]
-- ============================================================================

-- Вкладка: ДВИЖЕНИЕ
local movementTab = CyberHubMenu:CreateTab("Движение")
movementTab:AddSection("Контроль Физических Свойств")

movementTab:AddToggle({
    Name = "Активировать WalkSpeed",
    Description = "Блокирует скорость перемещения вашего персонажа",
    Default = Hub.Flags.WalkSpeedEnabled,
    Callback = function(st)
        Hub.Flags.WalkSpeedEnabled = st
        if st then
            pcall(function() lp.Character.Humanoid.WalkSpeed = Hub.Flags.WalkSpeedValue end)
        else
            pcall(function() lp.Character.Humanoid.WalkSpeed = 16 end)
        end
    end
})

movementTab:AddSlider({
    Name = "Кастомная Скорость",
    Min = 16,
    Max = 300,
    Default = Hub.Flags.WalkSpeedValue,
    Callback = function(val)
        Hub.Flags.WalkSpeedValue = val
        if Hub.Flags.WalkSpeedEnabled then
            pcall(function() lp.Character.Humanoid.WalkSpeed = val end)
        end
    end
})

movementTab:AddToggle({
    Name = "Активировать JumpPower",
    Description = "Позволяет изменять высоту прыжка без ограничений",
    Default = Hub.Flags.JumpPowerEnabled,
    Callback = function(st)
        Hub.Flags.JumpPowerEnabled = st
        if st then
            pcall(function() lp.Character.Humanoid.JumpPower = Hub.Flags.JumpPowerValue end)
        else
            pcall(function() lp.Character.Humanoid.JumpPower = 50 end)
        end
    end
})

movementTab:AddSlider({
    Name = "Сила Прыжка",
    Min = 50,
    Max = 400,
    Default = Hub.Flags.JumpPowerValue,
    Callback = function(val)
        Hub.Flags.JumpPowerValue = val
        if Hub.Flags.JumpPowerEnabled then
            pcall(function() lp.Character.Humanoid.JumpPower = val end)
        end
    end
})

movementTab:AddSection("Продвинутая Акробатика")

movementTab:AddToggle({
    Name = "Бесконечный Прыжок",
    Description = "Позволяет отталкиваться от воздуха неограниченно",
    Default = Hub.Flags.InfiniteJump,
    Callback = function(st) Hub.Flags.InfiniteJump = st end
})

movementTab:AddToggle({
    Name = "Режим Полета (Fly)",
    Description = "Движение строго по направлению вашей камеры (Исправлено)",
    Default = Hub.Flags.Fly,
    Callback = function(st) Hub.Flags.Fly = st end
})

movementTab:AddSlider({
    Name = "Скорость Полета",
    Min = 20,
    Max = 300,
    Default = Hub.Flags.FlySpeed,
    Callback = function(val) Hub.Flags.FlySpeed = val end
})

movementTab:AddToggle({
    Name = "Проход Сквозь Стены (Noclip)",
    Description = "Отключает обработку коллизий для всех частей тела",
    Default = Hub.Flags.Noclip,
    Callback = function(st) Hub.Flags.Noclip = st end
})


-- Вкладка: FTAP БОЙ (НОВЫЙ ФУНКЦИОНАЛ)
local ftapCombatTab = CyberHubMenu:CreateTab("FTAP Бой")
ftapCombatTab:AddSection("Автоматизация Захвата и Траектории")

ftapCombatTab:AddToggle({
    Name = "Сайлент Аим (Silent Aim)",
    Description = "Подставляет координаты ближайшего игрока в FOV круге",
    Default = Hub.Flags.SilentAim,
    Callback = function(st) Hub.Flags.SilentAim = st end
})

ftapCombatTab:AddToggle({
    Name = "Отображать Круг FOV",
    Description = "Визуализация кроссплатформенного радиуса наведения",
    Default = Hub.Flags.ShowFOV,
    Callback = function(st) Hub.Flags.ShowFOV = st end
})

ftapCombatTab:AddSlider({
    Name = "Радиус Наведения (FOV)",
    Min = 30,
    Max = 400,
    Default = Hub.Flags.SilentAimFOV,
    Callback = function(val) Hub.Flags.SilentAimFOV = val end
})

ftapCombatTab:AddSection("Механика Манипуляции Телами")

ftapCombatTab:AddToggle({
    Name = "Мега-Далекий Бросок за карту",
    Description = "Прикладывает разрушительный вектор импульса к цели",
    Default = Hub.Flags.MegaThrow,
    Callback = function(st) Hub.Flags.MegaThrow = st end
})

ftapCombatTab:AddSlider({
    Name = "Сила Дальнего Броска",
    Min = 100000,
    Max = 2000000,
    Default = Hub.Flags.ThrowForce,
    Callback = function(val) Hub.Flags.ThrowForce = val end
})

ftapCombatTab:AddToggle({
    Name = "Анти-Взятие Себя (Grab Break)",
    Description = "Моментально уничтожает связи удержания чужих лучей",
    Default = Hub.Flags.InstantGrabBreak,
    Callback = function(st) Hub.Flags.InstantGrabBreak = st end
})

ftapCombatTab:AddSection("Интеллектуальная Контратака")

ftapCombatTab:AddToggle({
    Name = "Авто-Отброс при атаке противника",
    Description = "Уклоняется и жестко наказывает приблизившегося обидчика",
    Default = Hub.Flags.CounterAttack,
    Callback = function(st) Hub.Flags.CounterAttack = st end
})

ftapCombatTab:AddTextBox({
    Name = "Режим Наказания",
    Placeholder = "В небо / В подкарту",
    Default = Hub.Flags.CounterMode,
    Callback = function(txt) Hub.Flags.CounterMode = txt end
})

ftapCombatTab:AddSlider({
    Name = "Угол Запуска (Для режима Небо)",
    Min = 30,
    Max = 90,
    Default = Hub.Flags.CounterAngle,
    Callback = function(val) Hub.Flags.CounterAngle = val end
})


-- Вкладка: ТРОЛЛИНГ И СЕРВЕРНЫЙ ХАОС
local trollTab = CyberHubMenu:CreateTab("Троллинг")
trollTab:AddSection("Прицельный Террор")

trollTab:AddTextBox({
    Name = "Юзернейм Жертвы",
    Placeholder = "Часть имени...",
    Default = Hub.Flags.TargetPlayer,
    Callback = function(text) Hub.Flags.TargetPlayer = text end
})

trollTab:AddButton({
    Name = "Уничтожить цель (Fling Target)",
    Callback = function()
        local t = FindPlayerByName(Hub.Flags.TargetPlayer)
        if t then ExecuteFling(t) else
            StarterGui:SetCore("SendNotification", {Title = "Внимание", Text = "Игрок не обнаружен!", Duration = 2.5})
        end
    end
})

trollTab:AddToggle({
    Name = "Режим Орбиты вокруг цели",
    Description = "Связывает позиционирование, запуская кружение",
    Default = Hub.Flags.OrbitPlayer,
    Callback = function(st) Hub.Flags.OrbitPlayer = st end
})

trollTab:AddSlider({
    Name = "Дистанция Орбиты",
    Min = 3,
    Max = 50,
    Default = Hub.Flags.OrbitDistance,
    Callback = function(val) Hub.Flags.OrbitDistance = val end
})

trollTab:AddSection("Массовые Разрушения")

trollTab:AddToggle({
    Name = "Машина: Kill All (В сиденье)",
    Description = "Использует коллизию транспорта для ликвидации сервера",
    Default = Hub.Flags.VehicleKillAll,
    Callback = function(st) Hub.Flags.VehicleKillAll = st end
})

trollTab:AddToggle({
    Name = "Аура Разрушения (Fling Aura)",
    Description = "Аннигилирует любого в радиусе 16 студов",
    Default = Hub.Flags.FlingAura,
    Callback = function(st) Hub.Flags.FlingAura = st end
})

trollTab:AddToggle({
    Name = "Click Fling (Зажать Ctrl + ЛКМ)",
    Description = "Атакует выбранную цель кликом мыши на карте",
    Default = Hub.Flags.ClickFling,
    Callback = function(st) Hub.Flags.ClickFling = st end
})

trollTab:AddButton({
    Name = "Ликвидировать Всех (Fling All)",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then task.spawn(function() ExecuteFling(p) end) end
        end
    end
})

trollTab:AddButton({
    Name = "Связать Физику Сервера (Mass Weld)",
    Callback = function() RunMassWeld() end
})

trollTab:AddToggle({
    Name = "Заморозка Лобби (Lobby Freeze)",
    Description = "Штормит пакетами позиции для лага физического движка",
    Default = Hub.Flags.LobbyFreeze,
    Callback = function(st) Hub.Flags.LobbyFreeze = st end
})


-- Вкладка: ВИЗУАЛЫ И ОКРУЖЕНИЕ
local visualsTab = CyberHubMenu:CreateTab("Визуалы")
visualsTab:AddSection("Рендеринг ESP Линий")

visualsTab:AddToggle({
    Name = "Отображать ESP Боксы",
    Description = "Очерчивает рамки вокруг силуэтов оппонентов",
    Default = Hub.Flags.ESP_Boxes,
    Callback = function(st) Hub.Flags.ESP_Boxes = st end
})

visualsTab:AddToggle({
    Name = "Отображать Трассеры",
    Description = "Линии векторов от центра экрана к игрокам",
    Default = Hub.Flags.ESP_Tracers,
    Callback = function(st) Hub.Flags.ESP_Tracers = st end
})

visualsTab:AddToggle({
    Name = "Отображать Ники",
    Description = "Показывает Nickname и DisplayName над головами",
    Default = Hub.Flags.ESP_Names,
    Callback = function(st) Hub.Flags.ESP_Names = st end
})

visualsTab:AddToggle({
    Name = "Отображать ХП бары",
    Description = "Шкала запаса здоровья игроков",
    Default = Hub.Flags.ESP_Health,
    Callback = function(st) Hub.Flags.ESP_Health = st end
})

visualsTab:AddSection("Параметры Окружающего Мира")

visualsTab:AddToggle({
    Name = "Постоянный День (Fullbright)",
    Description = "Исключает темноту, максимизируя яркость освещения",
    Default = Hub.Flags.Fullbright,
    Callback = function(st)
        Hub.Flags.Fullbright = st
        if not st then
            Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
            Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
            Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
            Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
        end
    end
})

visualsTab:AddToggle({
    Name = "Режим Оптимизации (Potato PC)",
    Description = "Убирает тяжелые материалы/декали для повышения FPS",
    Default = Hub.Flags.PotatoPC,
    Callback = function(st) ApplyPotatoPC(st) end
})


-- Вкладка: ИГРОВОЙ МАГАЗИН И СИСТЕМА
local shopSystemTab = CyberHubMenu:CreateTab("Мир & Магазин")
shopSystemTab:AddSection("Манипуляция Данными Игры")

shopSystemTab:AddToggle({
    Name = "Разблокировать весь Toy Shop",
    Description = "Подменяет статус предметов в ReplicatedStorage на купленные",
    Default = Hub.Flags.UnlockToyShop,
    Callback = function(st) Hub.Flags.UnlockToyShop = st end
})

shopSystemTab:AddToggle({
    Name = "Принудительное 3-е Лицо",
    Description = "Фиксирует режим камеры и разблокирует зум",
    Default = Hub.Flags.ForceThirdPerson,
    Callback = function(st)
        Hub.Flags.ForceThirdPerson = st
        if not st then
            lp.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end
})

shopSystemTab:AddSlider({
    Name = "Изменить Угол Обзора (FOV)",
    Min = 70,
    Max = 140,
    Default = Hub.Flags.CustomFOV,
    Callback = function(val) Hub.Flags.CustomFOV = val end
})

shopSystemTab:AddSection("Авто-Спамер")

shopSystemTab:AddToggle({
    Name = "Рекламный Спамер в чат",
    Description = "Циклическая отправка сообщения в общий канал",
    Default = Hub.Flags.ChatSpam,
    Callback = function(st) Hub.Flags.ChatSpam = st end
})

shopSystemTab:AddTextBox({
    Name = "Текст сообщения",
    Placeholder = "Пишите строку здесь...",
    Default = Hub.Flags.ChatSpamMessage,
    Callback = function(text) Hub.Flags.ChatSpamMessage = text end
})


-- Вкладка: ПРОФИЛЬ СТАТИСТИКА
local profileTab = CyberHubMenu:CreateTab("Профиль")
profileTab:AddSection("Информация о вашей учетной записи")

local profCard = Instance.new("Frame")
profCard.Size = UDim2.new(0.96, 0, 0, 270)
profCard.BackgroundColor3 = CYBER_THEME.PanelBg
profCard.Parent = profileTab.Page

local prCor = Instance.new("UICorner")
prCor.CornerRadius = UDim.new(0, 10)
prCor.Parent = profCard

local prStroke = Instance.new("UIStroke")
prStroke.Color = CYBER_THEME.BorderCyan
prStroke.Thickness = 1
prStroke.Parent = profCard

local pHeadImg = Instance.new("ImageLabel")
pHeadImg.Size = UDim2.new(0, 90, 0, 90)
pHeadImg.Position = UDim2.new(0.5, -45, 0, 15)
pHeadImg.BackgroundColor3 = CYBER_THEME.MainBg
pHeadImg.Image = "rbxasset://textures/ui/Guideline.png"
pHeadImg.Parent = profCard

local phCor = Instance.new("UICorner")
phCor.CornerRadius = UDim.new(1, 0)
phCor.Parent = pHeadImg

local phStroke = Instance.new("UIStroke")
phStroke.Color = CYBER_THEME.BorderPink
phStroke.Thickness = 2
phStroke.Parent = pHeadImg

local pNameLabel = Instance.new("TextLabel")
pNameLabel.Size = UDim2.new(1, -20, 0, 24)
pNameLabel.Position = UDim2.new(0, 10, 0, 115)
pNameLabel.Text = lp.DisplayName .. " (@" .. lp.Name .. ")"
pNameLabel.TextColor3 = CYBER_THEME.MainText
pNameLabel.Font = Enum.Font.SourceSansBold
pNameLabel.TextSize = 16
pNameLabel.TextAlignment = Enum.TextAlignment.Center
pNameLabel.BackgroundTransparency = 1
pNameLabel.Parent = profCard

local pAgeLabel = Instance.new("TextLabel")
pAgeLabel.Size = UDim2.new(1, -20, 0, 20)
pAgeLabel.Position = UDim2.new(0, 10, 0, 140)
pAgeLabel.Text = "Возраст Аккаунта: " .. tostring(lp.AccountAge) .. " дней"
pAgeLabel.TextColor3 = CYBER_THEME.DimText
pAgeLabel.Font = Enum.Font.SourceSansSemibold
pAgeLabel.TextSize = 14
pAgeLabel.TextAlignment = Enum.TextAlignment.Center
pAgeLabel.BackgroundTransparency = 1
pAgeLabel.Parent = profCard

local pPerfLabel = Instance.new("TextLabel")
pPerfLabel.Size = UDim2.new(1, -20, 0, 22)
pPerfLabel.Position = UDim2.new(0, 10, 0, 165)
pPerfLabel.Text = "Пинг: Расчет... | FPS: Расчет..."
pPerfLabel.TextColor3 = CYBER_THEME.BorderCyan
pPerfLabel.Font = Enum.Font.SourceSansBold
pPerfLabel.TextSize = 13
pPerfLabel.TextAlignment = Enum.TextAlignment.Center
pPerfLabel.BackgroundTransparency = 1
pPerfLabel.Parent = profCard

task.spawn(function()
    local uId = lp.UserId
    local content, ready = Players:GetUserThumbnailAsync(uId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    if ready then pHeadImg.Image = content end
end)

local framesCounter = 0
SafeConnect(RunService.Heartbeat, function(dt) framesCounter = math.floor(1/dt) end)

task.spawn(function()
    while task.wait(1) do
        if Hub.Loaded then
            pcall(function()
                local png = math.floor(Stats.Network.ServerToClientPing:GetValue() * 1000)
                pPerfLabel.Text = "Пинг: " .. tostring(png) .. " ms | FPS: " .. tostring(framesCounter)
            end)
        end
    end
end)


-- Вкладка: НАСТРОЙКИ ЯДРА И ДЕСТРУКЦИЯ
local coreConfigTab = CyberHubMenu:CreateTab("Ядро")
coreConfigTab:AddSection("Системная Модификация")

coreConfigTab:AddToggle({
    Name = "Bypass Metatable Protection",
    Description = "Предотвращает детекты модификации параметров сервером",
    Default = Hub.Flags.BypassMetatable,
    Callback = function(st) Hub.Flags.BypassMetatable = st end
})

coreConfigTab:AddSection("Полная Выгрузка Скрипта")

local function CompleteDestruction()
    Hub.Loaded = false
    
    -- Деактивация всех слушателей событий и циклов
    for _, conn in ipairs(Hub.Cache.Connections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(Hub.Cache.Connections)
    
    -- Восстановление параметров освещения
    Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
    Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
    Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
    
    -- Стирание графики ESP Drawing
    for _, item in pairs(Hub.Cache.EspBoxes) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspTracers) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspNames) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspHealth) do item:Destroy() end
    
    -- Удаление ScreenGui
    if CyberHubMenu.Screen then CyberHubMenu.Screen:Destroy() end
    if FOVGui then FOVGui:Destroy() end
    
    -- Откат текстур Potato PC
    for obj, data in pairs(Hub.Cache.OriginalMaterials) do
        if obj and obj.Parent then
            obj.Material = data[1]
            obj.Reflectance = data[2]
        end
    end
    
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)
    
    _G.BrosaHubGlobal = nil
    print("[Brosa System]: Скрипт успешно деактивирован, память очищена.")
end

coreConfigTab:AddButton({
    Name = "Выгрузить Скрипт (Destroy)",
    Callback = function() CompleteDestruction() end
})

-- ============================================================================
-- [9. ХУКИ МЕТАТАБЛИЦЫ, ПЕРЕХВАТ AIM И ОБХОД ЗАЩИТЫ]
-- ============================================================================
local rawMT = getrawmetatable(game)
local oldIndexMT = rawMT.__index
local oldNewIndexMT = rawMT.__newindex
setreadonly(rawMT, false)

-- Перехват __index для реализации ИСПРАВЛЕННОГО Silent Aim без багов кнопок
rawMT.__index = newcclosure(function(self, index)
    if Hub.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" then return 16 end
            if index == "JumpPower" then return 50 end
        end
    end
    
    -- Стабильный хук мыши: перехватывает Target и Hit только когда Silent Aim активен
    if Hub.Flags.SilentAim and self:IsA("Mouse") then
        if index == "Hit" then
            local targetUnit = GetClosestPlayerToCursor()
            if targetUnit and targetUnit.Character and targetUnit.Character:FindFirstChild("HumanoidRootPart") then
                return targetUnit.Character.HumanoidRootPart.CFrame
            end
        elseif index == "Target" then
            local targetUnit = GetClosestPlayerToCursor()
            if targetUnit and targetUnit.Character and targetUnit.Character:FindFirstChild("HumanoidRootPart") then
                return targetUnit.Character.HumanoidRootPart
            end
        end
    end
    
    return oldIndexMT(self, index)
end)

-- Перехват __newindex для контроля параметров
rawMT.__newindex = newcclosure(function(self, index, val)
    if Hub.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            -- Блокируем попытки внутриигровых скриптов обнулить скорость или прыжок
            if index == "WalkSpeed" and val == 0 then return end
            if index == "JumpPower" and val == 0 then return end
        end
    end
    oldNewIndexMT(self, index, val)
end)

setreadonly(rawMT, true)

-- Авто-накат параметров при респавне персонажа
SafeConnect(lp.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 12)
    if hum then
        task.wait(0.5)
        if Hub.Flags.WalkSpeedEnabled then hum.WalkSpeed = Hub.Flags.WalkSpeedValue end
        if Hub.Flags.JumpPowerEnabled then hum.JumpPower = Hub.Flags.JumpPowerValue end
    end
end)

-- Синхронизация визуальных эффектов Fullbright освещения
SafeConnect(RunService.LightingChanged, function()
    if Hub.Flags.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
    end
end)

print("[Brosa System v6.0]: Монолитный Cyberpunk хаб успешно инициализирован! Все функции исправлены и готовы к работе.")
