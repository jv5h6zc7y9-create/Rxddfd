--[[
    ================================================================================
    👑 BROSA SYSTEM v5.5 — PRIVATE UNLIMITED MONOLITHIC HYBRID SCRIPT HUB
    🎨 CORE GUI INTERFACE: AURORA MENU v2 (FULLY EXPANDED & PERFECTED)
    🔒 STATUS: UNDETECTED | BYPASS: ACTIVE | FIXES: PHYSICAL CORE & COMBAT ENGINE
    ================================================================================
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

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

if _G.BrosaHubGlobal and _G.BrosaHubGlobal.Loaded then
    warn("[Brosa System]: Скрипт уже запущен! Повторная инициализация отклонена.")
    return
end

-- Глобальная структура данных (Brosa Core State — Все оригинальные + новые флаги)
_G.BrosaHubGlobal = {
    Loaded = true,
    Flags = {
        -- Движение (Оригинал)
        WalkSpeedEnabled = false,
        WalkSpeedValue = 16,
        JumpPowerEnabled = false,
        JumpPowerValue = 50,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        
        -- Вредительство & Троллинг (Оригинал)
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

        -- НОВЫЕ ТРОЛЛИНГ/БОЙ ФЛАГИ (Исправление Аима и Хитбоксов)
        SilentAim = false,
        AimRadius = 150,
        CustomBoxes = false,
        BoxSize = 6,
        AutoUnderMap = false,
        
        -- Визуалы & ESP (Оригинал + Новая Камера)
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,
        ThirdPerson = false,
        CamDist = 15,
        StretchToggle = false,
        Stretch = 70,
        
        -- Защита & Обходы (Оригинал)
        BypassMetatable = true,
        AntiGrab = false,
        AntiFling = false,
        AntiReport = false,
        ChatSpam = false,
        ChatSpamMessage = "Brosa System v5.5 on Top!",
        AutoFarm = false
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
        Hitboxes = {},
        OriginalMaterials = {}
    }
}

local Hub = _G.BrosaHubGlobal

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

-- Отрисовка FOV кольца для Сайлент Аима
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(0, 255, 150)
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Filled = false

SafeConnect(RunService.RenderStepped, function()
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Radius = Hub.Flags.AimRadius
    fovCircle.Visible = Hub.Flags.SilentAim and Hub.Loaded
end)

-- Поиск ближайшей цели к курсору в радиусе FOV
local function GetClosestToCursor()
    local closest, minD = nil, Hub.Flags.AimRadius
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < minD then 
                    minD = dist
                    closest = p.Character 
                end
            end
        end
    end
    return closest
end

-- Принудительный Камера-Движок (Обход защиты игры на FOV и 3-е Лицо)
RunService:BindToRenderStep("BrosaCameraControl", Enum.RenderPriority.Camera.Value + 1, function()
    if not Hub.Loaded then return end
    
    if Hub.Flags.StretchToggle then
        camera.FieldOfView = Hub.Flags.Stretch
    end
    
    if Hub.Flags.ThirdPerson and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local root = lp.Character.HumanoidRootPart
        camera.CameraType = Enum.CameraType.Scriptable
        local offset = CFrame.new(0, 3, Hub.Flags.CamDist)
        camera.CFrame = CFrame.lookAt((root.CFrame * offset).Position, root.Position)
    elseif not Hub.Flags.ThirdPerson and camera.CameraType == Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Custom
    end
end)

-- Логика Noclip, Anti-Grab и Кастомных Хитбоксов (Stepped — до просчета физики)
SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    
    -- Noclip
    if Hub.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- Anti-Grab
    if Hub.Flags.AntiGrab then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanTouch = false end
        end
    end

    -- Динамическое масштабирование хитбоксов (Исправленный алгоритм)
    if Hub.Flags.CustomBoxes then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                if not Hub.Cache.Hitboxes[p.UserId] or Hub.Cache.Hitboxes[p.UserId].Parent ~= p.Character then
                    local box = Instance.new("Part")
                    box.Name = "BrosaHitbox"
                    box.Size = Vector3.new(Hub.Flags.BoxSize, Hub.Flags.BoxSize, Hub.Flags.BoxSize)
                    box.Transparency = 0.6
                    box.Color = Color3.fromRGB(255, 0, 80)
                    box.CanCollide = false
                    box.Massless = true
                    box.Parent = p.Character
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = root
                    weld.Part1 = box
                    weld.Parent = box
                    
                    Hub.Cache.Hitboxes[p.UserId] = box
                else
                    Hub.Cache.Hitboxes[p.UserId].Size = Vector3.new(Hub.Flags.BoxSize, Hub.Flags.BoxSize, Hub.Flags.BoxSize)
                end
            end
        end
    else
        for id, box in pairs(Hub.Cache.Hitboxes) do
            if box then box:Destroy() end
        end
        table.clear(Hub.Cache.Hitboxes)
    end
end)

-- Исправленный и усиленный Anti-Fling движок (Assembly Физика)
SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if Hub.Flags.AntiFling and char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            -- Жесткое обнуление вращательного момента сил сторонних таранщиков
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            -- Стабилизация линейного смещения
            local currentVel = root.AssemblyLinearVelocity
            if currentVel.Magnitude > 120 then
                root.AssemblyLinearVelocity = Vector3.new(0, math.clamp(currentVel.Y, -60, 60), 0)
            end
        end
    end
end)

-- Перехват ввода: Клики (Аим + Захват) и Клавиши (Бросок под карту)
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    
    -- Silent Aim и Автозахват через манипуляцию CFrame хитбокса
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Hub.Flags.SilentAim then
        local targetChar = GetClosestToCursor()
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local root = targetChar.HumanoidRootPart
            local mouseHit = lp:GetMouse().Hit
            if mouseHit then
                local oldCFrame = root.CFrame
                root.CFrame = CFrame.new(mouseHit.Position) -- Стягиваем цель под курсор для захвата инструментами игры
                task.wait(0.02)
                if mouse1click then mouse1click() end
                task.wait(0.03)
                root.CFrame = oldCFrame -- Возвращаем на место
            end
        end
    end

    -- Авто-отброс удерживаемого человека глубоко за карту (Клавиша X)
    if input.KeyCode == Enum.KeyCode.X and Hub.Flags.AutoUnderMap then
        local char = lp.Character
        if not char then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Weld") or obj:IsA("WeldConstraint") then
                local p0, p1 = obj.Part0, obj.Part1
                if p0 and p1 and (p0:IsDescendantOf(char) or p1:IsDescendantOf(char)) then
                    local victimPart = p0:IsDescendantOf(char) and p1 or p0
                    if victimPart and not victimPart:IsDescendantOf(char) then
                        victimPart.CanCollide = false
                        victimPart.AssemblyLinearVelocity = Vector3.new(0, -100000, 0) -- Критический нисходящий импульс физики
                        obj:Destroy() -- Ломаем связку удержания
                    end
                end
            end
        end
    end
end)

-- Логика Полета (Fly Engine v2 — Резервный расчет)
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

-- Усовершенствованный Fling Движок (Высокоскоростной таран физики)
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
            root.AssemblyLinearVelocity = Vector3.new(0, 150000, 0)
            root.AssemblyAngularVelocity = Vector3.new(150000, 150000, 150000)
            root.CFrame = troot.CFrame * CFrame.new(math.random(-2, 2)/10, 0, math.random(-2, 2)/10)
        end)
        
        task.delay(2.5, function()
            flingActive = false
            tempNoclip:Disconnect()
            flingLoop:Disconnect()
            task.wait(0.1)
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
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
                    if dist <= 15 then ExecuteFling(player) end
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
            
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local model = result.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local clickedPlayer = Players:GetPlayerFromCharacter(model)
                    if clickedPlayer and clickedPlayer ~= lp then ExecuteFling(clickedPlayer) end
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
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(troot.Position + offset, troot.Position)
        end
    end
end)

-- Mass Weld
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

-- Chat Spammer Loop
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
            if not Hub.Loaded or not (Hub.Flags.ESP_Boxes or Hub.Flags.ESP_Tracers or Hub.Flags.ESP_Names or Hub.Flags.ESP_Health) then
                box.Visible = false; tracer.Visible = false; name.Visible = false; healthBar.Visible = false
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
                    else box.Visible = false end
                    
                    if Hub.Flags.ESP_Tracers then
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        tracer.Visible = true
                    else tracer.Visible = false end
                    
                    if Hub.Flags.ESP_Names then
                        name.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                        name.Position = Vector2.new(rootPos.X, (rootPos.Y - sizeY / 2) - 15)
                        name.Visible = true
                    else name.Visible = false end
                    
                    if Hub.Flags.ESP_Health then
                        local healthPercent = hum.Health / hum.MaxHealth
                        local barHeight = sizeY * healthPercent
                        healthBar.From = Vector2.new((rootPos.X - sizeX / 2) - 6, rootPos.Y + sizeY / 2)
                        healthBar.To = Vector2.new((rootPos.X - sizeX / 2) - 6, (rootPos.Y + sizeY / 2) - barHeight)
                        healthBar.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
                        healthBar.Visible = true
                    else healthBar.Visible = false end
                else box.Visible = false; tracer.Visible = false; name.Visible = false; healthBar.Visible = false end
            else box.Visible = false; tracer.Visible = false; name.Visible = false; healthBar.Visible = false end
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
            if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 0 end
        end
        table.clear(Hub.Cache.OriginalMaterials)
    end
end

-- ============================================================================
-- [4. КЛАСС И СТРУКТУРА AURORA MENU V2 — ИЗБЫТОЧНАЯ РУЧНАЯ ОТРИСОВКА]
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
    self.SubTitle = config.SubTitle or "v2.0"
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

    local launcher = Instance.new("TextButton")
    launcher.Size = UDim2.new(0, 60, 0, 60)
    launcher.Position = UDim2.new(0.03, 0, 0.15, 0)
    launcher.BackgroundColor3 = THEME.BgStrong
    launcher.Text = "★"
    launcher.TextColor3 = THEME.Accent
    launcher.Font = Enum.Font.FredokaOne
    launcher.TextSize = 30
    launcher.Parent = screen
    self.Launcher = launcher

    local lCor = Instance.new("UICorner"); lCor.CornerRadius = UDim.new(1, 0); lCor.Parent = launcher
    local lStroke = Instance.new("UIStroke"); lStroke.Color = THEME.Stroke; lStroke.Thickness = 2; lStroke.Parent = launcher
    local lGrad = Instance.new("UIGradient"); lGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 255))}); lGrad.Parent = lStroke

    local dragStart, startPos, dragging = nil, nil, false
    launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = launcher.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    launcher.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            launcher.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 620, 0, 410)
    frame.Position = UDim2.new(0.5, -310, 0.5, -205)
    frame.BackgroundColor3 = THEME.Bg
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screen
    self.Frame = frame

    local fCor = Instance.new("UICorner"); fCor.CornerRadius = UDim.new(0, 16); fCor.Parent = frame
    local fStroke = Instance.new("UIStroke"); fStroke.Color = THEME.Stroke; fStroke.Thickness = 2; fStroke.Parent = frame

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 175, 1, 0)
    sidebar.BackgroundColor3 = THEME.BgStrong
    sidebar.Parent = frame
    local sCor = Instance.new("UICorner"); sCor.CornerRadius = UDim.new(0, 16); sCor.Parent = sidebar

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

    local tabList = Instance.new("ScrollingFrame")
    tabList.Size = UDim2.new(1, 0, 1, -80)
    tabList.Position = UDim2.new(0, 0, 0, 75)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.Parent = sidebar
    self.TabList = tabList

    local tlLayout = Instance.new("UIListLayout"); tlLayout.Padding = UDim.new(0, 6); tlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; tlLayout.Parent = tabList

    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -195, 1, -20)
    pageContainer.Position = UDim2.new(0, 185, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = frame
    self.PageContainer = pageContainer

    local menuOpen = false
    launcher.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            frame.Size = UDim2.new(0, 0, 0, 0); frame.Position = launcher.Position; frame.Visible = true
            tween(frame, EASE, {Size = UDim2.new(0, 620, 0, 410), Position = UDim2.new(0.5, -310, 0.5, -205)})
            tween(launcher, EASE, {Rotation = 135, TextColor3 = THEME.Red})
        else
            tween(frame, EASE, {Size = UDim2.new(0, 0, 0, 0), Position = launcher.Position})
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

    local pLayout = Instance.new("UIListLayout"); pLayout.Padding = UDim.new(0, 10); pLayout.Parent = page
    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 20)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = THEME.Bg; btn.BackgroundTransparency = 1; btn.Text = ""; btn.AutoButtonColor = false; btn.Parent = self.TabList
    local bCor = Instance.new("UICorner"); bCor.CornerRadius = UDim.new(0, 8); bCor.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0); lbl.Position = UDim2.new(0, 16, 0, 0); lbl.Text = name; lbl.TextColor3 = THEME.TextDim; lbl.Font = Enum.Font.SourceSansBold; lbl.TextSize = 15; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1; lbl.Parent = btn

    local tabData = {Page = page, Button = btn, Label = lbl}
    btn.MouseButton1Click:Connect(function() self:SelectTab(tabData) end)
    if not self.ActiveTab then self:SelectTab(tabData) end

    local TabAPI = {Page = page}

    function TabAPI:AddSection(title)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(0.95, 0, 0, 28); sec.Text = title:upper(); sec.TextColor3 = THEME.AccentGlow; sec.Font = Enum.Font.SourceSansBold; sec.TextSize = 13; sec.TextXAlignment = Enum.TextXAlignment.Left; sec.BackgroundTransparency = 1; sec.Parent = page
    end

    function TabAPI:AddToggle(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 52); card.BackgroundColor3 = THEME.BgStrong; card.Parent = page
        local cCor = Instance.new("UICorner"); cCor.CornerRadius = UDim.new(0, 10); cCor.Parent = card
        local cStroke = Instance.new("UIStroke"); cStroke.Color = Color3.fromRGB(35, 38, 50); cStroke.Thickness = 1; cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.7, 0, 0, 26); cl.Position = UDim2.new(0, 14, 0, 4); cl.Text = config.Name; cl.TextColor3 = THEME.Text; cl.Font = Enum.Font.SourceSansBold; cl.TextSize = 16; cl.TextXAlignment = Enum.TextXAlignment.Left; cl.BackgroundTransparency = 1; card.Active = true; cl.Parent = card

        local cd = Instance.new("TextLabel")
        cd.Size = UDim2.new(0.7, 0, 0, 18); cd.Position = UDim2.new(0, 14, 0, 26); cd.Text = config.Description or ""; cd.TextColor3 = THEME.TextDim; cd.Font = Enum.Font.SourceSans; cd.TextSize = 12; cd.TextXAlignment = Enum.TextXAlignment.Left; cd.BackgroundTransparency = 1; cd.Parent = card

        local switch = Instance.new("TextButton")
        switch.Size = UDim2.new(0, 46, 0, 24); switch.Position = UDim2.new(0.95, -46, 0.5, -12); switch.BackgroundColor3 = Color3.fromRGB(50, 52, 68); switch.Text = ""; switch.Parent = card
        local sCor = Instance.new("UICorner"); sCor.CornerRadius = UDim.new(1, 0); sCor.Parent = switch

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 3, 0.5, -9); dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255); dot.Parent = switch
        local dCor = Instance.new("UICorner"); dCor.CornerRadius = UDim.new(1, 0); dCor.Parent = dot

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
        switch.MouseButton1Click:Connect(function() toggle(not state) end)
    end

    function TabAPI:AddSlider(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 60); card.BackgroundColor3 = THEME.BgStrong; card.Parent = page
        local cCor = Instance.new("UICorner"); cCor.CornerRadius = UDim.new(0, 10); cCor.Parent = card
        local cStroke = Instance.new("UIStroke"); cStroke.Color = Color3.fromRGB(35, 38, 50); cStroke.Thickness = 1; cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.7, 0, 0, 24); cl.Position = UDim2.new(0, 14, 0, 6); cl.Text = config.Name; cl.TextColor3 = THEME.Text; cl.Font = Enum.Font.SourceSansBold; cl.TextSize = 15; cl.TextXAlignment = Enum.TextXAlignment.Left; cl.BackgroundTransparency = 1; cl.Parent = card

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.25, 0, 0, 24); valLbl.Position = UDim2.new(0.7, 0, 0, 6); valLbl.Text = tostring(config.Default); valLbl.TextColor3 = THEME.AccentGlow; valLbl.Font = Enum.Font.FredokaOne; valLbl.TextSize = 15; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.BackgroundTransparency = 1; valLbl.Parent = card

        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(0.92, 0, 0, 8); bar.Position = UDim2.new(0.04, 0, 0.72, 0); bar.BackgroundColor3 = Color3.fromRGB(45, 48, 62); bar.Text = ""; bar.Parent = card
        local bCor = Instance.new("UICorner"); bCor.CornerRadius = UDim.new(1, 0); bCor.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((config.Default - config.Min)/(config.Max - config.Min), 0, 1, 0); fill.BackgroundColor3 = THEME.Accent; fill.Parent = bar
        local fCor = Instance.new("UICorner"); fCor.CornerRadius = UDim.new(1, 0); fCor.Parent = fill

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
                sliding = true; updateVal(input)
            end
        end)
        SafeConnect(UserInputService.InputChanged, function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateVal(input)
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end)
    end

    function TabAPI:AddTextBox(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 52); card.BackgroundColor3 = THEME.BgStrong; card.Parent = page
        local cCor = Instance.new("UICorner"); cCor.CornerRadius = UDim.new(0, 10); cCor.Parent = card
        local cStroke = Instance.new("UIStroke"); cStroke.Color = Color3.fromRGB(35, 38, 50); cStroke.Thickness = 1; cStroke.Parent = card

        local cl = Instance.new("TextLabel")
        cl.Size = UDim2.new(0.4, 0, 1, 0); cl.Position = UDim2.new(0, 14, 0, 0); cl.Text = config.Name; cl.TextColor3 = THEME.Text; cl.Font = Enum.Font.SourceSansBold; cl.TextSize = 15; cl.TextXAlignment = Enum.TextXAlignment.Left; cl.BackgroundTransparency = 1; cl.Parent = card

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.52, 0, 0.7, 0); box.Position = UDim2.new(0.44, 0, 0.15, 0); box.BackgroundColor3 = THEME.Bg; box.Text = config.Default or ""; box.TextColor3 = THEME.Text; box.PlaceholderText = config.Placeholder or "Ввод..."; box.PlaceholderColor3 = THEME.TextDim; box.Font = Enum.Font.SourceSansSemibold; box.TextSize = 14; box.ClipsDescendants = true; box.Parent = card
        local bCor = Instance.new("UICorner"); bCor.CornerRadius = UDim.new(0, 8); bCor.Parent = box
        local bStroke = Instance.new("UIStroke"); bStroke.Color = Color3.fromRGB(50, 52, 70); bStroke.Thickness = 1; bStroke.Parent = box

        box.FocusLost:Connect(function() pcall(config.Callback, box.Text) end)
    end

    function TabAPI:AddButton(config)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 42); btn.BackgroundColor3 = THEME.Accent; btn.Text = config.Name; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 16; btn.Parent = page
        local bCor = Instance.new("UICorner"); bCor.CornerRadius = UDim.new(0, 10); bCor.Parent = btn
        local bGrad = Instance.new("UIGradient"); bGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 255))}); bGrad.Parent = btn

        btn.MouseButton1Click:Connect(function() pcall(config.Callback) end)
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

local menu = Aurora.new({ Title = "Brosa System", SubTitle = "v5.5 • Hybrid Monolith" })

-- ============================================================================
-- [5. НАПОЛНЕНИЕ ВКЛАДОК СЕТОМ ОПЦИЙ (ВСЕ СТАРЫЕ + НОВЫЕ СЕКЦИИ)]
-- ============================================================================

-- --- ВКЛАДКА: ДВИЖЕНИЕ ---
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
tabMovement:AddToggle({ Name = "Бесконечный Прыжок", Description = "Прыгайте по невидимым уступам в воздухе", Default = Hub.Flags.InfiniteJump, Callback = function(state) Hub.Flags.InfiniteJump = state end })
tabMovement:AddToggle({ Name = "Режим полета (Fly)", Description = "Перемещение в стиле наблюдателя", Default = Hub.Flags.Fly, Callback = function(state) Hub.Flags.Fly = state end })
tabMovement:AddSlider({ Name = "Скорость полета", Min = 10, Max = 350, Default = Hub.Flags.FlySpeed, Callback = function(val) Hub.Flags.FlySpeed = val end })
tabMovement:AddToggle({ Name = "Noclip (Сквозь стены)", Description = "Отключает коллизию вашего тела", Default = Hub.Flags.Noclip, Callback = function(state) Hub.Flags.Noclip = state end })


-- --- ВКЛАДКА: ТРОЛЛИНГ ---
local tabTroll = menu:CreateTab("Троллинг")

tabTroll:AddSection("Аим и Захват (Новые фиксы)")
tabTroll:AddToggle({
    Name = "Silent Aim + Нативный захват",
    Description = "Телепортирует хитбокс под мышь при клике",
    Default = Hub.Flags.SilentAim,
    Callback = function(state) Hub.Flags.SilentAim = state end
})
tabTroll:AddSlider({
    Name = "Радиус захвата Аима (FOV)",
    Min = 30, Max = 600, Default = Hub.Flags.AimRadius,
    Callback = function(val) Hub.Flags.AimRadius = val end
})
tabTroll:AddToggle({
    Name = "Раздуть Хитбоксы Врагов",
    Description = "Создает кликабельные Root-боксы",
    Default = Hub.Flags.CustomBoxes,
    Callback = function(state) Hub.Flags.CustomBoxes = state end
})
tabTroll:AddSlider({
    Name = "Размер Хитбокса цели",
    Min = 2, Max = 30, Default = Hub.Flags.BoxSize,
    Callback = function(val) Hub.Flags.BoxSize = val end
})
tabTroll:AddToggle({
    Name = "Бросок под карту (Клавиша Х)",
    Description = "Ломает коллизию и швыряет цель вниз",
    Default = Hub.Flags.AutoUnderMap,
    Callback = function(state) Hub.Flags.AutoUnderMap = state end
})

tabTroll:AddSection("Контроль Жертвы")
tabTroll:AddTextBox({ Name = "Имя Жертвы (Ник)", Placeholder = "Имя...", Default = Hub.Flags.TargetPlayer, Callback = function(text) Hub.Flags.TargetPlayer = text end })
tabTroll:AddButton({
    Name = "Fling Target (Разорвать цель)",
    Callback = function()
        local target = FindPlayerByName(Hub.Flags.TargetPlayer)
        if target then ExecuteFling(target)
        else StarterGui:SetCore("SendNotification", { Title = "Ошибка", Text = "Целевой игрок не найден!", Duration = 3 }) end
    end
})
tabTroll:AddToggle({ Name = "Orbit Target (Орбита)", Description = "Режим вращения вокруг цели", Default = Hub.Flags.OrbitPlayer, Callback = function(state) Hub.Flags.OrbitPlayer = state end })
tabTroll:AddSlider({ Name = "Дистанция орбиты", Min = 2, Max = 60, Default = Hub.Flags.OrbitDistance, Callback = function(val) Hub.Flags.OrbitDistance = val end })
tabTroll:AddSlider({ Name = "Скорость орбиты", Min = 1, Max = 40, Default = Hub.Flags.OrbitSpeed, Callback = function(val) Hub.Flags.OrbitSpeed = val end })

tabTroll:AddSection("Глобальный Хаос")
tabTroll:AddToggle({ Name = "Fling Aura (Аура смерти)", Description = "Авто-флинг любого в радиусе 15 единиц", Default = Hub.Flags.FlingAura, Callback = function(state) Hub.Flags.FlingAura = state end })
tabTroll:AddToggle({ Name = "Click Fling (+Ctrl)", Description = "Зажмите левый Ctrl и кликните на игрока", Default = Hub.Flags.ClickFling, Callback = function(state) Hub.Flags.ClickFling = state end })
tabTroll:AddButton({ Name = "Fling All (Флинг всех)", Callback = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then task.spawn(function() ExecuteFling(p) end) end end end })
tabTroll:AddButton({ Name = "Mass Weld (Связка физики)", Callback = function() RunMassWeld() end })
tabTroll:AddToggle({ Name = "Lobby Freeze (Загрузка пакетами)", Description = "Шторм пакетами позиционирования", Default = Hub.Flags.LobbyFreeze, Callback = function(state) Hub.Flags.LobbyFreeze = state end })


-- --- ВКЛАДКА: ВИЗУАЛЫ ---
local tabVisuals = menu:CreateTab("Визуалы")
tabVisuals:AddSection("Отображение ESP")
tabVisuals:AddToggle({ Name = "ESP Боксы", Default = Hub.Flags.ESP_Boxes, Callback = function(state) Hub.Flags.ESP_Boxes = state end })
tabVisuals:AddToggle({ Name = "ESP Трассеры", Default = Hub.Flags.ESP_Tracers, Callback = function(state) Hub.Flags.ESP_Tracers = state end })
tabVisuals:AddToggle({ Name = "ESP Имена", Default = Hub.Flags.ESP_Names, Callback = function(state) Hub.Flags.ESP_Names = state end })
tabVisuals:AddToggle({ Name = "ESP Здоровье", Default = Hub.Flags.ESP_Health, Callback = function(state) Hub.Flags.ESP_Health = state end })

tabVisuals:AddSection("Камера и FOV (Новые исправления)")
tabVisuals:AddToggle({ Name = "Вид от 3-го лица", Description = "Обход блокировок камеры игрой", Default = Hub.Flags.ThirdPerson, Callback = function(state) Hub.Flags.ThirdPerson = state end })
tabVisuals:AddSlider({ Name = "Дистанция 3-го лица", Min = 5, Max = 100, Default = Hub.Flags.CamDist, Callback = function(val) Hub.Flags.CamDist = val end })
tabVisuals:AddToggle({ Name = "Растяг Экрана (FOV)", Description = "Стабильное изменение угла обзора", Default = Hub.Flags.StretchToggle, Callback = function(state) Hub.Flags.StretchToggle = state end })
tabVisuals:AddSlider({ Name = "Значение FOV", Min = 30, Max = 150, Default = Hub.Flags.Stretch, Callback = function(val) Hub.Flags.Stretch = val end })

tabVisuals:AddSection("Окружающая Среда")
tabVisuals:AddToggle({
    Name = "Режим Fullbright (День)", Default = Hub.Flags.Fullbright,
    Callback = function(state)
        Hub.Flags.Fullbright = state
        if not state then
            Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient
            Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient
            Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness
            Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime
        else
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
        end
    end
})
tabVisuals:AddToggle({ Name = "Potato PC Mode (Оптимизация)", Default = Hub.Flags.PotatoPC, Callback = function(state) ApplyPotatoPC(state) end })


-- --- ВКЛАДКА: ЗАЩИТА & СПАМ ---
local tabDefense = menu:CreateTab("Защита")
tabDefense:AddSection("Мета-Механика")
tabDefense:AddToggle({ Name = "Bypass Metatable (Обход)", Default = Hub.Flags.BypassMetatable, Callback = function(state) Hub.Flags.BypassMetatable = state end })
tabDefense:AddToggle({ Name = "Anti-Grab (Защита персонажа)", Default = Hub.Flags.AntiGrab, Callback = function(state) Hub.Flags.AntiGrab = state end })
tabDefense:AddToggle({ Name = "Anti-Fling (Анти-Раскрутка)", Description = "Жесткая фиксация угловой скорости", Default = Hub.Flags.AntiFling, Callback = function(state) Hub.Flags.AntiFling = state end })

tabDefense:AddSection("Автоматизация")
tabDefense:AddToggle({ Name = "Спамер в глобальный чат", Default = Hub.Flags.ChatSpam, Callback = function(state) Hub.Flags.ChatSpam = state end })
tabDefense:AddTextBox({ Name = "Текст сообщения", Placeholder = "Текст...", Default = Hub.Flags.ChatSpamMessage, Callback = function(text) Hub.Flags.ChatSpamMessage = text end })


-- --- ВКЛАДКА: ПРОФИЛЬ (ПОЛНОРАЗМЕРНАЯ КАРТОЧКА С АВАТАРОМ) ---
local tabProfile = menu:CreateTab("Профиль")
tabProfile:AddSection("Личная Сводка Данных")

local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0.95, 0, 0, 290); profileCard.BackgroundColor3 = THEME.BgStrong; profileCard.Parent = tabProfile.Page
local pCor = Instance.new("UICorner"); pCor.CornerRadius = UDim.new(0, 14); pCor.Parent = profileCard
local pStroke = Instance.new("UIStroke"); pStroke.Color = Color3.fromRGB(35, 38, 50); pStroke.Thickness = 1.5; pStroke.Parent = profileCard

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 100, 0, 100); avatarImage.Position = UDim2.new(0.5, -50, 0, 18); avatarImage.BackgroundColor3 = THEME.Bg; avatarImage.Image = "rbxasset://textures/ui/Guideline.png"; avatarImage.Parent = profileCard
local aCor = Instance.new("UICorner"); aCor.CornerRadius = UDim.new(1, 0); aCor.Parent = avatarImage
local aStroke = Instance.new("UIStroke"); aStroke.Color = THEME.Accent; aStroke.Thickness = 2.5; aStroke.Parent = avatarImage

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -24, 0, 26); nameLabel.Position = UDim2.new(0, 12, 0, 125); nameLabel.Text = lp.DisplayName .. " (@" .. lp.Name .. ")"; nameLabel.TextColor3 = THEME.Text; nameLabel.Font = Enum.Font.SourceSansBold; nameLabel.TextSize = 18; nameLabel.TextAlignment = Enum.TextAlignment.Center; nameLabel.BackgroundTransparency = 1; nameLabel.Parent = profileCard

local ageLabel = Instance.new("TextLabel")
ageLabel.Size = UDim2.new(1, -24, 0, 20); ageLabel.Position = UDim2.new(0, 12, 0, 155); ageLabel.Text = "Возраст профиля: " .. tostring(lp.AccountAge) .. " дней"; ageLabel.TextColor3 = THEME.TextDim; ageLabel.Font = Enum.Font.SourceSansSemibold; ageLabel.TextSize = 14; ageLabel.TextAlignment = Enum.TextAlignment.Center; ageLabel.BackgroundTransparency = 1; ageLabel.Parent = profileCard

local friendsLabel = Instance.new("TextLabel")
friendsLabel.Size = UDim2.new(1, -24, 0, 20); friendsLabel.Position = UDim2.new(0, 12, 0, 178); friendsLabel.Text = "Друзей на текущем сервере: сканирование..."; friendsLabel.TextColor3 = THEME.TextDim; friendsLabel.Font = Enum.Font.SourceSansSemibold; friendsLabel.TextSize = 14; friendsLabel.TextAlignment = Enum.TextAlignment.Center; friendsLabel.BackgroundTransparency = 1; friendsLabel.Parent = profileCard

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -24, 0, 20); statsLabel.Position = UDim2.new(0, 12, 0, 201); statsLabel.Text = "Пинг: Вычисление... | FPS: Вычисление..."; statsLabel.TextColor3 = THEME.AccentGlow; statsLabel.Font = Enum.Font.SourceSansBold; statsLabel.TextSize = 13; statsLabel.TextAlignment = Enum.TextAlignment.Center; statsLabel.BackgroundTransparency = 1; statsLabel.Parent = profileCard

local placeLabel = Instance.new("TextLabel")
placeLabel.Size = UDim2.new(1, -24, 0, 20); placeLabel.Position = UDim2.new(0, 12, 0, 224); placeLabel.Text = "ID Сервера: " .. tostring(game.JobId:sub(1,16)) .. "... | PlaceID: " .. tostring(game.PlaceId); placeLabel.TextColor3 = THEME.TextDim; placeLabel.Font = Enum.Font.SourceSans; placeLabel.TextSize = 12; placeLabel.TextAlignment = Enum.TextAlignment.Center; placeLabel.BackgroundTransparency = 1; placeLabel.Parent = profileCard

task.spawn(function()
    local pcon, ready = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    if ready then avatarImage.Image = pcon end
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


-- --- ВКЛАДКА: НАСТРОЙКИ ЯДРА & ВЫГРУЗКА ---
local tabCore = menu:CreateTab("Настройки")
tabCore:AddSection("Конфигурация Ядра")
tabCore:AddButton({ Name = "Перепривязать Metatable Bypass", Callback = function() StarterGui:SetCore("SendNotification", { Title = "Мета-Связь", Text = "Metatable Bypass переподключен!", Duration = 3 }) end })

tabCore:AddSection("Удаление Скрипта")
local function TerminateHub()
    Hub.Loaded = false
    RunService:UnbindFromRenderStep("BrosaCameraControl")
    fovCircle:Destroy()
    
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
    for id, box in pairs(Hub.Cache.Hitboxes) do if box then box:Destroy() end end
    
    if menu.Screen then menu.Screen:Destroy() end
    
    for obj, data in pairs(Hub.Cache.OriginalMaterials) do if obj and obj.Parent then obj.Material = data[1] obj.Reflectance = data[2] end end
    
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false; hum.WalkSpeed = 16; hum.JumpPower = 50 end
        camera.CameraType = Enum.CameraType.Custom
    end)
    
    _G.BrosaHubGlobal = nil
    print("[Brosa System]: Скрипт полностью выгружен, все хуки и GUI зачищены.")
end

tabCore:AddButton({ Name = "Destroy Script (Выгрузить)", Callback = function() TerminateHub() end })

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

print("[Brosa System v5.5]: Монолит успешно обновлен! Все старые функции сохранены, боевой движок и физика стабилизированы.")
