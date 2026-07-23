-- Настройки скрипта
local Settings = {
    SilentAim = true,
    TargetPart = "Head",   -- Куда летит пуля: "Head" или "HumanoidRootPart"
    TeamCheck = true,      -- Не трогать своих
    FOV = 150,             -- Радиус Silent Aim

    -- Настройки ВХ (ESP)
    ESP_Enabled = true,
    ShowDistance = true,   -- Показывать метры
    VisibleColor = Color3.fromRGB(0, 255, 0),   -- Зеленый (виден)
    HiddenColor = Color3.fromRGB(255, 0, 0)     -- Красный (за стеной)
}

-- Сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- Таблица для хранения графических элементов ВХ
local ESP_Cache = {}

-- Проверка видимости игрока (для изменения цвета ВХ)
local function IsPlayerVisible(TargetChar)
    local Origin = Camera.CFrame.Position
    local Destination = TargetChar[Settings.TargetPart].Position
    local RaycastParamsEx = RaycastParams.new()
    RaycastParamsEx.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParamsEx.FilterDescendantsInstances = {LocalPlayer.Character, TargetChar}
    
    local Result = workspace:Raycast(Origin, Destination - Origin, RaycastParamsEx)
    return Result == nil
end

-- Создание ВХ элементов для игрока
local function CreateESP(Player)
    if ESP_Cache[Player] then return end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = 1.5
    Box.Filled = false

    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Size = 14
    Text.Center = true
    Text.Outline = true
    Text.Color = Color3.fromRGB(255, 255, 255)

    ESP_Cache[Player] = {Box = Box, Text = Text}
end

-- Удаление ВХ
local function RemoveESP(Player)
    if ESP_Cache[Player] then
        ESP_Cache[Player].Box:Remove()
        ESP_Cache[Player].Text:Remove()
        ESP_Cache[Player] = nil
    end
end

-- Инициализация существующих игроков
for _, P in pairs(Players:GetPlayers()) do
    if P ~= LocalPlayer then CreateESP(P) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Логика отрисовки ВХ и поиска цели
local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = Settings.FOV

    for _, Player in pairs(Players:GetPlayers()) do
        local Data = ESP_Cache[Player]
        
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.TargetPart) then
            local Char = Player.Character
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            local Root = Char:FindFirstChild("HumanoidRootPart")

            -- Проверки на команду и здоровье
            if (Settings.TeamCheck and Player.Team == LocalPlayer.Team) or (Hum and Hum.Health <= 0) or not Root then
                if Data then Data.Box.Visible = false; Data.Text.Visible = false end
                continue
            end

            -- Координаты на экране
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(Root.Position)

            if OnScreen and Settings.ESP_Enabled and Data then
                -- Расчет размера бокса на основе дистанции
                local Distance = (Camera.CFrame.Position - Root.Position).Magnitude
                local MeterDistance = math.floor(Distance / 3) -- Перевод в условные метры
                local BoxHeight = math.clamp(1000 / Distance * 3, 10, 200)
                local BoxWidth = BoxHeight * 0.6

                -- Обновление Бокса
                Data.Box.Size = Vector2.new(BoxWidth, BoxHeight)
                Data.Box.Position = Vector2.new(ScreenPos.X - BoxWidth / 2, ScreenPos.Y - BoxHeight / 2)
                Data.Box.Color = IsPlayerVisible(Char) and Settings.VisibleColor or Settings.HiddenColor
                Data.Box.Visible = true

                -- Обновление текста дистанции
                if Settings.ShowDistance then
                    Data.Text.Text = string.format("[%d m]", MeterDistance)
                    Data.Text.Position = Vector2.new(ScreenPos.X, ScreenPos.Y + (BoxHeight / 2) + 2)
                    Data.Text.Visible = true
                else
                    Data.Text.Visible = false
                end
            elseif Data then
                Data.Box.Visible = false
                Data.Text.Visible = false
            end

            -- Логика аима (расчет ближайшего к мыши)
            if ScreenPos then
                local MouseDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                if MouseDistance < MaxDistance then
                    ClosestTarget = Char[Settings.TargetPart]
                    MaxDistance = MouseDistance
                end
            end
        elseif Data then
            Data.Box.Visible = false
            Data.Text.Visible = false
        end
    end
    return ClosestTarget
end

-- Постоянное обновление кадров для ВХ
RunService.RenderStepped:Connect(function()
    GetClosestPlayer()
end)

-- Перехват выстрелов (Silent Aim)
local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(Object, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if Settings.SilentAim and (Method == "FindPartOnRay" or Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local Target = GetClosestPlayer()
        if Target then
            return OldNamecall(Object, Ray.new(Camera.CFrame.Position, (Target.Position - Camera.CFrame.Position).Unit * 1000), Args)
        end
    end

    return OldNamecall(Object, ...)
end)

setreadonly(RawMetatable, true)
print("Silent Aim + Wallhack загружены!")
