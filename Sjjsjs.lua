--[[
    ================================================================================
    👑 BROSA SYSTEM v6.0 — PRIVATE UNLIMITED MONOLITHIC HYBRID SCRIPT HUB
    🎨 CORE GUI INTERFACE: AURORA MENU v3 (REMASTERED EXPANDED EDITION)
    🔒 STATUS: UNDETECTED | BYPASS: ACTIVE | OPTIMIZED FOR DELTA/HYDROGEN/FLUXUS
    ================================================================================
]]

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

local lp = Players.LocalPlayer
if not lp.Character then 
    lp.CharacterAdded:Wait() 
end
local camera = workspace.CurrentCamera

-- Инициализация розтяга экрана по ТЗ
getgenv().Resolution = {
    [".gg/scripters"] = 1.0 -- По умолчанию 1.0 (без растяжения), можно менять в меню
}

if getgenv().gg_scripters == nil then
    game:GetService("RunService").RenderStepped:Connect(
        function()
            if camera and getgenv().Resolution[".gg/scripters"] ~= 1.0 then
                camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
            end
        end
    )
end
getgenv().gg_scripters = "Aori0001"

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
        ChatSpamMessage = "Brosa System v6.0 on Top!",
        AutoFarm = false,

        -- НОВЫЕ ФУНКЦИИ ЗАХВАТА & АИМА
        GrabAimbot = false,
        ShowFovCircle = true,
        FarThrow = false,
        SnaplinesEnabled = false,
        AutoCounterGrab = false,
        UnGrabable = false,
        CarGrabAll = false,
        AutoCounterMethod = "Sky" -- "Sky" или "Underground"
    },
    Options = {
        GrabFovRadius = 150,
        GrabMaxDistance = 250,
        ThrowForce = 900000, -- Сверх-сила для дальнего броска
        GrabFovColor = Color3.fromRGB(255, 60, 60), -- Новый агрессивный цвет прицела
        LineColor = Color3.fromRGB(255, 60, 60),
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
        LastSafeCFrame = nil,
        GrabbedPlayersTracker = {}
    }
}

local Hub = _G.BrosaHubGlobal

-- Безопасное подключение событий
local function SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Hub.Cache.Connections, connection)
    return connection
end

-- Вспомогательные функции
local function getChar() return lp.Character end
local function getRoot() return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end

--============================================================
-- ТОКЕНЫ ДИЗАЙНА AURORA MENU V3 (ОБНОВЛЕННЫЙ ВИЗУАЛ)
--============================================================
local THEME = {
    Bg          = Color3.fromRGB(15, 15, 20),
    BgStrong    = Color3.fromRGB(22, 22, 28),
    Stroke      = Color3.fromRGB(80, 80, 95),
    Text        = Color3.fromRGB(255, 255, 255),
    TextDim     = Color3.fromRGB(170, 170, 180),
    AccentA     = Color3.fromRGB(255, 60, 80),  -- Новый красный/розовый неон
    AccentB     = Color3.fromRGB(255, 120, 80),
    Danger      = Color3.fromRGB(255, 50, 50),
    Success     = Color3.fromRGB(50, 255, 130),
}

local SPRING = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local EASE   = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ОТРИСОВКИ GUI
--============================================================
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(parent, radius) return new("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent }) end
local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", { Color = color or THEME.Stroke, Thickness = thickness or 1, Transparency = transparency or 0.8, Parent = parent })
end
local function gradient(parent, rotation)
    return new("UIGradient", { Color = ColorSequence.new(THEME.AccentA, THEME.AccentB), Rotation = rotation or 45, Parent = parent })
end
local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function viewportSize()
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

--============================================================
-- УНИВЕРСАЛЬНОЕ ПЕРЕТАСКИВАНИЕ
--============================================================
local function makeDraggable(handle, target, opts)
    opts = opts or {}
    local dragging, dragInput, dragStart, startPos, moved

    local function clamp(pos)
        if not opts.Clamp then return pos end
        local vp = viewportSize()
        local size = target.AbsoluteSize
        local x = math.clamp(pos.X.Offset, 0, math.max(0, vp.X - size.X))
        local y = math.clamp(pos.Y.Offset, 0, math.max(0, vp.Y - size.Y))
        return UDim2.new(0, x, 0, y)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = target.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if opts.OnEnd then opts.OnEnd(moved) end
                    conn:Disconnect()
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then moved = true end
            local newPos = UDim2.new(
                0, startPos.X.Offset + delta.X,
                0, startPos.Y.Offset + delta.Y
            )
            newPos = clamp(newPos)
            target.Position = newPos
            if opts.OnMove then opts.OnMove(newPos) end
        end
    end)
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

SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    
    -- Noclip
    if Hub.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Anti-Grab
    if Hub.Flags.AntiGrab then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    end

    -- Un-Grabable
    if Hub.Flags.UnGrabable then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
            if part:IsA("Weld") or part:IsA("WeldConstraint") or part:IsA("TouchTransmitter") then
                local other = (part.Part0 and part.Part0:IsDescendantOf(char)) and part.Part1 or part.Part0
                if other and not other:IsDescendantOf(char) then
                    part:Destroy()
                end
            end
        end
    end
end)

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

SafeConnect(UserInputService.JumpRequest, function()
    if Hub.Flags.InfiniteJump then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

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

local function DrawESP(player)
    if player == lp then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = THEME.AccentA
    box.Thickness = 1.5
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = THEME.AccentA
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
                        box.Color = THEME.AccentA
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
-- [4. ЭЛИТНЫЙ ФИЗИЧЕСКИЙ ДВИЖОК СТРОГОГО ЗАХВАТА & АИМ-ЗАХВАТА]
-- ============================================================================

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Visible = false

local snapLine = Drawing.new("Line")
snapLine.Thickness = 2
snapLine.Visible = false

local currentGrabbedPlayer = nil

local function getClosestPlayerInStrictFOV(maxFovRadius, maxDistance)
    local closestTarget = nil
    local shortestDistance = maxFovRadius
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local root = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 then
                local myRoot = getRoot()
                if myRoot then
                    local distanceToMe = (root.Position - myRoot.Position).Magnitude
                    if distanceToMe <= maxDistance then
                        local screenPos, onScreen = camera:WorldToScreenPoint(root.Position)
                        if onScreen then
                            local vectorPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distFromCenter = (vectorPos - screenCenter).Magnitude
                            if distFromCenter <= maxFovRadius and distFromCenter < shortestDistance then
                                shortestDistance = distFromCenter
                                closestTarget = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

SafeConnect(RunService.RenderStepped, function()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    if Hub.Flags.GrabAimbot and Hub.Flags.ShowFovCircle then
        fovCircle.Visible = true
        fovCircle.Radius = Hub.Options.GrabFovRadius
        fovCircle.Position = screenCenter
        fovCircle.Color = Hub.Options.GrabFovColor
    else
        fovCircle.Visible = false
    end

    if Hub.Flags.GrabAimbot and Hub.Flags.SnaplinesEnabled then
        local target = getClosestPlayerInStrictFOV(Hub.Options.GrabFovRadius, Hub.Options.GrabMaxDistance)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToScreenPoint(targetRoot.Position)
            if onScreen then
                snapLine.From = screenCenter
                snapLine.To = Vector2.new(screenPos.X, screenPos.Y)
                snapLine.Color = Hub.Options.LineColor
                snapLine.Visible = true
            else
                snapLine.Visible = false
            end
        else
            snapLine.Visible = false
        end
    else
        snapLine.Visible = false
    end
end)

-- Взаимодействие с внутриигровым захватом и броском
-- Silent Aim: если мы кликаем, берем ближайшего
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if Hub.Flags.GrabAimbot then
            local target = getClosestPlayerInStrictFOV(Hub.Options.GrabFovRadius, Hub.Options.GrabMaxDistance)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = getRoot()
                if myRoot then
                    -- Телепортируем цель прямо перед собой, чтобы внутриигровой триггер захвата сработал
                    target.Character.HumanoidRootPart.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                end
            end
        end
    end
end)

-- Логика Далекого броска: Отслеживаем внутриигровой бросок
SafeConnect(RunService.Heartbeat, function()
    local myChar = lp.Character
    if not myChar then return end
    
    -- Сохраняем безопасную позицию для авто-эскейпа
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if myRoot and myRoot.Velocity.Magnitude < 50 then
        Hub.Cache.LastSafeCFrame = myRoot.CFrame
    end

    -- Отслеживаем, кого мы держим (welds)
    local currentlyHolding = {}
    for _, part in ipairs(myChar:GetDescendants()) do
        if part:IsA("Weld") or part:IsA("WeldConstraint") or part:IsA("Constraint") then
            local p0, p1 = part.Part0, part.Part1
            local otherPart = (p0 and p0:IsDescendantOf(myChar)) and p1 or p0
            
            if otherPart and otherPart.Parent then
                local otherModel = otherPart:FindFirstAncestorOfClass("Model")
                if otherModel and otherModel ~= myChar and Players:GetPlayerFromCharacter(otherModel) then
                    currentlyHolding[otherModel] = true
                    Hub.Cache.GrabbedPlayersTracker[otherModel] = true
                end
            end
        end
    end

    -- Если FarThrow включен, и мы только что ОТПУСТИЛИ (бросили) игрока через внутриигровую кнопку
    if Hub.Flags.FarThrow then
        for oldModel, _ in pairs(Hub.Cache.GrabbedPlayersTracker) do
            if not currentlyHolding[oldModel] then
                -- Мы отпустили этого игрока! Запускаем за карту!
                local targetRoot = oldModel:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    targetRoot.AssemblyLinearVelocity = camera.CFrame.LookVector * Hub.Options.ThrowForce + Vector3.new(0, Hub.Options.ThrowForce/3, 0)
                end
                Hub.Cache.GrabbedPlayersTracker[oldModel] = nil
            end
        end
    else
        -- Очищаем трекер, если функция выключена
        Hub.Cache.GrabbedPlayersTracker = currentlyHolding
    end

    -- Логика Авто-Контр Захвата (Escape & Instant Throw/Teleport)
    if Hub.Flags.AutoCounterGrab then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("Weld") or part:IsA("WeldConstraint") or part:IsA("Constraint") then
                local p0, p1 = part.Part0, part.Part1
                local suspectPart = (p0 and p0:IsDescendantOf(myChar)) and p1 or p0
                
                if suspectPart and suspectPart.Parent then
                    local attackerModel = suspectPart:FindFirstAncestorOfClass("Model")
                    -- Если нас кто-то схватил (и это не мы сами держим кого-то)
                    if attackerModel and attackerModel ~= myChar and Players:GetPlayerFromCharacter(attackerModel) then
                        -- Ломаем захват
                        part:Destroy()
                        
                        local attRoot = attackerModel:FindFirstChild("HumanoidRootPart")
                        if attRoot and myRoot then
                            -- Идем в исходное место
                            if Hub.Cache.LastSafeCFrame then
                                myRoot.CFrame = Hub.Cache.LastSafeCFrame
                                myRoot.Velocity = Vector3.new(0,0,0)
                            end

                            -- Отбрасываем обидчика
                            if Hub.Flags.AutoCounterMethod == "Sky" then
                                -- Под углом < 70 градусов в небо
                                attRoot.CFrame = attRoot.CFrame * CFrame.new(0, 10, 0)
                                attRoot.AssemblyLinearVelocity = (Vector3.new(math.random(-1,1), 2, math.random(-1,1))).Unit * 5000
                            else
                                -- Телепорт под карту
                                attRoot.CFrame = CFrame.new(attRoot.Position.X, -5000, attRoot.Position.Z)
                                attRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function ExecuteCarGrabAll()
    local hum = getHum()
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        local seat = hum.SeatPart
        local pullPos = seat.CFrame * CFrame.new(0, 3, -15).Position
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = p.Character.HumanoidRootPart
                tRoot.CFrame = CFrame.new(pullPos)
                tRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Ошибка",
            Text = "Вы должны находиться на сиденье машины!",
            Duration = 3
        })
    end
end

--============================================================
-- КЛАСС И СТРУКТУРА AURORA MENU V3 
--============================================================
local Aurora = {}
Aurora.__index = Aurora

function Aurora.new(config)
    config = config or {}
    local self = setmetatable({}, Aurora)

    self.Title = config.Title or "Aurora"
    self.SubTitle = config.SubTitle or "v3.0 · подключено"
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsOpen = false

    self.Gui = new("ScreenGui", {
        Name = "AuroraMenu_Brosa",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = CoreGui:FindFirstChild("RobloxGui") or lp:WaitForChild("PlayerGui"),
    })

    self:_buildLauncher()
    self:_buildWindow()

    return self
end

function Aurora:_buildLauncher()
    local vp = viewportSize()
    local launcher = new("TextButton", {
        Name = "Launcher",
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(56, 56),
        Position = UDim2.fromOffset(vp.X - 84, vp.Y - 200),
        BackgroundColor3 = THEME.BgStrong,
        BackgroundTransparency = 0.1,
        Parent = self.Gui,
    })
    corner(launcher, 18)
    stroke(launcher, THEME.Stroke, 1, 0.88)

    new("ImageLabel", {
        Image = "rbxassetid://10723407389",
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12),
        BackgroundTransparency = 1,
        ImageColor3 = THEME.AccentA,
        Parent = launcher,
    })

    local badge = new("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(1, -6, 0, -4),
        BackgroundColor3 = THEME.AccentB,
        Parent = launcher,
    })
    corner(badge, 5)

    makeDraggable(launcher, launcher, {
        Clamp = true,
        OnEnd = function(moved)
            if not moved then
                if self.IsOpen then
                    self:Minimize()
                else
                    self:Open()
                end
            end
        end,
    })

    self.Launcher = launcher
end

function Aurora:_buildWindow()
    local window = new("Frame", {
        Name = "Window",
        Size = UDim2.fromOffset(410, 490),
        Position = UDim2.fromOffset(200, 120),
        BackgroundColor3 = THEME.Bg,
        BackgroundTransparency = 0.05,
        ClipsDescendants = true,
        Visible = false,
        Parent = self.Gui,
    })
    corner(window, 20)
    stroke(window, THEME.Stroke, 1, 0.7)

    local scale = new("UIScale", { Scale = 0.12, Parent = window })
    self.WindowScale = scale
    self.Window = window

    local header = new("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, Parent = window })
    new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = THEME.Stroke, BackgroundTransparency = 0.9, Parent = header })

    local titleWrap = new("Frame", { Size = UDim2.new(1, -84, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1, Parent = header })
    new("TextLabel", { Text = self.Title, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 9), BackgroundTransparency = 1, Parent = titleWrap })
    new("TextLabel", { Text = self.SubTitle, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = THEME.AccentA, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 28), BackgroundTransparency = 1, Parent = titleWrap })

    local minimizeBtn = self:_headerIconButton(header, "—", THEME.Text, UDim2.new(1, -72, 0, 11))
    local closeBtn    = self:_headerIconButton(header, "×", THEME.Danger, UDim2.new(1, -38, 0, 11))
    minimizeBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    closeBtn.MouseButton1Click:Connect(function() self:CloseForever() end)

    makeDraggable(header, window, { Clamp = false })

    local mainArea = new("Frame", { Size = UDim2.new(1, 0, 1, -52), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1, Parent = window })

    local sidebar = new("Frame", {
        Size = UDim2.new(0, 75, 1, 0),
        BackgroundColor3 = THEME.BgStrong,
        BackgroundTransparency = 0.3,
        Parent = mainArea,
    })
    new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = THEME.Stroke, BackgroundTransparency = 0.9, Parent = sidebar })
    local sideList = new("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 8),
        Parent = sidebar,
    })
    new("UIPadding", { PaddingTop = UDim.new(0, 14), Parent = sidebar })
    self.Sidebar = sidebar

    local content = new("Frame", {
        Size = UDim2.new(1, -75, 1, 0),
        Position = UDim2.fromOffset(75, 0),
        BackgroundTransparency = 1,
        Parent = mainArea,
    })
    self.Body = content
end

function Aurora:_headerIconButton(parent, glyph, color, position)
    local btn = new("TextButton", {
        Text = glyph, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = color,
        Size = UDim2.fromOffset(28, 28), Position = position,
        BackgroundColor3 = THEME.BgStrong, BackgroundTransparency = 0.2,
        AutoButtonColor = false, Parent = parent,
    })
    corner(btn, 9)
    btn.MouseEnter:Connect(function() tween(btn, FAST, { BackgroundTransparency = 0.0 }) end)
    btn.MouseLeave:Connect(function() tween(btn, FAST, { BackgroundTransparency = 0.2 }) end)
    return btn
end

function Aurora:Open()
    if self.IsOpen then return end
    self.IsOpen = true

    local lpPos = self.Launcher.AbsolutePosition
    local ls = self.Launcher.AbsoluteSize
    local ws = self.Window.AbsoluteSize
    local vp = viewportSize()

    local targetX = math.clamp(lpPos.X + ls.X - ws.X, 8, vp.X - ws.X - 8)
    local targetY = math.clamp(lpPos.Y + ls.Y - ws.Y, 8, vp.Y - ws.Y - 8)
    self.Window.Position = UDim2.fromOffset(targetX, targetY)

    tween(self.Launcher, FAST, { BackgroundTransparency = 1 })
    self.Launcher.Visible = false
    self.Window.Visible = true

    self.WindowScale.Scale = 0.1
    tween(self.WindowScale, SPRING, { Scale = 1 })
end

function Aurora:Minimize()
    if not self.IsOpen then return end
    self.IsOpen = false

    local t = tween(self.WindowScale, EASE, { Scale = 0.08 })
    t.Completed:Connect(function()
        self.Window.Visible = false
        self.Launcher.Visible = true
        self.Launcher.BackgroundTransparency = 1
        tween(self.Launcher, EASE, { BackgroundTransparency = 0.1 })
        self:_popLauncher()
    end)
end

function Aurora:_popLauncher()
    local orig = self.Launcher.Size
    self.Launcher.Size = UDim2.fromOffset(orig.X.Offset * 0.6, orig.Y.Offset * 0.6)
    tween(self.Launcher, SPRING, { Size = orig })
end

function Aurora:CloseForever()
    local t = tween(self.WindowScale, EASE, { Scale = 0.05 })
    tween(self.Window, EASE, { BackgroundTransparency = 1 })
    t.Completed:Connect(function()
        local lt = tween(self.Launcher, EASE, { BackgroundTransparency = 1 })
        lt.Completed:Connect(function()
            self.Gui:Destroy()
        end)
    end)
end

function Aurora:CreateTab(name)
    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageTransparency = 0.6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Body,
    })
    new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 14), Parent = page })
    local layout = new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })

    local tabBtn = new("TextButton", {
        Text = "", AutoButtonColor = false,
        Size = UDim2.fromOffset(56, 56),
        BackgroundTransparency = 1,
        Parent = self.Sidebar,
    })
    corner(tabBtn, 16)
    new("TextLabel", {
        Text = name, Font = Enum.Font.GothamBold, TextSize = 9,
        TextColor3 = THEME.TextDim,
        Size = UDim2.new(1, 0, 1, 0),
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = tabBtn,
    })

    local tabData = { Name = name, Page = page, Button = tabBtn, Label = tabBtn:FindFirstChildOfClass("TextLabel"), Order = 0 }
    table.insert(self.Tabs, tabData)

    tabBtn.MouseButton1Click:Connect(function() self:_selectTab(tabData) end)
    if not self.ActiveTab then self:_selectTab(tabData) end

    local api = { _order = 0 }
    local function nextOrder()
        api._order = api._order + 1
        return api._order
    end

    function api:AddSection(title)
        local label = new("TextLabel", {
            Text = string.upper(title),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = THEME.AccentA,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
            Parent = page,
        })
        return label
    end

    function api:AddToggle(opts)
        opts = opts or {}
        local state = opts.Default or false

        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, 58),
            BackgroundColor3 = THEME.BgStrong,
            BackgroundTransparency = 0.4,
            LayoutOrder = nextOrder(),
            Parent = page,
        })
        corner(row, 12)
        local rStroke = stroke(row, THEME.Stroke, 1, 0.8)

        new("TextLabel", { Text = opts.Name or "Функция", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(14, 12), BackgroundTransparency = 1, Parent = row })
        new("TextLabel", { Text = opts.Description or "", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = THEME.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -70, 0, 14), Position = UDim2.fromOffset(14, 30), BackgroundTransparency = 1, Parent = row })

        local switch = new("Frame", { Size = UDim2.fromOffset(44, 24), Position = UDim2.new(1, -56, 0.5, -12), BackgroundColor3 = THEME.Stroke, BackgroundTransparency = 0.5, Parent = row })
        corner(switch, 12)
        local knob = new("Frame", { Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = switch })
        corner(knob, 9)

        local hitbox = new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = row })

        local function render(animated)
            local info = animated and SPRING or TweenInfo.new(0)
            if state then
                tween(switch, EASE, { BackgroundColor3 = THEME.AccentA, BackgroundTransparency = 0 })
                tween(knob, info, { Position = UDim2.fromOffset(23, 3) })
                tween(rStroke, EASE, { Transparency = 0.3 })
            else
                tween(switch, EASE, { BackgroundColor3 = THEME.Stroke, BackgroundTransparency = 0.5 })
                tween(knob, info, { Position = UDim2.fromOffset(3, 3) })
                tween(rStroke, EASE, { Transparency = 0.8 })
            end
        end
        render(false)

        hitbox.MouseButton1Click:Connect(function()
            state = not state
            render(true)
            if opts.Callback then task.spawn(opts.Callback, state) end
        end)
    end

    function api:AddSlider(config)
        local isFloat = config.Float or false
        local card = new("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = THEME.BgStrong,
            BackgroundTransparency = 0.4,
            LayoutOrder = nextOrder(),
            Parent = page
        })
        corner(card, 12)
        stroke(card, THEME.Stroke, 1, 0.8)

        local cl = new("TextLabel", {
            Size = UDim2.new(0.7, 0, 0, 24),
            Position = UDim2.fromOffset(14, 6),
            Text = config.Name,
            TextColor3 = THEME.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Parent = card
        })

        local valLbl = new("TextLabel", {
            Size = UDim2.new(0.25, 0, 0, 24),
            Position = UDim2.new(0.7, 0, 0, 6),
            Text = tostring(config.Default),
            TextColor3 = THEME.AccentA,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            BackgroundTransparency = 1,
            Parent = card
        })

        local bar = new("TextButton", {
            Size = UDim2.new(0.92, 0, 0, 6),
            Position = UDim2.new(0.04, 0, 0.72, 0),
            BackgroundColor3 = THEME.Stroke,
            BackgroundTransparency = 0.5,
            Text = "",
            Parent = card
        })
        corner(bar, 3)

        local fill = new("Frame", {
            Size = UDim2.new((config.Default - config.Min)/(config.Max - config.Min), 0, 1, 0),
            BackgroundColor3 = THEME.AccentA,
            Parent = bar
        })
        corner(fill, 3)

        local sliding = false
        local function updateVal(input)
            local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = config.Min + (config.Max - config.Min) * ratio
            if not isFloat then val = math.floor(val) end
            
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valLbl.Text = isFloat and string.format("%.2f", val) or tostring(val)
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

    function api:AddTextBox(config)
        local card = new("Frame", {
            Size = UDim2.new(1, 0, 0, 52),
            BackgroundColor3 = THEME.BgStrong,
            BackgroundTransparency = 0.4,
            LayoutOrder = nextOrder(),
            Parent = page
        })
        corner(card, 12)
        stroke(card, THEME.Stroke, 1, 0.8)

        local cl = new("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0),
            Position = UDim2.fromOffset(14, 0),
            Text = config.Name,
            TextColor3 = THEME.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Parent = card
        })

        local box = new("TextBox", {
            Size = UDim2.new(0.52, 0, 0.7, 0),
            Position = UDim2.new(0.44, 0, 0.15, 0),
            BackgroundColor3 = THEME.Bg,
            Text = config.Default or "",
            TextColor3 = THEME.AccentA,
            PlaceholderText = config.Placeholder or "Ввод...",
            PlaceholderColor3 = THEME.TextDim,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            ClipsDescendants = true,
            Parent = card
        })
        corner(box, 8)
        stroke(box, THEME.Stroke, 1, 0.5)

        box.FocusLost:Connect(function()
            pcall(config.Callback, box.Text)
        end)
    end

    function api:AddButton(config)
        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = THEME.AccentA,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            LayoutOrder = nextOrder(),
            Parent = page
        })
        corner(btn, 10)
        gradient(btn, 0)

        btn.MouseButton1Click:Connect(function()
            pcall(config.Callback)
        end)
    end
    
    function api:AddDropdown(config)
        local expanded = false
        local card = new("Frame", {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = THEME.BgStrong,
            BackgroundTransparency = 0.4,
            ClipsDescendants = true,
            LayoutOrder = nextOrder(),
            Parent = page
        })
        corner(card, 12)
        stroke(card, THEME.Stroke, 1, 0.8)
        
        local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Text = "", Parent = card })
        new("TextLabel", { Text = config.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1, Parent = btn })
        local valLbl = new("TextLabel", { Text = config.Default or "", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.AccentA, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -130, 0, 0), BackgroundTransparency = 1, Parent = btn })
        
        local list = new("Frame", { Size = UDim2.new(1, 0, 1, -45), Position = UDim2.fromOffset(0, 45), BackgroundTransparency = 1, Parent = card })
        local layout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
        
        for _, opt in ipairs(config.Options) do
            local optBtn = new("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.TextDim, Parent = list })
            optBtn.MouseButton1Click:Connect(function()
                valLbl.Text = opt
                expanded = false
                tween(card, EASE, { Size = UDim2.new(1, 0, 0, 45) })
                pcall(config.Callback, opt)
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            expanded = not expanded
            local h = expanded and (45 + (#config.Options * 30)) or 45
            tween(card, EASE, { Size = UDim2.new(1, 0, 0, h) })
        end)
    end

    function api:AddProfileCard()
        local hero = new("Frame", { Size = UDim2.new(1, 0, 0, 150), BackgroundTransparency = 1, LayoutOrder = nextOrder(), Parent = page })
        local avatar = new("ImageLabel", { Size = UDim2.fromOffset(78, 78), Position = UDim2.new(0.5, -39, 0, 6), BackgroundColor3 = THEME.BgStrong, Parent = hero })
        corner(avatar, 22)

        task.spawn(function()
            local ok, content = pcall(function() return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180) end)
            if ok and content then avatar.Image = content end
        end)

        new("TextLabel", { Text = lp.DisplayName, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = THEME.Text, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(0, 90), BackgroundTransparency = 1, Parent = hero })
        new("TextLabel", { Text = "@" .. lp.Name .. " · ID " .. lp.UserId, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = THEME.TextDim, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 112), BackgroundTransparency = 1, Parent = hero })
    end

    return api
end

function Aurora:_selectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tween(self.ActiveTab.Button, EASE, { BackgroundColor3 = THEME.BgStrong, BackgroundTransparency = 1 })
        tween(self.ActiveTab.Label, EASE, { TextColor3 = THEME.TextDim })
    end
    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tween(tabData.Button, EASE, { BackgroundColor3 = THEME.BgStrong, BackgroundTransparency = 0.5 })
    tween(tabData.Label, EASE, { TextColor3 = THEME.Text })
end

-- Инициализация графического интерфейса Aurora V3
local menu = Aurora.new({ Title = "Brosa System", SubTitle = "v6.0 · Remastered Hub" })

-- ============================================================================
-- [5. НАПОЛНЕНИЕ ВКЛАДОК СЕТОМ ОПЦИЙ]
-- ============================================================================

-- Вкладка: ЗАХВАТ & АИМ (Новая интегрированная вкладка)
local tabGrab = menu:CreateTab("Захват")
tabGrab:AddSection("Основные системы захвата")

tabGrab:AddToggle({
    Name = "Аимбот захват",
    Description = "Кликни по экрану, чтобы схватить игрока в прицеле",
    Default = Hub.Flags.GrabAimbot,
    Callback = function(state) Hub.Flags.GrabAimbot = state end
})

tabGrab:AddToggle({
    Name = "Показывать прицел",
    Description = "Отображает FOV круг на экране",
    Default = Hub.Flags.ShowFovCircle,
    Callback = function(state) Hub.Flags.ShowFovCircle = state end
})

tabGrab:AddToggle({
    Name = "Далекий бросок (Far Throw)",
    Description = "Бросок встроенной кнопкой откидывает игрока за карту",
    Default = Hub.Flags.FarThrow,
    Callback = function(state) Hub.Flags.FarThrow = state end
})

tabGrab:AddToggle({
    Name = "Линия наведения",
    Description = "Линия от центра экрана к ближайшей цели",
    Default = Hub.Flags.SnaplinesEnabled,
    Callback = function(state) Hub.Flags.SnaplinesEnabled = state end
})

tabGrab:AddSection("Защита и Авто-Ответ")

tabGrab:AddToggle({
    Name = "Неудержимый (Иммунитет)",
    Description = "Никто не сможет взять вас (даже на ходу)",
    Default = Hub.Flags.UnGrabable,
    Callback = function(state) Hub.Flags.UnGrabable = state end
})

tabGrab:AddToggle({
    Name = "Авто-Контр Захват",
    Description = "Если тебя берут - обидчик улетает, а ты на исходной",
    Default = Hub.Flags.AutoCounterGrab,
    Callback = function(state) Hub.Flags.AutoCounterGrab = state end
})

tabGrab:AddDropdown({
    Name = "Метод наказания",
    Options = {"Sky", "Underground"},
    Default = Hub.Flags.AutoCounterMethod,
    Callback = function(val) Hub.Flags.AutoCounterMethod = val end
})

tabGrab:AddSection("Настройки аима")

tabGrab:AddSlider({
    Name = "Ширина круга (FOV)", Min = 50, Max = 600, Default = Hub.Options.GrabFovRadius,
    Callback = function(val) Hub.Options.GrabFovRadius = val end
})

tabGrab:AddSlider({
    Name = "Дальность захвата", Min = 50, Max = 1000, Default = Hub.Options.GrabMaxDistance,
    Callback = function(val) Hub.Options.GrabMaxDistance = val end
})

tabGrab:AddButton({
    Name = "Собрать всех в круг (В машине)",
    Callback = function() ExecuteCarGrabAll() end
})


-- Вкладка: ДВИЖЕНИЕ
local tabMovement = menu:CreateTab("Движение")
tabMovement:AddSection("Физические Характеристики")
tabMovement:AddToggle({Name = "Кастомный WalkSpeed", Default = Hub.Flags.WalkSpeedEnabled, Callback = function(state) Hub.Flags.WalkSpeedEnabled = state if state then pcall(function() lp.Character.Humanoid.WalkSpeed = Hub.Flags.WalkSpeedValue end) else pcall(function() lp.Character.Humanoid.WalkSpeed = 16 end) end end})
tabMovement:AddSlider({Name = "Скорость", Min = 16, Max = 350, Default = Hub.Flags.WalkSpeedValue, Callback = function(val) Hub.Flags.WalkSpeedValue = val if Hub.Flags.WalkSpeedEnabled then pcall(function() lp.Character.Humanoid.WalkSpeed = val end) end end})
tabMovement:AddToggle({Name = "Кастомный JumpPower", Default = Hub.Flags.JumpPowerEnabled, Callback = function(state) Hub.Flags.JumpPowerEnabled = state if state then pcall(function() lp.Character.Humanoid.JumpPower = Hub.Flags.JumpPowerValue end) else pcall(function() lp.Character.Humanoid.JumpPower = 50 end) end end})
tabMovement:AddSlider({Name = "Сила прыжка", Min = 50, Max = 500, Default = Hub.Flags.JumpPowerValue, Callback = function(val) Hub.Flags.JumpPowerValue = val if Hub.Flags.JumpPowerEnabled then pcall(function() lp.Character.Humanoid.JumpPower = val end) end end})
tabMovement:AddSection("Супер-Способности")
tabMovement:AddToggle({Name = "Бесконечный Прыжок", Default = Hub.Flags.InfiniteJump, Callback = function(state) Hub.Flags.InfiniteJump = state end})
tabMovement:AddToggle({Name = "Режим полета (Fly)", Default = Hub.Flags.Fly, Callback = function(state) Hub.Flags.Fly = state end})
tabMovement:AddSlider({Name = "Скорость полета", Min = 10, Max = 350, Default = Hub.Flags.FlySpeed, Callback = function(val) Hub.Flags.FlySpeed = val end})
tabMovement:AddToggle({Name = "Noclip (Сквозь стены)", Default = Hub.Flags.Noclip, Callback = function(state) Hub.Flags.Noclip = state end})


-- Вкладка: ВРЕДИТЕЛЬСТВО
local tabTroll = menu:CreateTab("Троллинг")
tabTroll:AddSection("Контроль Жертвы")
tabTroll:AddTextBox({Name = "Имя Жертвы", Placeholder = "Ник...", Default = Hub.Flags.TargetPlayer, Callback = function(text) Hub.Flags.TargetPlayer = text end})
tabTroll:AddButton({Name = "Fling Target (Разорвать)", Callback = function() local t = FindPlayerByName(Hub.Flags.TargetPlayer) if t then ExecuteFling(t) end end})
tabTroll:AddToggle({Name = "Orbit Target", Default = Hub.Flags.OrbitPlayer, Callback = function(state) Hub.Flags.OrbitPlayer = state end})
tabTroll:AddSlider({Name = "Дистанция орбиты", Min = 2, Max = 60, Default = Hub.Flags.OrbitDistance, Callback = function(val) Hub.Flags.OrbitDistance = val end})
tabTroll:AddSlider({Name = "Скорость орбиты", Min = 1, Max = 40, Default = Hub.Flags.OrbitSpeed, Callback = function(val) Hub.Flags.OrbitSpeed = val end})
tabTroll:AddSection("Глобальный Хаос")
tabTroll:AddToggle({Name = "Fling Aura", Default = Hub.Flags.FlingAura, Callback = function(state) Hub.Flags.FlingAura = state end})
tabTroll:AddToggle({Name = "Click Fling (+Ctrl)", Default = Hub.Flags.ClickFling, Callback = function(state) Hub.Flags.ClickFling = state end})
tabTroll:AddButton({Name = "Fling All", Callback = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then task.spawn(function() ExecuteFling(p) end) end end end})
tabTroll:AddButton({Name = "Mass Weld", Callback = function() RunMassWeld() end})
tabTroll:AddToggle({Name = "Lobby Freeze", Default = Hub.Flags.LobbyFreeze, Callback = function(state) Hub.Flags.LobbyFreeze = state end})


-- Вкладка: ВИЗУАЛЫ
local tabVisuals = menu:CreateTab("Визуалы")
tabVisuals:AddSection("Отображение ESP")
tabVisuals:AddToggle({Name = "ESP Боксы", Default = Hub.Flags.ESP_Boxes, Callback = function(state) Hub.Flags.ESP_Boxes = state end})
tabVisuals:AddToggle({Name = "ESP Трассеры", Default = Hub.Flags.ESP_Tracers, Callback = function(state) Hub.Flags.ESP_Tracers = state end})
tabVisuals:AddToggle({Name = "ESP Имена", Default = Hub.Flags.ESP_Names, Callback = function(state) Hub.Flags.ESP_Names = state end})
tabVisuals:AddToggle({Name = "ESP Здоровье", Default = Hub.Flags.ESP_Health, Callback = function(state) Hub.Flags.ESP_Health = state end})
tabVisuals:AddSection("Окружающая Среда")
tabVisuals:AddSlider({Name = "Растяжение Экрана", Min = 0.1, Max = 2.0, Default = 1.0, Float = true, Callback = function(val) getgenv().Resolution[".gg/scripters"] = val end})
tabVisuals:AddToggle({Name = "Fullbright", Default = Hub.Flags.Fullbright, Callback = function(state) Hub.Flags.Fullbright = state if not state then Lighting.Ambient = Hub.Cache.OriginalLighting.Ambient Lighting.OutdoorAmbient = Hub.Cache.OriginalLighting.OutdoorAmbient Lighting.Brightness = Hub.Cache.OriginalLighting.Brightness Lighting.ClockTime = Hub.Cache.OriginalLighting.ClockTime end end})
tabVisuals:AddToggle({Name = "Potato PC Mode", Default = Hub.Flags.PotatoPC, Callback = function(state) ApplyPotatoPC(state) end})


-- Вкладка: ЗАЩИТА & СПАМ
local tabDefense = menu:CreateTab("Защита")
tabDefense:AddSection("Мета-Механика")
tabDefense:AddToggle({Name = "Bypass Metatable", Default = Hub.Flags.BypassMetatable, Callback = function(state) Hub.Flags.BypassMetatable = state end})
tabDefense:AddToggle({Name = "Anti-Grab (Старый)", Default = Hub.Flags.AntiGrab, Callback = function(state) Hub.Flags.AntiGrab = state end})
tabDefense:AddToggle({Name = "Anti-Fling", Default = Hub.Flags.AntiFling, Callback = function(state) Hub.Flags.AntiFling = state end})
tabDefense:AddSection("Автоматизация")
tabDefense:AddToggle({Name = "Спамер в чат", Default = Hub.Flags.ChatSpam, Callback = function(state) Hub.Flags.ChatSpam = state end})
tabDefense:AddTextBox({Name = "Текст сообщения", Default = Hub.Flags.ChatSpamMessage, Callback = function(text) Hub.Flags.ChatSpamMessage = text end})


-- Вкладка: ПРОФИЛЬ
local tabProfile = menu:CreateTab("Профиль")
tabProfile:AddSection("Личная Сводка Данных")
tabProfile:AddProfileCard()


-- Вкладка: НАСТРОЙКИ ЯДРА
local tabCore = menu:CreateTab("Настройки")
tabCore:AddSection("Удаление Скрипта")

local function TerminateHub()
    Hub.Loaded = false
    for _, conn in ipairs(Hub.Cache.Connections) do if conn.Connected then conn:Disconnect() end end
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
    
    fovCircle:Destroy()
    snapLine:Destroy()
    if menu.Gui then menu.Gui:Destroy() end
    getgenv().Resolution[".gg/scripters"] = 1.0
    
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false hum.WalkSpeed = 16 hum.JumpPower = 50 end
    end)
    _G.BrosaHubGlobal = nil
end

tabCore:AddButton({Name = "Destroy Script", Callback = function() TerminateHub() end})

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

print("[Brosa System v6.0]: Монолитный скрипт успешно загружен! Новое меню и функционал интегрированного захвата инициализированы.")
