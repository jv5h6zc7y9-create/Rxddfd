-- ==========================================
--               НАСТРОЙКИ ХИТБОКСА
-- ==========================================
local Settings = {
    Hitbox = {
        Size = 25,                    -- Размер хитбокса (чем больше число, тем больше враг)
        Transparency = 0.7,           -- Прозрачность хитбокса (0 — видно коробку, 1 — полностью невидимая)
        Color = Color3.fromRGB(0, 255, 100) -- Цвет увеличенной коробки (если Transparency меньше 1)
    },
    SuperFling = {
        Enabled = true,
        Power = 700                   -- Сила броска за карту
    },
    AntiGrab = {
        Enabled = true                -- Пассивная защита от чужих рук
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

-- Функция увеличения хитбокса для конкретного игрока
local function expandHitbox(player)
    if player == LocalPlayer then return end

    local function apply()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            
            -- Увеличиваем размер центральной части тела
            root.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
            root.Transparency = Settings.Hitbox.Transparency
            root.Color = Settings.Hitbox.Color
            root.Material = Enum.Material.Neon
            root.CanCollide = false -- Чтобы огромные хитбоксы не толкали вас физически
        end
    end

    -- Обновляем хитбокс при спавне игрока
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        apply()
    end)
    
    if player.Character then apply() end
end

-- Применяем ко всем текущим и будущим игрокам на сервере
for _, p in pairs(Players:GetPlayers()) do expandHitbox(p) end
Players.PlayerAdded:Connect(expandHitbox)

-- Постоянное удержание размера (защита от сброса скриптами игры)
RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            if root.Size.X ~= Settings.Hitbox.Size then
                root.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
            end
        end
    end
end)

-- ==========================================
--        МЕХАНИКА ДАЛЬНЕГО БРОСКА
-- ==========================================
local currentGrabbedCharacter = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Отслеживание клика
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Проверяем, наведен ли курсор на увеличенный хитбокс через стандартный клик Roblox
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        
        if target and target.Name == "HumanoidRootPart" and target.Parent ~= LocalPlayer.Character then
            local targetCharacter = target.Parent
            
            if targetCharacter and not currentGrabbedCharacter then
                -- Схватили огромный хитбокс
                currentGrabbedCharacter = targetCharacter
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    targetCharacter.HumanoidRootPart.CFrame = myRoot.CFrame + (myRoot.CFrame.LookVector * 5)
                end
            end
        elseif currentGrabbedCharacter then
            -- Если уже держим и кликаем второй раз — отправляем за карту
            local targetRoot = currentGrabbedCharacter:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local throwDirection = Camera.CFrame.LookVector
                targetRoot.Velocity = (throwDirection * Settings.SuperFling.Power) + Vector3.new(0, Settings.SuperFling.Power / 2, 0)
                targetRoot.RotVelocity = Vector3.new(math.random(-150, 150), math.random(-150, 150), math.random(-150, 150))
            end
            currentGrabbedCharacter = nil
        end
    end
end)

-- Фиксация врага перед собой во время удержания
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
