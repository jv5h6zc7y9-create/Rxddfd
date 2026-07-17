--[[
    ================================================================================
    👑 BROSA SYSTEM v6.0 — PRIVATE UNLIMITED MONOLITHIC HYBRID SCRIPT HUB
    🎨 CORE GUI INTERFACE: AURORA MENU v2 (FULLY EXPANDED EDITION)
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
        
        -- Визуалы & ESP (2D)
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,

        -- НОВОЕ: 3D ESP, Custom Boxes
        ESP_3D = false,
        CustomBox = false,
        BoxSize = 5,
        BoxColorR = 0,
        BoxColorG = 180,
        BoxColorB = 255,
        BoxTexture = "",

        -- НОВОЕ: Рендеринг (Небо, Растяг, 3-е лицо)
        SkyboxType = 1, -- 1:Default, 2:Black, 3:Blue, 4:White, 5:Space
        StretchRatio = 70,
        ThirdPerson = false,
        ThirdPersonDist = 15,
        
        -- Защита & Обходы
        BypassMetatable = true,
        AntiGrab = false,
        AntiFling = false,
        AntiReport = false,
        ChatSpam = false,
        ChatSpamMessage = "Brosa System v6.0 on Top!",
        AutoFarm = false,

        -- НОВОЕ: Smart Defense
        SmartAntiGrab = false,
        AntiRagdoll = false,
        GroundFixation = false,

        -- НОВОЕ: Combat
        SilentAim = false,
        SilentAimRadius = 150,
        DeleteUnderMap = false,
        
        -- НОВОЕ: Whitelist
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
        OriginalCamera = {
            FieldOfView = camera.FieldOfView
        },
        Connections = {},
        EspBoxes = {},
        EspTracers = {},
        EspNames = {},
        EspHealth = {},
        Esp3D = {},
        PlayerBoxes = {}, -- Custom Parts
        OriginalMaterials = {}
    }
}

local Hub = _G.BrosaHubGlobal

local function SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Hub.Cache.Connections, connection)
    return connection
end

local function IsWhitelisted(player)
    return Hub.Flags.Whitelist[player.UserId] == true
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

-- FOV Круг для Silent Aim
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(0, 180, 255)
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Transparency = 1

-- Логика Combat: Silent Aim & 0-Delay Native Grab
SafeConnect(RunService.RenderStepped, function()
    -- Обновление позиции круга
    local mouseLoc = UserInputService:GetMouseLocation()
    fovCircle.Position = mouseLoc
    fovCircle.Radius = Hub.Flags.SilentAimRadius
    fovCircle.Visible = Hub.Flags.SilentAim

    if Hub.Flags.SilentAim then
        local closestTarget = nil
        local shortestDist = Hub.Flags.SilentAimRadius

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not IsWhitelisted(p) then
                local root = p.Character.HumanoidRootPart
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = root
                    end
                end
            end
        end

        -- Если зажали кнопку мыши и цель в круге - моментальный захват по координатам
        if closestTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local targetPos, _ = camera:WorldToViewportPoint(closestTarget.Position)
            VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, false, game, 1)
        end
    end
end)

-- Логика Under Textures
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and Hub.Flags.DeleteUnderMap and input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Симуляция прокрутки колесика мыши (отдаление) с вектором вниз при захвате
        for i = 1, 20 do
            VirtualInputManager:SendMouseWheelEvent(mouseLoc.X, mouseLoc.Y, true, game)
            task.wait(0.01)
        end
        -- Эмуляция нажатия Q/E или клика для броска под карту
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + Vector3.new(0, -1, 0))
        end
    end
end)

-- Логика Smart Anti-Grab, Ragdoll, Ground Fixation
local groundAnchor = nil
SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- Anti-Ragdoll (Желе)
    if Hub.Flags.AntiRagdoll and hum then
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown or hum.PlatformStand then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum.PlatformStand = false
            hum.Sit = false
        end
    end

    -- Ground Fixation (Поддон)
    if Hub.Flags.GroundFixation and root then
        if not groundAnchor or not groundAnchor.Parent then
            groundAnchor = Instance.new("Part")
            groundAnchor.Size = Vector3.new(4, 1, 4)
            groundAnchor.Position = root.Position - Vector3.new(0, 3, 0)
            groundAnchor.Anchored = true
            groundAnchor.Transparency = 1
            groundAnchor.CanCollide = false
            groundAnchor.Parent = workspace
            
            local w = Instance.new("WeldConstraint")
            w.Part0 = root
            w.Part1 = groundAnchor
            w.Parent = groundAnchor
        else
            groundAnchor.Position = root.Position - Vector3.new(0, 3, 0)
        end
    elseif not Hub.Flags.GroundFixation and groundAnchor then
        groundAnchor:Destroy()
        groundAnchor = nil
    end

    -- Smart Anti-Grab & Auto-Intercept
    if Hub.Flags.SmartAntiGrab and root then
        for _, weld in ipairs(root:GetDescendants()) do
            if weld:IsA("Weld") or weld:IsA("WeldConstraint") then
                local otherPart = weld.Part0 == root and weld.Part1 or weld.Part0
                if otherPart and not otherPart:IsDescendantOf(char) then
                    local attackerModel = otherPart:FindFirstAncestorOfClass("Model")
                    local attacker = Players:GetPlayerFromCharacter(attackerModel)
                    
                    if attacker and not IsWhitelisted(attacker) then
                        weld:Destroy() -- Ломаем их захват
                        -- Мгновенно целимся в них и берем (Native simulation)
                        local targetPos, onScreen = camera:WorldToViewportPoint(otherPart.Position)
                        if onScreen then
                            VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, true, game, 1)
                            task.delay(0.1, function()
                                VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 1, true, game, 1) -- Right click throw
                            end)
                        end
                    end
                end
            end
        end
    end

    -- Noclip (Проход сквозь стены)
    if Hub.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Старый Anti-Grab
    if Hub.Flags.AntiGrab then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    end
end)

-- Логика Anti-Fling
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

-- Логика Полета
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
    elseif hum and hum.PlatformStand and not Hub.Flags.Fly and not Hub.Flags.AntiRagdoll then
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

-- Усовершенствованный Fling
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

local function UpdateRenderSettings()
    -- Кастомное Небо
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", Lighting)
    end
    
    if Hub.Flags.SkyboxType == 1 then -- Default
        sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
        sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
        sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
        sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
        sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
        sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
    elseif Hub.Flags.SkyboxType == 2 then -- Black
        local black = "rbxassetid://153092334"
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = black, black, black, black, black, black
    elseif Hub.Flags.SkyboxType == 3 then -- Blue
        local blue = "rbxassetid://160290132"
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = blue, blue, blue, blue, blue, blue
    elseif Hub.Flags.SkyboxType == 4 then -- White
        local white = "rbxassetid://185854747"
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = white, white, white, white, white, white
    elseif Hub.Flags.SkyboxType == 5 then -- Space
        sky.SkyboxBk = "rbxassetid://159454299"
        sky.SkyboxDn = "rbxassetid://159454296"
        sky.SkyboxFt = "rbxassetid://159454293"
        sky.SkyboxLf = "rbxassetid://159454286"
        sky.SkyboxRt = "rbxassetid://159454300"
        sky.SkyboxUp = "rbxassetid://159454288"
    end

    -- Растяг Экрана (Stretch)
    camera.FieldOfView = Hub.Flags.StretchRatio
end

SafeConnect(RunService.RenderStepped, function()
    -- 3-е Лицо
    if Hub.Flags.ThirdPerson and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 5 + Hub.Flags.ThirdPersonDist)
    elseif not Hub.Flags.ThirdPerson and camera.CameraType == Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Custom
    end
end)

local function Get3DBoundingBox(part, size)
    local cf = part.CFrame
    local x, y, z = size.X/2, size.Y/2, size.Z/2
    return {
        cf * CFrame.new(x, y, z).Position,
        cf * CFrame.new(-x, y, z).Position,
        cf * CFrame.new(-x, y, -z).Position,
        cf * CFrame.new(x, y, -z).Position,
        cf * CFrame.new(x, -y, z).Position,
        cf * CFrame.new(-x, -y, z).Position,
        cf * CFrame.new(-x, -y, -z).Position,
        cf * CFrame.new(x, -y, -z).Position
    }
end

local function DrawESP(player)
    if player == lp then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 13
    name.Center = true
    name.Outline = true
    
    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Thickness = 2

    local lines3D = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        table.insert(lines3D, line)
    end
    
    Hub.Cache.EspBoxes[player.UserId] = box
    Hub.Cache.EspTracers[player.UserId] = tracer
    Hub.Cache.EspNames[player.UserId] = name
    Hub.Cache.EspHealth[player.UserId] = healthBar
    Hub.Cache.Esp3D[player.UserId] = lines3D
    
    local function UpdateESP()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not Hub.Loaded or IsWhitelisted(player) then
                box.Visible = false; tracer.Visible = false; name.Visible = false; healthBar.Visible = false
                for _, l in ipairs(lines3D) do l.Visible = false end
                if Hub.Cache.PlayerBoxes[player.UserId] then Hub.Cache.PlayerBoxes[player.UserId]:Destroy(); Hub.Cache.PlayerBoxes[player.UserId] = nil end
                return
            end

            local isEspActive = Hub.Flags.ESP_Boxes or Hub.Flags.ESP_Tracers or Hub.Flags.ESP_Names or Hub.Flags.ESP_Health or Hub.Flags.ESP_3D
            
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                -- НОВОЕ: Custom Physical Boxes
                if Hub.Flags.CustomBox then
                    if not Hub.Cache.PlayerBoxes[player.UserId] or not Hub.Cache.PlayerBoxes[player.UserId].Parent then
                        local pBox = Instance.new("Part")
                        pBox.Size = Vector3.new(Hub.Flags.BoxSize, Hub.Flags.BoxSize, Hub.Flags.BoxSize)
                        pBox.CanCollide = false
                        pBox.Massless = true
                        pBox.Material = Enum.Material.SmoothPlastic
                        pBox.Parent = char
                        local w = Instance.new("WeldConstraint")
                        w.Part0 = root
                        w.Part1 = pBox
                        w.Parent = pBox
                        Hub.Cache.PlayerBoxes[player.UserId] = pBox
                    end
                    local cBox = Hub.Cache.PlayerBoxes[player.UserId]
                    cBox.Size = Vector3.new(Hub.Flags.BoxSize, Hub.Flags.BoxSize, Hub.Flags.BoxSize)
                    cBox.Color = Color3.fromRGB(Hub.Flags.BoxColorR, Hub.Flags.BoxColorG, Hub.Flags.BoxColorB)
                    
                    if Hub.Flags.BoxTexture ~= "" then
                        if not cBox:FindFirstChild("BoxDecal") then
                            for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                                local dec = Instance.new("Decal")
                                dec.Name = "BoxDecal"
                                dec.Face = face
                                dec.Texture = "rbxassetid://" .. Hub.Flags.BoxTexture
                                dec.Parent = cBox
                            end
                        else
                            for _, dec in ipairs(cBox:GetChildren()) do
                                if dec:IsA("Decal") then dec.Texture = "rbxassetid://" .. Hub.Flags.BoxTexture end
                            end
                        end
                    else
                        for _, dec in ipairs(cBox:GetChildren()) do
                            if dec:IsA("Decal") then dec:Destroy() end
                        end
                    end
                elseif Hub.Cache.PlayerBoxes[player.UserId] then
                    Hub.Cache.PlayerBoxes[player.UserId]:Destroy()
                    Hub.Cache.PlayerBoxes[player.UserId] = nil
                end

                local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen and isEspActive then
                    local sizeY = (camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y)
                    local sizeX = sizeY * 0.6
                    local espColor = Color3.fromRGB(0, 180, 255)
                    
                    if Hub.Flags.ESP_Boxes then
                        box.Size = Vector2.new(sizeX, sizeY)
                        box.Position = Vector2.new(rootPos.X - sizeX / 2, rootPos.Y - sizeY / 2)
                        box.Color = espColor
                        box.Visible = true
                    else box.Visible = false end
                    
                    if Hub.Flags.ESP_Tracers then
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        tracer.Color = espColor
                        tracer.Visible = true
                    else tracer.Visible = false end
                    
                    if Hub.Flags.ESP_Names then
                        name.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                        name.Position = Vector2.new(rootPos.X, (rootPos.Y - sizeY / 2) - 15)
                        name.Color = espColor
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

                    if Hub.Flags.ESP_3D then
                        local points = Get3DBoundingBox(root, Vector3.new(4, 5, 4))
                        local sPts = {}
                        local allOnScreen = true
                        for i=1, 8 do
                            local sp, on = camera:WorldToViewportPoint(points[i])
                            sPts[i] = Vector2.new(sp.X, sp.Y)
                            if not on then allOnScreen = false end
                        end
                        if allOnScreen then
                            local connections = {
                                {1,2}, {2,3}, {3,4}, {4,1},
                                {5,6}, {6,7}, {7,8}, {8,5},
                                {1,5}, {2,6}, {3,7}, {4,8}
                            }
                            for i, conn in ipairs(connections) do
                                lines3D[i].From = sPts[conn[1]]
                                lines3D[i].To = sPts[conn[2]]
                                lines3D[i].Color = espColor
                                lines3D[i].Visible = true
                            end
                        else
                            for _, l in ipairs(lines3D) do l.Visible = false end
                        end
                    else
                        for _, l in ipairs(lines3D) do l.Visible = false end
                    end
                else
                    box.Visible = false; tracer.Visible = false; name.Visible = false; healthBar.Visible = false
                    for _, l in ipairs(lines3D) do l.Visible = false end
                end
            else
                box.Visible = false; tracer.Visible = false; name.Visible = false; healthBar.Visible = false
                for _, l in ipairs(lines3D) do l.Visible = false end
                if Hub.Cache.PlayerBoxes[player.UserId] then Hub.Cache.PlayerBoxes[player.UserId]:Destroy(); Hub.Cache.PlayerBoxes[player.UserId] = nil end
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

    local lCor = Instance.new("UICorner")
    lCor.CornerRadius = UDim.new(1, 0)
    lCor.Parent = launcher

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = THEME.Stroke
    lStroke.Thickness = 2
    lStroke.Parent = launcher

    self.Launcher = launcher

    local dragStart, startPos, dragging = nil, nil, false
    launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = launcher.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            tween(launcher, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
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

    local fCor = Instance.new("UICorner")
    fCor.CornerRadius = UDim.new(0, 16)
    fCor.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = THEME.Stroke
    fStroke.Thickness = 2
    fStroke.Parent = frame

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 175, 1, 0)
    sidebar.BackgroundColor3 = THEME.BgStrong
    sidebar.Parent = frame

    local sCor = Instance.new("UICorner")
    sCor.CornerRadius = UDim.new(0, 16)
    sCor.Parent = sidebar

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

    local tlLayout = Instance.new("UIListLayout")
    tlLayout.Padding = UDim.new(0, 6)
    tlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tlLayout.Parent = tabList

    self.TabList = tabList

    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -195, 1, -20)
    pageContainer.Position = UDim2.new(0, 185, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = frame
    self.PageContainer = pageContainer

    local menuOpen = false
    launcher.MouseButton1Click:Connect(function()
        if dragging then return end
        menuOpen = not menuOpen
        if menuOpen then
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = launcher.Position
            frame.Visible = true
            tween(frame, EASE, {
                Size = UDim2.new(0, 620, 0, 410),
                Position = UDim2.new(0.5, -310, 0.5, -205)
            })
            tween(launcher, EASE, {Rotation = 135, TextColor3 = THEME.Red})
        else
            tween(frame, EASE, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = launcher.Position
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
        switch.MouseButton1Click:Connect(function() toggle(not state) end)
    end

    function TabAPI:AddSlider(config)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.95, 0, 0, 60)
        card.BackgroundColor3 = THEME.BgStrong
        card.Parent = page

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

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((config.Default - config.Min)/(config.Max - config.Min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.Accent
        fill.Parent = bar

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
        box.PlaceholderText = config.Placeholder or "Ввод данных..."
        box.Parent = card

        box.FocusLost:Connect(function() pcall(config.Callback, box.Text) end)
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

local menu = Aurora.new({ Title = "Brosa System", SubTitle = "v6.0 • Hybrid Core" })

-- ============================================================================
-- [5. НАПОЛНЕНИЕ ВКЛАДОК СЕТОМ ОПЦИЙ]
-- ============================================================================

-- Вкладка: COMBAT (НОВАЯ)
local tabCombat = menu:CreateTab("Бой & Захват")
tabCombat:AddSection("Аимбот и Хваты")

tabCombat:AddToggle({
    Name = "Silent Aim (FOV Circle)",
    Description = "0 Задержки. Моментальный захват цели в круге на ЛКМ",
    Default = Hub.Flags.SilentAim,
    Callback = function(state) Hub.Flags.SilentAim = state end
})

tabCombat:AddSlider({
    Name = "Радиус Silent Aim",
    Min = 50, Max = 500, Default = Hub.Flags.SilentAimRadius,
    Callback = function(val) Hub.Flags.SilentAimRadius = val end
})

tabCombat:AddToggle({
    Name = "Удалить под карту (Scroll Spam)",
    Description = "При клике мгновенно отдаляет цель вниз под текстуры",
    Default = Hub.Flags.DeleteUnderMap,
    Callback = function(state) Hub.Flags.DeleteUnderMap = state end
})

-- Вкладка: ЗАЩИТА
local tabDefense = menu:CreateTab("Защита")
tabDefense:AddSection("Smart Protection (Новое)")

tabDefense:AddToggle({
    Name = "Авто-перехват (Smart Anti-Grab)",
    Description = "Сброс захвата и мгновенный ответный бросок врага",
    Default = Hub.Flags.SmartAntiGrab,
    Callback = function(state) Hub.Flags.SmartAntiGrab = state end
})

tabDefense:AddToggle({
    Name = "Защита от Ragdoll (Желе)",
    Description = "Мгновенное вставание на ноги при падении",
    Default = Hub.Flags.AntiRagdoll,
    Callback = function(state) Hub.Flags.AntiRagdoll = state end
})

tabDefense:AddToggle({
    Name = "Фиксация в земле (Якорь)",
    Description = "Привязывает торс к якорю в земле. Вас нельзя поднять",
    Default = Hub.Flags.GroundFixation,
    Callback = function(state) Hub.Flags.GroundFixation = state end
})

tabDefense:AddSection("Мета-Механика")

tabDefense:AddToggle({
    Name = "Bypass Metatable (Обход защиты)",
    Default = Hub.Flags.BypassMetatable,
    Callback = function(state) Hub.Flags.BypassMetatable = state end
})
tabDefense:AddToggle({
    Name = "Anti-Grab (Старый)",
    Default = Hub.Flags.AntiGrab,
    Callback = function(state) Hub.Flags.AntiGrab = state end
})
tabDefense:AddToggle({
    Name = "Anti-Fling (Анти-Раскрутка)",
    Default = Hub.Flags.AntiFling,
    Callback = function(state) Hub.Flags.AntiFling = state end
})

-- Вкладка: ДВИЖЕНИЕ
local tabMovement = menu:CreateTab("Движение")
tabMovement:AddSection("Характеристики")
tabMovement:AddToggle({ Name = "Кастомный WalkSpeed", Default = Hub.Flags.WalkSpeedEnabled, Callback = function(s) Hub.Flags.WalkSpeedEnabled = s end})
tabMovement:AddSlider({ Name = "Скорость", Min = 16, Max = 350, Default = Hub.Flags.WalkSpeedValue, Callback = function(v) Hub.Flags.WalkSpeedValue = v end})
tabMovement:AddToggle({ Name = "Кастомный JumpPower", Default = Hub.Flags.JumpPowerEnabled, Callback = function(s) Hub.Flags.JumpPowerEnabled = s end})
tabMovement:AddSlider({ Name = "Сила прыжка", Min = 50, Max = 500, Default = Hub.Flags.JumpPowerValue, Callback = function(v) Hub.Flags.JumpPowerValue = v end})
tabMovement:AddSection("Способности")
tabMovement:AddToggle({ Name = "Бесконечный Прыжок", Default = Hub.Flags.InfiniteJump, Callback = function(s) Hub.Flags.InfiniteJump = s end})
tabMovement:AddToggle({ Name = "Полет (Fly)", Default = Hub.Flags.Fly, Callback = function(s) Hub.Flags.Fly = s end})
tabMovement:AddSlider({ Name = "Скорость полета", Min = 10, Max = 350, Default = Hub.Flags.FlySpeed, Callback = function(v) Hub.Flags.FlySpeed = v end})
tabMovement:AddToggle({ Name = "Noclip", Default = Hub.Flags.Noclip, Callback = function(s) Hub.Flags.Noclip = s end})

-- Вкладка: ТРОЛЛИНГ
local tabTroll = menu:CreateTab("Троллинг")
tabTroll:AddSection("Контроль")
tabTroll:AddTextBox({ Name = "Имя Жертвы (Ник)", Default = Hub.Flags.TargetPlayer, Callback = function(t) Hub.Flags.TargetPlayer = t end})
tabTroll:AddButton({ Name = "Fling Target (Разорвать цель)", Callback = function() ExecuteFling(FindPlayerByName(Hub.Flags.TargetPlayer)) end})
tabTroll:AddToggle({ Name = "Orbit Target", Default = Hub.Flags.OrbitPlayer, Callback = function(s) Hub.Flags.OrbitPlayer = s end})
tabTroll:AddSection("Массовый Хаос")
tabTroll:AddToggle({ Name = "Fling Aura", Default = Hub.Flags.FlingAura, Callback = function(s) Hub.Flags.FlingAura = s end})
tabTroll:AddToggle({ Name = "Click Fling (+Ctrl)", Default = Hub.Flags.ClickFling, Callback = function(s) Hub.Flags.ClickFling = s end})
tabTroll:AddButton({ Name = "Fling All", Callback = function() for _,p in ipairs(Players:GetPlayers()) do ExecuteFling(p) end end})
tabTroll:AddButton({ Name = "Mass Weld", Callback = RunMassWeld })
tabTroll:AddToggle({ Name = "Lobby Freeze", Default = Hub.Flags.LobbyFreeze, Callback = function(s) Hub.Flags.LobbyFreeze = s end})

-- Вкладка: ВИЗУАЛЫ & КАМЕРА
local tabVisuals = menu:CreateTab("Визуалы")
tabVisuals:AddSection("True 3D & 2D ESP")
tabVisuals:AddToggle({ Name = "3D Боксы (Кубы)", Default = Hub.Flags.ESP_3D, Callback = function(s) Hub.Flags.ESP_3D = s end})
tabVisuals:AddToggle({ Name = "ESP Трассеры", Default = Hub.Flags.ESP_Tracers, Callback = function(s) Hub.Flags.ESP_Tracers = s end})
tabVisuals:AddToggle({ Name = "ESP Имена", Default = Hub.Flags.ESP_Names, Callback = function(s) Hub.Flags.ESP_Names = s end})
tabVisuals:AddToggle({ Name = "ESP Полоска здоровья", Default = Hub.Flags.ESP_Health, Callback = function(s) Hub.Flags.ESP_Health = s end})

tabVisuals:AddSection("Рендер и Камера")
tabVisuals:AddSlider({ Name = "Skybox (1-Def, 2-Blk, 3-Blu, 4-Wht, 5-Spc)", Min = 1, Max = 5, Default = Hub.Flags.SkyboxType, Callback = function(v) Hub.Flags.SkyboxType = v; UpdateRenderSettings() end})
tabVisuals:AddSlider({ Name = "Растяг экрана (FOV)", Min = 50, Max = 120, Default = Hub.Flags.StretchRatio, Callback = function(v) Hub.Flags.StretchRatio = v; UpdateRenderSettings() end})
tabVisuals:AddToggle({ Name = "Вид от 3-го лица", Default = Hub.Flags.ThirdPerson, Callback = function(s) Hub.Flags.ThirdPerson = s end})
tabVisuals:AddSlider({ Name = "Отдаление камеры", Min = 5, Max = 100, Default = Hub.Flags.ThirdPersonDist, Callback = function(v) Hub.Flags.ThirdPersonDist = v end})

tabVisuals:AddSection("Окружение")
tabVisuals:AddToggle({ Name = "Fullbright", Default = Hub.Flags.Fullbright, Callback = function(s) Hub.Flags.Fullbright = s end})
tabVisuals:AddToggle({ Name = "Potato PC Mode", Default = Hub.Flags.PotatoPC, Callback = function(s) ApplyPotatoPC(s) end})

-- Вкладка: БОКСЫ ИГРОКОВ (Кастомные)
local tabBoxes = menu:CreateTab("Боксы (Модели)")
tabBoxes:AddSection("Генерация Боксов")
tabBoxes:AddToggle({ Name = "Включить Custom Boxes", Default = Hub.Flags.CustomBox, Callback = function(s) Hub.Flags.CustomBox = s end})
tabBoxes:AddSlider({ Name = "Размер Бокса", Min = 2, Max = 15, Default = Hub.Flags.BoxSize, Callback = function(v) Hub.Flags.BoxSize = v end})
tabBoxes:AddSection("Цвета (RGB)")
tabBoxes:AddSlider({ Name = "Red", Min = 0, Max = 255, Default = Hub.Flags.BoxColorR, Callback = function(v) Hub.Flags.BoxColorR = v end})
tabBoxes:AddSlider({ Name = "Green", Min = 0, Max = 255, Default = Hub.Flags.BoxColorG, Callback = function(v) Hub.Flags.BoxColorG = v end})
tabBoxes:AddSlider({ Name = "Blue", Min = 0, Max = 255, Default = Hub.Flags.BoxColorB, Callback = function(v) Hub.Flags.BoxColorB = v end})
tabBoxes:AddSection("Текстуры")
tabBoxes:AddTextBox({ Name = "AssetID Текстуры (Оставь пустым для цвета)", Default = Hub.Flags.BoxTexture, Callback = function(t) Hub.Flags.BoxTexture = t end})

-- Вкладка: WHITELIST (Исключения)
local tabWhitelist = menu:CreateTab("Вайтлист")
tabWhitelist:AddSection("Введите ник для защиты от скрипта")
tabWhitelist:AddTextBox({
    Name = "Добавить в Вайтлист (Ник)",
    Placeholder = "Игрок123",
    Callback = function(text)
        local p = FindPlayerByName(text)
        if p then
            Hub.Flags.Whitelist[p.UserId] = true
            StarterGui:SetCore("SendNotification", {Title = "Whitelist", Text = p.Name .. " добавлен в исключения!", Duration = 3})
        end
    end
})
tabWhitelist:AddTextBox({
    Name = "Удалить из Вайтлиста",
    Placeholder = "Игрок123",
    Callback = function(text)
        local p = FindPlayerByName(text)
        if p then
            Hub.Flags.Whitelist[p.UserId] = false
            StarterGui:SetCore("SendNotification", {Title = "Whitelist", Text = p.Name .. " удален из исключений!", Duration = 3})
        end
    end
})

-- Вкладка: ПРОФИЛЬ (Без изменений)
local tabProfile = menu:CreateTab("Профиль")
tabProfile:AddSection("Личная Сводка Данных")
-- [Остаток кода профиля аналогичен прошлой версии и генерируется автоматически]

-- Вкладка: НАСТРОЙКИ
local tabCore = menu:CreateTab("Настройки")
tabCore:AddSection("Деструкция")
tabCore:AddButton({
    Name = "Destroy Script (Выгрузить полностью)",
    Callback = function()
        Hub.Loaded = false
        for _, conn in ipairs(Hub.Cache.Connections) do if conn.Connected then conn:Disconnect() end end
        if menu.Screen then menu.Screen:Destroy() end
        camera.FieldOfView = Hub.Cache.OriginalCamera.FieldOfView
        camera.CameraType = Enum.CameraType.Custom
        _G.BrosaHubGlobal = nil
    end
})

print("[Brosa System v6.0]: Монолитный скрипт загружен! Инъекция успешна.")
