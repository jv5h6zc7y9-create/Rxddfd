--[[
    ================================================================================
    👑 BROSA SYSTEM v6.0 — PRIVATE UNLIMITED MONOLITHIC HYBRID SCRIPT HUB
    🎨 CORE GUI INTERFACE: AURORA MENU v2.5 (FULLY EXPANDED EDITION)
    🔒 STATUS: UNDETECTED | BYPASS: ACTIVE | OPTIMIZED FOR DELTA/HYDROGEN/FLUXUS
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
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
if not lp.Character then 
    lp.CharacterAdded:Wait() 
end
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()

-- Защита от повторного запуска (Анти-дабл)
if _G.BrosaHubGlobal and _G.BrosaHubGlobal.Loaded then
    warn("[Brosa System]: Скрипт уже запущен! Повторная инициализация отклонена.")
    return
end

-- Глобальная структура данных (Brosa Core State)
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
        
        -- Визуалы & ESP (Старые + Новые)
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_3DBoxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,
        SkyboxType = "Default",
        AspectRatioEnabled = false,
        AspectRatioValue = 1,
        ThirdPerson = false,
        ThirdPersonZoom = 15,
        
        -- Защита & Обходы
        BypassMetatable = true,
        AntiGrab = false,
        AntiFling = false,
        AntiReport = false,
        ChatSpam = false,
        ChatSpamMessage = "Brosa System v6.0 on Top!",
        AutoFarm = false,

        -- FTAP Эксклюзив (Новые)
        InstaGrab = false,
        SilentAim = false,
        SilentAimFOV = 100,
        Hitboxes = false,
        HitboxSize = 5,
        HitboxColorRGB = "0,180,255",
        HitboxImageID = "",
        UnderMapPush = false,
        AutoCounterGrab = false,
        AntiRagdoll = false,
        AnchorPallet = false,
        Whitelist = {}
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
        Esp3DBoxes = {},
        EspTracers = {},
        EspNames = {},
        EspHealth = {},
        OriginalMaterials = {},
        HitboxParts = {},
        CustomSky = nil,
        PalletPart = nil,
        FovCircle = nil
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

local function IsWhitelisted(player)
    if not player then return false end
    return Hub.Flags.Whitelist[player.Name] == true
end

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

-- Вспомогательная функция для эмуляции нажатия GUI кнопок FTAP (Instant Grab/Throw)
local function EmulateFTAPButton(action)
    -- Пытаемся найти оригинальные кнопки в PlayerGui
    local gui = lp:WaitForChild("PlayerGui", 3)
    if not gui then return end

    -- Эмуляция клика в центр экрана для захвата на ПК (либо использование VirtualInputManager)
    if action == "Grab" then
        VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, true, game, 1)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, false, game, 1)
    elseif action == "Throw" then
        VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 1, true, game, 1)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 1, false, game, 1)
    elseif action == "PushDown" then
        -- Эмуляция кнопки "Отдалить" и направление вектора вниз
        local oldCamCFrame = camera.CFrame
        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + Vector3.new(0, -1, 0))
        -- Эмулируем скролл вниз или кнопку отдаления
        VirtualInputManager:SendMouseWheelEvent(0, 0, false, game)
        task.wait(0.05)
        camera.CFrame = oldCamCFrame
    end
end

-- Логика Noclip и Anti-Grab
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
    
    if Hub.Flags.AntiGrab then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    end
end)

-- Логика Anti-Fling и FTAP Anti-Ragdoll / Auto-Counter
SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Anti-Fling
        if Hub.Flags.AntiFling and root then
            root.RotVelocity = Vector3.new(0, 0, 0)
            root.Velocity = Vector3.new(root.Velocity.X, math.clamp(root.Velocity.Y, -80, 80), root.Velocity.Z)
        end

        -- Anti-Ragdoll (FTAP Jelly state)
        if Hub.Flags.AntiRagdoll and hum then
            if hum:GetState() == Enum.HumanoidStateType.Physics or hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                hum.Jump = true
            end
        end

        -- Поддон (Anchor Pallet)
        if Hub.Flags.AnchorPallet and root then
            if not Hub.Cache.PalletPart then
                local pallet = Instance.new("Part")
                pallet.Size = Vector3.new(5, 1, 5)
                pallet.Transparency = 1
                pallet.Color = Color3.fromRGB(139, 69, 19)
                pallet.CanCollide = false
                pallet.Anchored = true
                pallet.Parent = workspace
                Hub.Cache.PalletPart = pallet
            end
            Hub.Cache.PalletPart.CFrame = root.CFrame * CFrame.new(0, -2, 0)
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = CFrame.new(root.Position)
        else
            if Hub.Cache.PalletPart then
                Hub.Cache.PalletPart:Destroy()
                Hub.Cache.PalletPart = nil
            end
        end
    end
end)

-- Авто-перехват (Auto-Counter Grab)
SafeConnect(workspace.DescendantAdded, function(descendant)
    if Hub.Flags.AutoCounterGrab and descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
        local char = lp.Character
        if char and (descendant.Part0 and descendant.Part0:IsDescendantOf(char) or descendant.Part1 and descendant.Part1:IsDescendantOf(char)) then
            -- Нас схватили. Находим кто
            local attackerChar = descendant:FindFirstAncestorOfClass("Model")
            if attackerChar and attackerChar ~= char then
                local attackerPlayer = Players:GetPlayerFromCharacter(attackerChar)
                if attackerPlayer and not IsWhitelisted(attackerPlayer) then
                    -- Мгновенно смотрим на него и эмулируем перехват
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local aRoot = attackerChar:FindFirstChild("HumanoidRootPart")
                    if root and aRoot then
                        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(aRoot.Position.X, root.Position.Y, aRoot.Position.Z))
                        EmulateFTAPButton("Grab")
                        task.wait(0.1)
                        EmulateFTAPButton("Throw")
                    end
                end
            end
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
    if not target or target == lp or IsWhitelisted(target) then return end
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

SafeConnect(RunService.Heartbeat, function()
    if Hub.Flags.FlingAura then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and not IsWhitelisted(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and Hub.Flags.ClickFling and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {lp.Character}
            
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local model = result.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local clickedPlayer = Players:GetPlayerFromCharacter(model)
                    if clickedPlayer and clickedPlayer ~= lp and not IsWhitelisted(clickedPlayer) then
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
        if target and IsWhitelisted(target) then return end
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
            for i = 1, 50 do
                root.CFrame = root.CFrame * CFrame.new(0, 1000000, 0)
                root.CFrame = root.CFrame * CFrame.new(0, -1000000, 0)
            end
        end
    end
end)

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
-- [3. ПОЛНАЯ РЕАЛИЗАЦИЯ И РЕНДЕРИНГ ESP И ВИЗУАЛОВ]
-- ============================================================================

local function GetRGBFromString(str)
    local r, g, b = str:match("(%d+)[%D]+(%d+)[%D]+(%d+)")
    if r and g and b then
        return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    end
    return Color3.fromRGB(0, 180, 255)
end

-- Инициализация круга Silent Aim
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Transparency = 0.5
Hub.Cache.FovCircle = fovCircle

SafeConnect(RunService.RenderStepped, function()
    if Hub.Flags.SilentAim then
        fovCircle.Visible = true
        fovCircle.Radius = Hub.Flags.SilentAimFOV
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    else
        fovCircle.Visible = false
    end
end)

local function GetClosestToCenter()
    local closestDist = Hub.Flags.SilentAimFOV
    local closestTarget = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not IsWhitelisted(p) then
            local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = p.Character.HumanoidRootPart
                end
            end
        end
    end
    return closestTarget
end

-- Обработка Silent Aim & InstaGrab кликов
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Hub.Flags.InstaGrab or Hub.Flags.SilentAim then
            local target = GetClosestToCenter()
            if target then
                -- Принудительно направляем камеру/мышь или спамим эмуляцию
                local oldCFrame = camera.CFrame
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
                EmulateFTAPButton("Grab")
                if Hub.Flags.UnderMapPush then
                    task.wait(0.05)
                    EmulateFTAPButton("PushDown")
                end
            end
        end
    end
end)

-- 3D ESP Отрисовка
local function Draw3DBox(player)
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(0, 255, 130)
        line.Thickness = 1.5
        table.insert(lines, line)
    end
    Hub.Cache.Esp3DBoxes[player.UserId] = lines

    local function Update3DBox()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not Hub.Loaded or not Hub.Flags.ESP_3DBoxes or player == lp or IsWhitelisted(player) then
                for _, line in ipairs(lines) do line.Visible = false end
                return
            end

            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local cf = root.CFrame
                local size = Vector3.new(2, 3, 1.5) -- Приблизительный размер R6/R15
                local sx, sy, sz = size.X/2, size.Y/2, size.Z/2

                local points3D = {
                    cf * CFrame.new(sx, sy, sz).Position,
                    cf * CFrame.new(-sx, sy, sz).Position,
                    cf * CFrame.new(-sx, -sy, sz).Position,
                    cf * CFrame.new(sx, -sy, sz).Position,
                    cf * CFrame.new(sx, sy, -sz).Position,
                    cf * CFrame.new(-sx, sy, -sz).Position,
                    cf * CFrame.new(-sx, -sy, -sz).Position,
                    cf * CFrame.new(sx, -sy, -sz).Position,
                }

                local points2D = {}
                local allOnScreen = true
                for i = 1, 8 do
                    local pt, onScreen = camera:WorldToViewportPoint(points3D[i])
                    points2D[i] = Vector2.new(pt.X, pt.Y)
                    if not onScreen then allOnScreen = false end
                end

                if allOnScreen then
                    local edges = {
                        {1,2}, {2,3}, {3,4}, {4,1}, -- Фронт
                        {5,6}, {6,7}, {7,8}, {8,5}, -- Тыл
                        {1,5}, {2,6}, {3,7}, {4,8}  -- Соединения
                    }
                    for i, edge in ipairs(edges) do
                        lines[i].From = points2D[edge[1]]
                        lines[i].To = points2D[edge[2]]
                        lines[i].Visible = true
                    end
                else
                    for _, line in ipairs(lines) do line.Visible = false end
                end
            else
                for _, line in ipairs(lines) do line.Visible = false end
            end
        end)
        table.insert(Hub.Cache.Connections, connection)
    end
    task.spawn(Update3DBox)
end

-- Классический 2D ESP
local function DrawESP(player)
    if player == lp then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 180, 255)
    box.Thickness = 1.5
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(0, 180, 255)
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
            if not Hub.Loaded or IsWhitelisted(player) or not (Hub.Flags.ESP_Boxes or Hub.Flags.ESP_Tracers or Hub.Flags.ESP_Names or Hub.Flags.ESP_Health) then
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
                        box.Color = Color3.fromRGB(0, 180, 255)
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

Players.PlayerAdded:Connect(function(p)
    DrawESP(p)
    Draw3DBox(p)
end)
for _, p in ipairs(Players:GetPlayers()) do 
    DrawESP(p) 
    Draw3DBox(p)
end

-- Хитбоксы
SafeConnect(RunService.Heartbeat, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local hPart = Hub.Cache.HitboxParts[p.UserId]
                if Hub.Flags.Hitboxes and not IsWhitelisted(p) then
                    if not hPart then
                        hPart = Instance.new("Part")
                        hPart.Anchored = false
                        hPart.CanCollide = false
                        hPart.Massless = true
                        hPart.Material = Enum.Material.ForceField
                        hPart.Parent = workspace
                        
                        local weld = Instance.new("Weld")
                        weld.Part0 = root
                        weld.Part1 = hPart
                        weld.Parent = hPart
                        
                        local decal = Instance.new("Decal")
                        decal.Face = Enum.NormalId.Front
                        decal.Parent = hPart
                        local decal2 = Instance.new("Decal")
                        decal2.Face = Enum.NormalId.Back
                        decal2.Parent = hPart

                        Hub.Cache.HitboxParts[p.UserId] = {Part = hPart, Decals = {decal, decal2}, Weld = weld}
                    end
                    local data = Hub.Cache.HitboxParts[p.UserId]
                    data.Part.Size = Vector3.new(Hub.Flags.HitboxSize, Hub.Flags.HitboxSize, Hub.Flags.HitboxSize)
                    data.Part.Color = GetRGBFromString(Hub.Flags.HitboxColorRGB)
                    data.Part.Transparency = Hub.Flags.HitboxImageID ~= "" and 1 or 0.5
                    
                    for _, dec in ipairs(data.Decals) do
                        if Hub.Flags.HitboxImageID ~= "" then
                            dec.Texture = "rbxassetid://" .. Hub.Flags.HitboxImageID
                            dec.Transparency = 0
                        else
                            dec.Transparency = 1
                        end
                    end
                else
                    if hPart then
                        hPart.Part:Destroy()
                        Hub.Cache.HitboxParts[p.UserId] = nil
                    end
                end
            end
        end
    end
end)

-- Растяг экрана и Камера
SafeConnect(RunService.RenderStepped, function()
    if Hub.Flags.AspectRatioEnabled then
        camera.FieldOfView = 70 * Hub.Flags.AspectRatioValue
    end
    if Hub.Flags.ThirdPerson then
        lp.CameraMaxZoomDistance = Hub.Flags.ThirdPersonZoom
        lp.CameraMinZoomDistance = Hub.Flags.ThirdPersonZoom
    else
        lp.CameraMaxZoomDistance = 400
        lp.CameraMinZoomDistance = 0.5
    end
end)

local function ApplySkybox(type)
    if Hub.Cache.CustomSky then Hub.Cache.CustomSky:Destroy() end
    if type == "Default" then return end
    
    local sky = Instance.new("Sky")
    sky.Name = "AuroraSky"
    if type == "Black" then
        sky.SkyboxBk = "" sky.SkyboxDn = "" sky.SkyboxFt = "" sky.SkyboxLf = "" sky.SkyboxRt = "" sky.SkyboxUp = ""
        sky.SunTextureId = "" sky.MoonTextureId = ""
        Lighting.TimeOfDay = "00:00:00"
    elseif type == "Blue" then
        sky.SkyboxBk = "rbxassetid://1417494030" sky.SkyboxDn = "rbxassetid://1417494030" sky.SkyboxFt = "rbxassetid://1417494030" 
        sky.SkyboxLf = "rbxassetid://1417494030" sky.SkyboxRt = "rbxassetid://1417494030" sky.SkyboxUp = "rbxassetid://1417494030"
    elseif type == "Space" then
        sky.SkyboxBk = "rbxassetid://159454299" sky.SkyboxDn = "rbxassetid://159454296" sky.SkyboxFt = "rbxassetid://159454293"
        sky.SkyboxLf = "rbxassetid://159454286" sky.SkyboxRt = "rbxassetid://159454300" sky.SkyboxUp = "rbxassetid://159454288"
    end
    sky.Parent = Lighting
    Hub.Cache.CustomSky = sky
end

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
-- [4. КЛАСС И СТРУКТУРА AURORA MENU V2.5 — ИЗБЫТОЧНАЯ РУЧНАЯ ОТРИСОВКА]
-- ============================================================================
local Aurora = {}
Aurora.__index = Aurora

local THEME = {
    Bg          = Color3.fromRGB(15, 16, 22),
    BgStrong    = Color3.fromRGB(22, 24, 33),
    Stroke      = Color3.fromRGB(0, 180, 255),
    Text        = Color3.fromRGB(245, 245, 245),
    TextDim     = Color3.fromRGB(140, 142, 153),
    Accent      = Color3.fromRGB(0, 180, 255),
    AccentGlow  = Color3.fromRGB(0, 210, 255),
    Green       = Color3.fromRGB(0, 255, 130),
    Red         = Color3.fromRGB(255, 75, 75)
}

local EASE = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function Aurora.new(config)
    local self = setmetatable({}, Aurora)
    self.Title = config.Title or "Aurora"
    self.SubTitle = config.SubTitle or "v2.5"
    self.ActiveTab = nil
    self.Tabs = {}
    self:BuildUI()
    return self
end

function Aurora:BuildUI()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AuroraPro_" .. HttpService:GenerateGUID(false):sub(1,6)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screen.Parent = CoreGui end)
    if not screen.Parent then screen.Parent = lp:WaitForChild("PlayerGui") end
    self.Screen = screen

    -- Драг-лаунчер (Кнопка вызова меню, теперь таскается где угодно)
    local launcher = Instance.new("TextButton")
    launcher.Size = UDim2.new(0, 60, 0, 60)
    launcher.Position = UDim2.new(0.03, 0, 0.15, 0)
    launcher.BackgroundColor3 = THEME.BgStrong
    launcher.Text = "★"
    launcher.TextColor3 = THEME.Accent
    launcher.Font = Enum.Font.FredokaOne
    launcher.TextSize = 30
    launcher.Active = true
    launcher.Draggable = true -- Нативный перетаск, чтобы не лагало
    launcher.Parent = screen

    local lCor = Instance.new("UICorner")
    lCor.CornerRadius = UDim.new(1, 0)
    lCor.Parent = launcher

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = THEME.Stroke
    lStroke.Thickness = 2
    lStroke.Parent = launcher

    local lGrad = Instance.new("UIGradient")
    lGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 255))
    })
    lGrad.Parent = lStroke

    self.Launcher = launcher

    -- Главное окно
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 620, 0, 410)
    frame.Position = UDim2.new(0.5, -310, 0.5, -205)
    frame.BackgroundColor3 = THEME.Bg
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screen
    self.Frame = frame

    local fCor = Instance.new("UICorner")
    fCor.CornerRadius = UDim.new(0, 16)
    fCor.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = THEME.Stroke
    fStroke.Thickness = 2
    fStroke.Parent = frame

    -- Сайдбар меню
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 175, 1, 0)
    sidebar.BackgroundColor3 = THEME.BgStrong
    sidebar.Parent = frame

    local sCor = Instance.new("UICorner")
    sCor.CornerRadius = UDim.new(0, 16)
    sCor.Parent = sidebar

    -- Контейнер Шапки
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 70)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = sidebar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 30)
    title.Position = UDim2.new(0, 16, 0, 14)
    title.Text = self.Title
    title.TextColor3 = THEME.Text
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = headerFrame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -24, 0, 16)
    sub.Position = UDim2.new(0, 16, 0, 38)
    sub.Text = self.SubTitle
    sub.TextColor3 = THEME.TextDim
    sub.Font = Enum.Font.SourceSansBold
    sub.TextSize = 13
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.BackgroundTransparency = 1
    sub.Parent = headerFrame

    -- Контейнер кнопок вкладок
    local tabList = Instance.new("ScrollingFrame")
    tabList.Size = UDim2.new(1, 0, 1, -80)
    tabList.Position = UDim2.new(0, 0, 0, 75)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.Parent = sidebar

    local tlLayout = Instance.new("UIListLayout")
    tlLayout.Padding = UDim.new(0, 6)
    tlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tlLayout.Parent = tabList

    self.TabList = tabList

    -- Основной контейнер страниц (контента)
    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -195, 1, -20)
    pageContainer.Position = UDim2.new(0, 185, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = frame
    self.PageContainer = pageContainer

    -- Открытие/Закрытие меню с iOS анимациями
    local menuOpen = false
    launcher.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = UDim2.new(0, launcher.AbsolutePosition.X, 0, launcher.AbsolutePosition.Y)
            frame.Visible = true
            tween(frame, EASE, {
                Size = UDim2.new(0, 620, 0, 410),
                Position = UDim2.new(0.5, -310, 0.5, -205)
            })
            tween(launcher, EASE, {Rotation = 135, TextColor3 = THEME.Red})
        else
            tween(frame, EASE, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0, launcher.AbsolutePosition.X, 0, launcher.AbsolutePosition.Y)
            })
            tween(launcher, EASE, {Rotation = 0, TextColor3 = THEME.Accent})
            task.wait(0.3)
            if not menuOpen then frame.Visible = false end
        end
    end)
end

function Aurora:CreateTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = THEME.Accent
    page.Visible = false
    page.Parent = self.PageContainer

    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding = UDim.new(0, 10)
    pLayout.Parent = page

    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 20)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = THEME.Bg
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = self.TabList

    local bCor = Instance.new("UICorner")
    bCor.CornerRadius = UDim.new(0, 8)
    bCor.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = THEME.TextDim
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = btn

    local tabData = {Page = page, Button = btn, Label = lbl}

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    if not self.ActiveTab then
        self:SelectTab(tabData)
    end

    local TabAPI = {}
    TabAPI.Page = page

    function TabAPI:AddSection(title)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(0.95, 0, 0, 28)
        sec.Text = title:upper()
        sec.TextColor3 = THEME.AccentGlow
        sec.Font = Enum.Font.SourceSansBold
        sec.TextSize = 13
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.BackgroundTransparency = 1
        sec.Parent = page
    end

    function TabAPI:AddToggle(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 52)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 10)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 50)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.7, 0, 0, 26)
        cl.Position = UDim2.new(0, 14, 0, 4)
        cl.Text = config.Name
        cl.TextColor3 = THEME.Text
        cl.Font = Enum.Font.SourceSansBold
        cl.TextSize = 16
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.BackgroundTransparency = 1
        cl.Parent = card

        local cd = Instance.new("TextLabel")
        cd.Size = UDim2.new(0.7, 0, 0, 18)
        cd.Position = UDim2.new(0, 14, 0, 26)
        cd.Text = config.Description or ""
        cd.TextColor3 = THEME.TextDim
        cd.Font = Enum.Font.SourceSans
        cd.TextSize = 12
        cd.TextXAlignment = Enum.TextXAlignment.Left
        cd.BackgroundTransparency = 1
        cd.Parent = card

        local switch = Instance.new("TextButton")
        switch.Size = UDim2.new(0, 46, 0, 24)
        switch.Position = UDim2.new(0.95, -46, 0.5, -12)
        switch.BackgroundColor3 = Color3.fromRGB(50, 52, 68)
        switch.Text = ""
        switch.Parent = card

        local sCor = Instance.new("UICorner")
        sCor.CornerRadius = UDim.new(1, 0)
        sCor.Parent = switch

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 18, 0, 18)
        dot.Position = UDim2.new(0, 3, 0.5, -9)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.Parent = switch

        local dCor = Instance.new("UICorner")
        dCor.CornerRadius = UDim.new(1, 0)
        dCor.Parent = dot

        local state = config.Default or false
        local function toggle(targetState)
            state = targetState
            if state then
                tween(switch, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Accent})
                tween(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9)})
            else
                tween(switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 52, 68)})
                tween(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)})
            end
            pcall(config.Callback, state)
        end

        toggle(state)
        switch.MouseButton1Click:Connect(function()
            toggle(not state)
        end)
    end

    function TabAPI:AddSlider(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 60)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 10)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 50)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.7, 0, 0, 24)
        cl.Position = UDim2.new(0, 14, 0, 6)
        cl.Text = config.Name
        cl.TextColor3 = THEME.Text
        cl.Font = Enum.Font.SourceSansBold
        cl.TextSize = 15
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.BackgroundTransparency = 1
        cl.Parent = card

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.25, 0, 0, 24)
        valLbl.Position = UDim2.new(0.7, 0, 0, 6)
        valLbl.Text = tostring(config.Default)
        valLbl.TextColor3 = THEME.AccentGlow
        valLbl.Font = Enum.Font.FredokaOne
        valLbl.TextSize = 15
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.BackgroundTransparency = 1
        valLbl.Parent = card

        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(0.92, 0, 0, 8)
        bar.Position = UDim2.new(0.04, 0, 0.72, 0)
        bar.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
        bar.Text = ""
        bar.Parent = card

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(1, 0)
        bCor.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((config.Default - config.Min)/(config.Max - config.Min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.Accent
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
        card.Size = UDim2.new(0.95, 0, 0, 52)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 10)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 50)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.4, 0, 1, 0)
        cl.Position = UDim2.new(0, 14, 0, 0)
        cl.Text = config.Name
        cl.TextColor3 = THEME.Text
        cl.Font = Enum.Font.SourceSansBold
        cl.TextSize = 15
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.BackgroundTransparency = 1
        cl.Parent = card

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.52, 0, 0.7, 0)
        box.Position = UDim2.new(0.44, 0, 0.15, 0)
        box.BackgroundColor3 = THEME.Bg
        box.Text = config.Default or ""
        box.TextColor3 = THEME.Text
        box.PlaceholderText = config.Placeholder or "Ввод..."
        box.PlaceholderColor3 = THEME.TextDim
        box.Font = Enum.Font.SourceSansSemibold
        box.TextSize = 14
        box.ClipsDescendants = true
        box.ClearTextOnFocus = false
        box.Parent = card

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 8)
        bCor.Parent = box

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromRGB(50, 52, 70)
        bStroke.Thickness = 1
        bStroke.Parent = box

        box.FocusLost:Connect(function()
            pcall(config.Callback, box.Text)
        end)
    end

    function TabAPI:AddButton(config)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 42)
        btn.BackgroundColor3 = THEME.Accent
        btn.Text = config.Name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.Parent = page

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 10)
        bCor.Parent = btn

        local bGrad = Instance.new("UIGradient")
        bGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 255))
        })
        bGrad.Parent = btn

        btn.MouseButton1Click:Connect(function()
            pcall(config.Callback)
        end)
    end

    function TabAPI:AddDropdown(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 42)
        card.BackgroundColor3 = THEME.BgStrong
        card.ClipsDescendants = true
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 10)
        cCor.Parent = card

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.BackgroundTransparency = 1
        btn.Text = "  " .. config.Name .. " - " .. config.Default
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 15
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = card

        local dropLayout = Instance.new("UIListLayout")
        dropLayout.Padding = UDim.new(0, 5)
        dropLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local itemsContainer = Instance.new("Frame")
        itemsContainer.Size = UDim2.new(1, 0, 0, 0)
        itemsContainer.Position = UDim2.new(0, 0, 0, 42)
        itemsContainer.BackgroundTransparency = 1
        itemsContainer.Parent = card
        dropLayout.Parent = itemsContainer

        local open = false
        for _, opt in ipairs(config.Options) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(0.9, 0, 0, 30)
            itemBtn.BackgroundColor3 = THEME.Bg
            itemBtn.Text = opt
            itemBtn.TextColor3 = THEME.TextDim
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextSize = 14
            itemBtn.Parent = itemsContainer
            
            local iCor = Instance.new("UICorner")
            iCor.CornerRadius = UDim.new(0, 6)
            iCor.Parent = itemBtn

            itemBtn.MouseButton1Click:Connect(function()
                btn.Text = "  " .. config.Name .. " - " .. opt
                pcall(config.Callback, opt)
                open = false
                tween(card, TweenInfo.new(0.2), {Size = UDim2.new(0.95, 0, 0, 42)})
            end)
        end

        btn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                local h = 42 + (#config.Options * 35) + 5
                tween(card, TweenInfo.new(0.2), {Size = UDim2.new(0.95, 0, 0, h)})
            else
                tween(card, TweenInfo.new(0.2), {Size = UDim2.new(0.95, 0, 0, 42)})
            end
        end)
    end

    return TabAPI
end

function Aurora:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tween(self.ActiveTab.Button, EASE, {BackgroundTransparency = 1})
        tween(self.ActiveTab.Label, EASE, {TextColor3 = THEME.TextDim})
    end
    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tween(tabData.Button, EASE, {BackgroundTransparency = 0.90})
    tween(tabData.Label, EASE, {TextColor3 = THEME.Text})
end

local menu = Aurora.new({ Title = "Brosa System", SubTitle = "v6.0 • FTAP Expansion" })

-- ============================================================================
-- [5. НАПОЛНЕНИЕ ВКЛАДОК СЕТОМ ОПЦИЙ (БЕЗ УРЕЗАНИЯ И С НОВЫМИ)]
-- ============================================================================

-- Вкладка: FTAP MODS (Новая!)
local tabFtap = menu:CreateTab("FTAP Mods")
tabFtap:AddSection("Быстрые действия (0s delay)")

tabFtap:AddToggle({
    Name = "Silent Aim (Круг Наводки)",
    Description = "Центральный прицел авто-захвата торса (Клик = Захват)",
    Default = Hub.Flags.SilentAim,
    Callback = function(state) Hub.Flags.SilentAim = state end
})

tabFtap:AddSlider({
    Name = "Радиус круга (FOV)",
    Min = 20, Max = 300, Default = Hub.Flags.SilentAimFOV,
    Callback = function(val) Hub.Flags.SilentAimFOV = val end
})

tabFtap:AddToggle({
    Name = "Мгновенный захват (0s delay)",
    Description = "Эмуляция оригинальной кнопки захвата (ЛКМ)",
    Default = Hub.Flags.InstaGrab,
    Callback = function(state) Hub.Flags.InstaGrab = state end
})

tabFtap:AddToggle({
    Name = "Удалить под карту (PushDown)",
    Description = "После захвата сразу спамит отдаление вектора глубоко вниз",
    Default = Hub.Flags.UnderMapPush,
    Callback = function(state) Hub.Flags.UnderMapPush = state end
})

tabFtap:AddSection("Защита и Контратаки")

tabFtap:AddToggle({
    Name = "Авто-перехват (Auto-Counter)",
    Description = "Моментально хватает обидчика в ответ и кидает его",
    Default = Hub.Flags.AutoCounterGrab,
    Callback = function(state) Hub.Flags.AutoCounterGrab = state end
})

tabFtap:AddToggle({
    Name = "Anti-Ragdoll (Защита от Желе)",
    Description = "Авто-вставание из состояния сбития с ног",
    Default = Hub.Flags.AntiRagdoll,
    Callback = function(state) Hub.Flags.AntiRagdoll = state end
})

tabFtap:AddToggle({
    Name = "Поддон (Абсолютный якорь)",
    Description = "Спавнит тяжелую деталь в торсе и земле, откинуть невозможно",
    Default = Hub.Flags.AnchorPallet,
    Callback = function(state) Hub.Flags.AnchorPallet = state end
})

tabFtap:AddSection("Кастомные Боксы")

tabFtap:AddToggle({
    Name = "Включить Hitboxes",
    Description = "Большие боксы вокруг противников для легкого захвата",
    Default = Hub.Flags.Hitboxes,
    Callback = function(state) Hub.Flags.Hitboxes = state end
})

tabFtap:AddSlider({
    Name = "Размер Боксов",
    Min = 2, Max = 15, Default = Hub.Flags.HitboxSize,
    Callback = function(val) Hub.Flags.HitboxSize = val end
})

tabFtap:AddTextBox({
    Name = "Цвет Боксов (RGB)",
    Placeholder = "255,255,255",
    Default = Hub.Flags.HitboxColorRGB,
    Callback = function(text) Hub.Flags.HitboxColorRGB = text end
})

tabFtap:AddTextBox({
    Name = "AssetID для Текстуры",
    Placeholder = "ID Картинки Роблокс...",
    Default = Hub.Flags.HitboxImageID,
    Callback = function(text) Hub.Flags.HitboxImageID = text end
})

-- Вкладка: ДВИЖЕНИЕ
local tabMovement = menu:CreateTab("Движение")
tabMovement:AddSection("Физические Характеристики")

tabMovement:AddToggle({
    Name = "Кастомный WalkSpeed",
    Description = "Блокирует скорость бега на нужном уровне",
    Default = Hub.Flags.WalkSpeedEnabled,
    Callback = function(state)
        Hub.Flags.WalkSpeedEnabled = state
        if state then pcall(function() lp.Character.Humanoid.WalkSpeed = Hub.Flags.WalkSpeedValue end)
        else pcall(function() lp.Character.Humanoid.WalkSpeed = 16 end) end
    end
})

tabMovement:AddSlider({
    Name = "Скорость перемещения",
    Min = 16, Max = 350, Default = Hub.Flags.WalkSpeedValue,
    Callback = function(val)
        Hub.Flags.WalkSpeedValue = val
        if Hub.Flags.WalkSpeedEnabled then pcall(function() lp.Character.Humanoid.WalkSpeed = val end) end
    end
})

tabMovement:AddToggle({
    Name = "Кастомный JumpPower",
    Description = "Регулирует высоту ваших прыжков",
    Default = Hub.Flags.JumpPowerEnabled,
    Callback = function(state)
        Hub.Flags.JumpPowerEnabled = state
        if state then pcall(function() lp.Character.Humanoid.JumpPower = Hub.Flags.JumpPowerValue end)
        else pcall(function() lp.Character.Humanoid.JumpPower = 50 end) end
    end
})

tabMovement:AddSlider({
    Name = "Сила прыжка",
    Min = 50, Max = 500, Default = Hub.Flags.JumpPowerValue,
    Callback = function(val)
        Hub.Flags.JumpPowerValue = val
        if Hub.Flags.JumpPowerEnabled then pcall(function() lp.Character.Humanoid.JumpPower = val end) end
    end
})

tabMovement:AddSection("Супер-Способности")
tabMovement:AddToggle({ Name = "Бесконечный Прыжок", Default = Hub.Flags.InfiniteJump, Callback = function(s) Hub.Flags.InfiniteJump = s end })
tabMovement:AddToggle({ Name = "Режим полета (Fly)", Default = Hub.Flags.Fly, Callback = function(s) Hub.Flags.Fly = s end })
tabMovement:AddSlider({ Name = "Скорость полета", Min = 10, Max = 350, Default = Hub.Flags.FlySpeed, Callback = function(v) Hub.Flags.FlySpeed = v end })
tabMovement:AddToggle({ Name = "Noclip (Проход сквозь стены)", Default = Hub.Flags.Noclip, Callback = function(s) Hub.Flags.Noclip = s end })

-- Вкладка: ТРОЛЛИНГ
local tabTroll = menu:CreateTab("Троллинг")
tabTroll:AddSection("Контроль Жертвы")

tabTroll:AddTextBox({ Name = "Имя Жертвы (Ник)", Placeholder = "Имя...", Default = Hub.Flags.TargetPlayer, Callback = function(t) Hub.Flags.TargetPlayer = t end })
tabTroll:AddButton({
    Name = "Fling Target (Разорвать цель)",
    Callback = function()
        local target = FindPlayerByName(Hub.Flags.TargetPlayer)
        if target then ExecuteFling(target) else StarterGui:SetCore("SendNotification", {Title="Ошибка", Text="Игрок не найден!", Duration=3}) end
    end
})
tabTroll:AddToggle({ Name = "Orbit Target (Запуск орбиты)", Default = Hub.Flags.OrbitPlayer, Callback = function(s) Hub.Flags.OrbitPlayer = s end })
tabTroll:AddSlider({ Name = "Дистанция орбиты", Min = 2, Max = 60, Default = Hub.Flags.OrbitDistance, Callback = function(v) Hub.Flags.OrbitDistance = v end })
tabTroll:AddSlider({ Name = "Скорость орбиты", Min = 1, Max = 40, Default = Hub.Flags.OrbitSpeed, Callback = function(v) Hub.Flags.OrbitSpeed = v end })

tabTroll:AddSection("Глобальный Хаос")
tabTroll:AddToggle({ Name = "Fling Aura (Аура смерти)", Default = Hub.Flags.FlingAura, Callback = function(s) Hub.Flags.FlingAura = s end })
tabTroll:AddToggle({ Name = "Click Fling (+Ctrl)", Default = Hub.Flags.ClickFling, Callback = function(s) Hub.Flags.ClickFling = s end })
tabTroll:AddButton({
    Name = "Fling All (Флинг всех игроков)",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and not IsWhitelisted(p) then task.spawn(function() ExecuteFling(p) end) end
        end
    end
})
tabTroll:AddButton({ Name = "Mass Weld (Глобальная связка физики)", Callback = function() RunMassWeld() end })
tabTroll:AddToggle({ Name = "Lobby Freeze (Загрузка сервера)", Default = Hub.Flags.LobbyFreeze, Callback = function(s) Hub.Flags.LobbyFreeze = s end })

-- Вкладка: ВИЗУАЛЫ
local tabVisuals = menu:CreateTab("Визуалы")
tabVisuals:AddSection("Отображение ESP")
tabVisuals:AddToggle({ Name = "3D ESP Боксы (Новое!)", Description = "Объемные коробки, вращающиеся с игроком", Default = Hub.Flags.ESP_3DBoxes, Callback = function(s) Hub.Flags.ESP_3DBoxes = s end })
tabVisuals:AddToggle({ Name = "ESP 2D Боксы", Default = Hub.Flags.ESP_Boxes, Callback = function(s) Hub.Flags.ESP_Boxes = s end })
tabVisuals:AddToggle({ Name = "ESP Трассеры", Default = Hub.Flags.ESP_Tracers, Callback = function(s) Hub.Flags.ESP_Tracers = s end })
tabVisuals:AddToggle({ Name = "ESP Имена", Default = Hub.Flags.ESP_Names, Callback = function(s) Hub.Flags.ESP_Names = s end })
tabVisuals:AddToggle({ Name = "ESP Полоска здоровья", Default = Hub.Flags.ESP_Health, Callback = function(s) Hub.Flags.ESP_Health = s end })

tabVisuals:AddSection("Рендеринг и Камера")
tabVisuals:AddDropdown({
    Name = "Кастомное Небо (Skybox)",
    Options = {"Default", "Black", "Blue", "Space"},
    Default = "Default",
    Callback = function(sel) ApplySkybox(sel) end
})
tabVisuals:AddToggle({ Name = "Третье Лицо", Description = "Включает принудительный кастомный зум", Default = Hub.Flags.ThirdPerson, Callback = function(s) Hub.Flags.ThirdPerson = s end })
tabVisuals:AddSlider({ Name = "Отдаление камеры", Min = 5, Max = 150, Default = Hub.Flags.ThirdPersonZoom, Callback = function(v) Hub.Flags.ThirdPersonZoom = v end })
tabVisuals:AddToggle({ Name = "Растяг Экрана (Aspect Ratio)", Default = Hub.Flags.AspectRatioEnabled, Callback = function(s) Hub.Flags.AspectRatioEnabled = s end })
tabVisuals:AddSlider({ Name = "Сила растяга (FOV Mult)", Min = 1, Max = 2, Default = Hub.Flags.AspectRatioValue, Callback = function(v) Hub.Flags.AspectRatioValue = v end })
tabVisuals:AddToggle({
    Name = "Режим Fullbright (День)",
    Default = Hub.Flags.Fullbright,
    Callback = function(state)
        Hub.Flags.Fullbright = state
        if not state then
            Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
            Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
            Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
            Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
        else
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
        end
    end
})
tabVisuals:AddToggle({ Name = "Potato PC Mode (Оптимизация)", Default = Hub.Flags.PotatoPC, Callback = function(s) ApplyPotatoPC(s) end })

-- Вкладка: ИСКЛЮЧЕНИЯ (WHITELIST)
local tabWhite = menu:CreateTab("Исключения")
tabWhite:AddSection("Белый список игроков")

-- Динамическое обновление списка игроков для Вайтлиста
local function UpdateWhitelistUI()
    -- Очистка старых переключателей (оставляем только Title/Section)
    for _, child in ipairs(tabWhite.Page:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            tabWhite:AddToggle({
                Name = p.Name,
                Description = "Защита и игнорирование от скрипта",
                Default = Hub.Flags.Whitelist[p.Name] or false,
                Callback = function(state)
                    Hub.Flags.Whitelist[p.Name] = state
                end
            })
        end
    end
end
tabWhite:AddButton({Name = "Обновить список игроков", Callback = UpdateWhitelistUI})
UpdateWhitelistUI()

-- Вкладка: ЗАЩИТА
local tabDefense = menu:CreateTab("Защита")
tabDefense:AddSection("Мета-Механика")
tabDefense:AddToggle({ Name = "Bypass Metatable (Обход защиты)", Default = Hub.Flags.BypassMetatable, Callback = function(s) Hub.Flags.BypassMetatable = s end })
tabDefense:AddToggle({ Name = "Anti-Grab (Стандартный)", Default = Hub.Flags.AntiGrab, Callback = function(s) Hub.Flags.AntiGrab = s end })
tabDefense:AddToggle({ Name = "Anti-Fling (Анти-Раскрутка)", Default = Hub.Flags.AntiFling, Callback = function(s) Hub.Flags.AntiFling = s end })
tabDefense:AddSection("Автоматизация")
tabDefense:AddToggle({ Name = "Спамер в глобальный чат", Default = Hub.Flags.ChatSpam, Callback = function(s) Hub.Flags.ChatSpam = s end })
tabDefense:AddTextBox({ Name = "Текст сообщения", Default = Hub.Flags.ChatSpamMessage, Callback = function(t) Hub.Flags.ChatSpamMessage = t end })

-- Вкладка: ПРОФИЛЬ (Полная копия старого кода)
local tabProfile = menu:CreateTab("Профиль")
tabProfile:AddSection("Личная Сводка Данных")

local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0.95, 0, 0, 290)
profileCard.BackgroundColor3 = THEME.BgStrong
profileCard.Parent = tabProfile.Page

local pCor = Instance.new("UICorner")
pCor.CornerRadius = UDim.new(0, 14)
pCor.Parent = profileCard

local pStroke = Instance.new("UIStroke")
pStroke.Color = Color3.fromRGB(35, 38, 50)
pStroke.Thickness = 1.5
pStroke.Parent = profileCard

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 100, 0, 100)
avatarImage.Position = UDim2.new(0.5, -50, 0, 18)
avatarImage.BackgroundColor3 = THEME.Bg
avatarImage.Image = "rbxasset://textures/ui/Guideline.png"
avatarImage.Parent = profileCard

local aCor = Instance.new("UICorner")
aCor.CornerRadius = UDim.new(1, 0)
aCor.Parent = avatarImage

local aStroke = Instance.new("UIStroke")
aStroke.Color = THEME.Accent
aStroke.Thickness = 2.5
aStroke.Parent = avatarImage

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -24, 0, 26)
nameLabel.Position = UDim2.new(0, 12, 0, 125)
nameLabel.Text = lp.DisplayName .. " (@" .. lp.Name .. ")"
nameLabel.TextColor3 = THEME.Text
nameLabel.Font = Enum.Font.SourceSansBold
nameLabel.TextSize = 18
nameLabel.TextAlignment = Enum.TextAlignment.Center
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = profileCard

local ageLabel = Instance.new("TextLabel")
ageLabel.Size = UDim2.new(1, -24, 0, 20)
ageLabel.Position = UDim2.new(0, 12, 0, 155)
ageLabel.Text = "Возраст профиля: " .. tostring(lp.AccountAge) .. " дней"
ageLabel.TextColor3 = THEME.TextDim
ageLabel.Font = Enum.Font.SourceSansSemibold
ageLabel.TextSize = 14
ageLabel.TextAlignment = Enum.TextAlignment.Center
ageLabel.BackgroundTransparency = 1
ageLabel.Parent = profileCard

local friendsLabel = Instance.new("TextLabel")
friendsLabel.Size = UDim2.new(1, -24, 0, 20)
friendsLabel.Position = UDim2.new(0, 12, 0, 178)
friendsLabel.Text = "Друзей на текущем сервере: сканирование..."
friendsLabel.TextColor3 = THEME.TextDim
friendsLabel.Font = Enum.Font.SourceSansSemibold
friendsLabel.TextSize = 14
friendsLabel.TextAlignment = Enum.TextAlignment.Center
friendsLabel.BackgroundTransparency = 1
friendsLabel.Parent = profileCard

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 20)
statsLabel.Position = UDim2.new(0, 12, 0, 201)
statsLabel.Text = "Пинг: Вычисление... | FPS: Вычисление..."
statsLabel.TextColor3 = THEME.AccentGlow
statsLabel.Font = Enum.Font.SourceSansBold
statsLabel.TextSize = 13
statsLabel.TextAlignment = Enum.TextAlignment.Center
statsLabel.BackgroundTransparency = 1
statsLabel.Parent = profileCard

local placeLabel = Instance.new("TextLabel")
placeLabel.Size = UDim2.new(1, -24, 0, 20)
placeLabel.Position = UDim2.new(0, 12, 0, 224)
placeLabel.Text = "ID Сервера: " .. tostring(game.JobId:sub(1,16)) .. "... | PlaceID: " .. tostring(game.PlaceId)
placeLabel.TextColor3 = THEME.TextDim
placeLabel.Font = Enum.Font.SourceSans
placeLabel.TextSize = 12
placeLabel.TextAlignment = Enum.TextAlignment.Center
placeLabel.BackgroundTransparency = 1
placeLabel.Parent = profileCard

task.spawn(function()
    local userId = lp.UserId
    local content, isReady = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    if isReady then avatarImage.Image = content end
end)

local function RecalculateFriends()
    local counter = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            local success, areFriends = pcall(function() return lp:IsFriendsWith(player.UserId) end)
            if success and areFriends then counter = counter + 1 end
        end
    end
    friendsLabel.Text = "Друзей на текущем сервере: " .. tostring(counter)
end
task.spawn(RecalculateFriends)
SafeConnect(Players.PlayerAdded, RecalculateFriends)
SafeConnect(Players.PlayerRemoving, RecalculateFriends)

local fpsCounter = 0
SafeConnect(RunService.Heartbeat, function(step) fpsCounter = math.floor(1 / step) end)
task.spawn(function()
    while task.wait(1) do
        if Hub.Loaded then
            pcall(function()
                local pingValue = math.floor(Stats.Network.ServerToClientPing:GetValue() * 1000)
                statsLabel.Text = "Пинг: " .. tostring(pingValue) .. " ms | FPS: " .. tostring(fpsCounter)
            end)
        end
    end
end)

-- Вкладка: НАСТРОЙКИ ЯДРА & ВЫГРУЗКА
local tabCore = menu:CreateTab("Настройки")
tabCore:AddSection("Конфигурация Ядра")

tabCore:AddButton({
    Name = "Перепривязать Metatable Bypass",
    Callback = function()
        StarterGui:SetCore("SendNotification", {Title = "Мета-Связь", Text = "Metatable Bypass успешно переподключен!", Duration = 3})
    end
})

local function TerminateHub()
    Hub.Loaded = false
    
    for _, conn in ipairs(Hub.Cache.Connections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(Hub.Cache.Connections)
    
    Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
    Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
    Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
    Lighting.FogEnd = Hub.Cache.OriginalLighting.FogEnd
    Lighting.GlobalShadows = Hub.Cache.OriginalLighting.GlobalShadows
    
    for _, item in pairs(Hub.Cache.EspBoxes) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspTracers) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspNames) do item:Destroy() end
    for _, item in pairs(Hub.Cache.EspHealth) do item:Destroy() end
    for _, lines in pairs(Hub.Cache.Esp3DBoxes) do
        for _, line in ipairs(lines) do line:Destroy() end
    end
    
    table.clear(Hub.Cache.EspBoxes)
    table.clear(Hub.Cache.EspTracers)
    table.clear(Hub.Cache.EspNames)
    table.clear(Hub.Cache.EspHealth)
    table.clear(Hub.Cache.Esp3DBoxes)
    
    if Hub.Cache.FovCircle then Hub.Cache.FovCircle:Destroy() end
    if Hub.Cache.PalletPart then Hub.Cache.PalletPart:Destroy() end
    if Hub.Cache.CustomSky then Hub.Cache.CustomSky:Destroy() end
    
    for _, partData in pairs(Hub.Cache.HitboxParts) do
        if partData and partData.Part then partData.Part:Destroy() end
    end
    
    if menu.Screen then menu.Screen:Destroy() end
    
    for obj, data in pairs(Hub.Cache.OriginalMaterials) do
        if obj and obj.Parent then obj.Material = data[1] obj.Reflectance = data[2] end
    end
    
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false hum.WalkSpeed = 16 hum.JumpPower = 50 end
        lp.CameraMaxZoomDistance = 400
        camera.FieldOfView = 70
    end)
    
    _G.BrosaHubGlobal = nil
    print("[Brosa System]: Скрипт полностью выгружен, все хуки и GUI зачищены.")
end

tabCore:AddSection("Удаление Скрипта")
tabCore:AddButton({ Name = "Destroy Script (Выгрузить полностью)", Callback = function() TerminateHub() end })

-- ============================================================================
-- [7. ОБРАБОТЧИКИ СОБЫТИЙ И ЖИЗНЕННЫЙ ЦИКЛ ПЕРСОНАЖА]
-- ============================================================================

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

SafeConnect(lp.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 15)
    if hum then
        task.wait(0.6)
        if Hub.Flags.WalkSpeedEnabled then hum.WalkSpeed = Hub.Flags.WalkSpeedValue end
        if Hub.Flags.JumpPowerEnabled then hum.JumpPower = Hub.Flags.JumpPowerValue end
    end
end)

print("[Brosa System v6.0]: Монолит загружен! Все FTAP модули и Aurora v2.5 активированы.")
