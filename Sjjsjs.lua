--[[
    ================================================================================
    👑 BROSA SYSTEM v6.0 — CYBERPUNK MONOLITH EDITION (FTAP EXCLUSIVE)
    🎨 CORE GUI: NEON CYBERPUNK UI (FULLY EXPANDED)
    🔒 STATUS: UNDETECTED | BYPASS: ACTIVE | OPTIMIZED FOR DELTA/HYDROGEN
    ================================================================================
]]

-- Ожидание полной загрузки игры
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================================
-- [1. СИСТЕМНЫЕ СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ]
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
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
if not lp.Character then 
    lp.CharacterAdded:Wait() 
end
local camera = Workspace.CurrentCamera

-- Защита от повторного запуска (Анти-дабл)
if _G.BrosaHubGlobal and _G.BrosaHubGlobal.Loaded then
    warn("[Brosa System v6.0]: Скрипт уже запущен! Повторная инициализация отклонена.")
    return
end

-- Глобальная структура данных (Расширенная под FTAP)
_G.BrosaHubGlobal = {
    Loaded = true,
    Flags = {
        -- Движение
        WalkSpeedEnabled = false,
        WalkSpeedValue = 16,
        JumpPowerEnabled = false,
        JumpPowerValue = 50,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        
        -- Вредительство & Троллинг
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
        
        -- Визуалы & ESP
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,
        
        -- Защита & Обходы
        BypassMetatable = true,
        AntiGrab = false,
        AntiFling = false,
        AntiReport = false,
        ChatSpam = false,
        ChatSpamMessage = "Brosa System v6.0 Cyberpunk Edition!",
        AutoFarm = false,

        -- FTAP Эксклюзивные Функции
        FtapSilentAim = false,
        FtapFOVRadius = 150,
        FtapShowFOV = false,
        FtapThrowMap = false,
        FtapInstantBreak = false,
        FtapCounterAttack = false,
        FtapCounterMode = "Sky", -- "Sky" или "Void"
        FtapVehicleKill = false,
        FtapForce3rdPerson = false,
        FtapCustomFOV = false,
        FtapCustomFOVValue = 70
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
        OriginalMaterials = {}
    }
}

local Hub = _G.BrosaHubGlobal

-- Безопасное подключение событий
local function SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Hub.Cache.Connections, connection)
    return connection
end

-- ============================================================================
-- [2. СЛОЖНЫЙ МАТЕМАТИЧЕСКИЙ И ФИЗИЧЕСКИЙ ДВИЖОК ЭКСПЛУАТОВ]
-- ============================================================================

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

-- Логика Noclip и Anti-Grab
SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    
    -- Noclip (Проход сквозь стены)
    if Hub.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Anti-Grab (Стандартная защита, физическое игнорирование)
    if Hub.Flags.AntiGrab then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    end
end)

-- Логика Anti-Fling (Фиксация угловой скорости для стабильности)
SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if Hub.Flags.AntiFling and char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.RotVelocity = Vector3.new(0, 0, 0)
            root.Velocity = Vector3.new(root.Velocity.X, math.clamp(root.Velocity.Y, -80, 80), root.Velocity.Z)
        end
    end
end)

-- Логика Полета (Fly Engine v2)
SafeConnect(RunService.RenderStepped, function()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Hub.Flags.Fly and root and hum then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        local camCFrame = camera.CFrame
        local flyVel = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            flyVel = moveDir * Hub.Flags.FlySpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyVel = flyVel + Vector3.new(0, Hub.Flags.FlySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyVel = flyVel - Vector3.new(0, Hub.Flags.FlySpeed, 0)
        end
        root.Velocity = flyVel
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

-- Усовершенствованный Fling Движок
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
            if not tchar or not troot or not troot.Parent or not flingActive then
                return
            end
            root.Velocity = Vector3.new(0, 150000, 0)
            root.RotVelocity = Vector3.new(150000, 150000, 150000)
            root.CFrame = troot.CFrame * CFrame.new(math.random(-2, 2)/10, 0, math.random(-2, 2)/10)
        end)
        
        task.delay(2.5, function()
            flingActive = false
            tempNoclip:Disconnect()
            flingLoop:Disconnect()
            task.wait(0.1)
            if root then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                root.CFrame = oldCFrame
            end
        end)
    end
end

-- Fling Aura
SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.FlingAura then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = player.Character.HumanoidRootPart
                    local dist = (root.Position - targetRoot.Position).Magnitude
                    if dist <= 15 then
                        ExecuteFling(player)
                    end
                end
            end
        end
    end
end)

-- Click Fling (+Ctrl)
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and Hub.Flags.ClickFling and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {lp.Character}
            
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
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

-- Orbit Движок
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
            root.Velocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(troot.Position + offset, troot.Position)
        end
    end
end)

-- Mass Weld
local function RunMassWeld()
    local char = lp.Character
    if not char then return end
    for _, part in ipairs(Workspace:GetDescendants()) do
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

-- Lobby Freeze
SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.LobbyFreeze then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for i = 1, 50 do
                root.CFrame = root.CFrame * CFrame.new(0, 1000000, 0)
                root.CFrame = root.CFrame * CFrame.new(0, -1000000, 0)
            end
        end
    end
end)

-- Chat Spammer
task.spawn(function()
    while task.wait(3) do
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
-- [3. ЭКСКЛЮЗИВНЫЕ ФУНКЦИИ ДЛЯ FLING THINGS AND PEOPLE (FTAP)]
-- ============================================================================

-- 1. Умный Silent Aim FOV (Перехват захвата)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Hub.Flags.FtapFOVRadius
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

SafeConnect(RunService.RenderStepped, function()
    if Hub.Flags.FtapShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Hub.Flags.FtapFOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    -- Динамический кастомный FOV камеры
    if Hub.Flags.FtapCustomFOV then
        camera.FieldOfView = Hub.Flags.FtapCustomFOVValue
    end
    
    -- Принудительное 3-е Лицо
    if Hub.Flags.FtapForce3rdPerson then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 50
        lp.CameraMinZoomDistance = 10
    else
        if lp.CameraMode == Enum.CameraMode.Classic and not Hub.Flags.FtapForce3rdPerson and Hub.Loaded then
            -- Сброс только если мы отключаем (для FTAP стандартом часто бывает First Person)
            lp.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end
end)

-- Функция поиска ближайшего врага в FOV
local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = Hub.Flags.FtapFOVRadius
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Хук Метаметода для Silent Aim (Подмена Mouse.Target / Mouse.Hit)
local rawMeta = getrawmetatable(game)
local oldNamecall = rawMeta.__namecall
local oldIndexMeta = rawMeta.__index
setreadonly(rawMeta, false)

rawMeta.__index = newcclosure(function(self, index)
    if Hub.Flags.FtapSilentAim and not checkcaller() then
        if self:IsA("Mouse") then
            if index == "Target" or index == "Hit" then
                local closest = GetClosestPlayerInFOV()
                if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                    if index == "Target" then
                        return closest.Character.HumanoidRootPart
                    elseif index == "Hit" then
                        return closest.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end
    return oldIndexMeta(self, index)
end)

-- Хук Namecall для перехвата Raycast (Некоторые скрипты FTAP используют Raycast)
rawMeta.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Hub.Flags.FtapSilentAim and not checkcaller() and method == "Raycast" then
        local closest = GetClosestPlayerInFOV()
        if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
            -- Модифицируем направление луча прямо в HRP цели
            local origin = args[1]
            local targetPos = closest.Character.HumanoidRootPart.Position
            local direction = (targetPos - origin).Unit * 1000
            args[2] = direction
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(rawMeta, true)

-- 2. Мега-Далекий Бросок за карту (Out of Map Fling)
-- Отслеживаем отпускание левой кнопки или нажатие правой кнопки (Бросок)
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and Hub.Flags.FtapThrowMap then
        -- ПК: ПКМ (бросок). Если мобилка - надо адаптировать под кнопку
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            local char = lp.Character
            if not char then return end
            
            -- Ищем объект, который мы держим (FTAP создает SpringConstraint или AlignPosition)
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Constraint") and obj.Attachment1 then
                    local targetPart = obj.Attachment1.Parent
                    if targetPart and targetPart:IsA("BasePart") then
                        -- Применяем колоссальный импульс перед тем как игра удалит констрейнт
                        local lookVec = camera.CFrame.LookVector
                        targetPart.AssemblyLinearVelocity = lookVec * 50000
                        
                        -- Если это игрок, ломаем его физику
                        local model = targetPart:FindFirstAncestorOfClass("Model")
                        if model and Players:GetPlayerFromCharacter(model) then
                            local tHRP = model:FindFirstChild("HumanoidRootPart")
                            if tHRP then
                                tHRP.AssemblyLinearVelocity = lookVec * 100000
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 3. Анти-Взятие Себя (Instant Grab Break)
SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.FtapInstantBreak then
        local char = lp.Character
        if not char then return end
        
        -- FTAP вешает на нашего персонажа чужие констрейнты
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Constraint") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then
                -- Если констрейнт соединяет нас с чужим персонажем - ломаем
                local p0, p1 = nil, nil
                if obj:IsA("Constraint") then
                    if obj.Attachment0 then p0 = obj.Attachment0.Parent end
                    if obj.Attachment1 then p1 = obj.Attachment1.Parent end
                else
                    p0 = obj.Part0
                    p1 = obj.Part1
                end
                
                if p0 and p1 then
                    local isUs0 = p0:IsDescendantOf(char)
                    local isUs1 = p1:IsDescendantOf(char)
                    -- Если одна часть наша, а другая нет -> кто-то нас схватил!
                    if (isUs0 and not isUs1) or (isUs1 and not isUs0) then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)

-- 4. Авто-Отброс в Небо и Телепорт под Карту (Контратака)
local counterAttackCooldown = false
SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.FtapCounterAttack and not counterAttackCooldown then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root then return end
        
        -- Ищем тех, кто смотрит на нас и слишком близко (угроза захвата)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = p.Character.HumanoidRootPart
                local dist = (eRoot.Position - root.Position).Magnitude
                
                -- Простая эвристика: враг в радиусе 10 студов, у него в руке инструмент или он направил луч
                -- В FTAP луч часто создается как Part. Проверяем наличие чужих сварных швов на нас.
                local grabbedUs = false
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("Constraint") and (not obj:IsDescendantOf(lp.Character)) then
                        grabbedUs = true
                        obj:Destroy() -- Мгновенно ломаем
                    end
                end
                
                if grabbedUs then
                    counterAttackCooldown = true
                    local originalPos = root.CFrame
                    
                    -- Уклонение
                    root.CFrame = root.CFrame * CFrame.new(0, 0, 15) 
                    task.wait(0.1)
                    
                    if Hub.Flags.FtapCounterMode == "Sky" then
                        -- Телепортируем врага в небо (симуляция захвата и броска)
                        eRoot.CFrame = eRoot.CFrame + Vector3.new(0, 500, 0)
                        eRoot.AssemblyLinearVelocity = Vector3.new(0, 10000, 0)
                    elseif Hub.Flags.FtapCounterMode == "Void" then
                        -- Отправляем в Void (Глубоко под карту)
                        eRoot.CFrame = CFrame.new(0, -5000, 0)
                        eRoot.AssemblyLinearVelocity = Vector3.new(0, -5000, 0)
                    end
                    
                    task.wait(0.2)
                    -- Возвращаемся
                    root.CFrame = originalPos
                    
                    task.delay(1, function() counterAttackCooldown = false end)
                end
            end
        end
    end
end)

-- 5. Машины: Функция "Убить Всех" (Vehicle Kill All)
local function ActivateVehicleKillAll()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then
        StarterGui:SetCore("SendNotification", {
            Title = "Vehicle Kill",
            Text = "Сядьте в машину (VehicleSeat) для активации!",
            Duration = 3
        })
        return
    end
    
    local vehicle = hum.SeatPart:FindFirstAncestorOfClass("Model")
    if not vehicle then return end
    
    local originalPos = vehicle:GetPivot()
    Hub.Flags.FtapVehicleKill = true
    
    StarterGui:SetCore("SendNotification", {
        Title = "Vehicle Kill",
        Text = "Уничтожение начато! Держитесь.",
        Duration = 3
    })
    
    task.spawn(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if not Hub.Flags.FtapVehicleKill then break end
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tHRP = p.Character.HumanoidRootPart
                for i = 1, 10 do -- Крутим машину в игроке
                    if not Hub.Flags.FtapVehicleKill then break end
                    vehicle:PivotTo(tHRP.CFrame * CFrame.Angles(math.random(), math.random(), math.random()))
                    if vehicle.PrimaryPart then
                        vehicle.PrimaryPart.AssemblyLinearVelocity = Vector3.new(math.random(-500, 500), 500, math.random(-500, 500))
                    end
                    task.wait(0.05)
                end
            end
        end
        Hub.Flags.FtapVehicleKill = false
        vehicle:PivotTo(originalPos)
    end)
end

-- 6. Скрытые и заблокированные предметы (Unlock All Toy Shop Items)
local function UnlockAllToys()
    local count = 0
    -- В FTAP данные часто лежат в ReplicatedStorage -> Items/Shop
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("BoolValue") and (obj.Name:lower():match("locked") or obj.Name:lower():match("owned")) then
            if obj.Name:lower():match("locked") then
                obj.Value = false
                count = count + 1
            elseif obj.Name:lower():match("owned") then
                obj.Value = true
                count = count + 1
            end
        elseif obj:IsA("NumberValue") or obj:IsA("IntValue") then
            if obj.Name:lower():match("price") or obj.Name:lower():match("cost") then
                obj.Value = 0
                count = count + 1
            end
        end
    end
    
    StarterGui:SetCore("SendNotification", {
        Title = "Toy Shop Unlock",
        Text = "Разблокировано/изменено " .. tostring(count) .. " значений цен и блокировок!",
        Duration = 5
    })
end

-- ============================================================================
-- [4. ПОЛНАЯ РЕАЛИЗАЦИЯ И РЕНДЕРИНГ ESP И ВИЗУАЛОВ]
-- ============================================================================

local function DrawESP(player)
    if player == lp then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 255)
    box.Thickness = 1.5
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 0, 85)
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

-- Potato PC
local function ApplyPotatoPC(state)
    Hub.Flags.PotatoPC = state
    if state then
        for _, obj in ipairs(Workspace:GetDescendants()) do
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
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
            end
        end
        table.clear(Hub.Cache.OriginalMaterials)
    end
end

-- ============================================================================
-- [5. НОВЫЙ CYBERPUNK ИНТЕРФЕЙС (AURORA CYBERPUNK EDITION)]
-- ============================================================================
local AuroraCyber = {}
AuroraCyber.__index = AuroraCyber

local THEME = {
    Bg          = Color3.fromRGB(10, 10, 15),     -- Глубокий темный
    BgStrong    = Color3.fromRGB(18, 18, 25),     -- Панели
    Stroke      = Color3.fromRGB(0, 255, 255),    -- Неоновый циан
    Text        = Color3.fromRGB(255, 255, 255),  -- Белый
    TextDim     = Color3.fromRGB(120, 120, 140),  -- Серый
    Accent      = Color3.fromRGB(255, 0, 85),     -- Неоновый маджента (Cyberpunk)
    AccentGlow  = Color3.fromRGB(0, 255, 255),    -- Вторичный акцент
    Green       = Color3.fromRGB(0, 255, 130),
    Red         = Color3.fromRGB(255, 50, 50)
}

local EASE = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function AuroraCyber.new(config)
    local self = setmetatable({}, AuroraCyber)
    self.Title = config.Title or "CYBER-HUB"
    self.SubTitle = config.SubTitle or "FTAP EDITION"
    self.ActiveTab = nil
    self.Tabs = {}
    self:BuildUI()
    return self
end

function AuroraCyber:BuildUI()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AuroraCyber_" .. HttpService:GenerateGUID(false):sub(1,6)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screen.Parent = CoreGui end)
    if not screen.Parent then screen.Parent = lp:WaitForChild("PlayerGui") end
    self.Screen = screen

    -- Драг-лаунчер (Иконка вызова)
    local launcher = Instance.new("TextButton")
    launcher.Size = UDim2.new(0, 55, 0, 55)
    launcher.Position = UDim2.new(0.02, 0, 0.15, 0)
    launcher.BackgroundColor3 = THEME.BgStrong
    launcher.Text = "⚡"
    launcher.TextColor3 = THEME.Stroke
    launcher.Font = Enum.Font.FredokaOne
    launcher.TextSize = 28
    launcher.Parent = screen

    local lCor = Instance.new("UICorner")
    lCor.CornerRadius = UDim.new(1, 0)
    lCor.Parent = launcher

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = THEME.Accent
    lStroke.Thickness = 2
    lStroke.Parent = launcher

    self.Launcher = launcher

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

    -- Главное окно
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 680, 0, 450)
    frame.Position = UDim2.new(0.5, -340, 0.5, -225)
    frame.BackgroundColor3 = THEME.Bg
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screen
    self.Frame = frame

    local fCor = Instance.new("UICorner")
    fCor.CornerRadius = UDim.new(0, 12)
    fCor.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = THEME.Accent
    fStroke.Thickness = 2
    fStroke.Parent = frame

    -- Сайдбар меню
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 190, 1, 0)
    sidebar.BackgroundColor3 = THEME.BgStrong
    sidebar.BorderSizePixel = 0
    sidebar.Parent = frame

    local sLine = Instance.new("Frame")
    sLine.Size = UDim2.new(0, 2, 1, 0)
    sLine.Position = UDim2.new(1, 0, 0, 0)
    sLine.BackgroundColor3 = THEME.Stroke
    sLine.BorderSizePixel = 0
    sLine.Parent = sidebar

    -- Шапка
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 80)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = sidebar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 20)
    title.Text = self.Title
    title.TextColor3 = THEME.Stroke
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = headerFrame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 16)
    sub.Position = UDim2.new(0, 15, 0, 48)
    sub.Text = self.SubTitle
    sub.TextColor3 = THEME.Accent
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 12
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.BackgroundTransparency = 1
    sub.Parent = headerFrame

    -- Контейнер вкладок
    local tabList = Instance.new("ScrollingFrame")
    tabList.Size = UDim2.new(1, 0, 1, -90)
    tabList.Position = UDim2.new(0, 0, 0, 85)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.Parent = sidebar

    local tlLayout = Instance.new("UIListLayout")
    tlLayout.Padding = UDim.new(0, 8)
    tlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tlLayout.Parent = tabList

    self.TabList = tabList

    -- Контейнер страниц
    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -210, 1, -20)
    pageContainer.Position = UDim2.new(0, 200, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = frame
    self.PageContainer = pageContainer

    -- Открытие/Закрытие меню
    local menuOpen = false
    launcher.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = launcher.Position
            frame.Visible = true
            tween(frame, EASE, {
                Size = UDim2.new(0, 680, 0, 450),
                Position = UDim2.new(0.5, -340, 0.5, -225)
            })
            tween(launcher, EASE, {Rotation = 180, TextColor3 = THEME.Accent})
        else
            tween(frame, EASE, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = launcher.Position
            })
            tween(launcher, EASE, {Rotation = 0, TextColor3 = THEME.Stroke})
            task.wait(0.4)
            if not menuOpen then frame.Visible = false end
        end
    end)
end

function AuroraCyber:CreateTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.Accent
    page.Visible = false
    page.Parent = self.PageContainer

    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding = UDim.new(0, 12)
    pLayout.Parent = page

    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 20)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.BackgroundColor3 = THEME.Bg
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = self.TabList

    local bCor = Instance.new("UICorner")
    bCor.CornerRadius = UDim.new(0, 6)
    bCor.Parent = btn
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = THEME.Accent
    bStroke.Thickness = 1
    bStroke.Transparency = 1
    bStroke.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = THEME.TextDim
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = btn

    local tabData = {Page = page, Button = btn, Label = lbl, Stroke = bStroke}

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    if not self.ActiveTab then self:SelectTab(tabData) end

    local TabAPI = {Page = page}

    function TabAPI:AddSection(title)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(0.95, 0, 0, 30)
        sec.Text = "» " .. title:upper()
        sec.TextColor3 = THEME.Stroke
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 13
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.BackgroundTransparency = 1
        sec.Parent = page
    end

    function TabAPI:AddToggle(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 56)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(40, 40, 55)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.7, 0, 0, 26)
        cl.Position = UDim2.new(0, 15, 0, 6)
        cl.Text = config.Name
        cl.TextColor3 = THEME.Text
        cl.Font = Enum.Font.GothamBold
        cl.TextSize = 15
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.BackgroundTransparency = 1
        cl.Parent = card

        local cd = Instance.new("TextLabel")
        cd.Size = UDim2.new(0.7, 0, 0, 18)
        cd.Position = UDim2.new(0, 15, 0, 28)
        cd.Text = config.Description or ""
        cd.TextColor3 = THEME.TextDim
        cd.Font = Enum.Font.Gotham
        cd.TextSize = 11
        cd.TextXAlignment = Enum.TextXAlignment.Left
        cd.BackgroundTransparency = 1
        cd.Parent = card

        local switch = Instance.new("TextButton")
        switch.Size = UDim2.new(0, 50, 0, 26)
        switch.Position = UDim2.new(0.95, -50, 0.5, -13)
        switch.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        switch.Text = ""
        switch.Parent = card

        local sCor = Instance.new("UICorner")
        sCor.CornerRadius = UDim.new(1, 0)
        sCor.Parent = switch

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 20, 0, 20)
        dot.Position = UDim2.new(0, 3, 0.5, -10)
        dot.BackgroundColor3 = THEME.Text
        dot.Parent = switch

        local dCor = Instance.new("UICorner")
        dCor.CornerRadius = UDim.new(1, 0)
        dCor.Parent = dot

        local state = config.Default or false
        local function toggle(targetState)
            state = targetState
            if state then
                tween(switch, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent})
                tween(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10)})
                tween(cStroke, TweenInfo.new(0.2), {Color = THEME.Accent})
            else
                tween(switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)})
                tween(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10)})
                tween(cStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 55)})
            end
            pcall(config.Callback, state)
        end

        toggle(state)
        switch.MouseButton1Click:Connect(function() toggle(not state) end)
    end

    function TabAPI:AddSlider(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 65)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card
        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(40, 40, 55)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.7, 0, 0, 24)
        cl.Position = UDim2.new(0, 15, 0, 8)
        cl.Text = config.Name
        cl.TextColor3 = THEME.Text
        cl.Font = Enum.Font.GothamBold
        cl.TextSize = 14
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.BackgroundTransparency = 1
        cl.Parent = card

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.25, 0, 0, 24)
        valLbl.Position = UDim2.new(0.7, 0, 0, 8)
        valLbl.Text = tostring(config.Default)
        valLbl.TextColor3 = THEME.Stroke
        valLbl.Font = Enum.Font.GothamBlack
        valLbl.TextSize = 14
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.BackgroundTransparency = 1
        valLbl.Parent = card

        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(0.92, 0, 0, 8)
        bar.Position = UDim2.new(0.04, 0, 0.7, 0)
        bar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        bar.Text = ""
        bar.Parent = card

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(1, 0)
        bCor.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((config.Default - config.Min)/(config.Max - config.Min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.Stroke
        fill.Parent = bar

        local fCor = Instance.new("UICorner")
        fCor.CornerRadius = UDim.new(1, 0)
        fCor.Parent = fill

        local sliding = false
        local function updateVal(input)
            local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(config.Min + (config.Max - config.Min) * ratio)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valLbl.Text = tostring(val)
            pcall(config.Callback, val)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                updateVal(input)
            end
        end)
        SafeConnect(UserInputService.InputChanged, function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateVal(input)
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
    end

    function TabAPI:AddTextBox(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 56)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card
        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(40, 40, 55)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.4, 0, 1, 0)
        cl.Position = UDim2.new(0, 15, 0, 0)
        cl.Text = config.Name
        cl.TextColor3 = THEME.Text
        cl.Font = Enum.Font.GothamBold
        cl.TextSize = 14
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.BackgroundTransparency = 1
        cl.Parent = card

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.5, 0, 0.7, 0)
        box.Position = UDim2.new(0.46, 0, 0.15, 0)
        box.BackgroundColor3 = THEME.Bg
        box.Text = config.Default or ""
        box.TextColor3 = THEME.Stroke
        box.PlaceholderText = config.Placeholder or "..."
        box.PlaceholderColor3 = THEME.TextDim
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClipsDescendants = true
        box.Parent = card

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 6)
        bCor.Parent = box
        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromRGB(50, 50, 70)
        bStroke.Thickness = 1
        bStroke.Parent = box

        box.FocusLost:Connect(function() pcall(config.Callback, box.Text) end)
    end

    function TabAPI:AddButton(config)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 45)
        btn.BackgroundColor3 = THEME.BgStrong
        btn.Text = config.Name
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 15
        btn.Parent = page

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 8)
        bCor.Parent = btn
        
        local bStroke = Instance.new("UIStroke")
        bStroke.Color = THEME.Accent
        bStroke.Thickness = 1
        bStroke.Parent = btn

        btn.MouseButton1Click:Connect(function()
            tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.Accent})
            task.wait(0.1)
            tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.BgStrong})
            pcall(config.Callback)
        end)
    end

    return TabAPI
end

function AuroraCyber:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tween(self.ActiveTab.Button, EASE, {BackgroundTransparency = 1})
        tween(self.ActiveTab.Label, EASE, {TextColor3 = THEME.TextDim})
        tween(self.ActiveTab.Stroke, EASE, {Transparency = 1})
    end
    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tween(tabData.Button, EASE, {BackgroundTransparency = 0.5})
    tween(tabData.Label, EASE, {TextColor3 = THEME.Stroke})
    tween(tabData.Stroke, EASE, {Transparency = 0})
end

local menu = AuroraCyber.new({ Title = "BROSA HUB", SubTitle = "FTAP CYBERPUNK V6" })


-- ============================================================================
-- [6. НАПОЛНЕНИЕ ВКЛАДОК ФУНКЦИОНАЛОМ (БЕЗ УРЕЗАНИЯ)]
-- ============================================================================

-- Вкладка: FTAP (ЭКСКЛЮЗИВ)
local tabFTAP = menu:CreateTab("FTAP Exploits")
tabFTAP:AddSection("Оружие и Захват")

tabFTAP:AddToggle({
    Name = "Smart Silent Aim",
    Description = "Аимбот для Grab Line (мгновенный перехват луча)",
    Default = Hub.Flags.FtapSilentAim,
    Callback = function(state) Hub.Flags.FtapSilentAim = state end
})

tabFTAP:AddToggle({
    Name = "Показывать FOV",
    Description = "Визуальный круг работы Silent Aim",
    Default = Hub.Flags.FtapShowFOV,
    Callback = function(state) Hub.Flags.FtapShowFOV = state end
})

tabFTAP:AddSlider({
    Name = "Радиус FOV",
    Min = 50,
    Max = 600,
    Default = Hub.Flags.FtapFOVRadius,
    Callback = function(val) Hub.Flags.FtapFOVRadius = val end
})

tabFTAP:AddToggle({
    Name = "Out of Map Fling (Бросок)",
    Description = "Бросок ПКМ отправляет игрока за пределы карты",
    Default = Hub.Flags.FtapThrowMap,
    Callback = function(state) Hub.Flags.FtapThrowMap = state end
})

tabFTAP:AddSection("Защита и Контратаки")

tabFTAP:AddToggle({
    Name = "Анти-Взятие (Instant Break)",
    Description = "Моментально ломает луч врага, делая вас неуязвимым",
    Default = Hub.Flags.FtapInstantBreak,
    Callback = function(state) Hub.Flags.FtapInstantBreak = state end
})

tabFTAP:AddToggle({
    Name = "Авто-Контратака",
    Description = "Уклонение и бросок агрессора (защитный механизм)",
    Default = Hub.Flags.FtapCounterAttack,
    Callback = function(state) Hub.Flags.FtapCounterAttack = state end
})

-- Для переключения режимов контратаки используем TextBox, чтобы сэкономить UI элементы, 
-- либо просто Toggle для двух режимов. Сделаем через кнопку-переключатель.
tabFTAP:AddButton({
    Name = "Сменить режим Контратаки (Sky / Void)",
    Callback = function()
        if Hub.Flags.FtapCounterMode == "Sky" then
            Hub.Flags.FtapCounterMode = "Void"
        else
            Hub.Flags.FtapCounterMode = "Sky"
        end
        StarterGui:SetCore("SendNotification", {Title="Режим изменен", Text="Текущий: "..Hub.Flags.FtapCounterMode, Duration=2})
    end
})

tabFTAP:AddSection("Глобальные события")

tabFTAP:AddButton({
    Name = "Vehicle Kill All (Сесть в авто!)",
    Callback = function() ActivateVehicleKillAll() end
})

tabFTAP:AddButton({
    Name = "Unlock All Toy Shop Items",
    Callback = function() UnlockAllToys() end
})

tabFTAP:AddSection("Управление Камерой")

tabFTAP:AddToggle({
    Name = "Форсировать 3-е Лицо",
    Description = "Отвязывает камеру от 1 лица",
    Default = Hub.Flags.FtapForce3rdPerson,
    Callback = function(state) Hub.Flags.FtapForce3rdPerson = state end
})

tabFTAP:AddToggle({
    Name = "Кастомный Растяг Экрана (FOV)",
    Description = "Позволяет изменять угол обзора",
    Default = Hub.Flags.FtapCustomFOV,
    Callback = function(state) Hub.Flags.FtapCustomFOV = state end
})

tabFTAP:AddSlider({
    Name = "Угол Обзора (FOV Value)",
    Min = 70,
    Max = 130,
    Default = Hub.Flags.FtapCustomFOVValue,
    Callback = function(val) Hub.Flags.FtapCustomFOVValue = val end
})


-- Вкладка: ДВИЖЕНИЕ
local tabMovement = menu:CreateTab("Движение")
tabMovement:AddSection("Физические Характеристики")

tabMovement:AddToggle({
    Name = "Кастомный WalkSpeed",
    Description = "Блокирует скорость бега",
    Default = Hub.Flags.WalkSpeedEnabled,
    Callback = function(state)
        Hub.Flags.WalkSpeedEnabled = state
        if state then pcall(function() lp.Character.Humanoid.WalkSpeed = Hub.Flags.WalkSpeedValue end)
        else pcall(function() lp.Character.Humanoid.WalkSpeed = 16 end) end
    end
})

tabMovement:AddSlider({
    Name = "Скорость бега",
    Min = 16,
    Max = 350,
    Default = Hub.Flags.WalkSpeedValue,
    Callback = function(val)
        Hub.Flags.WalkSpeedValue = val
        if Hub.Flags.WalkSpeedEnabled then pcall(function() lp.Character.Humanoid.WalkSpeed = val end) end
    end
})

tabMovement:AddToggle({
    Name = "Кастомный JumpPower",
    Description = "Высота прыжков",
    Default = Hub.Flags.JumpPowerEnabled,
    Callback = function(state)
        Hub.Flags.JumpPowerEnabled = state
        if state then pcall(function() lp.Character.Humanoid.JumpPower = Hub.Flags.JumpPowerValue end)
        else pcall(function() lp.Character.Humanoid.JumpPower = 50 end) end
    end
})

tabMovement:AddSlider({
    Name = "Сила прыжка",
    Min = 50,
    Max = 500,
    Default = Hub.Flags.JumpPowerValue,
    Callback = function(val)
        Hub.Flags.JumpPowerValue = val
        if Hub.Flags.JumpPowerEnabled then pcall(function() lp.Character.Humanoid.JumpPower = val end) end
    end
})

tabMovement:AddSection("Супер-Способности")

tabMovement:AddToggle({Name = "Бесконечный Прыжок", Default = Hub.Flags.InfiniteJump, Callback = function(s) Hub.Flags.InfiniteJump = s end})
tabMovement:AddToggle({Name = "Режим полета (Fly)", Default = Hub.Flags.Fly, Callback = function(s) Hub.Flags.Fly = s end})
tabMovement:AddSlider({Name = "Скорость полета", Min = 10, Max = 350, Default = Hub.Flags.FlySpeed, Callback = function(v) Hub.Flags.FlySpeed = v end})
tabMovement:AddToggle({Name = "Noclip (Сквозь стены)", Default = Hub.Flags.Noclip, Callback = function(s) Hub.Flags.Noclip = s end})


-- Вкладка: ТРОЛЛИНГ
local tabTroll = menu:CreateTab("Троллинг")
tabTroll:AddSection("Контроль Жертвы")

tabTroll:AddTextBox({
    Name = "Имя Жертвы", Placeholder = "Никнейм...", Default = Hub.Flags.TargetPlayer,
    Callback = function(text) Hub.Flags.TargetPlayer = text end
})

tabTroll:AddButton({
    Name = "Fling Target (Разорвать)",
    Callback = function()
        local target = FindPlayerByName(Hub.Flags.TargetPlayer)
        if target then ExecuteFling(target) else
            StarterGui:SetCore("SendNotification", {Title="Ошибка", Text="Игрок не найден!", Duration=3})
        end
    end
})

tabTroll:AddToggle({Name = "Orbit Target", Default = Hub.Flags.OrbitPlayer, Callback = function(s) Hub.Flags.OrbitPlayer = s end})
tabTroll:AddSlider({Name = "Дистанция орбиты", Min = 2, Max = 60, Default = Hub.Flags.OrbitDistance, Callback = function(v) Hub.Flags.OrbitDistance = v end})
tabTroll:AddSlider({Name = "Скорость орбиты", Min = 1, Max = 40, Default = Hub.Flags.OrbitSpeed, Callback = function(v) Hub.Flags.OrbitSpeed = v end})

tabTroll:AddSection("Глобальный Хаос")
tabTroll:AddToggle({Name = "Fling Aura (Аура смерти)", Default = Hub.Flags.FlingAura, Callback = function(s) Hub.Flags.FlingAura = s end})
tabTroll:AddToggle({Name = "Click Fling (+Ctrl)", Default = Hub.Flags.ClickFling, Callback = function(s) Hub.Flags.ClickFling = s end})
tabTroll:AddButton({Name = "Fling All", Callback = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then task.spawn(function() ExecuteFling(p) end) end end end})
tabTroll:AddButton({Name = "Mass Weld", Callback = function() RunMassWeld() end})
tabTroll:AddToggle({Name = "Lobby Freeze", Default = Hub.Flags.LobbyFreeze, Callback = function(s) Hub.Flags.LobbyFreeze = s end})


-- Вкладка: ВИЗУАЛЫ
local tabVisuals = menu:CreateTab("Визуалы")
tabVisuals:AddSection("Отображение ESP")
tabVisuals:AddToggle({Name = "ESP Боксы", Default = Hub.Flags.ESP_Boxes, Callback = function(s) Hub.Flags.ESP_Boxes = s end})
tabVisuals:AddToggle({Name = "ESP Трассеры", Default = Hub.Flags.ESP_Tracers, Callback = function(s) Hub.Flags.ESP_Tracers = s end})
tabVisuals:AddToggle({Name = "ESP Имена", Default = Hub.Flags.ESP_Names, Callback = function(s) Hub.Flags.ESP_Names = s end})
tabVisuals:AddToggle({Name = "ESP Здоровье", Default = Hub.Flags.ESP_Health, Callback = function(s) Hub.Flags.ESP_Health = s end})

tabVisuals:AddSection("Окружающая Среда")
tabVisuals:AddToggle({
    Name = "Fullbright (День)", Default = Hub.Flags.Fullbright,
    Callback = function(s)
        Hub.Flags.Fullbright = s
        if not s then
            Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
            Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
            Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
            Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
        end
    end
})
tabVisuals:AddToggle({Name = "Potato PC Mode", Default = Hub.Flags.PotatoPC, Callback = function(s) ApplyPotatoPC(s) end})


-- Вкладка: ЗАЩИТА & СПАМ
local tabDefense = menu:CreateTab("Защита")
tabDefense:AddSection("Мета-Механика")
tabDefense:AddToggle({Name = "Bypass Metatable", Default = Hub.Flags.BypassMetatable, Callback = function(s) Hub.Flags.BypassMetatable = s end})
tabDefense:AddToggle({Name = "Anti-Grab (Стандарт)", Default = Hub.Flags.AntiGrab, Callback = function(s) Hub.Flags.AntiGrab = s end})
tabDefense:AddToggle({Name = "Anti-Fling", Default = Hub.Flags.AntiFling, Callback = function(s) Hub.Flags.AntiFling = s end})

tabDefense:AddSection("Автоматизация")
tabDefense:AddToggle({Name = "Спамер в чат", Default = Hub.Flags.ChatSpam, Callback = function(s) Hub.Flags.ChatSpam = s end})
tabDefense:AddTextBox({Name = "Текст сообщения", Default = Hub.Flags.ChatSpamMessage, Callback = function(t) Hub.Flags.ChatSpamMessage = t end})


-- Вкладка: ПРОФИЛЬ (CYBERPUNK CARD)
local tabProfile = menu:CreateTab("Профиль")
tabProfile:AddSection("Личные данные")

local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0.95, 0, 0, 270)
profileCard.BackgroundColor3 = THEME.BgStrong
profileCard.Parent = tabProfile.Page

local pCor = Instance.new("UICorner")
pCor.CornerRadius = UDim.new(0, 10)
pCor.Parent = profileCard
local pStroke = Instance.new("UIStroke")
pStroke.Color = THEME.Stroke
pStroke.Thickness = 1
pStroke.Parent = profileCard

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 100, 0, 100)
avatarImage.Position = UDim2.new(0.5, -50, 0, 15)
avatarImage.BackgroundColor3 = THEME.Bg
avatarImage.Image = "rbxasset://textures/ui/Guideline.png"
avatarImage.Parent = profileCard

local aCor = Instance.new("UICorner")
aCor.CornerRadius = UDim.new(1, 0)
aCor.Parent = avatarImage
local aStroke = Instance.new("UIStroke")
aStroke.Color = THEME.Accent
aStroke.Thickness = 2
aStroke.Parent = avatarImage

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 25)
nameLabel.Position = UDim2.new(0, 0, 0, 125)
nameLabel.Text = lp.DisplayName .. " [ @" .. lp.Name .. " ]"
nameLabel.TextColor3 = THEME.Text
nameLabel.Font = Enum.Font.GothamBlack
nameLabel.TextSize = 16
nameLabel.TextAlignment = Enum.TextAlignment.Center
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = profileCard

local ageLabel = Instance.new("TextLabel")
ageLabel.Size = UDim2.new(1, 0, 0, 20)
ageLabel.Position = UDim2.new(0, 0, 0, 150)
ageLabel.Text = "Возраст профиля: " .. tostring(lp.AccountAge) .. " дней"
ageLabel.TextColor3 = THEME.TextDim
ageLabel.Font = Enum.Font.Gotham
ageLabel.TextSize = 13
ageLabel.TextAlignment = Enum.TextAlignment.Center
ageLabel.BackgroundTransparency = 1
ageLabel.Parent = profileCard

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 20)
statsLabel.Position = UDim2.new(0, 0, 0, 175)
statsLabel.Text = "Пинг: --- | FPS: ---"
statsLabel.TextColor3 = THEME.Stroke
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextSize = 13
statsLabel.TextAlignment = Enum.TextAlignment.Center
statsLabel.BackgroundTransparency = 1
statsLabel.Parent = profileCard

local placeLabel = Instance.new("TextLabel")
placeLabel.Size = UDim2.new(1, 0, 0, 20)
placeLabel.Position = UDim2.new(0, 0, 0, 200)
placeLabel.Text = "Server ID: " .. tostring(game.JobId:sub(1,12)) .. "..."
placeLabel.TextColor3 = THEME.TextDim
placeLabel.Font = Enum.Font.Gotham
placeLabel.TextSize = 12
placeLabel.TextAlignment = Enum.TextAlignment.Center
placeLabel.BackgroundTransparency = 1
placeLabel.Parent = profileCard

task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    if isReady then avatarImage.Image = content end
end)

local fpsCounter = 0
SafeConnect(RunService.Heartbeat, function(step) fpsCounter = math.floor(1 / step) end)
task.spawn(function()
    while task.wait(1) do
        if Hub.Loaded then
            pcall(function()
                local pingValue = math.floor(Stats.Network.ServerToClientPing:GetValue() * 1000)
                statsLabel.Text = "Ping: " .. tostring(pingValue) .. "ms | FPS: " .. tostring(fpsCounter)
            end)
        end
    end
end)


-- Вкладка: НАСТРОЙКИ (ВЫГРУЗКА)
local tabCore = menu:CreateTab("Настройки")
tabCore:AddSection("Управление Скриптом")

local function TerminateHub()
    Hub.Loaded = false
    for _, conn in ipairs(Hub.Cache.Connections) do if conn.Connected then conn:Disconnect() end end
    table.clear(Hub.Cache.Connections)
    
    Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
    Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
    Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
    
    for _, item in pairs(Hub.Cache.EspBoxes) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspTracers) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspNames) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspHealth) do item:Destroy() end
    FOVCircle:Remove()
    
    if menu.Screen then menu.Screen:Destroy() end
    ApplyPotatoPC(false)
    
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false; hum.WalkSpeed = 16; hum.JumpPower = 50 end
        lp.CameraMode = Enum.CameraMode.Classic
        camera.FieldOfView = 70
    end)
    _G.BrosaHubGlobal = nil
    print("[Brosa System]: Скрипт выгружен.")
end

tabCore:AddButton({Name = "Destroy Script (Выгрузить полностью)", Callback = function() TerminateHub() end})


-- Обход метатаблицы для стандартных значений
local rawMetatable = getrawmetatable(game)
local oldIndex = rawMetatable.__index
local oldNewIndex = rawMetatable.__newindex
setreadonly(rawMetatable, false)

rawMetatable.__index = newcclosure(function(self, index)
    if Hub.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" then return 16 end
            if index == "JumpPower" then return 50 end
        end
    end
    return oldIndex(self, index)
end)

rawMetatable.__newindex = newcclosure(function(self, index, val)
    if Hub.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" and val == 0 then return end
            if index == "JumpPower" and val == 0 then return end
        end
    end
    oldNewIndex(self, index, val)
end)
setreadonly(rawMetatable, true)

-- Восстановление при респавне
SafeConnect(lp.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 15)
    if hum then
        task.wait(0.6)
        if Hub.Flags.WalkSpeedEnabled then hum.WalkSpeed = Hub.Flags.WalkSpeedValue end
        if Hub.Flags.JumpPowerEnabled then hum.JumpPower = Hub.Flags.JumpPowerValue end
    end
end)

print("[Brosa System v6.0]: Монолит FTAP Edition загружен. Успешной игры!")
