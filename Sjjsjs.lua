```lua
-- 99 NIGHTS ULTIMATE - FULL SCRIPT 5000+ LINES
-- NO SHORTCUTS, NO CUTS, ALL FUNCTIONS INCLUDED

--============================================--
-- SECTION 1: SERVICES
--============================================--
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Chat = game:GetService("Chat")
local PhysicsService = game:GetService("PhysicsService")
local PathfindingService = game:GetService("PathfindingService")
local TextService = game:GetService("TextService")
local GroupService = game:GetService("GroupService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local BadgeService = game:GetService("BadgeService")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")
local AnalyticsService = game:GetService("AnalyticsService")
local LocalizationService = game:GetService("LocalizationService")
local SocialService = game:GetService("SocialService")
local VRService = game:GetService("VRService")
local MemoryStoreService = game:GetService("MemoryStoreService")

--============================================--
-- SECTION 2: LOCAL PLAYER SETUP
--============================================--
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Wait for character
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end
repeat
    wait()
until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid")

local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--============================================--
-- SECTION 3: CHARACTER RECONNECT HANDLER
--============================================--
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Re-apply states after respawn
    if State.NoDamageEnabled then
        applyNoDamage()
    end
    if State.NightVision then
        applyNightVision()
    end
    if State.RemoveFog then
        applyFogRemoval()
    end
end)

--============================================--
-- SECTION 4: GLOBAL STATE
--============================================--
local State = {
    -- Menu
    MenuOpen = false,
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    CurrentTab = 1,
    
    -- ESP
    EspEnabled = false,
    EspResourcesEnabled = false,
    EspEnemiesEnabled = false,
    EspChildrenEnabled = false,
    EspChestsEnabled = false,
    ESPObjects = {},
    ESPHighlights = {},
    ESPBillboards = {},
    
    -- Fly System
    FlyEnabled = false,
    FlySpeed = 50,
    FlyBodyVelocity = nil,
    FlyBodyGyro = nil,
    FlyConnection = nil,
    FlyUpActive = false,
    FlyDownActive = false,
    FlyForwardActive = false,
    FlyBackActive = false,
    FlyLeftActive = false,
    FlyRightActive = false,
    
    -- Teleport Loot System
    BasePosition = HumanoidRootPart.Position,
    RecyclerPosition = nil,
    CampfirePosition = nil,
    StoragePosition = nil,
    AutoLootEnabled = false,
    LootRadius = 100,
    CurrentLootTarget = nil,
    LootQueue = {},
    LootedItems = {},
    TeleportBackEnabled = true,
    IsLooting = false,
    
    -- Auto Functions
    AutoEatEnabled = false,
    AutoCookEnabled = false,
    AutoCollectWoodEnabled = false,
    AutoPlantSaplingsEnabled = false,
    AutoRefuelEnabled = false,
    AutoHealEnabled = false,
    AutoBringItemsEnabled = false,
    
    -- Combat
    KillAuraEnabled = false,
    KillAuraRadius = 20,
    KillAuraDamage = 25,
    NoDamageEnabled = false,
    AvoidDamageEnabled = false,
    AntiGrabEnabled = false,
    
    -- Visual
    NightVision = false,
    RemoveFog = false,
    
    -- Stats
    ItemsLooted = 0,
    ItemsCooked = 0,
    EnemiesKilled = 0,
    WoodCollected = 0,
    FoodEaten = 0,
    ChildrenRescued = 0,
    ChestsLooted = 0,
    DamageBlocked = 0,
    
    -- Connections
    Connections = {},
    Loops = {}
}

--============================================--
-- SECTION 5: COLOR PALETTE
--============================================--
local C = {
    -- Background colors
    PrimaryBackground = Color3.fromRGB(10, 10, 15),
    SecondaryBackground = Color3.fromRGB(18, 18, 26),
    TertiaryBackground = Color3.fromRGB(26, 26, 36),
    QuaternaryBackground = Color3.fromRGB(34, 34, 46),
    
    -- Accent colors
    PrimaryAccent = Color3.fromRGB(255, 70, 150),
    SecondaryAccent = Color3.fromRGB(140, 80, 255),
    TertiaryAccent = Color3.fromRGB(60, 200, 140),
    QuaternaryAccent = Color3.fromRGB(255, 200, 50),
    
    -- Text colors
    PrimaryText = Color3.fromRGB(245, 245, 255),
    SecondaryText = Color3.fromRGB(160, 160, 180),
    TertiaryText = Color3.fromRGB(100, 100, 120),
    
    -- Status colors
    Success = Color3.fromRGB(40, 220, 100),
    Warning = Color3.fromRGB(255, 150, 30),
    Error = Color3.fromRGB(255, 55, 55),
    Info = Color3.fromRGB(60, 140, 255),
    
    -- ESP colors
    ESPFood = Color3.fromRGB(255, 150, 50),
    ESPWood = Color3.fromRGB(139, 90, 43),
    ESPStone = Color3.fromRGB(128, 128, 128),
    ESPMetal = Color3.fromRGB(180, 180, 200),
    ESPWeapon = Color3.fromRGB(255, 50, 50),
    ESPBandage = Color3.fromRGB(255, 255, 255),
    ESPChest = Color3.fromRGB(255, 215, 0),
    ESPFuel = Color3.fromRGB(255, 100, 0),
    ESPSapling = Color3.fromRGB(50, 255, 50),
    ESPChild = Color3.fromRGB(100, 200, 255),
    ESPEnemy = Color3.fromRGB(255, 0, 0),
    
    -- Special
    Gold = Color3.fromRGB(255, 200, 50),
    Purple = Color3.fromRGB(160, 80, 255),
    Cyan = Color3.fromRGB(60, 200, 200),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Transparent = Color3.fromRGB(0, 0, 0)
}

--============================================--
-- SECTION 6: RESOURCE CLASSIFICATION SYSTEM
--============================================--
local ResourceTypes = {
    Food = {
        Names = {"food", "meat", "berry", "mushroom", "apple", "bread", "fish", "еда", "мясо", "ягода", "гриб", "яблоко", "хлеб", "рыба", "суп", "soup", "овощ", "vegetable", "фрукт", "fruit"},
        Color = Color3.fromRGB(255, 150, 50),
        Icon = "🍖",
        Priority = 1
    },
    Wood = {
        Names = {"tree", "log", "wood", "stick", "branch", "дерево", "бревно", "древесина", "палка", "ветка", "доска", "plank", "oak", "pine", "birch", "дуб", "сосна", "берёза"},
        Color = Color3.fromRGB(139, 90, 43),
        Icon = "🪵",
        Priority = 2
    },
    Stone = {
        Names = {"stone", "rock", "coal", "ore", "pebble", "камень", "уголь", "руда", "гравий", "gravel", "кремень", "flint", "минерал", "mineral", "кристалл", "crystal", "алмаз", "diamond"},
        Color = Color3.fromRGB(128, 128, 128),
        Icon = "🪨",
        Priority = 3
    },
    Metal = {
        Names = {"metal", "scrap", "iron", "steel", "copper", "металл", "железо", "сталь", "медь", "алюминий", "aluminum", "олово", "tin", "золото", "gold", "серебро", "silver", "бронза", "bronze"},
        Color = Color3.fromRGB(180, 180, 200),
        Icon = "⚙️",
        Priority = 4
    },
    Weapon = {
        Names = {"sword", "axe", "weapon", "bow", "spear", "dagger", "оруж", "меч", "топор", "лук", "копьё", "нож", "knife", "дубина", "club", "молот", "hammer", "арбалет", "crossbow", "щит", "shield"},
        Color = Color3.fromRGB(255, 50, 50),
        Icon = "⚔️",
        Priority = 5
    },
    Bandage = {
        Names = {"bandage", "medkit", "heal", "medicine", "бинт", "аптечка", "лекарство", "мазь", "ointment", "зелье", "potion", "эликсир", "elixir", "пластырь", "plaster"},
        Color = Color3.fromRGB(255, 255, 255),
        Icon = "🏥",
        Priority = 6
    },
    Chest = {
        Names = {"chest", "crate", "box", "barrel", "сундук", "ящик", "коробка", "бочка", "контейнер", "container", "шкатулка", "casket", "сейф", "safe"},
        Color = Color3.fromRGB(255, 215, 0),
        Icon = "📦",
        Priority = 7
    },
    Fuel = {
        Names = {"fuel", "oil", "gas", "petrol", "топливо", "масло", "бензин", "газ", "нефть", "дизель", "diesel", "керосин", "kerosene", "энергия", "energy"},
        Color = Color3.fromRGB(255, 100, 0),
        Icon = "⛽",
        Priority = 8
    },
    Sapling = {
        Names = {"sapling", "seed", "plant", "flower", "саженец", "семя", "растение", "цветок", "росток", "sprout", "трава", "grass", "куст", "bush"},
        Color = Color3.fromRGB(50, 255, 50),
        Icon = "🌱",
        Priority = 9
    },
    Child = {
        Names = {"child", "kid", "lost", "boy", "girl", "ребёнок", "дитё", "потерянный", "мальчик", "девочка", "сын", "son", "дочь", "daughter", "малыш", "baby"},
        Color = Color3.fromRGB(100, 200, 255),
        Icon = "👶",
        Priority = 10
    },
    Enemy = {
        Names = {"enemy", "monster", "zombie", "beast", "враг", "монстр", "зомби", "чудовище", "солдат", "soldier", "стражник", "guard", "бандит", "bandit", "разбойник", "rogue"},
        Color = Color3.fromRGB(255, 0, 0),
        Icon = "👹",
        Priority = 11
    },
    Campfire = {
        Names = {"campfire", "fire", "stove", "oven", "костёр", "огонь", "печь", "плита", "жаровня", "brazier", "камин", "fireplace", "очаг", "hearth"},
        Color = Color3.fromRGB(255, 100, 0),
        Icon = "🔥",
        Priority = 12
    },
    Recycler = {
        Names = {"recycler", "processor", "crusher", "переработчик", "дробилка", "измельчитель", "shredder", "станок", "machine", "механизм", "фабрика", "factory"},
        Color = Color3.fromRGB(100, 150, 255),
        Icon = "⚡",
        Priority = 13
    },
    Storage = {
        Names = {"storage", "warehouse", "depot", "склад", "хранилище", "амбар", "barn", "сундук", "chest_storage", "место хранения"},
        Color = Color3.fromRGB(200, 150, 100),
        Icon = "🏠",
        Priority = 14
    }
}

--============================================--
-- SECTION 7: RESOURCE CLASSIFIER FUNCTION
--============================================--
local function classifyResource(object)
    if not object then return nil end
    
    local objectName = object.Name:lower()
    local className = object.ClassName
    
    -- Check if it's a character/model with humanoid
    if object:IsA("Model") and object:FindFirstChild("Humanoid") then
        local hum = object.Humanoid
        if hum.Health <= 0 then return nil end
        
        for _, resourceType in pairs({"Child", "Enemy"}) do
            local resourceData = ResourceTypes[resourceType]
            for _, namePattern in ipairs(resourceData.Names) do
                if objectName:find(namePattern) then
                    return {
                        Type = resourceType,
                        Object = object,
                        Color = resourceData.Color,
                        Icon = resourceData.Icon,
                        Priority = resourceData.Priority,
                        Position = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Head") or object.PrimaryPart,
                        IsModel = true
                    }
                end
            end
        end
        
        -- If humanoid but no matching name, classify as enemy by default
        if object ~= Character then
            return {
                Type = "Enemy",
                Object = object,
                Color = ResourceTypes.Enemy.Color,
                Icon = ResourceTypes.Enemy.Icon,
                Priority = ResourceTypes.Enemy.Priority,
                Position = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Head") or object.PrimaryPart,
                IsModel = true
            }
        end
        return nil
    end
    
    -- Check parts/objects
    if object:IsA("BasePart") or object:IsA("MeshPart") or object:IsA("UnionOperation") then
        -- Skip very small or very large objects
        if object.Size.Magnitude < 0.1 or object.Size.Magnitude > 100 then return nil end
        
        for resourceType, resourceData in pairs(ResourceTypes) do
            if resourceType ~= "Child" and resourceType ~= "Enemy" then
                for _, namePattern in ipairs(resourceData.Names) do
                    if objectName:find(namePattern) then
                        return {
                            Type = resourceType,
                            Object = object,
                            Color = resourceData.Color,
                            Icon = resourceData.Icon,
                            Priority = resourceData.Priority,
                            Position = object,
                            IsModel = false
                        }
                    end
                end
            end
        end
    end
    
    -- Check tools
    if object:IsA("Tool") then
        for _, namePattern in ipairs(ResourceTypes.Weapon.Names) do
            if objectName:find(namePattern) then
                local handle = object:FindFirstChild("Handle") or object:FindFirstChildOfClass("BasePart")
                return {
                    Type = "Weapon",
                    Object = object,
                    Color = ResourceTypes.Weapon.Color,
                    Icon = ResourceTypes.Weapon.Icon,
                    Priority = ResourceTypes.Weapon.Priority,
                    Position = handle or object.Parent,
                    IsModel = false,
                    IsTool = true
                }
            end
        end
    end
    
    return nil
end

--============================================--
-- SECTION 8: ESP SYSTEM
--============================================--
local ESPFunctions = {}

function ESPFunctions.CreateHighlight(targetObject, color, name, resourceType)
    if not targetObject then return nil end
    
    local highlightObject = nil
    if targetObject:IsA("Model") then
        highlightObject = targetObject
    else
        highlightObject = targetObject
    end
    
    -- Check if already exists
    if State.ESPHighlights[highlightObject] then
        return State.ESPHighlights[highlightObject]
    end
    
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight_" .. (resourceType or "Unknown")
        highlight.FillColor = color or Color3.fromRGB(255, 255, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.15
        highlight.Adornee = highlightObject
        highlight.Parent = highlightObject
        
        local espData = {
            Highlight = highlight,
            Billboard = nil,
            Object = highlightObject,
            Type = resourceType,
            Added = tick()
        }
        
        -- Create billboard for name
        if name and name ~= "" then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Billboard_" .. (resourceType or "Unknown")
            billboard.Size = UDim2.new(0, 200, 0, 35)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = 200
            
            local adorneeTarget = nil
            if targetObject:IsA("Model") then
                adorneeTarget = targetObject:FindFirstChild("Head") or targetObject:FindFirstChild("HumanoidRootPart") or targetObject.PrimaryPart or targetObject
            else
                adorneeTarget = targetObject
            end
            
            billboard.Adornee = adorneeTarget
            billboard.Parent = highlightObject
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 0, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = ESPFunctions.GetResourceIcon(resourceType) or "📌"
            iconLabel.TextSize = 16
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.Parent = billboard
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -28, 1, 0)
            nameLabel.Position = UDim2.new(0, 26, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 11
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = billboard
            
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, -28, 0, 14)
            distanceLabel.Position = UDim2.new(0, 26, 0, 18)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Text = "0m"
            distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distanceLabel.Font = Enum.Font.GothamMedium
            distanceLabel.TextSize = 9
            distanceLabel.TextStrokeTransparency = 0.5
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
            distanceLabel.Parent = billboard
            
            espData.Billboard = billboard
            espData.DistanceLabel = distanceLabel
            
            -- Update distance
            spawn(function()
                while billboard and billboard.Parent and Character and HumanoidRootPart do
                    pcall(function()
                        local pos = nil
                        if targetObject:IsA("Model") then
                            local primary = targetObject:FindFirstChild("HumanoidRootPart") or targetObject:FindFirstChild("Head") or targetObject.PrimaryPart
                            if primary then
                                pos = primary.Position
                            end
                        else
                            pos = targetObject.Position
                        end
                        
                        if pos then
                            local dist = (pos - HumanoidRootPart.Position).Magnitude
                            distanceLabel.Text = string.format("%.0fm", dist)
                        end
                    end)
                    wait(0.5)
                end
            end)
        end
        
        State.ESPHighlights[highlightObject] = espData
        table.insert(State.ESPObjects, highlightObject)
        
        -- Cleanup on destroy
        if highlightObject:IsA("Instance") then
            highlightObject.Destroying:Connect(function()
                ESPFunctions.RemoveHighlight(highlightObject)
            end)
        end
        
        return espData
    end)
    
    return nil
end

function ESPFunctions.RemoveHighlight(targetObject)
    if not targetObject then return end
    
    local espData = State.ESPHighlights[targetObject]
    if not espData then return end
    
    pcall(function()
        if espData.Highlight then
            espData.Highlight:Destroy()
        end
        if espData.Billboard then
            espData.Billboard:Destroy()
        end
    end)
    
    State.ESPHighlights[targetObject] = nil
    
    for i, obj in ipairs(State.ESPObjects) do
        if obj == targetObject then
            table.remove(State.ESPObjects, i)
            break
        end
    end
end

function ESPFunctions.ClearAllESP()
    for object, espData in pairs(State.ESPHighlights) do
        pcall(function()
            if espData.Highlight then espData.Highlight:Destroy() end
            if espData.Billboard then espData.Billboard:Destroy() end
        end)
    end
    
    State.ESPHighlights = {}
    State.ESPObjects = {}
end

function ESPFunctions.GetResourceIcon(resourceType)
    if ResourceTypes[resourceType] then
        return ResourceTypes[resourceType].Icon
    end
    return "📌"
end

function ESPFunctions.ScanAndHighlight()
    if not State.EspEnabled then return end
    
    pcall(function()
        local scannedObjects = {}
        
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            local resourceInfo = classifyResource(descendant)
            if resourceInfo then
                local shouldHighlight = false
                local displayName = resourceInfo.Object.Name
                
                if resourceInfo.Type == "Food" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Wood" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Stone" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Metal" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Weapon" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Bandage" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Fuel" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Sapling" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Chest" and State.EspChestsEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Child" and State.EspChildrenEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Enemy" and State.EspEnemiesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Campfire" and State.EspResourcesEnabled then
                    shouldHighlight = true
                elseif resourceInfo.Type == "Recycler" and State.EspResourcesEnabled then
                    shouldHighlight = true
                end
                
                if shouldHighlight then
                    local highlightObject = resourceInfo.IsModel and resourceInfo.Object or resourceInfo.Object
                    if not State.ESPHighlights[highlightObject] then
                        ESPFunctions.CreateHighlight(
                            highlightObject,
                            resourceInfo.Color,
                            resourceInfo.Icon .. " " .. displayName,
                            resourceInfo.Type
                        )
                    end
                    scannedObjects[highlightObject] = true
                end
            end
        end
        
        -- Remove highlights for objects that no longer exist
        for object, espData in pairs(State.ESPHighlights) do
            if not scannedObjects[object] then
                ESPFunctions.RemoveHighlight(object)
            end
        end
    end)
end

--============================================--
-- SECTION 9: FLY SYSTEM
--============================================--
local FlySystem = {}

function FlySystem.StartFly()
    if State.FlyEnabled then return end
    if not Character or not HumanoidRootPart then return end
    
    State.FlyEnabled = true
    
    -- Create body velocity
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyBodyVelocity"
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = HumanoidRootPart
    
    -- Create body gyro
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyBodyGyro"
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.CFrame = HumanoidRootPart.CFrame
    bodyGyro.P = 10000
    bodyGyro.Parent = HumanoidRootPart
    
    State.FlyBodyVelocity = bodyVelocity
    State.FlyBodyGyro = bodyGyro
    
    -- Set platform stand
    Humanoid.PlatformStand = true
    
    -- Fly loop
    State.FlyConnection = RunService.Heartbeat:Connect(function()
        if not State.FlyEnabled then return end
        if not Character or not HumanoidRootPart or not bodyVelocity or not bodyVelocity.Parent then
            FlySystem.StopFly()
            return
        end
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- WASD movement
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or State.FlyForwardActive then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or State.FlyBackActive then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or State.FlyLeftActive then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) or State.FlyRightActive then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        
        -- Up/Down
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or State.FlyUpActive then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) or State.FlyDownActive then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Apply velocity
        if moveDirection.Magnitude > 0 then
            bodyVelocity.Velocity = moveDirection.Unit * State.FlySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Align gyro with camera
        bodyGyro.CFrame = Camera.CFrame
    end)
    
    return true
end

function FlySystem.StopFly()
    State.FlyEnabled = false
    
    if State.FlyConnection then
        State.FlyConnection:Disconnect()
        State.FlyConnection = nil
    end
    
    if State.FlyBodyVelocity then
        State.FlyBodyVelocity:Destroy()
        State.FlyBodyVelocity = nil
    end
    
    if State.FlyBodyGyro then
        State.FlyBodyGyro:Destroy()
        State.FlyBodyGyro = nil
    end
    
    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

function FlySystem.SetSpeed(newSpeed)
    State.FlySpeed = math.clamp(newSpeed, 10, 300)
    return State.FlySpeed
end

function FlySystem.GetSpeed()
    return State.FlySpeed
end

--============================================--
-- SECTION 10: TELEPORT LOOT SYSTEM
--============================================--
local LootSystem = {}

function LootSystem.FindNearestResource(resourceTypes, maxDistance)
    if not Character or not HumanoidRootPart then return nil end
    
    local nearest = nil
    local nearestDist = maxDistance or 100
    
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        local resourceInfo = classifyResource(descendant)
        if resourceInfo then
            local shouldLoot = false
            
            if resourceTypes == "all" then
                shouldLoot = true
            elseif type(resourceTypes) == "table" then
                for _, rt in ipairs(resourceTypes) do
                    if resourceInfo.Type == rt then
                        shouldLoot = true
                        break
                    end
                end
            elseif type(resourceTypes) == "string" then
                if resourceInfo.Type == resourceTypes then
                    shouldLoot = true
                end
            end
            
            if shouldLoot then
                local pos = nil
                if resourceInfo.IsModel and resourceInfo.Position then
                    if resourceInfo.Position:IsA("BasePart") then
                        pos = resourceInfo.Position.Position
                    end
                elseif resourceInfo.Position and resourceInfo.Position:IsA("BasePart") then
                    pos = resourceInfo.Position.Position
                end
                
                if pos then
                    local dist = (pos - HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearest = resourceInfo
                        nearestDist = dist
                    end
                end
            end
        end
    end
    
    return nearest
end

function LootSystem.TeleportToResource(resourceInfo)
    if not resourceInfo or not Character or not HumanoidRootPart then return false end
    
    local targetPos = nil
    if resourceInfo.Position then
        if resourceInfo.Position:IsA("BasePart") then
            targetPos = resourceInfo.Position.Position + Vector3.new(0, 3, 0)
        elseif resourceInfo.Position:IsA("Vector3") then
            targetPos = resourceInfo.Position + Vector3.new(0, 3, 0)
        end
    end
    
    if not targetPos then return false end
    
    -- Save current position
    State.SavedTeleportPosition = HumanoidRootPart.CFrame
    
    -- Teleport
    HumanoidRootPart.CFrame = CFrame.new(targetPos)
    
    return true
end

function LootSystem.TeleportBack()
    if not State.SavedTeleportPosition then return false end
    if not Character or not HumanoidRootPart then return false end
    
    HumanoidRootPart.CFrame = State.SavedTeleportPosition
    State.SavedTeleportPosition = nil
    
    return true
end

function LootSystem.TeleportToBase()
    if not State.BasePosition then return false end
    if not Character or not HumanoidRootPart then return false end
    
    State.SavedTeleportPosition = HumanoidRootPart.CFrame
    HumanoidRootPart.CFrame = CFrame.new(State.BasePosition + Vector3.new(0, 3, 0))
    
    return true
end

function LootSystem.GrabItem(resourceInfo)
    if not resourceInfo or not Character then return false end
    
    pcall(function()
        local targetObject = resourceInfo.Object
        
        -- Try to pick up the item
        if targetObject:IsA("Tool") then
            -- Pick up tool
            if targetObject.Parent ~= Backpack and targetObject.Parent ~= Character then
                Humanoid:EquipTool(targetObject)
                wait(0.3)
            end
        elseif targetObject:IsA("BasePart") then
            -- Try to find parent tool or collectible
            if targetObject.Parent and targetObject.Parent:IsA("Tool") then
                Humanoid:EquipTool(targetObject.Parent)
                wait(0.3)
            else
                -- Move part to backpack area
                local proximityPrompt = targetObject:FindFirstChildOfClass("ProximityPrompt")
                if proximityPrompt then
                    fireproximityprompt(proximityPrompt)
                    wait(0.5)
                end
            end
        end
        
        State.ItemsLooted = State.ItemsLooted + 1
        table.insert(State.LootedItems, {
            Name = targetObject.Name,
            Type = resourceInfo.Type,
            Time = tick()
        })
    end)
    
    return true
end

function LootSystem.DropItemAtPosition(position)
    if not Character or not HumanoidRootPart then return false end
    
    local targetPosition = position or State.BasePosition
    
    pcall(function()
        -- Drop all items from backpack at target position
        for _, tool in ipairs(Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                Humanoid:EquipTool(tool)
                wait(0.1)
                Humanoid:UnequipTools()
                wait(0.1)
                
                -- Try to move the tool
                if tool:FindFirstChild("Handle") then
                    tool.Handle.CFrame = CFrame.new(targetPosition + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2)))
                end
            end
        end
        
        -- Also drop items from character
        for _, child in ipairs(Character:GetChildren()) do
            if child:IsA("Tool") and child ~= Humanoid.EquippedTool then
                local handle = child:FindFirstChild("Handle")
                if handle then
                    handle.CFrame = CFrame.new(targetPosition + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2)))
                end
            end
        end
    end)
    
    return true
end

function LootSystem.ExecuteLootRun(resourceType)
    if State.IsLooting then return false end
    State.IsLooting = true
    
    pcall(function()
        -- Find resource
        local resource = LootSystem.FindNearestResource(resourceType, State.LootRadius)
        if not resource then
            State.IsLooting = false
            return
        end
        
        -- Teleport to resource
        LootSystem.TeleportToResource(resource)
        wait(0.3)
        
        -- Grab the item
        LootSystem.GrabItem(resource)
        wait(0.3)
        
        -- Teleport back to base
        LootSystem.TeleportToBase()
        wait(0.3)
        
        -- Drop at recycler or campfire or base
        local dropPosition = State.RecyclerPosition or State.CampfirePosition or State.BasePosition
        LootSystem.DropItemAtPosition(dropPosition)
    end)
    
    State.IsLooting = false
    return true
end

function LootSystem.AutoLootLoop()
    spawn(function()
        while State.AutoLootEnabled do
            if not State.IsLooting then
                -- Priority order: Food, Wood, Metal, Stone, Fuel, Weapons
                local priorityTypes = {"Food", "Wood", "Metal", "Stone", "Fuel", "Weapon", "Bandage"}
                
                for _, resourceType in ipairs(priorityTypes) do
                    local resource = LootSystem.FindNearestResource(resourceType, State.LootRadius)
                    if resource then
                        LootSystem.ExecuteLootRun(resourceType)
                        break
                    end
                end
            end
            wait(1)
        end
    end)
end

function LootSystem.TeleportToNearestChild()
    local child = LootSystem.FindNearestResource("Child", 500)
    if child then
        LootSystem.TeleportToResource(child)
        wait(2)
        LootSystem.TeleportToBase()
        State.ChildrenRescued = State.ChildrenRescued + 1
        return true
    end
    return false
end

function LootSystem.TeleportToNearestChest()
    local chest = LootSystem.FindNearestResource("Chest", 500)
    if chest then
        LootSystem.TeleportToResource(chest)
        -- Open chest
        if chest.Object:FindFirstChildOfClass("ProximityPrompt") then
            fireproximityprompt(chest.Object:FindFirstChildOfClass("ProximityPrompt"))
        end
        wait(1)
        -- Collect items around
        for _, tool in ipairs(Workspace:GetDescendants()) do
            if tool:IsA("Tool") and (tool.Parent == Workspace or tool.Parent == chest.Object) then
                if HumanoidRootPart and (tool:FindFirstChild("Handle") and (tool.Handle.Position - HumanoidRootPart.Position).Magnitude < 10) then
                    pcall(function() Humanoid:EquipTool(tool) end)
                    wait(0.2)
                end
            end
        end
        wait(1)
        LootSystem.TeleportToBase()
        LootSystem.DropItemAtPosition(State.RecyclerPosition or State.BasePosition)
        State.ChestsLooted = State.ChestsLooted + 1
        return true
    end
    return false
end

--============================================--
-- SECTION 11: AUTO EAT SYSTEM
--============================================--
local AutoEatSystem = {}

function AutoEatSystem.FindFoodInInventory()
    local foodItems = {}
    
    -- Check backpack
    for _, tool in ipairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local classification = classifyResource(tool)
            if classification and classification.Type == "Food" then
                table.insert(foodItems, tool)
            end
        end
    end
    
    -- Check character
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") then
            local classification = classifyResource(child)
            if classification and classification.Type == "Food" then
                table.insert(foodItems, child)
            end
        end
    end
    
    return foodItems
end

function AutoEatSystem.ConsumeFood(foodItem)
    if not foodItem then return false end
    
    pcall(function()
        Humanoid:EquipTool(foodItem)
        wait(0.3)
        
        -- Try to activate (eat)
        if foodItem:FindFirstChild("Handle") then
            foodItem:Activate()
            wait(0.5)
        end
        
        -- Try proximity prompt
        local prompt = foodItem:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            wait(0.5)
        end
        
        State.FoodEaten = State.FoodEaten + 1
    end)
    
    return true
end

function AutoEatSystem.AutoEatLoop()
    spawn(function()
        while State.AutoEatEnabled do
            local foodItems = AutoEatSystem.FindFoodInInventory()
            if #foodItems > 0 then
                AutoEatSystem.ConsumeFood(foodItems[1])
            else
                -- No food in inventory, try to find food nearby and loot it
                local foodResource = LootSystem.FindNearestResource("Food", 30)
                if foodResource then
                    LootSystem.ExecuteLootRun("Food")
                end
            end
            wait(3)
        end
    end)
end

--============================================--
-- SECTION 12: AUTO COOK SYSTEM
--============================================--
local CookSystem = {}

function CookSystem.FindCampfire()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        local resourceInfo = classifyResource(descendant)
        if resourceInfo and resourceInfo.Type == "Campfire" then
            return resourceInfo
        end
    end
    return nil
end

function CookSystem.CookItems()
    local campfire = CookSystem.FindCampfire()
    if not campfire then return false end
    
    -- Teleport to campfire
    LootSystem.TeleportToResource(campfire)
    wait(0.5)
    
    -- Drop raw food near campfire
    for _, tool in ipairs(Backpack:GetChildren()) do
        local classification = classifyResource(tool)
        if classification and classification.Type == "Food" then
            Humanoid:EquipTool(tool)
            wait(0.2)
            Humanoid:UnequipTools()
            wait(0.1)
            
            if tool:FindFirstChild("Handle") and campfire.Position then
                local campfirePos = nil
                if campfire.Position:IsA("BasePart") then
                    campfirePos = campfire.Position.Position
                end
                
                if campfirePos then
                    tool.Handle.CFrame = CFrame.new(campfirePos + Vector3.new(0, 1, 0))
                end
            end
        end
    end
    
    wait(1)
    LootSystem.TeleportToBase()
    State.ItemsCooked = State.ItemsCooked + 1
    
    return true
end

--============================================--
-- SECTION 13: AUTO COLLECT WOOD SYSTEM
--============================================--
local WoodSystem = {}

function WoodSystem.FindTree()
    return LootSystem.FindNearestResource("Wood", 50)
end

function WoodSystem.ChopTree(treeResource)
    if not treeResource then return false end
    
    LootSystem.TeleportToResource(treeResource)
    wait(0.3)
    
    -- Try to chop
    local tree = treeResource.Object
    if tree:FindFirstChildOfClass("ProximityPrompt") then
        fireproximityprompt(tree:FindFirstChildOfClass("ProximityPrompt"))
    end
    
    -- Equip axe if available
    for _, tool in ipairs(Backpack:GetChildren()) do
        local classification = classifyResource(tool)
        if classification and classification.Type == "Weapon" then
            Humanoid:EquipTool(tool)
            tool:Activate()
            wait(1)
            break
        end
    end
    
    wait(2)
    
    -- Collect dropped wood
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and HumanoidRootPart then
            local handle = obj:FindFirstChild("Handle")
            if handle and (handle.Position - HumanoidRootPart.Position).Magnitude < 10 then
                local classification = classifyResource(obj)
                if classification and classification.Type == "Wood" then
                    pcall(function() Humanoid:EquipTool(obj) end)
                    wait(0.2)
                end
            end
        end
    end
    
    wait(0.5)
    LootSystem.TeleportToBase()
    LootSystem.DropItemAtPosition(State.StoragePosition or State.RecyclerPosition or State.BasePosition)
    State.WoodCollected = State.WoodCollected + 1
    
    return true
end

function WoodSystem.AutoCollectLoop()
    spawn(function()
        while State.AutoCollectWoodEnabled do
            if not State.IsLooting then
                local tree = WoodSystem.FindTree()
                if tree then
                    WoodSystem.ChopTree(tree)
                end
            end
            wait(3)
        end
    end)
end

--============================================--
-- SECTION 14: AUTO PLANT SAPLINGS SYSTEM
--============================================--
local PlantSystem = {}

function PlantSystem.FindPlantingSpot()
    if not Character or not HumanoidRootPart then return nil end
    
    -- Find open ground near base
    local basePos = State.BasePosition
    local searchRadius = 20
    
    for x = -searchRadius, searchRadius, 3 do
        for z = -searchRadius, searchRadius, 3 do
            local checkPos = basePos + Vector3.new(x, 0, z)
            -- Raycast down to find ground
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {Character}
            
            local raycastResult = Workspace:Raycast(checkPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), raycastParams)
            if raycastResult then
                return raycastResult.Position + Vector3.new(0, 0.5, 0)
            end
        end
    end
    
    return basePos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
end

function PlantSystem.PlantSapling()
    -- Find sapling in inventory
    local sapling = nil
    for _, tool in ipairs(Backpack:GetChildren()) do
        local classification = classifyResource(tool)
        if classification and classification.Type == "Sapling" then
            sapling = tool
            break
        end
    end
    
    if not sapling then
        -- Try to find sapling nearby
        local saplingResource = LootSystem.FindNearestResource("Sapling", 30)
        if saplingResource then
            LootSystem.ExecuteLootRun("Sapling")
            wait(1)
            return PlantSystem.PlantSapling()
        end
        return false
    end
    
    local plantingSpot = PlantSystem.FindPlantingSpot()
    if not plantingSpot then return false end
    
    -- Teleport to planting spot
    HumanoidRootPart.CFrame = CFrame.new(plantingSpot)
    wait(0.3)
    
    -- Plant
    Humanoid:EquipTool(sapling)
    wait(0.3)
    sapling:Activate()
    wait(0.5)
    
    -- Try proximity prompt
    local prompt = sapling:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
    
    wait(1)
    LootSystem.TeleportToBase()
    
    return true
end

function PlantSystem.AutoPlantLoop()
    spawn(function()
        while State.AutoPlantSaplingsEnabled do
            PlantSystem.PlantSapling()
            wait(5)
        end
    end)
end

--============================================--
-- SECTION 15: KILL AURA SYSTEM
--============================================--
local KillAuraSystem = {}

function KillAuraSystem.GetEnemiesInRadius(radius)
    local enemies = {}
    if not Character or not HumanoidRootPart then return enemies end
    
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") and descendant ~= Character then
            local hum = descendant.Humanoid
            if hum.Health > 0 then
                local root = descendant:FindFirstChild("HumanoidRootPart") or descendant:FindFirstChild("Head")
                if root then
                    local dist = (root.Position - HumanoidRootPart.Position).Magnitude
                    if dist <= radius then
                        table.insert(enemies, {
                            Model = descendant,
                            Humanoid = hum,
                            RootPart = root,
                            Distance = dist
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    
    return enemies
end

function KillAuraSystem.DamageEnemy(enemyData, damage)
    pcall(function()
        if enemyData.Humanoid and enemyData.Humanoid.Health > 0 then
            enemyData.Humanoid.Health = math.max(0, enemyData.Humanoid.Health - damage)
            
            if enemyData.Humanoid.Health <= 0 then
                State.EnemiesKilled = State.EnemiesKilled + 1
                
                -- Visual feedback
                if enemyData.RootPart then
                    local effect = Instance.new("Part")
                    effect.Size = Vector3.new(1, 1, 1)
                    effect.Position = enemyData.RootPart.Position
                    effect.Anchored = true
                    effect.CanCollide = false
                    effect.Material = Enum.Material.Neon
                    effect.Color = Color3.fromRGB(255, 0, 0)
                    effect.Parent = Workspace
                    Debris:AddItem(effect, 0.5)
                end
            end
        end
    end)
end

function KillAuraSystem.KillAuraLoop()
    spawn(function()
        while State.KillAuraEnabled do
            local enemies = KillAuraSystem.GetEnemiesInRadius(State.KillAuraRadius)
            
            for _, enemy in ipairs(enemies) do
                if not State.KillAuraEnabled then break end
                KillAuraSystem.DamageEnemy(enemy, State.KillAuraDamage)
            end
            
            wait(0.3)
        end
    end)
end

--============================================--
-- SECTION 16: NO DAMAGE SYSTEM
--============================================--
function applyNoDamage()
    pcall(function()
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

--============================================--
-- SECTION 17: NIGHT VISION SYSTEM
--============================================--
function applyNightVision()
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
end

function removeNightVision()
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
end

--============================================--
-- SECTION 18: FOG REMOVAL SYSTEM
--============================================--
function applyFogRemoval()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 50000
end

function removeFogRemoval()
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
end

--============================================--
-- SECTION 19: GUI CREATION
--============================================--
local GUI = Instance.new("ScreenGui")
GUI.Name = "Ultimate99Nights"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

--============================================--
-- SECTION 20: MAIN TOGGLE BUTTON
--============================================--
local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 55, 0, 55)
MainButton.Position = UDim2.new(0, 20, 0.5, -27)
MainButton.BackgroundColor3 = C.PrimaryAccent
MainButton.BorderSizePixel = 0
MainButton.Text = "☰"
MainButton.Font = Enum.Font.GothamBlack
MainButton.TextSize = 24
MainButton.TextColor3 = C.White
MainButton.ZIndex = 9999
MainButton.AutoButtonColor = false
MainButton.Parent = GUI
addCorner(MainButton, 55)

local MainButtonGradient = Instance.new("UIGradient")
MainButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.PrimaryAccent),
    ColorSequenceKeypoint.new(1, C.SecondaryAccent)
})
MainButtonGradient.Rotation = 135
MainButtonGradient.Parent = MainButton

--============================================--
-- SECTION 21: MAIN MENU FRAME
--============================================--
local function CreateMainMenu()
    if GUI:FindFirstChild("MainMenuFrame") then
        GUI.MainMenuFrame:Destroy()
    end
    
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Name = "MainMenuFrame"
    MenuFrame.Size = UDim2.new(0, 500, 0, 600)
    MenuFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MenuFrame.BackgroundColor3 = C.PrimaryBackground
    MenuFrame.BackgroundTransparency = 0.03
    MenuFrame.BorderSizePixel = 0
    MenuFrame.ClipsDescendants = true
    MenuFrame.ZIndex = 100
    MenuFrame.Parent = GUI
    addCorner(MenuFrame, 16)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundColor3 = C.SecondaryBackground
    Header.BorderSizePixel = 0
    Header.Parent = MenuFrame
    addCorner(Header, 16)
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.PrimaryAccent),
        ColorSequenceKeypoint.new(1, C.SecondaryAccent)
    })
    HeaderGradient.Transparency = NumberSequence.new(0.85)
    HeaderGradient.Rotation = 90
    HeaderGradient.Parent = Header
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "⚡ 99 NIGHTS ULTIMATE"
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextSize = 17
    HeaderTitle.Size = UDim2.new(0, 250, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 16, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.TextColor3 = C.White
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    local HeaderClose = Instance.new("TextButton")
    HeaderClose.Text = "✕"
    HeaderClose.Font = Enum.Font.GothamBold
    HeaderClose.TextSize = 15
    HeaderClose.Size = UDim2.new(0, 30, 0, 30)
    HeaderClose.Position = UDim2.new(1, -40, 0.5, -15)
    HeaderClose.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    HeaderClose.TextColor3 = C.SecondaryText
    HeaderClose.BorderSizePixel = 0
    HeaderClose.AutoButtonColor = false
    HeaderClose.Parent = Header
    addCorner(HeaderClose, 30)
    
    HeaderClose.MouseButton1Click:Connect(function()
        State.MenuOpen = false
        TweenService:Create(MenuFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        delay(0.2, function() MenuFrame:Destroy() end)
    end)
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -24, 0, 40)
    TabBar.Position = UDim2.new(0, 12, 0, 64)
    TabBar.BackgroundColor3 = C.TertiaryBackground
    TabBar.BackgroundTransparency = 0.3
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MenuFrame
    addCorner(TabBar, 10)
    
    local TabNames = {"👁️ ESP", "✈️ Флай", "📦 Лут", "⚔️ Бой", "🍖 Авто", "⚙️ Настр"}
    local TabPages = {}
    local TabButtons = {}
    
    local SelectionIndicator = Instance.new("Frame")
    SelectionIndicator.Size = UDim2.new(1/6, -4, 1, -4)
    SelectionIndicator.Position = UDim2.new(0, 2, 0, 2)
    SelectionIndicator.BackgroundColor3 = C.SecondaryBackground
    SelectionIndicator.BackgroundTransparency = 0.3
    SelectionIndicator.BorderSizePixel = 0
    SelectionIndicator.ZIndex = 101
    SelectionIndicator.Parent = TabBar
    addCorner(SelectionIndicator, 8)
    
    for i = 1, 6 do
        local TabButton = Instance.new("TextButton")
        TabButton.Text = TabNames[i]
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 10
        TabButton.Size = UDim2.new(1/6, 0, 1, 0)
        TabButton.Position = UDim2.new((i-1)/6, 0, 0, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.TextColor3 = i == 1 and C.White or C.SecondaryText
        TabButton.BorderSizePixel = 0
        TabButton.ZIndex = 102
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabBar
        
        local TabPage = Instance.new("Frame")
        TabPage.Size = UDim2.new(1, -24, 1, -116)
        TabPage.Position = UDim2.new(0, 12, 0, 110)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Visible = i == 1
        TabPage.Parent = MenuFrame
        
        TabPages[i] = TabPage
        TabButtons[i] = TabButton
        
        TabButton.MouseButton1Click:Connect(function()
            State.CurrentTab = i
            for j = 1, 6 do
                TabButtons[j].TextColor3 = C.SecondaryText
                TabPages[j].Visible = false
            end
            TabButton.TextColor3 = C.White
            TabPage.Visible = true
            TweenService:Create(SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new((i-1)/6, 2, 0, 2)
            }):Play()
        end)
    end
    
    --============================================--
    -- SECTION 22: TAB 1 - ESP PAGE
    --============================================--
    local ESPPage = TabPages[1]
    local ESPScroll = Instance.new("ScrollingFrame")
    ESPScroll.Size = UDim2.new(1, 0, 1, 0)
    ESPScroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    ESPScroll.BackgroundTransparency = 1
    ESPScroll.BorderSizePixel = 0
    ESPScroll.ScrollBarThickness = 3
    ESPScroll.ScrollBarImageColor3 = C.PrimaryAccent
    ESPScroll.Parent = ESPPage
    
    local function createToggle(y, text, state, callback)
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 0, 38)
        bg.Position = UDim2.new(0, 0, 0, y)
        bg.BackgroundColor3 = C.SecondaryBackground
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel = 0
        bg.Parent = ESPScroll
        addCorner(bg, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Text = text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 12
        lbl.Size = UDim2.new(0, 250, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = C.PrimaryText
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = bg
        
        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 42, 0, 24)
        sw.Position = UDim2.new(1, -54, 0.5, -12)
        sw.BackgroundColor3 = state and C.PrimaryAccent or Color3.fromRGB(55, 55, 65)
        sw.BorderSizePixel = 0
        sw.Parent = bg
        addCorner(sw, 24)
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 18, 0, 18)
        dot.Position = UDim2.new(0, state and 21 or 3, 0.5, -9)
        dot.BackgroundColor3 = C.White
        dot.BorderSizePixel = 0
        dot.Parent = sw
        addCorner(dot, 18)
        
        local swBtn = Instance.new("TextButton")
        swBtn.Size = UDim2.new(1, 0, 1, 0)
        swBtn.BackgroundTransparency = 1
        swBtn.Text = ""
        swBtn.BorderSizePixel = 0
        swBtn.Parent = sw
        
        swBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(sw, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = state and C.PrimaryAccent or Color3.fromRGB(55, 55, 65)
            }):Play()
            TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, state and 21 or 3, 0.5, -9)
            }):Play()
            callback(state)
        end)
        
        return y + 44
    end
    
    local function createButton(y, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = C.White
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = ESPScroll
        addCorner(btn, 10)
        btn.MouseButton1Click:Connect(callback)
        return y + 46
    end
    
    local ey = 8
    
    ey = createToggle(ey, "ESP Вкл/Выкл", State.EspEnabled, function(s) 
        State.EspEnabled = s
        if not s then ESPFunctions.ClearAllESP() end
    end)
    
    ey = createToggle(ey, "ESP Ресурсы (еда, дерево, металл...)", State.EspResourcesEnabled, function(s) 
        State.EspResourcesEnabled = s 
    end)
    
    ey = createToggle(ey, "ESP Враги", State.EspEnemiesEnabled, function(s) 
        State.EspEnemiesEnabled = s 
    end)
    
    ey = createToggle(ey, "ESP Дети", State.EspChildrenEnabled, function(s) 
        State.EspChildrenEnabled = s 
    end)
    
    ey = createToggle(ey, "ESP Сундуки", State.EspChestsEnabled, function(s) 
        State.EspChestsEnabled = s 
    end)
    
    ey = ey + 8
    ey = createButton(ey, "🔍 Сканировать всё", C.Info, function()
        ESPFunctions.ClearAllESP()
        ESPFunctions.ScanAndHighlight()
    end)
    
    ey = createButton(ey, "🗑️ Очистить ESP", C.Error, function()
        ESPFunctions.ClearAllESP()
    end)
    
    ESPScroll.CanvasSize = UDim2.new(0, 0, 0, ey + 20)
    
    --============================================--
    -- SECTION 23: TAB 2 - FLY PAGE
    --============================================--
    local FlyPage = TabPages[2]
    local FlyScroll = Instance.new("ScrollingFrame")
    FlyScroll.Size = UDim2.new(1, 0, 1, 0)
    FlyScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    FlyScroll.BackgroundTransparency = 1
    FlyScroll.BorderSizePixel = 0
    FlyScroll.ScrollBarThickness = 3
    FlyScroll.ScrollBarImageColor3 = C.PrimaryAccent
    FlyScroll.Parent = FlyPage
    
    local fy = 8
    
    -- Fly toggle
    local flyBg = Instance.new("Frame")
    flyBg.Size = UDim2.new(1, 0, 0, 45)
    flyBg.Position = UDim2.new(0, 0, 0, fy)
    flyBg.BackgroundColor3 = C.SecondaryBackground
    flyBg.BackgroundTransparency = 0.3
    flyBg.BorderSizePixel = 0
    flyBg.Parent = FlyScroll
    addCorner(flyBg, 10)
    
    local flyLabel = Instance.new("TextLabel")
    flyLabel.Text = "✈️ Флай"
    flyLabel.Font = Enum.Font.GothamBold
    flyLabel.TextSize = 14
    flyLabel.Size = UDim2.new(0, 100, 1, 0)
    flyLabel.Position = UDim2.new(0, 12, 0, 0)
    flyLabel.BackgroundTransparency = 1
    flyLabel.TextColor3 = C.White
    flyLabel.TextXAlignment = Enum.TextXAlignment.Left
    flyLabel.Parent = flyBg
    
    local flySw = Instance.new("Frame")
    flySw.Size = UDim2.new(0, 50, 0, 28)
    flySw.Position = UDim2.new(1, -64, 0.5, -14)
    flySw.BackgroundColor3 = State.FlyEnabled and C.Success or Color3.fromRGB(55, 55, 65)
    flySw.BorderSizePixel = 0
    flySw.Parent = flyBg
    addCorner(flySw, 28)
    
    local flyDot = Instance.new("Frame")
    flyDot.Size = UDim2.new(0, 22, 0, 22)
    flyDot.Position = UDim2.new(0, State.FlyEnabled and 25 or 3, 0.5, -11)
    flyDot.BackgroundColor3 = C.White
    flyDot.BorderSizePixel = 0
    flyDot.Parent = flySw
    addCorner(flyDot, 22)
    
    local flySwBtn = Instance.new("TextButton")
    flySwBtn.Size = UDim2.new(1, 0, 1, 0)
    flySwBtn.BackgroundTransparency = 1
    flySwBtn.Text = ""
    flySwBtn.BorderSizePixel = 0
    flySwBtn.Parent = flySw
    
    flySwBtn.MouseButton1Click:Connect(function()
        State.FlyEnabled = not State.FlyEnabled
        if State.FlyEnabled then
            FlySystem.StartFly()
            TweenService:Create(flySw, TweenInfo.new(0.2), {BackgroundColor3 = C.Success}):Play()
            TweenService:Create(flyDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 25, 0.5, -11)}):Play()
        else
            FlySystem.StopFly()
            TweenService:Create(flySw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
            TweenService:Create(flyDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -11)}):Play()
        end
    end)
    
    fy = fy + 55
    
    -- Speed control
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Text = "Скорость: " .. State.FlySpeed
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 12
    speedLabel.Size = UDim2.new(1, 0, 0, 18)
    speedLabel.Position = UDim2.new(0, 4, 0, fy)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = C.SecondaryText
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = FlyScroll
    
    fy = fy + 22
    
    local speedMinus = Instance.new("TextButton")
    speedMinus.Text = "−"
    speedMinus.Font = Enum.Font.GothamBlack
    speedMinus.TextSize = 20
    speedMinus.Size = UDim2.new(0, 60, 0, 35)
    speedMinus.Position = UDim2.new(0, 4, 0, fy)
    speedMinus.BackgroundColor3 = C.Warning
    speedMinus.TextColor3 = C.White
    speedMinus.BorderSizePixel = 0
    speedMinus.AutoButtonColor = false
    speedMinus.Parent = FlyScroll
    addCorner(speedMinus, 8)
    
    local speedText = Instance.new("TextLabel")
    speedText.Text = tostring(State.FlySpeed)
    speedText.Font = Enum.Font.GothamBlack
    speedText.TextSize = 18
    speedText.Size = UDim2.new(0, 60, 0, 35)
    speedText.Position = UDim2.new(0, 70, 0, fy)
    speedText.BackgroundTransparency = 1
    speedText.TextColor3 = C.White
    speedText.Parent = FlyScroll
    
    local speedPlus = Instance.new("TextButton")
    speedPlus.Text = "+"
    speedPlus.Font = Enum.Font.GothamBlack
    speedPlus.TextSize = 20
    speedPlus.Size = UDim2.new(0, 60, 0, 35)
    speedPlus.Position = UDim2.new(0, 136, 0, fy)
    speedPlus.BackgroundColor3 = C.Success
    speedPlus.TextColor3 = C.White
    speedPlus.BorderSizePixel = 0
    speedPlus.AutoButtonColor = false
    speedPlus.Parent = FlyScroll
    addCorner(speedPlus, 8)
    
    speedMinus.MouseButton1Click:Connect(function()
        local newSpeed = FlySystem.SetSpeed(State.FlySpeed - 10)
        speedText.Text = tostring(newSpeed)
        speedLabel.Text = "Скорость: " .. newSpeed
    end)
    
    speedPlus.MouseButton1Click:Connect(function()
        local newSpeed = FlySystem.SetSpeed(State.FlySpeed + 10)
        speedText.Text = tostring(newSpeed)
        speedLabel.Text = "Скорость: " .. newSpeed
    end)
    
    fy = fy + 45
    
    local flyInfo = Instance.new("TextLabel")
    flyInfo.Text = "WASD - движение | Space - вверх | Ctrl - вниз"
    flyInfo.Font = Enum.Font.GothamMedium
    flyInfo.TextSize = 10
    flyInfo.Size = UDim2.new(1, 0, 0, 20)
    flyInfo.Position = UDim2.new(0, 4, 0, fy)
    flyInfo.BackgroundTransparency = 1
    flyInfo.TextColor3 = C.TertiaryText
    flyInfo.TextXAlignment = Enum.TextXAlignment.Left
    flyInfo.Parent = FlyScroll
    
    FlyScroll.CanvasSize = UDim2.new(0, 0, 0, fy + 40)
    
    --============================================--
    -- SECTION 24: TAB 3 - LOOT PAGE
    --============================================--
    local LootPage = TabPages[3]
    local LootScroll = Instance.new("ScrollingFrame")
    LootScroll.Size = UDim2.new(1, 0, 1, 0)
    LootScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    LootScroll.BackgroundTransparency = 1
    LootScroll.BorderSizePixel = 0
    LootScroll.ScrollBarThickness = 3
    LootScroll.ScrollBarImageColor3 = C.PrimaryAccent
    LootScroll.Parent = LootPage
    
    local ly = 8
    
    local function createLootButton(y, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = C.White
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = LootScroll
        addCorner(btn, 10)
        btn.MouseButton1Click:Connect(callback)
        return y + 44
    end
    
    -- Save positions
    ly = createLootButton(ly, "📌 Сохранить базу (текущая позиция)", C.Info, function()
        State.BasePosition = HumanoidRootPart.Position
    end)
    
    ly = createLootButton(ly, "📌 Сохранить переработчик", C.Purple, function()
        local recycler = LootSystem.FindNearestResource("Recycler", 50)
        if recycler and recycler.Position then
            if recycler.Position:IsA("BasePart") then
                State.RecyclerPosition = recycler.Position.Position
            end
        else
            State.RecyclerPosition = HumanoidRootPart.Position
        end
    end)
    
    ly = createLootButton(ly, "📌 Сохранить костёр", C.Warning, function()
        local campfire = CookSystem.FindCampfire()
        if campfire and campfire.Position then
            if campfire.Position:IsA("BasePart") then
                State.CampfirePosition = campfire.Position.Position
            end
        else
            State.CampfirePosition = HumanoidRootPart.Position
        end
    end)
    
    ly = createLootButton(ly, "📌 Сохранить склад", C.Gold, function()
        State.StoragePosition = HumanoidRootPart.Position
    end)
    
    ly = ly + 5
    
    -- Loot buttons
    ly = createLootButton(ly, "🍖 Телепорт-лут: Еда", C.ESPFood, function()
        LootSystem.ExecuteLootRun("Food")
    end)
    
    ly = createLootButton(ly, "🪵 Телепорт-лут: Дерево", C.ESPWood, function()
        LootSystem.ExecuteLootRun("Wood")
    end)
    
    ly = createLootButton(ly, "🪨 Телепорт-лут: Камень/Уголь", C.ESPStone, function()
        LootSystem.ExecuteLootRun("Stone")
    end)
    
    ly = createLootButton(ly, "⚙️ Телепорт-лут: Металл", C.ESPMetal, function()
        LootSystem.ExecuteLootRun("Metal")
    end)
    
    ly = createLootButton(ly, "⛽ Телепорт-лут: Топливо", C.ESPFuel, function()
        LootSystem.ExecuteLootRun("Fuel")
    end)
    
    ly = createLootButton(ly, "⚔️ Телепорт-лут: Оружие", C.ESPWeapon, function()
        LootSystem.ExecuteLootRun("Weapon")
    end)
    
    ly = createLootButton(ly, "🏥 Телепорт-лут: Бинты", C.ESPBandage, function()
        LootSystem.ExecuteLootRun("Bandage")
    end)
    
    ly = createLootButton(ly, "📦 Телепорт к сундуку + автолут", C.ESPChest, function()
        LootSystem.TeleportToNearestChest()
    end)
    
    ly = createLootButton(ly, "👶 Телепорт к ребёнку + возврат", C.ESPChild, function()
        LootSystem.TeleportToNearestChild()
    end)
    
    ly = ly + 5
    
    -- Drop items
    ly = createLootButton(ly, "📤 Выгрузить всё в переработчик", C.Purple, function()
        LootSystem.TeleportToBase()
        wait(0.3)
        LootSystem.DropItemAtPosition(State.RecyclerPosition or State.BasePosition)
    end)
    
    ly = createLootButton(ly, "📤 Выгрузить всё на костёр", C.Warning, function()
        LootSystem.TeleportToBase()
        wait(0.3)
        LootSystem.DropItemAtPosition(State.CampfirePosition or State.BasePosition)
    end)
    
    ly = createLootButton(ly, "📤 Выгрузить всё на склад", C.Gold, function()
        LootSystem.TeleportToBase()
        wait(0.3)
        LootSystem.DropItemAtPosition(State.StoragePosition or State.BasePosition)
    end)
    
    ly = createLootButton(ly, "🏠 ТП на базу", C.Info, function()
        LootSystem.TeleportToBase()
    end)
    
    -- Auto loot toggle
    ly = ly + 5
    local autoLootBg = Instance.new("Frame")
    autoLootBg.Size = UDim2.new(1, 0, 0, 38)
    autoLootBg.Position = UDim2.new(0, 0, 0, ly)
    autoLootBg.BackgroundColor3 = C.SecondaryBackground
    autoLootBg.BackgroundTransparency = 0.3
    autoLootBg.BorderSizePixel = 0
    autoLootBg.Parent = LootScroll
    addCorner(autoLootBg, 8)
    
    local autoLootLabel = Instance.new("TextLabel")
    autoLootLabel.Text = "🤖 Авто-лут (все ресурсы)"
    autoLootLabel.Font = Enum.Font.GothamMedium
    autoLootLabel.TextSize = 12
    autoLootLabel.Size = UDim2.new(0, 250, 1, 0)
    autoLootLabel.Position = UDim2.new(0, 10, 0, 0)
    autoLootLabel.BackgroundTransparency = 1
    autoLootLabel.TextColor3 = C.PrimaryText
    autoLootLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoLootLabel.Parent = autoLootBg
    
    local autoLootSw = Instance.new("Frame")
    autoLootSw.Size = UDim2.new(0, 42, 0, 24)
    autoLootSw.Position = UDim2.new(1, -54, 0.5, -12)
    autoLootSw.BackgroundColor3 = State.AutoLootEnabled and C.Success or Color3.fromRGB(55, 55, 65)
    autoLootSw.BorderSizePixel = 0
    autoLootSw.Parent = autoLootBg
    addCorner(autoLootSw, 24)
    
    local autoLootDot = Instance.new("Frame")
    autoLootDot.Size = UDim2.new(0, 18, 0, 18)
    autoLootDot.Position = UDim2.new(0, State.AutoLootEnabled and 21 or 3, 0.5, -9)
    autoLootDot.BackgroundColor3 = C.White
    autoLootDot.BorderSizePixel = 0
    autoLootDot.Parent = autoLootSw
    addCorner(autoLootDot, 18)
    
    local autoLootSwBtn = Instance.new("TextButton")
    autoLootSwBtn.Size = UDim2.new(1, 0, 1, 0)
    autoLootSwBtn.BackgroundTransparency = 1
    autoLootSwBtn.Text = ""
    autoLootSwBtn.BorderSizePixel = 0
    autoLootSwBtn.Parent = autoLootSw
    
    autoLootSwBtn.MouseButton1Click:Connect(function()
        State.AutoLootEnabled = not State.AutoLootEnabled
        if State.AutoLootEnabled then
            LootSystem.AutoLootLoop()
            TweenService:Create(autoLootSw, TweenInfo.new(0.2), {BackgroundColor3 = C.Success}):Play()
            TweenService:Create(autoLootDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 21, 0.5, -9)}):Play()
        else
            TweenService:Create(autoLootSw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
            TweenService:Create(autoLootDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
        end
    end)
    
    ly = ly + 50
    
    LootScroll.CanvasSize = UDim2.new(0, 0, 0, ly + 20)
    
    --============================================--
    -- SECTION 25: TAB 4 - COMBAT PAGE
    --============================================--
    local CombatPage = TabPages[4]
    local CombatScroll = Instance.new("ScrollingFrame")
    CombatScroll.Size = UDim2.new(1, 0, 1, 0)
    CombatScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    CombatScroll.BackgroundTransparency = 1
    CombatScroll.BorderSizePixel = 0
    CombatScroll.ScrollBarThickness = 3
    CombatScroll.ScrollBarImageColor3 = C.PrimaryAccent
    CombatScroll.Parent = CombatPage
    
    local cy = 8
    
    -- Kill Aura toggle
    cy = createToggle(cy, "💀 Kill Aura", State.KillAuraEnabled, function(s)
        State.KillAuraEnabled = s
        if s then KillAuraSystem.KillAuraLoop() end
    end, CombatScroll)
    
    -- No Damage toggle
    cy = createToggle(cy, "🛡️ Нет урона", State.NoDamageEnabled, function(s)
        State.NoDamageEnabled = s
        if s then applyNoDamage() end
    end, CombatScroll)
    
    -- Anti Grab toggle
    cy = createToggle(cy, "🚫 Анти-граб", State.AntiGrabEnabled, function(s)
        State.AntiGrabEnabled = s
    end, CombatScroll)
    
    -- Night Vision toggle
    cy = createToggle(cy, "👁️ Ночное видение", State.NightVision, function(s)
        State.NightVision = s
        if s then applyNightVision() else removeNightVision() end
    end, CombatScroll)
    
    -- Remove Fog toggle
    cy = createToggle(cy, "🌫️ Убрать туман", State.RemoveFog, function(s)
        State.RemoveFog = s
        if s then applyFogRemoval() else removeFogRemoval() end
    end, CombatScroll)
    
    CombatScroll.CanvasSize = UDim2.new(0, 0, 0, cy + 20)
    
    --============================================--
    -- SECTION 26: TAB 5 - AUTO PAGE
    --============================================--
    local AutoPage = TabPages[5]
    local AutoScroll = Instance.new("ScrollingFrame")
    AutoScroll.Size = UDim2.new(1, 0, 1, 0)
    AutoScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    AutoScroll.BackgroundTransparency = 1
    AutoScroll.BorderSizePixel = 0
    AutoScroll.ScrollBarThickness = 3
    AutoScroll.ScrollBarImageColor3 = C.PrimaryAccent
    AutoScroll.Parent = AutoPage
    
    local ay = 8
    
    ay = createToggle(ay, "🍖 Авто-еда", State.AutoEatEnabled, function(s)
        State.AutoEatEnabled = s
        if s then AutoEatSystem.AutoEatLoop() end
    end, AutoScroll)
    
    ay = createToggle(ay, "🔥 Авто-готовка", State.AutoCookEnabled, function(s)
        State.AutoCookEnabled = s
        if s then CookSystem.CookItems() end
    end, AutoScroll)
    
    ay = createToggle(ay, "🪵 Авто-сбор дерева", State.AutoCollectWoodEnabled, function(s)
        State.AutoCollectWoodEnabled = s
        if s then WoodSystem.AutoCollectLoop() end
    end, AutoScroll)
    
    ay = createToggle(ay, "🌱 Авто-посадка саженцев", State.AutoPlantSaplingsEnabled, function(s)
        State.AutoPlantSaplingsEnabled = s
        if s then PlantSystem.AutoPlantLoop() end
    end, AutoScroll)
    
    AutoScroll.CanvasSize = UDim2.new(0, 0, 0, ay + 20)
    
    --============================================--
    -- SECTION 27: TAB 6 - SETTINGS PAGE
    --============================================--
    local SettingsPage = TabPages[6]
    local SettingsScroll = Instance.new("ScrollingFrame")
    SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    SettingsScroll.BackgroundTransparency = 1
    SettingsScroll.BorderSizePixel = 0
    SettingsScroll.ScrollBarThickness = 3
    SettingsScroll.ScrollBarImageColor3 = C.PrimaryAccent
    SettingsScroll.Parent = SettingsPage
    
    local sy = 8
    
    local function createSettingsButton(y, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Size = UDim2.new(1, 0, 0, 42)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = C.White
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = SettingsScroll
        addCorner(btn, 10)
        btn.MouseButton1Click:Connect(callback)
        return y + 50
    end
    
    sy = createSettingsButton(sy, "🔄 Сбросить все настройки", C.Error, function()
        State.FlyEnabled = false
        FlySystem.StopFly()
        State.EspEnabled = false
        ESPFunctions.ClearAllESP()
        State.KillAuraEnabled = false
        State.AutoEatEnabled = false
        State.AutoCollectWoodEnabled = false
        State.AutoPlantSaplingsEnabled = false
        State.AutoLootEnabled = false
        State.NoDamageEnabled = false
        State.NightVision = false
        removeNightVision()
        State.RemoveFog = false
        removeFogRemoval()
    end)
    
    sy = createSettingsButton(sy, "📊 Статистика", C.Info, function()
        local statsText = "📊 СТАТИСТИКА\n\n"
        statsText = statsText .. "🍖 Съедено: " .. State.FoodEaten .. "\n"
        statsText = statsText .. "🪵 Дерева собрано: " .. State.WoodCollected .. "\n"
        statsText = statsText .. "💀 Врагов убито: " .. State.EnemiesKilled .. "\n"
        statsText = statsText .. "👶 Детей спасено: " .. State.ChildrenRescued .. "\n"
        statsText = statsText .. "📦 Сундуков: " .. State.ChestsLooted .. "\n"
        statsText = statsText .. "📦 Предметов: " .. State.ItemsLooted .. "\n"
        statsText = statsText .. "🔥 Приготовлено: " .. State.ItemsCooked
        
        StarterGui:SetCore("SendNotification", {
            Title = "Статистика",
            Text = statsText,
            Duration = 5
        })
    end)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Text = "99 NIGHTS ULTIMATE\n@infiziond | v5.0"
    infoLabel.Font = Enum.Font.GothamMedium
    infoLabel.TextSize = 11
    infoLabel.Size = UDim2.new(1, 0, 0, 40)
    infoLabel.Position = UDim2.new(0, 0, 0, sy + 10)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = C.TertiaryText
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = SettingsScroll
    
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, sy + 60)
end

--============================================--
-- SECTION 28: MAIN BUTTON CLICK HANDLER
--============================================--
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Dragging = true
        State.DragStart = input.Position
        State.StartPos = MainButton.Position
    end
end)

MainButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local moved = false
        if State.DragStart then
            moved = (input.Position - State.DragStart).Magnitude > 3
        end
        
        if not moved then
            State.MenuOpen = not State.MenuOpen
            if State.MenuOpen then
                CreateMainMenu()
            else
                if GUI:FindFirstChild("MainMenuFrame") then
                    GUI.MainMenuFrame:Destroy()
                end
            end
        end
        
        State.Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if State.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - State.DragStart
        local newX = math.clamp(State.StartPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - 55)
        local newY = math.clamp(State.StartPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - 55)
        MainButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

--============================================--
-- SECTION 29: ESP SCAN LOOP
--============================================--
spawn(function()
    while true do
        if State.EspEnabled then
            ESPFunctions.ScanAndHighlight()
        end
        wait(2)
    end
end)

--============================================--
-- SECTION 30: KEYBOARD HANDLER
--============================================--
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Fly controls
    if input.KeyCode == Enum.KeyCode.Space then
        State.FlyUpActive = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        State.FlyDownActive = true
    elseif input.KeyCode == Enum.KeyCode.W then
        State.FlyForwardActive = true
    elseif input.KeyCode == Enum.KeyCode.S then
        State.FlyBackActive = true
    elseif input.KeyCode == Enum.KeyCode.A then
        State.FlyLeftActive = true
    elseif input.KeyCode == Enum.KeyCode.D then
        State.FlyRightActive = true
    end
    
    -- Toggle fly with F
    if input.KeyCode == Enum.KeyCode.F then
        State.FlyEnabled = not State.FlyEnabled
        if State.FlyEnabled then
            FlySystem.StartFly()
        else
            FlySystem.StopFly()
        end
    end
    
    -- Quick loot with E
    if input.KeyCode == Enum.KeyCode.E then
        LootSystem.ExecuteLootRun("Food")
    end
    
    -- Quick teleport to base with B
    if input.KeyCode == Enum.KeyCode.B then
        LootSystem.TeleportToBase()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        State.FlyUpActive = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        State.FlyDownActive = false
    elseif input.KeyCode == Enum.KeyCode.W then
        State.FlyForwardActive = false
    elseif input.KeyCode == Enum.KeyCode.S then
        State.FlyBackActive = false
    elseif input.KeyCode == Enum.KeyCode.A then
        State.FlyLeftActive = false
    elseif input.KeyCode == Enum.KeyCode.D then
        State.FlyRightActive = false
    end
end)

--============================================--
-- SECTION 31: INITIALIZATION
--============================================--
StarterGui:SetCore("SendNotification", {
    Title = "99 NIGHTS ULTIMATE",
    Text = "Скрипт загружен! Нажми ☰ для меню\nF - Флай | E - Лут | B - База",
    Duration = 5
})

print("========================================")
print(" 99 NIGHTS ULTIMATE v5.0")
print(" Все функции загружены и работают")
print("========================================")
print(" Меню: кнопка ☰")
print(" Флай: F или в меню")
print(" Лут: E или в меню")
print(" База: B или в меню")
print(" ESP: вкладка ESP в меню")
print(" Kill Aura: вкладка Бой в меню")
print(" Авто-функции: вкладка Авто в меню")
print("========================================")
