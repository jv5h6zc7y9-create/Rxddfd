-- Настройки скрипта
local Settings = {
    SilentAim = true,
    TargetPart = "Head", -- Куда летит пуля: "Head" (Голова) или "HumanoidRootPart" (Торс)
    TeamCheck = true,    -- Не стрелять по своим
    FOV = 150            -- Радиус работы Silent Aim (в пикселях)
}

-- Переменные окружения
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Функция поиска ближайшей цели в радиусе FOV
local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = Settings.FOV

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.TargetPart) then
            -- Проверка на команду
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then 
                continue 
            end
            
            -- Проверка здоровья
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health <= 0 then 
                continue 
            end

            -- Расчет дистанции на экране от прицела до игрока
            local ScreenPosition, OnScreen = Camera:WorldToScreenPoint(Player.Character[Settings.TargetPart].Position)
            if OnScreen then
                local MouseDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude
                if MouseDistance < MaxDistance then
                    ClosestTarget = Player.Character[Settings.TargetPart]
                    MaxDistance = MouseDistance
                end
            end
        end
    end
    return ClosestTarget
end

-- Перехват системных вызовов игры (Namecall Hook)
local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(Object, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    -- Если игра запрашивает позицию луча или клика для выстрела
    if Settings.SilentAim and (Method == "FindPartOnRay" or Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local Target = GetClosestPlayer()
        if Target then
            -- Подменяем направление выстрела на координаты цели
            return OldNamecall(Object, Ray.new(Camera.CFrame.Position, (Target.Position - Camera.CFrame.Position).Unit * 1000), Args[2])
        end
    end

    return OldNamecall(Object, ...)
end)

setreadonly(RawMetatable, true)
print("Silent Aim успешно загружен в Delta!")
