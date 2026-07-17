-- ============================================================================
-- 👑 BROSA SYSTEM v5.3 — PRIVATE ELITE MONOLITH SCRIPT HUB [ПОЛНАЯ СБОРКА]
-- 🛠️ Среда выполнения: Delta Executor / Спецификация движка: Luau (Roblox API)
-- 🎯 Оптимизировано под режим: Fling Things and People (FTAP)
-- 🎨 Дизайн-код: Полная поддержка интерфейса v4.5 + Aurora UI с кастомными прицелами
-- ============================================================================

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")

local lp = Players.LocalPlayer
if not lp.Character then lp.CharacterAdded:Wait() end
local camera = workspace.CurrentCamera

_G.BrosaHub = {
	Flags = {
		FlingAura = false, ClickFling = false, FlingAll = false, KillAura = false, 
		BringAll = false, PropsFling = false, OrbitPlayer = false, GrabEnabled = false,
		AntiGrab = false, AntiFling = false, GodMode = false, AntiVoid = false, AntiRagdoll = false,
		InfJump = false, Fly = false, Noclip = false, TPToPlayer = false, ClickTP = false,
		PlayerESP = false, NameESP = false, TracerESP = false, Fullbright = false, Starfield = false,
		Kidnap = false, AnimateFling = false, MassWeld = false, NetClaim = false, 
		LobbyFreeze = false, ChatSpam = false, AntiReport = false, ServerHopper = false,
		AutoFarm = false, AutoQuest = false, PotatoPC = false,
		-- НОВЫЕ ФЛАГИ V5.3
		InstaGrabZeroDelay = false, ThrowUnderMap = false, AutoIntercept = false,
		AntiRagdollSpam = false, AnchorPallet = false, True3DESP = false, BoxESP = false,
		ForceThirdPerson = false
	},
	Options = {
		WalkSpeed = 16,
		JumpPower = 50,
		FlySpeed = 50,
		FlingPower = 6500,
		AuraRadius = 100,
		OrbitRadius = 7,
		OrbitSpeed = 12,
		ChatSpamDelay = 2.5,
		ThrowForce = 150,
		MaxDistance = 200,
		AspectRatio = 1.5,
		StretchX = 840,    
		StretchY = 560,
		CrosshairType = "Circle", 
		CrosshairColor = Color3.fromRGB(99, 102, 241), 
		CrosshairThickness = 2,
		CrosshairSides = 4, 
		CrosshairAlpha = 0.75,
		LineColor = Color3.fromRGB(239, 68, 68),
		-- НОВЫЕ НАСТРОЙКИ V5.3
		BoxColor = Color3.fromRGB(255, 255, 255),
		BoxTextureID = "",
		BoxSizeOffset = 1,
		SkyboxType = "Default",
		CameraDistance = 12.5
	},
	Whitelist = {}, -- Вайтлист игроков
	Cache = {
		OrbitTarget = nil,
		ActivePage = "attack",
		DrawingObjects = {}, 
		Connections = {},
		OriginalTextures = {},
		ESPBoxes = {}, -- Кэш для 3D ESP
		OriginalLighting = {
			Brightness = Lighting.Brightness,
			GlobalShadows = Lighting.GlobalShadows,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient
		}
	},
	TargetPart = "HumanoidRootPart",
	DeviceMode = "PC"
}

local function getChar() return lp.Character end
local function getRoot() return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end

-- Вспомогательная функция для симуляции клика (Родной захват/бросок без задержек)
local function SimulateNativeClick(targetPos)
	local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
	if onScreen then
		VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 1)
		task.wait()
		VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 1)
	end
end

local rawmetatable = getrawmetatable or debug.getmetatable
if rawmetatable and make_writeable then
	local mt = rawmetatable(game)
	local old_index = mt.__index
	local old_newindex = mt.__newindex
	pcall(function()
		make_writeable(mt)
		mt.__index = newcclosure(function(self, key)
			if not checkcaller() and self:IsA("Humanoid") then
				if key == "WalkSpeed" then return 16 end
				if key == "JumpPower" then return 50 end
			end
			return old_index(self, key)
		end)
		mt.__newindex = newcclosure(function(self, key, value)
			if not checkcaller() and self:IsA("Humanoid") then
				if key == "WalkSpeed" and _G.BrosaHub.Flags.Fly then return end
			end
			return old_newindex(self, key, value)
		end)
		make_readonly(mt)
	end)
end

local Colors = {
	BgPanel = Color3.fromRGB(9, 9, 11),       
	BgSidebar = Color3.fromRGB(3, 3, 3),     
	BgCard = Color3.fromRGB(20, 20, 23),     
	Border = Color3.fromRGB(36, 36, 39),     
	Accent = Color3.fromRGB(99, 102, 241),   
	TextMain = Color3.fromRGB(244, 244, 245), 
	TextMuted = Color3.fromRGB(113, 113, 122),
	StatusGreen = Color3.fromRGB(46, 204, 113)
}

local function DestroyBrosaSystemForever()
	for flag, _ in pairs(_G.BrosaHub.Flags) do _G.BrosaHub.Flags[flag] = false end
	for name, connection in pairs(_G.BrosaHub.Cache.Connections) do if connection then connection:Disconnect() end end
	for obj, tex in pairs(_G.BrosaHub.Cache.OriginalTextures) do if obj and obj.Parent then obj.Texture = tex end end
	
	Lighting.Brightness = _G.BrosaHub.Cache.OriginalLighting.Brightness
	Lighting.GlobalShadows = _G.BrosaHub.Cache.OriginalLighting.GlobalShadows
	Lighting.Ambient = _G.BrosaHub.Cache.OriginalLighting.Ambient
	Lighting.OutdoorAmbient = _G.BrosaHub.Cache.OriginalLighting.OutdoorAmbient
	
	local hum = getHum()
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStand, true)
	end
	
	if _G.BrosaHub.Cache.DrawingObjects then
		for _, drawObj in pairs(_G.BrosaHub.Cache.DrawingObjects) do
			if drawObj and drawObj.Destroy then drawObj:Destroy() end
		end
	end
	
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			local hl = p.Character:FindFirstChild("BrosaESP_Highlight") if hl then hl:Destroy() end
			if p.Character:FindFirstChild("Head") then
				local nameGui = p.Character.Head:FindFirstChild("BrosaNameGui") if nameGui then nameGui:Destroy() end
			end
			-- Очистка 3D ESP
			for _, child in pairs(p.Character:GetChildren()) do
				if child.Name == "Brosa3DBox" or child.Name == "BrosaBoxTexture" then child:Destroy() end
			end
		end
	end
	for _, oldBeam in pairs(workspace:GetChildren()) do
		if oldBeam.Name:sub(1, 12) == "BrosaTracer_" then oldBeam:Destroy() end
	end
	
	local ui = CoreGui:FindFirstChild("BrosaSystemV4_UI") or lp.PlayerGui:FindFirstChild("BrosaSystemV4_UI")
	if ui then ui:Destroy() end
	local aui = lp.PlayerGui:FindFirstChild("AuroraMenu")
	if aui then aui:Destroy() end
	_G.BrosaHub = nil
end

for _, old in pairs(CoreGui:GetChildren()) do if old.Name == "BrosaSystemV4_UI" then old:Destroy() end end
if lp:WaitForChild("PlayerGui"):FindFirstChild("BrosaSystemV4_UI") then lp.PlayerGui.BrosaSystemV4_UI:Destroy() end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "BrosaSystemV4_UI"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = lp:WaitForChild("PlayerGui")

local WindowContainer = Instance.new("Frame", MainGui)
WindowContainer.Name = "WindowContainer"
WindowContainer.Size = UDim2.new(0, _G.BrosaHub.Options.StretchX, 0, _G.BrosaHub.Options.StretchY)
WindowContainer.Position = UDim2.new(0.5, -(_G.BrosaHub.Options.StretchX / 2), 0.5, -(_G.BrosaHub.Options.StretchY / 2))
WindowContainer.BackgroundTransparency = 1
WindowContainer.BorderSizePixel = 0

local LoadingScreen = Instance.new("Frame", WindowContainer)
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Colors.BgPanel
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 100

local LoadingCorner = Instance.new("UICorner", LoadingScreen)
LoadingCorner.CornerRadius = UDim.new(0, 12)
local LoadingStroke = Instance.new("UIStroke", LoadingScreen)
LoadingStroke.Color = Colors.Border
LoadingStroke.Thickness = 1

local LoaderTitle = Instance.new("TextLabel", LoadingScreen)
LoaderTitle.Size = UDim2.new(1, 0, 0, 20)
LoaderTitle.Position = UDim2.new(0, 0, 0.5, -30)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "BROSA SYSTEM V5.3"
LoaderTitle.TextColor3 = Colors.TextMain
LoaderTitle.Font = Enum.Font.RobotoMono
LoaderTitle.TextSize = 14
LoaderTitle.ZIndex = 101

local LoaderBarBg = Instance.new("Frame", LoadingScreen)
LoaderBarBg.Size = UDim2.new(0, 200, 0, 4)
LoaderBarBg.Position = UDim2.new(0.5, -100, 0.5, 10)
LoaderBarBg.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
LoaderBarBg.BorderSizePixel = 0
LoaderBarBg.ZIndex = 101
Instance.new("UICorner", LoaderBarBg).CornerRadius = UDim.new(0, 10)

local LoaderBarFill = Instance.new("Frame", LoaderBarBg)
LoaderBarFill.Size = UDim2.new(0, 0, 1, 0)
LoaderBarFill.BackgroundColor3 = Colors.Accent
LoaderBarFill.BorderSizePixel = 0
LoaderBarFill.ZIndex = 102
Instance.new("UICorner", LoaderBarFill).CornerRadius = UDim.new(0, 10)

local LoaderBarGlow = Instance.new("ImageLabel", LoaderBarFill)
LoaderBarGlow.Size = UDim2.new(1, 20, 1, 20)
LoaderBarGlow.Position = UDim2.new(0, -10, 0, -10)
LoaderBarGlow.BackgroundTransparency = 1
LoaderBarGlow.Image = "rbxassetid://6015897843"
LoaderBarGlow.ImageColor3 = Colors.Accent
LoaderBarGlow.ImageTransparency = 0.6
LoaderBarGlow.ZIndex = 103

local MainPanel = Instance.new("Frame", WindowContainer)
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(1, 0, 1, 0)
MainPanel.BackgroundColor3 = Colors.BgPanel
MainPanel.BorderSizePixel = 0
MainPanel.ClipsDescendants = true
MainPanel.Visible = false
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainPanel)
MainStroke.Color = Colors.Border

local Dragging, DragInput, DragStart, StartPosition
local function UpdateDrag(input)
	local delta = input.Position - DragStart
	WindowContainer.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
end

WindowContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPosition = WindowContainer.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)
WindowContainer.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		DragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		UpdateDrag(input)
	end
end)

task.spawn(function()
	TweenService:Create(LoaderBarFill, TweenInfo.new(1.1, Enum.EasingStyle.Cubic), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
	task.wait(1.3)
	TweenService:Create(LoaderBarFill, TweenInfo.new(0.8, Enum.EasingStyle.Cubic), {Size = UDim2.new(0.85, 0, 1, 0)}):Play()
	task.wait(0.9)
	TweenService:Create(LoaderBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	task.wait(0.7)

	local screenHideInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
	TweenService:Create(LoadingScreen, screenHideInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, _G.BrosaHub.Options.StretchX * 1.05, 0, _G.BrosaHub.Options.StretchY * 1.05), Position = UDim2.new(0, -21, 0, -14)}):Play()
	TweenService:Create(LoaderTitle, screenHideInfo, {TextTransparency = 1}):Play()
	TweenService:Create(LoaderBarBg, screenHideInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoaderBarFill, screenHideInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoaderBarGlow, screenHideInfo, {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingStroke, screenHideInfo, {Transparency = 1}):Play()
	task.wait(0.4)
	LoadingScreen:Destroy()

	MainPanel.Visible = true
	MainPanel.Size = UDim2.new(0, _G.BrosaHub.Options.StretchX - 17, 0, _G.BrosaHub.Options.StretchY - 12)
	MainPanel.Position = UDim2.new(0, 8, 0, 6)
	MainPanel.BackgroundTransparency = 0
	MainPanel.Transparency = 0
	WindowContainer.BackgroundTransparency = 1
	TweenService:Create(MainPanel, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()
end)

local Sidebar = Instance.new("Frame", MainPanel)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 230, 1, 0)
Sidebar.BackgroundColor3 = Colors.BgSidebar
Sidebar.BorderSizePixel = 0

local SidebarStroke = Instance.new("Frame", Sidebar)
SidebarStroke.Size = UDim2.new(0, 1, 1, 0)
SidebarStroke.Position = UDim2.new(1, -1, 0, 0)
SidebarStroke.BackgroundColor3 = Colors.Border

local SidebarTop = Instance.new("Frame", Sidebar)
SidebarTop.Size = UDim2.new(1, 0, 1, -115)
SidebarTop.BackgroundTransparency = 1

local Logo = Instance.new("TextLabel", SidebarTop)
Logo.Size = UDim2.new(1, -24, 0, 40)
Logo.Position = UDim2.new(0, 24, 0, 24)
Logo.BackgroundTransparency = 1
Logo.Text = "BROSA SYSTEM"
Logo.TextColor3 = Colors.TextMain
Logo.Font = Enum.Font.SourceSansBold
Logo.TextSize = 13
Logo.TextXAlignment = Enum.TextXAlignment.Left

local NavList = Instance.new("Frame", SidebarTop)
NavList.Size = UDim2.new(1, -24, 1, -80)
NavList.Position = UDim2.new(0, 12, 0, 80)
NavList.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavList)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)

local PagesContainer = Instance.new("Frame", MainPanel)
PagesContainer.Size = UDim2.new(1, -230, 1, 0)
PagesContainer.Position = UDim2.new(0, 230, 0, 0)
PagesContainer.BackgroundColor3 = Colors.BgPanel

local NavButtons = {}
local function switchPage(pageName, clickedButton)
	_G.BrosaHub.Cache.ActivePage = pageName
	for name, btn in pairs(NavButtons) do
		TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Colors.TextMuted, BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		TweenService:Create(btn.ActiveIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	end
	TweenService:Create(clickedButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Colors.TextMain, BackgroundColor3 = Color3.fromRGB(8, 8, 26)}):Play()
	TweenService:Create(clickedButton.ActiveIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
	for _, pageFrame in pairs(PagesContainer:GetChildren()) do
		if pageFrame:IsA("ScrollingFrame") then
			if pageFrame.Name == "Page_" .. pageName then
				pageFrame.Visible = true
				pageFrame.CanvasPosition = Vector2.new(0, 0)
				TweenService:Create(pageFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)}):Play()
			else
				TweenService:Create(pageFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 15, 0, 0)}):Play()
				task.delay(0.2, function()
					if _G.BrosaHub.Cache.ActivePage ~= pageFrame.Name:sub(6) then
						pageFrame.Visible = false
					end
				end)
			end
		end
	end
end

local function createNavItem(displayName, targetPage, layoutOrder)
	local NavItem = Instance.new("TextButton", NavList)
	NavItem.Size = UDim2.new(1, 0, 0, 38)
	NavItem.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	NavItem.BorderSizePixel = 0
	NavItem.Text = " " .. displayName
	NavItem.TextColor3 = (layoutOrder == 1) and Colors.TextMain or Colors.TextMuted
	NavItem.Font = Enum.Font.SourceSansProSemibold
	NavItem.TextSize = 13
	NavItem.TextXAlignment = Enum.TextXAlignment.Left
	NavItem.LayoutOrder = layoutOrder
	Instance.new("UICorner", NavItem).CornerRadius = UDim.new(0, 6)
	
	local ActiveIndicator = Instance.new("Frame", NavItem)
	ActiveIndicator.Name = "ActiveIndicator"
	ActiveIndicator.Size = UDim2.new(0, 2, 0, 19)
	ActiveIndicator.Position = UDim2.new(0, 0, 0.5, -9)
	ActiveIndicator.BackgroundColor3 = Colors.Accent
	ActiveIndicator.BackgroundTransparency = (layoutOrder == 1) and 0 or 1
	if layoutOrder == 1 then
		NavItem.BackgroundColor3 = Color3.fromRGB(8, 8, 26)
	end
	NavButtons[targetPage] = NavItem
	
	NavItem.MouseEnter:Connect(function()
		if _G.BrosaHub.Cache.ActivePage ~= targetPage then
			TweenService:Create(NavItem, TweenInfo.new(0.2), {TextColor3 = Colors.TextMain, BackgroundColor3 = Color3.fromRGB(6, 6, 6)}):Play()
		end
	end)
	NavItem.MouseLeave:Connect(function()
		if _G.BrosaHub.Cache.ActivePage ~= targetPage then
			TweenService:Create(NavItem, TweenInfo.new(0.2), {TextColor3 = Colors.TextMuted, BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		end
	end)
	NavItem.MouseButton1Click:Connect(function()
		switchPage(targetPage, NavItem)
	end)
end

createNavItem("Combat & Fling", "attack", 1)
createNavItem("Defense & Safe", "defense", 2)
createNavItem("Movement & TP", "movement", 3)
createNavItem("Visuals & ESP", "visuals", 4)
createNavItem("Crosshair Panel", "crosshair", 5)
createNavItem("Exploits & Server", "exploits", 6)
createNavItem("Whitelist", "whitelist", 7) -- НОВАЯ ВКЛАДКА

local ExitHubBtn = Instance.new("TextButton", Sidebar)
ExitHubBtn.Name = "ExitHubBtn"
ExitHubBtn.Size = UDim2.new(1, -24, 0, 30)
ExitHubBtn.Position = UDim2.new(0, 12, 1, -112)
ExitHubBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
ExitHubBtn.Text = "Закрыть скрипт навсегда"
ExitHubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitHubBtn.Font = Enum.Font.SourceSansProBold
ExitHubBtn.TextSize = 12
Instance.new("UICorner", ExitHubBtn).CornerRadius = UDim.new(0, 6)
ExitHubBtn.MouseButton1Click:Connect(function()
	DestroyBrosaSystemForever()
end)

local ProfileBox = Instance.new("Frame", Sidebar)
ProfileBox.Size = UDim2.new(1, -24, 0, 56)
ProfileBox.Position = UDim2.new(0, 12, 1, -68)
ProfileBox.BackgroundColor3 = Colors.BgCard
Instance.new("UICorner", ProfileBox).CornerRadius = UDim.new(0, 8)

local ProfileStroke = Instance.new("UIStroke", ProfileBox)
ProfileStroke.Color = Colors.Border

local AvatarMini = Instance.new("Frame", ProfileBox)
AvatarMini.Size = UDim2.new(0, 32, 0, 32)
AvatarMini.Position = UDim2.new(0, 12, 0.5, -16)
Instance.new("UICorner", AvatarMini).CornerRadius = UDim.new(1, 0)

local AvatarGradient = Instance.new("UIGradient", AvatarMini)
AvatarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Colors.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 180, 252))})
AvatarGradient.Rotation = 135

local AvatarText = Instance.new("TextLabel", AvatarMini)
AvatarText.Size = UDim2.new(1, 0, 1, 0)
AvatarText.BackgroundTransparency = 1
AvatarText.Text = "BS"
AvatarText.TextColor3 = Color3.fromRGB(255, 255, 255)
AvatarText.Font = Enum.Font.SourceSansBold
AvatarText.TextSize = 11

local MetaMini = Instance.new("Frame", ProfileBox)
MetaMini.Size = UDim2.new(1, -62, 1, 0)
MetaMini.Position = UDim2.new(0, 52, 0, 0)
MetaMini.BackgroundTransparency = 1

local NameMini = Instance.new("TextLabel", MetaMini)
NameMini.Size = UDim2.new(1, 0, 0, 16)
NameMini.Position = UDim2.new(0, 0, 0.5, -14)
NameMini.BackgroundTransparency = 1
NameMini.Text = lp.Name or "Delta User"
NameMini.TextColor3 = Colors.TextMain
NameMini.Font = Enum.Font.SourceSansBold
NameMini.TextSize = 12
NameMini.TextXAlignment = Enum.TextXAlignment.Left

local StatusMini = Instance.new("TextLabel", MetaMini)
StatusMini.Size = UDim2.new(1, 0, 0, 14)
StatusMini.Position = UDim2.new(0, 0, 0.5, 2)
StatusMini.BackgroundTransparency = 1
StatusMini.Text = "Active Premium"
StatusMini.TextColor3 = Colors.StatusGreen
StatusMini.Font = Enum.Font.SourceSansPro
StatusMini.TextSize = 10
StatusMini.TextXAlignment = Enum.TextXAlignment.Left
StatusMini.Parent = MetaMini

local LayoutCounters = {}
local function getNextLayoutOrder(pageFrame)
	if not LayoutCounters[pageFrame.Name] then 
		LayoutCounters[pageFrame.Name] = 1 
	else 
		LayoutCounters[pageFrame.Name] = LayoutCounters[pageFrame.Name] + 1 
	end
	return LayoutCounters[pageFrame.Name]
end

local function createPage(pageName, isVisible)
	local PageFrame = Instance.new("ScrollingFrame", PagesContainer)
	PageFrame.Name = "Page_" .. pageName 
	PageFrame.Size = UDim2.new(1, 0, 1, 0) 
	PageFrame.BackgroundTransparency = 1 
	PageFrame.BorderSizePixel = 0 
	PageFrame.ScrollBarThickness = 4 
	PageFrame.ScrollBarImageColor3 = Color3.fromRGB(36, 36, 39)
	PageFrame.Visible = isVisible
	
	local PagePadding = Instance.new("UIPadding", PageFrame)
	PagePadding.PaddingTop = UDim.new(0, 30) 
	PagePadding.PaddingBottom = UDim.new(0, 30) 
	PagePadding.PaddingLeft = UDim.new(0, 30) 
	PagePadding.PaddingRight = UDim.new(0, 30)
	
	local PageListLayout = Instance.new("UIListLayout", PageFrame)
	PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
	PageListLayout.Padding = UDim.new(0, 8)
	
	PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
		PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 60) 
	end)
	return PageFrame
end

local PageAttack = createPage("attack", true)
local PageDefense = createPage("defense", false)
local PageMovement = createPage("movement", false)
local PageVisuals = createPage("visuals", false)
local PageCrosshair = createPage("crosshair", false)
local PageExploits = createPage("exploits", false)
local PageWhitelist = createPage("whitelist", false)

local function createSectionHeader(parentPage, titleText, descText)
	local HeaderFrame = Instance.new("Frame", parentPage)
	HeaderFrame.Size = UDim2.new(1, 0, 0, 50) 
	HeaderFrame.BackgroundTransparency = 1 
	HeaderFrame.LayoutOrder = getNextLayoutOrder(parentPage)
	
	local TitleLabel = Instance.new("TextLabel", HeaderFrame)
	TitleLabel.Size = UDim2.new(1, 0, 0, 20) 
	TitleLabel.BackgroundTransparency = 1 
	TitleLabel.Text = titleText 
	TitleLabel.TextColor3 = Colors.TextMain 
	TitleLabel.Font = Enum.Font.SourceSansBold 
	TitleLabel.TextSize = 16 
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local DescLabel = Instance.new("TextLabel", HeaderFrame)
	DescLabel.Size = UDim2.new(1, 0, 0, 16) 
	DescLabel.Position = UDim2.new(0, 0, 0, 22) 
	DescLabel.BackgroundTransparency = 1 
	DescLabel.Text = descText 
	DescLabel.TextColor3 = Colors.TextMuted 
	DescLabel.Font = Enum.Font.SourceSansPro 
	DescLabel.TextSize = 12 
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left
end

createSectionHeader(PageAttack, "Attack & Fling Функции", "Управление физическим давлением и уничтожением целей на сервере FTAP.")
createSectionHeader(PageDefense, "Defense & Safety Функции", "Защита вашей физической оболочки от чужих атак и скриптов захвата.")
createSectionHeader(PageMovement, "Movement & Teleport Функции", "Свободное перемещение по координатной сетке карты и кастомизация физики.")
createSectionHeader(PageVisuals, "Visuals & ESP Функции", "Рендеринг скрытых объектов, подсветка игроков и модификация окружения.")
createSectionHeader(PageCrosshair, "Crosshair Panel (Прицелы)", "Кастомизация векторной графики перекрестий, колец FOV и лазеров Drawing API.")
createSectionHeader(PageExploits, "Exploits & Automation", "Сетевые манипуляции, троллинг сервера, автоматизация фарма квестов и PotatoPC.")
createSectionHeader(PageWhitelist, "Server Whitelist (Исключения)", "Управление списком игроков, на которых не действуют атаки, боксы и ВХ.")

local function createFeatureCard(parentPage, featureName, featureDesc)
	local Card = Instance.new("Frame", parentPage)
	Card.Name = "Card_" .. featureName:gsub("%s+", "") 
	Card.Size = UDim2.new(1, -4, 0, 62) 
	Card.BackgroundColor3 = Colors.BgCard 
	Card.BorderSizePixel = 0 
	Card.LayoutOrder = getNextLayoutOrder(parentPage)
	
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
	local CardStroke = Instance.new("UIStroke", Card)
	CardStroke.Color = Colors.Border 
	CardStroke.Thickness = 1
	
	local InfoFrame = Instance.new("Frame", Card)
	InfoFrame.Size = UDim2.new(1, -180, 1, 0) 
	InfoFrame.BackgroundTransparency = 1
	Instance.new("UIPadding", InfoFrame).PaddingLeft = UDim.new(0, 18)
	
	local NameLabel = Instance.new("TextLabel", InfoFrame)
	NameLabel.Size = UDim2.new(1, 0, 0, 18) 
	NameLabel.Position = UDim2.new(0, 0, 0.5, -18) 
	NameLabel.BackgroundTransparency = 1 
	NameLabel.Text = featureName 
	NameLabel.TextColor3 = Colors.TextMain 
	NameLabel.Font = Enum.Font.SourceSansBold 
	NameLabel.TextSize = 13 
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local DescLabel = Instance.new("TextLabel", InfoFrame)
	DescLabel.Size = UDim2.new(1, 0, 0, 14) 
	DescLabel.Position = UDim2.new(0, 0, 0.5, 2) 
	DescLabel.BackgroundTransparency = 1 
	DescLabel.Text = featureDesc 
	DescLabel.TextColor3 = Colors.TextMuted 
	DescLabel.Font = Enum.Font.SourceSansPro 
	DescLabel.TextSize = 11 
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	Card.InputBegan:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseMovement then 
			TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(23, 23, 28)}):Play() 
			TweenService:Create(CardStroke, TweenInfo.new(0.2), {Color = Colors.Accent}):Play() 
		end 
	end)
	Card.InputEnded:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseMovement then 
			TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Colors.BgCard}):Play() 
			TweenService:Create(CardStroke, TweenInfo.new(0.2), {Color = Colors.Border}):Play() 
		end 
	end)
	return Card
end

local function createToggleComponent(cardParent, flagKey, callback)
	local Switch = Instance.new("TextButton", cardParent)
	Switch.Size = UDim2.new(0, 38, 0, 20) 
	Switch.Position = UDim2.new(1, -56, 0.5, -10) 
	Switch.BackgroundColor3 = Color3.fromRGB(39, 39, 42) 
	Switch.Text = "" 
	Switch.AutoButtonColor = false
	
	Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
	local Circle = Instance.new("Frame", Switch)
	Circle.Size = UDim2.new(0, 14, 0, 14) 
	Circle.Position = UDim2.new(0, 3, 0.5, -7) 
	Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
	Circle.BorderSizePixel = 0
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
	
	local function updateToggleState(state)
		_G.BrosaHub.Flags[flagKey] = state
		local targetBg = state and Colors.Accent or Color3.fromRGB(39, 39, 42)
		local targetPos = state and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		TweenService:Create(Switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(Circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
		if callback then task.spawn(callback, state) end
	end
	Switch.MouseButton1Click:Connect(function() updateToggleState(not _G.BrosaHub.Flags[flagKey]) end)
end

local function createSliderComponent(cardParent, optionKey, minVal, maxVal, defaultVal, callback)
	local SliderContainer = Instance.new("Frame", cardParent)
	SliderContainer.Size = UDim2.new(0, 150, 0, 20) 
	SliderContainer.Position = UDim2.new(1, -168, 0.5, -10) 
	SliderContainer.BackgroundTransparency = 1
	
	local Track = Instance.new("TextButton", SliderContainer)
	Track.Size = UDim2.new(1, -34, 0, 4) 
	Track.Position = UDim2.new(0, 0, 0.5, -2) 
	Track.BackgroundColor3 = Color3.fromRGB(39, 39, 42) 
	Track.Text = "" 
	Track.AutoButtonColor = false
	Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)
	
	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new(0, 0, 1, 0) 
	Fill.BackgroundColor3 = Colors.Accent 
	Fill.BorderSizePixel = 0
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
	
	local Thumb = Instance.new("Frame", Track)
	Thumb.Size = UDim2.new(0, 12, 0, 12) 
	Thumb.Position = UDim2.new(0, -6, 0.5, -6) 
	Thumb.BackgroundColor3 = Colors.Accent 
	Thumb.BorderSizePixel = 0
	Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
	
	local ValueLabel = Instance.new("TextLabel", SliderContainer)
	ValueLabel.Size = UDim2.new(0, 24, 1, 0) 
	ValueLabel.Position = UDim2.new(1, -24, 0, 0) 
	ValueLabel.BackgroundTransparency = 1 
	ValueLabel.Text = tostring(defaultVal) 
	ValueLabel.TextColor3 = Colors.TextMain 
	ValueLabel.Font = Enum.Font.SourceSansProSemibold 
	ValueLabel.TextSize = 12 
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	
	local isSliding = false
	local function updateSliderPosition(inputPosition)
		local absPos = Track.AbsolutePosition.X 
		local absSize = Track.AbsoluteSize.X
		local percentage = math.clamp((inputPosition - absPos) / absSize, 0, 1)
		local finalValue = math.round(minVal + (percentage * (maxVal - minVal)))
		Fill.Size = UDim2.new(percentage, 0, 1, 0) 
		Thumb.Position = UDim2.new(percentage, -6, 0.5, -6) 
		ValueLabel.Text = tostring(finalValue)
		_G.BrosaHub.Options[optionKey] = finalValue 
		if callback then task.spawn(callback, finalValue) end
	end
	
	local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
	Fill.Size = UDim2.new(initPercent, 0, 1, 0) 
	Thumb.Position = UDim2.new(initPercent, -6, 0.5, -6)

	Track.InputBegan:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
			isSliding = true 
			updateSliderPosition(input.Position.X) 
		end 
	end)
	UserInputService.InputChanged:Connect(function(input) 
		if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
			updateSliderPosition(input.Position.X) 
		end 
	end)
	UserInputService.InputEnded:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
			isSliding = false 
		end 
	end)
end

-- PAGE 1: COMBAT & FLING
createToggleComponent(createFeatureCard(PageAttack, "InstaGrab (0 Delay)", "Мгновенная эмуляция оригинального клика захвата при наведении на бокс."), "InstaGrabZeroDelay")
createToggleComponent(createFeatureCard(PageAttack, "Silent Aim (FOV Center)", "Авто-наводка оригинальной кнопки точно в торс, если враг в центре экрана."), "GrabEnabled")
createToggleComponent(createFeatureCard(PageAttack, "Throw Under Map", "При захвате мгновенно направить вектор отдаления вниз под текстуры."), "ThrowUnderMap")
createToggleComponent(createFeatureCard(PageAttack, "Fling Aura", "Автоматический разброс игроков в радиусе за счет накрутки скорости Velocity."), "FlingAura")
createToggleComponent(createFeatureCard(PageAttack, "Click Fling", "Мгновенный телепорт к цели по клику мыши для совершения флинга и возврат назад."), "ClickFling")
createToggleComponent(createFeatureCard(PageAttack, "Fling All", "Циклический авто-телепорт по всему серверу для поочередного выкидывания каждого игрока."), "FlingAll")
createToggleComponent(createFeatureCard(PageAttack, "Kill Aura", "Автоматическое уничтожение персонажей или сброс их здоровья в определенном радиусе."), "KillAura")
createToggleComponent(createFeatureCard(PageAttack, "Bring All", "Принудительное стягивание всех игроков и подвижных предметов в одну точку к читеру."), "BringAll")
createToggleComponent(createFeatureCard(PageAttack, "Props Fling", "Захват тяжелых предметов карты, придание им безумного вращения и запуск в игроков."), "PropsFling")
createToggleComponent(createFeatureCard(PageAttack, "Orbit Player", "Вращение вокруг жертвы по круговой оси на бешеной скорости с использованием центробежной силы."), "OrbitPlayer", function(state)
	if state then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and not _G.BrosaHub.Whitelist[p.Name] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				_G.BrosaHub.Cache.OrbitTarget = p
				break
			end
		end
	else
		_G.BrosaHub.Cache.OrbitTarget = nil
	end
end)

createSliderComponent(createFeatureCard(PageAttack, "FOV Radius Slider", "Настройка радиуса окружности круга захвата Silent Aim."), "AuraRadius", 10, 500, 100)
createSliderComponent(createFeatureCard(PageAttack, "Fling Power Slider", "Регулировка мощности импульса вращения тела при совершении флинга."), "FlingPower", 1000, 50000, 6500)
createSliderComponent(createFeatureCard(PageAttack, "Throw Force Slider", "Регулировка силы линейного броска вперед при активации атаки."), "ThrowForce", 50, 500, 150)
createSliderComponent(createFeatureCard(PageAttack, "Max Distance Tracking", "Предельное расстояние от игрока до цели для удержания локатором."), "MaxDistance", 50, 1000, 200)

-- PAGE 2: DEFENSE & SAFE
createToggleComponent(createFeatureCard(PageDefense, "Auto-Intercept Grab", "Мгновенный ответный перехват врага, если он пытается схватить тебя."), "AutoIntercept")
createToggleComponent(createFeatureCard(PageDefense, "Anti-Ragdoll Spam", "Жесткий спам легальной кнопки вырывания/прыжка при падении в желе."), "AntiRagdollSpam")
createToggleComponent(createFeatureCard(PageDefense, "Anchor Pallet Fix", "Фиксация в земле тяжелым невидимым поддоном для 100% защиты от откидывания."), "AnchorPallet")
createToggleComponent(createFeatureCard(PageDefense, "Anti-Grab", "Отключение коллизии тела CanTouch для полной защиты от чужого захвата руками."), "AntiGrab")
createToggleComponent(createFeatureCard(PageDefense, "Anti-Fling", "Постоянный мониторинг скорости персонажа и принудительный сброс Velocity до нуля при ударах."), "AntiFling")
createToggleComponent(createFeatureCard(PageDefense, "God Mode", "Установка бесконечного здоровья или удаление локального хитбокса получения урона."), "GodMode", function(state)
	if state then
		local char = getChar()
		local hum = getHum()
		if char and hum then
			local clone = hum:Clone()
			hum:Destroy()
			clone.Parent = char
			camera.CameraSubject = char:WaitForChild("Humanoid")
		end
	end
end)
createToggleComponent(createFeatureCard(PageDefense, "Anti-Void", "Авто-детекция падения под карту по оси Y и мгновенный телепорт обратно на спавн."), "AntiVoid")
createToggleComponent(createFeatureCard(PageDefense, "Anti-Ragdoll (Native)", "Программный запрет на включение анимаций падения гуманоида Ragdoll и FallingDown."), "AntiRagdoll")

-- PAGE 3: MOVEMENT & TP
createSliderComponent(createFeatureCard(PageMovement, "WalkSpeed Changer", "Перезапись стандартного значения скорости бега в объекте Humanoid."), "WalkSpeed", 16, 300, 16)
createSliderComponent(createFeatureCard(PageMovement, "JumpPower Changer", "Настройка высоты прыжка через изменение встроенных физических параметров прыжка."), "JumpPower", 50, 500, 50)
createToggleComponent(createFeatureCard(PageMovement, "Infinite Jump", "Обход лимита прыжков за счет принудительной активации состояния Jumping при каждом нажатии пробела."), "InfJump")
createToggleComponent(createFeatureCard(PageMovement, "Fly", "Полноценный контролируемый полет персонажа по направлению взгляда камеры."), "Fly", function(state)
	local myRoot = getRoot()
	if not myRoot then return end
	if state then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "BrosaFlyBV"
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = myRoot
		local bg = Instance.new("BodyGyro")
		bg.Name = "BrosaFlyBG"
		bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bg.CFrame = camera.CFrame
		bg.Parent = myRoot
	else
		if myRoot:FindFirstChild("BrosaFlyBV") then myRoot.BrosaFlyBV:Destroy() end
		if myRoot:FindFirstChild("BrosaFlyBG") then myRoot.BrosaFlyBG:Destroy() end
	end
end)
createToggleComponent(createFeatureCard(PageMovement, "Noclip", "Отключение твердости объектов CanCollide для свободного прохода сквозь стены и текстуры."), "Noclip")
createToggleComponent(createFeatureCard(PageMovement, "TP to Player", "Мгновенное присвоение координат CFrame выбранного игрока вашему персонажу."), "TPToPlayer", function(state)
	if state then
		local players = Players:GetPlayers()
		if #players > 1 then
			local randomPlayer = players[math.random(1, #players)]
			while randomPlayer == lp or _G.BrosaHub.Whitelist[randomPlayer.Name] do
				randomPlayer = players[math.random(1, #players)]
			end
			if randomPlayer.Character and randomPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local myRoot = getRoot()
				if myRoot then
					myRoot.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
				end
			end
		end
		_G.BrosaHub.Flags.TPToPlayer = false
	end
end)
createToggleComponent(createFeatureCard(PageMovement, "Click TP", "Считывание 3D-точки клика мыши Mouse.Hit и моментальный перенос торса в это место."), "ClickTP")

-- PAGE 4: VISUALS & ESP
createToggleComponent(createFeatureCard(PageVisuals, "True 3D Box ESP", "Отрисовка объемных 3D-коробок вокруг игроков (поворачиваются в пространстве)."), "True3DESP")
createToggleComponent(createFeatureCard(PageVisuals, "Highlight ESP", "Создание блоков подсветки (Highlight) поверх моделей игроков."), "PlayerESP")
createToggleComponent(createFeatureCard(PageVisuals, "Name ESP", "Отрисовка интерфейса BillboardGui над головами целей с показом их ников и дистанции."), "NameESP")
createToggleComponent(createFeatureCard(PageVisuals, "Tracer ESP", "Рисование двухмерных линий от центра вашего экрана к трехмерным координатам игроков."), "TracerESP")

local skyCard = createFeatureCard(PageVisuals, "Skybox Customizer", "Смена окружения и типа неба.")
local skyBtn = Instance.new("TextButton", skyCard)
skyBtn.Size = UDim2.new(0, 110, 0, 24)
skyBtn.Position = UDim2.new(1, -124, 0.5, -12)
skyBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
skyBtn.Text = "Type: Default"
skyBtn.TextColor3 = Colors.TextMain
skyBtn.Font = Enum.Font.SourceSansProSemibold
skyBtn.TextSize = 12
Instance.new("UICorner", skyBtn).CornerRadius = UDim.new(0, 4)
skyBtn.MouseButton1Click:Connect(function()
	local sType = _G.BrosaHub.Options.SkyboxType
	if sType == "Default" then sType = "Black"; skyBtn.Text = "Type: Black"
	elseif sType == "Black" then sType = "Blue"; skyBtn.Text = "Type: Blue"
	elseif sType == "Blue" then sType = "White"; skyBtn.Text = "Type: White"
	elseif sType == "White" then sType = "Cosmos"; skyBtn.Text = "Type: Cosmos"
	else sType = "Default"; skyBtn.Text = "Type: Default" end
	_G.BrosaHub.Options.SkyboxType = sType
end)

createToggleComponent(createFeatureCard(PageVisuals, "Fullbright", "Отключение глобальных теней GlobalShadows и выкручивание яркости Lighting на максимум."), "Fullbright", function(state)
	if state then
		Lighting.Brightness = 4
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	else
		Lighting.Brightness = 2
		Lighting.GlobalShadows = true
		Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
end)

-- Texture Box input
local txtCard = createFeatureCard(PageVisuals, "ESP Box Texture ID", "Введи AssetID картинки для натягивания на 3D боксы (оставь пустым для цвета).")
local idInput = Instance.new("TextBox", txtCard)
idInput.Size = UDim2.new(0, 110, 0, 24)
idInput.Position = UDim2.new(1, -124, 0.5, -12)
idInput.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
idInput.TextColor3 = Colors.TextMain
idInput.PlaceholderText = "Asset ID..."
idInput.Text = ""
idInput.Font = Enum.Font.SourceSansPro
idInput.TextSize = 12
Instance.new("UICorner", idInput).CornerRadius = UDim.new(0, 4)
idInput.FocusLost:Connect(function()
	_G.BrosaHub.Options.BoxTextureID = idInput.Text
end)

-- PAGE 5: CROSSHAIR PANEL (Оставлено без изменений, логика старая)
local crossCard = createFeatureCard(PageCrosshair, "Crosshair Style Selector", "Выбор геометрической формы кастомного прицела для Silent Aim локатора.")
local crossBtn = Instance.new("TextButton", crossCard)
crossBtn.Size = UDim2.new(0, 110, 0, 24)
crossBtn.Position = UDim2.new(1, -124, 0.5, -12)
crossBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
crossBtn.Text = "Тип: Circle"
crossBtn.TextColor3 = Colors.TextMain
crossBtn.Font = Enum.Font.SourceSansProSemibold
crossBtn.TextSize = 12
Instance.new("UICorner", crossBtn).CornerRadius = UDim.new(0, 4)
crossBtn.MouseButton1Click:Connect(function()
	if _G.BrosaHub.Options.CrosshairType == "Circle" then
		_G.BrosaHub.Options.CrosshairType = "Cross"
		crossBtn.Text = "Тип: Cross"
	elseif _G.BrosaHub.Options.CrosshairType == "Cross" then
		_G.BrosaHub.Options.CrosshairType = "Dot"
		crossBtn.Text = "Тип: Dot"
	elseif _G.BrosaHub.Options.CrosshairType == "Dot" then
		_G.BrosaHub.Options.CrosshairType = "Combined"
		crossBtn.Text = "Тип: Combined"
	else
		_G.BrosaHub.Options.CrosshairType = "Circle"
		crossBtn.Text = "Тип: Circle"
	end
end)

createSliderComponent(createFeatureCard(PageCrosshair, "Crosshair Thickness", "Толщина линий векторного перекрестия или окружности прицела."), "CrosshairThickness", 1, 10, 2)
createSliderComponent(createFeatureCard(PageCrosshair, "Crosshair Polygon Sides", "Количество углов (сторон) для многоугольных кастомных форм перекрестий."), "CrosshairSides", 3, 12, 4)

local colorCard = createFeatureCard(PageCrosshair, "Crosshair Color Shifter", "Циклическое переключение цветового спектра (RGB палитра) для прицела.")
local colorBtn = Instance.new("TextButton", colorCard)
colorBtn.Size = UDim2.new(0, 110, 0, 24)
colorBtn.Position = UDim2.new(1, -124, 0.5, -12)
colorBtn.BackgroundColor3 = Colors.Accent
colorBtn.Text = "Сменить Цвет"
colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
colorBtn.Font = Enum.Font.SourceSansProSemibold
colorBtn.TextSize = 12
Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 4)
colorBtn.MouseButton1Click:Connect(function()
	local r, g, b = math.random(100, 255), math.random(100, 255), math.random(100, 255)
	_G.BrosaHub.Options.CrosshairColor = Color3.fromRGB(r, g, b)
	colorBtn.BackgroundColor3 = _G.BrosaHub.Options.CrosshairColor
end)

-- PAGE 6: EXPLOITS & AUTOMATION
createToggleComponent(createFeatureCard(PageExploits, "Force 3rd Person", "Принудительный режим от 3-го лица с кастомной дальностью."), "ForceThirdPerson")
createSliderComponent(createFeatureCard(PageExploits, "Aspect Ratio / Stretch", "Управление растяжением экрана FOV (Resolution Stretch)."), "AspectRatio", 50, 150, 100, function(val)
	if camera then camera.FieldOfView = val end
end)
createToggleComponent(createFeatureCard(PageExploits, "Kidnap Player", "Телепорт к жертве, взятие в жесткий физический захват и унос в бездну."), "Kidnap")
createToggleComponent(createFeatureCard(PageExploits, "Animate Fling", "Смена анимаций тела для непредсказуемой деформации хитбокса."), "AnimateFling")
createToggleComponent(createFeatureCard(PageExploits, "Mass Weld", "Сваривание физических хитбоксов всего мусора на карте с игроком."), "MassWeld")
createToggleComponent(createFeatureCard(PageExploits, "Network Claim", "Получение эксклюзивных прав управления физикой окружающих предметов."), "NetClaim")
createToggleComponent(createFeatureCard(PageExploits, "Lobby Freeze", "Спам импульсами касаний для тотального сброса FPS у сервера."), "LobbyFreeze")
createToggleComponent(createFeatureCard(PageExploits, "Chat Spammer", "Автоматическая отправка заданного текста в чат по таймеру."), "ChatSpam")
createToggleComponent(createFeatureCard(PageExploits, "Anti-Report", "Блокировка отображения списка игроков и панели логов."), "AntiReport", function(state)
	local g = CoreGui:FindFirstChild("PlayerList")
	if g then g.Enabled = not state end
end)
createToggleComponent(createFeatureCard(PageExploits, "Potato PC Mode", "Оптимизация производительности: полное отключение тяжелых текстур игрового мира."), "PotatoPC", function(state)
	if state then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("Texture") or obj:IsA("Decal") then
				_G.BrosaHub.Cache.OriginalTextures[obj] = obj.Texture
				obj.Texture = ""
			end
		end
	else
		for obj, tex in pairs(_G.BrosaHub.Cache.OriginalTextures) do
			if obj and obj.Parent then obj.Texture = tex end
		end
		table.clear(_G.BrosaHub.Cache.OriginalTextures)
	end
end)
createSliderComponent(createFeatureCard(PageExploits, "Menu Stretch Width", "Динамическая настройка горизонтального растяжения главного окна меню."), "StretchX", 400, 1200, 840, function(val)
	WindowContainer.Size = UDim2.new(0, val, 0, _G.BrosaHub.Options.StretchY)
	WindowContainer.Position = UDim2.new(0.5, -(val / 2), 0.5, -(_G.BrosaHub.Options.StretchY / 2))
end)
createSliderComponent(createFeatureCard(PageExploits, "Menu Stretch Height", "Динамическая настройка вертикального растяжения главного окна меню."), "StretchY", 300, 900, 560, function(val)
	WindowContainer.Size = UDim2.new(0, _G.BrosaHub.Options.StretchX, 0, val)
	WindowContainer.Position = UDim2.new(0.5, -(_G.BrosaHub.Options.StretchX / 2), 0.5, -(val / 2))
end)

-- PAGE 7: WHITELIST
local function UpdateWhitelistUI()
	for _, child in pairs(PageWhitelist:GetChildren()) do
		if child:IsA("Frame") and child.Name:sub(1,5) == "Card_" then child:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= lp then
			local wCard = createFeatureCard(PageWhitelist, p.Name, "Игнорировать данного игрока при атаках и ВХ.")
			local Switch = Instance.new("TextButton", wCard)
			Switch.Size = UDim2.new(0, 38, 0, 20) 
			Switch.Position = UDim2.new(1, -56, 0.5, -10) 
			Switch.BackgroundColor3 = _G.BrosaHub.Whitelist[p.Name] and Colors.Accent or Color3.fromRGB(39, 39, 42) 
			Switch.Text = "" 
			Switch.AutoButtonColor = false
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
			
			local Circle = Instance.new("Frame", Switch)
			Circle.Size = UDim2.new(0, 14, 0, 14) 
			Circle.Position = _G.BrosaHub.Whitelist[p.Name] and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) 
			Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
			Circle.BorderSizePixel = 0
			Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
			
			Switch.MouseButton1Click:Connect(function()
				local newState = not _G.BrosaHub.Whitelist[p.Name]
				_G.BrosaHub.Whitelist[p.Name] = newState
				TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = newState and Colors.Accent or Color3.fromRGB(39, 39, 42)}):Play()
				TweenService:Create(Circle, TweenInfo.new(0.15), {Position = newState and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
			end)
		end
	end
end
Players.PlayerAdded:Connect(UpdateWhitelistUI)
Players.PlayerRemoving:Connect(UpdateWhitelistUI)
UpdateWhitelistUI()

-- Geometric Objects Vector Drawing API (Прицелы и Локаторы)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5 
FOVCircle.Filled = false 
FOVCircle.Color = Colors.Accent 
FOVCircle.Transparency = 0.75 
FOVCircle.Visible = false
table.insert(_G.BrosaHub.Cache.DrawingObjects, FOVCircle)

local TracerLine = Drawing.new("Line")
TracerLine.Thickness = 2 
TracerLine.Color = Color3.fromRGB(239, 68, 68) 
TracerLine.Transparency = 0.9 
TracerLine.Visible = false
table.insert(_G.BrosaHub.Cache.DrawingObjects, TracerLine)

local CrosshairLines = {
	L1 = Drawing.new("Line"),
	L2 = Drawing.new("Line"),
	L3 = Drawing.new("Line"),
	L4 = Drawing.new("Line"),
	CenterDot = Drawing.new("Circle")
}
for _, obj in pairs(CrosshairLines) do
	obj.Visible = false
	table.insert(_G.BrosaHub.Cache.DrawingObjects, obj)
end

local function RenderCustomCrosshair(center, fovRadius)
	local opts = _G.BrosaHub.Options
	local cType = opts.CrosshairType
	local cColor = opts.CrosshairColor
	local cThick = opts.CrosshairThickness
	
	for _, obj in pairs(CrosshairLines) do obj.Visible = false end
	if not _G.BrosaHub.Flags.GrabEnabled then return end
	
	if cType == "Dot" or cType == "Combined" then
		CrosshairLines.CenterDot.Position = center
		CrosshairLines.CenterDot.Radius = cThick * 1.5
		CrosshairLines.CenterDot.Filled = true
		CrosshairLines.CenterDot.Color = cColor
		CrosshairLines.CenterDot.Transparency = opts.CrosshairAlpha
		CrosshairLines.CenterDot.Visible = true
	end
	
	if cType == "Cross" or cType == "Combined" then
		local gap = 5
		local length = 15
		
		CrosshairLines.L1.From = Vector2.new(center.X - gap - length, center.Y)
		CrosshairLines.L1.To = Vector2.new(center.X - gap, center.Y)
		
		CrosshairLines.L2.From = Vector2.new(center.X + gap, center.Y)
		CrosshairLines.L2.To = Vector2.new(center.X + gap + length, center.Y)
		
		CrosshairLines.L3.From = Vector2.new(center.X, center.Y - gap - length)
		CrosshairLines.L3.To = Vector2.new(center.X, center.Y - gap)
		
		CrosshairLines.L4.From = Vector2.new(center.X, center.Y + gap)
		CrosshairLines.L4.To = Vector2.new(center.X, center.Y + gap + length)
		
		for _, line in pairs({CrosshairLines.L1, CrosshairLines.L2, CrosshairLines.L3, CrosshairLines.L4}) do
			line.Color = cColor
			line.Thickness = cThick
			line.Transparency = opts.CrosshairAlpha
			line.Visible = true
		end
	end
end

local clickMouse = lp:GetMouse()
clickMouse.Button1Down:Connect(function()
	if not _G.BrosaHub then return end
	if _G.BrosaHub.Flags.ClickFling then
		local target = clickMouse.Target
		if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
			local enemyPlayer = Players:GetPlayerFromCharacter(target.Parent)
			if enemyPlayer and _G.BrosaHub.Whitelist[enemyPlayer.Name] then return end
			local enemyRoot = target.Parent:FindFirstChild("HumanoidRootPart") 
			local myRoot = getRoot()
			if enemyRoot and myRoot then
				local oldCFrame = myRoot.CFrame 
				myRoot.CFrame = enemyRoot.CFrame 
				myRoot.Velocity = Vector3.new(999999, 999999, 999999)
				task.wait(0.1) 
				myRoot.CFrame = oldCFrame 
				myRoot.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end
	if _G.BrosaHub.Flags.ClickTP then 
		local myRoot = getRoot() 
		if myRoot and clickMouse.Hit then 
			myRoot.CFrame = clickMouse.Hit + Vector3.new(0, 3, 0) 
		end 
	end
end)

UserInputService.JumpRequest:Connect(function()
	if not _G.BrosaHub then return end
	if _G.BrosaHub.Flags.InfJump then 
		local hum = getHum() 
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end 
	end
end)

_G.BrosaHub.Cache.Connections["SteppedLoop"] = RunService.Stepped:Connect(function()
	if not _G.BrosaHub then return end
	local char = getChar() 
	if not char then return end
	if _G.BrosaHub.Flags.AntiGrab then
		for _, part in pairs(char:GetChildren()) do 
			if part:IsA("BasePart") then part.CanTouch = false end 
		end
	end
	if _G.BrosaHub.Flags.Noclip then
		for _, part in pairs(char:GetChildren()) do 
			if part:IsA("BasePart") then part.CanCollide = false end 
		end
	end
end)

_G.BrosaHub.Cache.Connections["RenderSteppedLoop"] = RunService.RenderStepped:Connect(function()
	if not _G.BrosaHub then return end
	local hum = getHum() 
	local myRoot = getRoot()
	if hum and not _G.BrosaHub.Flags.Fly then
		hum.WalkSpeed = _G.BrosaHub.Options.WalkSpeed
		hum.JumpPower = _G.BrosaHub.Options.JumpPower
	end
	if _G.BrosaHub.Flags.Fly and myRoot and myRoot:FindFirstChild("BrosaFlyBV") and myRoot:FindFirstChild("BrosaFlyBG") then
		myRoot.BrosaFlyBV.Velocity = camera.CFrame.LookVector * _G.BrosaHub.Options.FlySpeed
		myRoot.BrosaFlyBG.CFrame = camera.CFrame
	end
	
	-- УМНЫЙ ANTI-GRAB И АВТО-ОТВЕТНЫЙ ПЕРЕХВАТ & АНТИ-РАГДОЛЛ
	if hum and _G.BrosaHub.Flags.AntiRagdollSpam then
		if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		end
	end
	
	if _G.BrosaHub.Flags.ForceThirdPerson then
		lp.CameraMaxZoomDistance = 1000
		lp.CameraMinZoomDistance = _G.BrosaHub.Options.CameraDistance
		camera.CFrame = camera.CFrame * CFrame.new(0, 0, _G.BrosaHub.Options.CameraDistance)
	end
end)

_G.BrosaHub.Cache.Connections["HeartbeatLoop"] = RunService.Heartbeat:Connect(function()
	if not _G.BrosaHub then return end
	local myRoot = getRoot() 
	if not myRoot then return end
	local mc = getChar()
	local hum = getHum()

	-- ФИКСАЦИЯ В ЗЕМЛЕ (ПОДДОН)
	if _G.BrosaHub.Flags.AnchorPallet then
		local pallet = mc:FindFirstChild("BrosaPalletFix")
		if not pallet then
			pallet = Instance.new("Part", mc)
			pallet.Name = "BrosaPalletFix"
			pallet.Size = Vector3.new(4, 1, 4)
			pallet.Transparency = 1
			pallet.CanCollide = false
			pallet.Anchored = true
		end
		pallet.CFrame = myRoot.CFrame * CFrame.new(0, -3, 0)
	else
		if mc:FindFirstChild("BrosaPalletFix") then mc.BrosaPalletFix:Destroy() end
	end

	-- АВТО-ПЕРЕХВАТ СО СПИНЫ
	if _G.BrosaHub.Flags.AutoIntercept then
		for _, v in pairs(mc:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("WeldConstraint") then
				if v.Part1 and v.Part1.Parent and v.Part1.Parent ~= mc and v.Part1.Parent:FindFirstChild("Humanoid") then
					local enemyRoot = v.Part1.Parent:FindFirstChild("HumanoidRootPart")
					if enemyRoot then
						-- Мы захвачены, смотрим на врага и эмулируем перехват
						myRoot.CFrame = CFrame.lookAt(myRoot.Position, enemyRoot.Position)
						SimulateNativeClick(enemyRoot.Position)
						task.wait(0.1)
						-- Бросаем врага
						if _G.BrosaHub.Flags.ThrowUnderMap then
							camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + Vector3.new(0, -1, 0))
						end
						VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1) -- Эмуляция броска (левый клик или нужная кнопка FTAP)
					end
				end
			end
		end
	end

	if _G.BrosaHub.Flags.FlingAura then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and not _G.BrosaHub.Whitelist[p.Name] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local eRoot = p.Character.HumanoidRootPart
				if (myRoot.Position - eRoot.Position).Magnitude < _G.BrosaHub.Options.AuraRadius then
					myRoot.Velocity = (eRoot.Position - myRoot.Position).Unit * _G.BrosaHub.Options.FlingPower
					myRoot.RotVelocity = Vector3.new(0, _G.BrosaHub.Options.FlingPower, 0)
				end
			end
		end
	end

	if _G.BrosaHub.Flags.FlingAll then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and not _G.BrosaHub.Whitelist[p.Name] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and _G.BrosaHub.Flags.FlingAll then
				myRoot.CFrame = p.Character.HumanoidRootPart.CFrame 
				myRoot.Velocity = Vector3.new(999999, 999999, 999999) 
				task.wait(0.06)
			end
		end
	end

	if _G.BrosaHub.Flags.KillAura and firetouchinterest then
		local tool = mc and mc:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= lp and not _G.BrosaHub.Whitelist[p.Name] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					firetouchinterest(tool.Handle, p.Character.HumanoidRootPart, 0) 
					firetouchinterest(tool.Handle, p.Character.HumanoidRootPart, 1)
				end
			end
		end
	end

	if _G.BrosaHub.Flags.BringAll then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(mc) then 
				obj.CFrame = myRoot.CFrame + Vector3.new(0, 6, 0) 
			end
		end
	end

	if _G.BrosaHub.Flags.PropsFling then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(mc) then
				if (obj.Position - myRoot.Position).Magnitude < 35 then 
					obj.RotVelocity = Vector3.new(0, 18000, 0) 
					obj.Velocity = Vector3.new(0, 120, 0) 
				end
			end
		end
	end

	if _G.BrosaHub.Flags.OrbitPlayer and _G.BrosaHub.Cache.OrbitTarget and _G.BrosaHub.Cache.OrbitTarget.Character then
		local tChar = _G.BrosaHub.Cache.OrbitTarget.Character
		if tChar:FindFirstChild("HumanoidRootPart") then
			local tRoot = tChar.HumanoidRootPart 
			local currentTime = tick() * _G.BrosaHub.Options.OrbitSpeed 
			local rad = _G.BrosaHub.Options.OrbitRadius
			myRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(math.cos(currentTime) * rad, 2, math.sin(currentTime) * rad), tRoot.Position)
		end
	end

	if _G.BrosaHub.Flags.AntiFling then
		if myRoot.Velocity.Magnitude > 85 or myRoot.RotVelocity.Magnitude > 85 then
			myRoot.Velocity = Vector3.new(0, 0, 0) 
			myRoot.RotVelocity = Vector3.new(0, 0, 0)
		end
	end

	if _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -180 then
		myRoot.CFrame = CFrame.new(0, 45, 0) 
		myRoot.Velocity = Vector3.new(0, 0, 0)
	end

	if _G.BrosaHub.Flags.AntiRagdoll and hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) 
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) 
		hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStand, false) 
	end

	if _G.BrosaHub.Flags.NetClaim and setsimulationradius then
		setsimulationradius(99999, 99999)
	end

	if _G.BrosaHub.Flags.LobbyFreeze then
		for i = 1, 30 do
			local thrust = Instance.new("BodyThrust")
			thrust.Force = Vector3.new(math.huge, math.huge, math.huge)
			thrust.Parent = myRoot
			Debris:AddItem(thrust, 0.02)
		end
	end
end)

_G.BrosaHub.Cache.Connections["AimLoop"] = RunService.RenderStepped:Connect(function()
	if not _G.BrosaHub then return end
	local centerPoint = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	
	if _G.BrosaHub.Flags.GrabEnabled then
		FOVCircle.Radius = _G.BrosaHub.Options.AuraRadius 
		FOVCircle.Position = centerPoint
		FOVCircle.Color = _G.BrosaHub.Options.CrosshairColor
		FOVCircle.Thickness = _G.BrosaHub.Options.CrosshairThickness
		FOVCircle.Visible = (_G.BrosaHub.Options.CrosshairType == "Circle" or _G.BrosaHub.Options.CrosshairType == "Combined")
		
		RenderCustomCrosshair(centerPoint, _G.BrosaHub.Options.AuraRadius)
	else
		FOVCircle.Visible = false 
		TracerLine.Visible = false 
		RenderCustomCrosshair(centerPoint, 0)
		return
	end
	
	local myRoot = getRoot() 
	if not myRoot then TracerLine.Visible = false return end
	
	local closestPlayer, shortestDistance = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= lp and not _G.BrosaHub.Whitelist[player.Name] and player.Character then
			local tPart = player.Character:FindFirstChild(_G.BrosaHub.TargetPart)
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if tPart and hum and hum.Health > 0 then
				if (myRoot.Position - tPart.Position).Magnitude <= _G.BrosaHub.Options.MaxDistance then
					local screenPos, onScreen = camera:WorldToViewportPoint(tPart.Position)
					if onScreen then
						local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - centerPoint).Magnitude
						if mouseDistance <= _G.BrosaHub.Options.AuraRadius and mouseDistance < shortestDistance then
							shortestDistance = mouseDistance
							closestPlayer = player
						end
					end
				end
			end
		end
	end
	
	if closestPlayer and closestPlayer.Character then
		local tPart = closestPlayer.Character:FindFirstChild(_G.BrosaHub.TargetPart)
		if tPart then
			local screenPos, _ = camera:WorldToViewportPoint(tPart.Position)
			TracerLine.From = centerPoint
			TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
			TracerLine.Color = _G.BrosaHub.Options.LineColor
			TracerLine.Visible = true
			
			-- 0-СЕКУНДНАЯ ЗАДЕРЖКА & ЦЕНТРАЛЬНЫЙ SILENT AIM
			if _G.BrosaHub.Flags.InstaGrabZeroDelay then
				-- Если цель в круге, моментально кликаем на неё родным методом игры
				SimulateNativeClick(tPart.Position)
				
				-- ФУНКЦИЯ ПОД ТЕКСТУРЫ (Отдаление вниз)
				if _G.BrosaHub.Flags.ThrowUnderMap then
					camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + Vector3.new(0, -1, 0))
					-- Эмуляция нажатия отдаления (в FTAP часто это прокрутка мыши или кнопка)
					VirtualInputManager:SendMouseWheelEvent(0, 0, true, game)
				end
			end
			
			if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				tPart.Velocity = (tPart.Position - myRoot.Position).Unit * _G.BrosaHub.Options.ThrowForce
			end
		else
			TracerLine.Visible = false
		end
	else
		TracerLine.Visible = false
	end
end)

_G.BrosaHub.Cache.Connections["ViewportResizeListener"] = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if FOVCircle then
		FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	end
end)

task.spawn(function()
	while task.wait(0.1) do
		if not _G.BrosaHub then break end
		local myRoot = getRoot()
		if myRoot then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= lp and p.Character then
					local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
					local hl = p.Character:FindFirstChild("BrosaESP_Highlight")
					
					-- 3D BOX ESP
					if _G.BrosaHub.Flags.True3DESP and eRoot and not _G.BrosaHub.Whitelist[p.Name] then
						local box = eRoot:FindFirstChild("Brosa3DBox")
						if not box then
							box = Instance.new("BoxHandleAdornment")
							box.Name = "Brosa3DBox"
							box.Size = Vector3.new(4, 5.5, 2)
							box.Adornee = eRoot
							box.AlwaysOnTop = true
							box.ZIndex = 5
							box.Transparency = 0.5
							box.Parent = eRoot
						end
						box.Color3 = _G.BrosaHub.Options.BoxColor
						
						-- Обработка текстур для бокса
						if _G.BrosaHub.Options.BoxTextureID ~= "" then
							local texBox = eRoot:FindFirstChild("BrosaBoxTexture")
							if not texBox then
								texBox = Instance.new("Part")
								texBox.Name = "BrosaBoxTexture"
								texBox.Size = Vector3.new(4, 5.5, 2)
								texBox.Transparency = 1
								texBox.CanCollide = false
								local weld = Instance.new("Weld", texBox)
								weld.Part0 = eRoot
								weld.Part1 = texBox
								texBox.Parent = eRoot
								
								local faces = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right}
								for _, face in pairs(faces) do
									local dec = Instance.new("Decal")
									dec.Face = face
									dec.Texture = "rbxassetid://" .. _G.BrosaHub.Options.BoxTextureID
									dec.Parent = texBox
								end
							else
								for _, dec in pairs(texBox:GetChildren()) do
									if dec:IsA("Decal") then dec.Texture = "rbxassetid://" .. _G.BrosaHub.Options.BoxTextureID end
								end
							end
							box.Transparency = 1 -- Скрываем цвет, если есть текстура
						else
							if eRoot:FindFirstChild("BrosaBoxTexture") then eRoot.BrosaBoxTexture:Destroy() end
							box.Transparency = 0.5
						end
					else
						if eRoot and eRoot:FindFirstChild("Brosa3DBox") then eRoot.Brosa3DBox:Destroy() end
						if eRoot and eRoot:FindFirstChild("BrosaBoxTexture") then eRoot.BrosaBoxTexture:Destroy() end
					end

					-- HIGHLIGHT ESP
					if _G.BrosaHub.Flags.PlayerESP and not _G.BrosaHub.Whitelist[p.Name] then
						if not hl then
							local newHl = Instance.new("Highlight")
							newHl.Name = "BrosaESP_Highlight"
							newHl.FillColor = Colors.Accent
							newHl.OutlineColor = Color3.fromRGB(255, 255, 255)
							newHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							newHl.Parent = p.Character
						end
					elseif hl then
						hl:Destroy()
					end
					
					if p.Character:FindFirstChild("Head") then
						local gui = p.Character.Head:FindFirstChild("BrosaNameGui")
						if _G.BrosaHub.Flags.NameESP and not _G.BrosaHub.Whitelist[p.Name] then
							if not gui then
								local bgui = Instance.new("BillboardGui")
								bgui.Name = "BrosaNameGui"
								bgui.Size = UDim2.new(0, 150, 0, 40)
								bgui.AlwaysOnTop = true
								bgui.StudsOffset = Vector3.new(0, 3, 0)
								local tl = Instance.new("TextLabel")
								tl.Size = UDim2.new(1, 0, 1, 0)
								tl.BackgroundTransparency = 1
								tl.Text = p.Name
								tl.TextColor3 = Colors.TextMain
								tl.Font = Enum.Font.SourceSansBold
								tl.TextSize = 14
								tl.Parent = bgui
								bgui.Parent = p.Character.Head
							end
						elseif gui then
							gui:Destroy()
						end
					end
					
					if eRoot then
						local oldBeam = workspace:FindFirstChild("BrosaTracer_" .. p.Name)
						if oldBeam then oldBeam:Destroy() end
						if _G.BrosaHub.Flags.TracerESP and not _G.BrosaHub.Whitelist[p.Name] then
							local att1 = myRoot:FindFirstChild("BrosaAtt") or Instance.new("Attachment", myRoot)
							att1.Name = "BrosaAtt"
							local att2 = eRoot:FindFirstChild("BrosaAttEnemy") or Instance.new("Attachment", eRoot)
							att2.Name = "BrosaAttEnemy"
							local beam = Instance.new("Beam")
							beam.Name = "BrosaTracer_" .. p.Name
							beam.Attachment0 = att1
							beam.Attachment1 = att2
							beam.Color = ColorSequence.new(Colors.Accent)
							beam.FaceCamera = true
							beam.Width0 = 0.1
							beam.Width1 = 0.1
							beam.Parent = workspace
						end
					end
					
					if _G.BrosaHub.Flags.Kidnap and not _G.BrosaHub.Whitelist[p.Name] and eRoot then
						if (myRoot.Position - eRoot.Position).Magnitude < 15 then
							eRoot.CFrame = CFrame.new(myRoot.Position.X, -400, myRoot.Position.Z)
						end
					end
				end
			end
			
			if _G.BrosaHub.Flags.AutoFarm then
				local mapFolder = workspace:FindFirstChild("Coins") or workspace:FindFirstChild("Money") or workspace:FindFirstChild("Cash") or workspace
				for _, object in pairs(mapFolder:GetChildren()) do
					if _G.BrosaHub.Flags.AutoFarm and object:IsA("BasePart") then
						local nameLower = object.Name:lower()
						if nameLower:match("coin") or nameLower:match("money") or nameLower:match("cash") then
							myRoot.CFrame = object.CFrame
							task.wait(0.3)
						end
					end
				end
			end
			
			if _G.BrosaHub.Flags.AutoQuest then
				local questFolder = workspace:FindFirstChild("Quests") or workspace:FindFirstChild("QuestGivers")
				if questFolder then
					for _, questZone in pairs(questFolder:GetChildren()) do
						if _G.BrosaHub.Flags.AutoQuest then
							if questZone:IsA("BasePart") then
								myRoot.CFrame = questZone.CFrame
								task.wait(0.5)
							elseif questZone:FindFirstChildOfClass("BasePart") then
								myRoot.CFrame = questZone:FindFirstChildOfClass("BasePart").CFrame
								task.wait(0.5)
							end
						end
					end
				end
			end
		end
	end
end)

_G.BrosaHub.Cache.Connections["EnvLoop"] = RunService.Heartbeat:Connect(function()
	if not _G.BrosaHub then return end
	
	local curSky = Lighting:FindFirstChildOfClass("Sky")
	local sType = _G.BrosaHub.Options.SkyboxType
	
	if sType ~= "Default" then
		if curSky and curSky.Name ~= "BrosaCosmosSky" then curSky:Destroy() end
		if not Lighting:FindFirstChild("BrosaCosmosSky") then
			local s = Instance.new("Sky")
			s.Name = "BrosaCosmosSky"
			s.Parent = Lighting
		end
		local sky = Lighting.BrosaCosmosSky
		if sType == "Cosmos" then
			sky.SkyboxBk = "rbxassetid://12064107"
			sky.SkyboxDn = "rbxassetid://12064152"
			sky.SkyboxFt = "rbxassetid://12064121"
			sky.SkyboxLf = "rbxassetid://12064131"
			sky.SkyboxRt = "rbxassetid://12064143"
			sky.SkyboxUp = "rbxassetid://12064175"
			sky.StarsCircle = true
		elseif sType == "Black" then
			sky.SkyboxBk = "" sky.SkyboxDn = "" sky.SkyboxFt = "" sky.SkyboxLf = "" sky.SkyboxRt = "" sky.SkyboxUp = ""
			Lighting.Ambient = Color3.fromRGB(0, 0, 0)
			Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
		elseif sType == "Blue" then
			sky.SkyboxBk = "" sky.SkyboxDn = "" sky.SkyboxFt = "" sky.SkyboxLf = "" sky.SkyboxRt = "" sky.SkyboxUp = ""
			Lighting.Ambient = Color3.fromRGB(0, 0, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 255)
		elseif sType == "White" then
			sky.SkyboxBk = "" sky.SkyboxDn = "" sky.SkyboxFt = "" sky.SkyboxLf = "" sky.SkyboxRt = "" sky.SkyboxUp = ""
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		end
	else
		if Lighting:FindFirstChild("BrosaCosmosSky") then Lighting.BrosaCosmosSky:Destroy() end
	end
end)

local function SecureCharacterPhysics(char)
	if not char then return end
	char.ChildAdded:Connect(function(child)
		if not _G.BrosaHub then return end
		if _G.BrosaHub.Flags.AntiGrab and (child:IsA("Weld") or child:IsA("ManualWeld") or child:IsA("RigidConstraint")) then
			task.wait()
			child:Destroy()
		end
	end)
end

if lp.Character then SecureCharacterPhysics(lp.Character) end
lp.CharacterAdded:Connect(SecureCharacterPhysics)

task.spawn(function()
	while task.wait() do
		if not _G.BrosaHub then break end
		if _G.BrosaHub.Flags.ChatSpam then
			local textChannel = TextChatService:FindFirstChild("TextChannels")
			if textChannel and textChannel:FindFirstChild("RBXGeneral") then
				textChannel.RBXGeneral:SendAsync("BROSA SYSTEM v5.3 dominates this server.")
			else
				local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
				if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
					chatEvents.SayMessageRequest:FireServer("BROSA SYSTEM v5.3 dominates this server.", "All")
				end
			end
			task.wait(_G.BrosaHub.Options.ChatSpamDelay)
		else
			task.wait(0.5)
		end
	end
end)

local menuOpen = true
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not _G.BrosaHub then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		menuOpen = not menuOpen
		if menuOpen then
			WindowContainer.Visible = true
			TweenService:Create(MainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}):Play()
		else
			TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
			task.wait(0.2)
			if not menuOpen then WindowContainer.Visible = false end
		end
	end
end)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "BrosaToggleBtn"
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Colors.BgPanel
ToggleBtn.Text = "👑"
ToggleBtn.TextColor3 = Colors.TextMain
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Parent = MainGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = Colors.Border

local BtnDragging, BtnDragInput, BtnDragStart, BtnStartPosition
local function UpdateBtnDrag(input)
	local delta = input.Position - BtnDragStart
	ToggleBtn.Position = UDim2.new(BtnStartPosition.X.Scale, BtnStartPosition.X.Offset + delta.X, BtnStartPosition.Y.Scale, BtnStartPosition.Y.Offset + delta.Y)
end

ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		BtnDragging = true
		BtnDragStart = input.Position
		BtnStartPosition = ToggleBtn.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				BtnDragging = false
			end
		end)
	end
end)

ToggleBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		BtnDragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == BtnDragInput and BtnDragging then
		UpdateBtnDrag(input)
	end
end)

WindowContainer.Visible = true
MainPanel.Visible = true

ToggleBtn.MouseButton1Click:Connect(function()
	if not _G.BrosaHub then return end
	menuOpen = not menuOpen
	if menuOpen then
		WindowContainer.Visible = true
		TweenService:Create(MainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}):Play()
	else
		TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
		task.wait(0.2)
		if not menuOpen then WindowContainer.Visible = false end
	end
end)

print("[👑 BROSA HUB v5.3]: Ядро монолита успешно скомпилировано.")

-- ============================================================================
-- ДОБАВЛЕНИЕ МЕНЮ AURORA (вставляется в конец, ничего не удаляет)
-- ============================================================================

local AuroraTheme = {
	Bg = Color3.fromRGB(24, 24, 29),
	BgStrong = Color3.fromRGB(30, 30, 37),
	Text = Color3.fromRGB(245, 245, 247),
	TextDim = Color3.fromRGB(152, 152, 163),
	AccentA = Color3.fromRGB(124, 108, 255),
	AccentB = Color3.fromRGB(79, 216, 255),
	Danger = Color3.fromRGB(255, 95, 87),
	Success = Color3.fromRGB(52, 211, 153),
}

local AuroraGui = Instance.new("ScreenGui")
AuroraGui.Name = "AuroraMenu"
AuroraGui.ResetOnSpawn = false
AuroraGui.IgnoreGuiInset = true
AuroraGui.Parent = lp:WaitForChild("PlayerGui")

local AuroraLauncher = Instance.new("TextButton")
AuroraLauncher.Name = "Launcher"
AuroraLauncher.Text = "⚡"
AuroraLauncher.Size = UDim2.fromOffset(56, 56)
AuroraLauncher.Position = UDim2.new(1, -28 - 56, 0, 28)
AuroraLauncher.BackgroundColor3 = AuroraTheme.BgStrong
AuroraLauncher.BackgroundTransparency = 0.1
AuroraLauncher.Font = Enum.Font.GothamBold
AuroraLauncher.TextSize = 24
AuroraLauncher.TextColor3 = AuroraTheme.Text
AuroraLauncher.Parent = AuroraGui
local launcherCorner = Instance.new("UICorner", AuroraLauncher)
launcherCorner.CornerRadius = UDim.new(0, 18)
local launcherStroke = Instance.new("UIStroke", AuroraLauncher)
launcherStroke.Color = AuroraTheme.Text
launcherStroke.Thickness = 1
launcherStroke.Transparency = 0.88

local auroraDrag, auroraDragInput, auroraDragStart, auroraStartPos
AuroraLauncher.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		auroraDrag = true
		auroraDragStart = input.Position
		auroraStartPos = AuroraLauncher.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then auroraDrag = false end
		end)
	end
end)
AuroraLauncher.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then auroraDragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == auroraDragInput and auroraDrag then
		local delta = input.Position - auroraDragStart
		AuroraLauncher.Position = UDim2.new(
			auroraStartPos.X.Scale, auroraStartPos.X.Offset + delta.X,
			auroraStartPos.Y.Scale, auroraStartPos.Y.Offset + delta.Y
		)
	end
end)

local auroraOpen = false
local AuroraWindow = Instance.new("Frame")
AuroraWindow.Name = "Window"
AuroraWindow.Size = UDim2.fromOffset(340, 520)
AuroraWindow.Position = UDim2.new(0, 28, 0, 28)
AuroraWindow.BackgroundColor3 = AuroraTheme.Bg
AuroraWindow.BackgroundTransparency = 0.12
AuroraWindow.ClipsDescendants = true
AuroraWindow.Visible = false
AuroraWindow.Parent = AuroraGui
local windowCorner = Instance.new("UICorner", AuroraWindow)
windowCorner.CornerRadius = UDim.new(0, 28)
local windowStroke = Instance.new("UIStroke", AuroraWindow)
windowStroke.Color = AuroraTheme.Text
windowStroke.Thickness = 1
windowStroke.Transparency = 0.9

local AuroraScale = Instance.new("UIScale", AuroraWindow)
AuroraScale.Scale = 0.1

local AuroraHeader = Instance.new("Frame")
AuroraHeader.Size = UDim2.new(1, 0, 0, 54)
AuroraHeader.BackgroundTransparency = 1
AuroraHeader.Parent = AuroraWindow

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = AuroraTheme.Text
headerLine.BackgroundTransparency = 0.92
headerLine.Parent = AuroraHeader

local titleWrap = Instance.new("Frame")
titleWrap.Size = UDim2.new(1, -90, 1, 0)
titleWrap.Position = UDim2.fromOffset(16, 0)
titleWrap.BackgroundTransparency = 1
titleWrap.Parent = AuroraHeader

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "BROSA SETTINGS"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextColor3 = AuroraTheme.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Size = UDim2.new(1, 0, 0, 18)
titleLabel.Position = UDim2.fromOffset(0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleWrap

local subLabel = Instance.new("TextLabel")
subLabel.Text = "Настройки функций · Aurora UI"
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 11
subLabel.TextColor3 = AuroraTheme.TextDim
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Size = UDim2.new(1, 0, 0, 14)
subLabel.Position = UDim2.fromOffset(0, 30)
subLabel.BackgroundTransparency = 1
subLabel.Parent = titleWrap

local function auroraHeaderBtn(glyph, color, posX)
	local btn = Instance.new("TextButton")
	btn.Text = glyph
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.TextColor3 = color
	btn.Size = UDim2.fromOffset(30, 30)
	btn.Position = UDim2.new(1, posX, 0, 12)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.95
	btn.AutoButtonColor = false
	btn.Parent = AuroraHeader
	local btnCorner = Instance.new("UICorner", btn)
	btnCorner.CornerRadius = UDim.new(0, 10)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.85}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.95}):Play()
	end)
	return btn
end

local auroraMinimize = auroraHeaderBtn("—", AuroraTheme.Text, -76)
local auroraClose = auroraHeaderBtn("×", AuroraTheme.Danger, -40)

auroraMinimize.MouseButton1Click:Connect(function()
	if auroraOpen then
		auroraOpen = false
		TweenService:Create(AuroraScale, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {Scale = 0.08}):Play()
		task.wait(0.3)
		AuroraWindow.Visible = false
		AuroraLauncher.Visible = true
		TweenService:Create(AuroraLauncher, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1}):Play()
	end
end)

auroraClose.MouseButton1Click:Connect(function()
	TweenService:Create(AuroraScale, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {Scale = 0.05}):Play()
	TweenService:Create(AuroraWindow, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	task.wait(0.4)
	AuroraGui:Destroy()
end)

local adrag, adragInput, adragStart, astartPos
AuroraHeader.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		adrag = true
		adragStart = input.Position
		astartPos = AuroraWindow.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then adrag = false end
		end)
	end
end)
AuroraHeader.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then adragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == adragInput and adrag then
		local delta = input.Position - adragStart
		AuroraWindow.Position = UDim2.new(
			astartPos.X.Scale, astartPos.X.Offset + delta.X,
			astartPos.Y.Scale, astartPos.Y.Offset + delta.Y
		)
	end
end)

AuroraLauncher.MouseButton1Click:Connect(function()
	if not auroraOpen then
		auroraOpen = true
		AuroraLauncher.Visible = false
		AuroraWindow.Visible = true
		AuroraScale.Scale = 0.1
		TweenService:Create(AuroraScale, TweenInfo.new(0.42, Enum.EasingStyle.Back), {Scale = 1}):Play()
	end
end)

local AuroraBody = Instance.new("Frame")
AuroraBody.Size = UDim2.new(1, -20, 1, -54 - 64)
AuroraBody.Position = UDim2.fromOffset(10, 54)
AuroraBody.BackgroundTransparency = 1
AuroraBody.Parent = AuroraWindow

local AuroraTabBar = Instance.new("Frame")
AuroraTabBar.Size = UDim2.new(1, -20, 0, 56)
AuroraTabBar.Position = UDim2.new(0, 10, 1, -56)
AuroraTabBar.BackgroundTransparency = 1
AuroraTabBar.Parent = AuroraWindow

local AuroraTabLayout = Instance.new("UIListLayout")
AuroraTabLayout.FillDirection = Enum.FillDirection.Horizontal
AuroraTabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
AuroraTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
AuroraTabLayout.Padding = UDim.new(0, 6)
AuroraTabLayout.Parent = AuroraTabBar

local auroraTabs = {}
local auroraActiveTab = nil

local function auroraSelectTab(tabData)
	if auroraActiveTab then
		auroraActiveTab.Page.Visible = false
		TweenService:Create(auroraActiveTab.Label, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {TextColor3 = AuroraTheme.TextDim}):Play()
	end
	auroraActiveTab = tabData
	tabData.Page.Visible = true
	TweenService:Create(tabData.Label, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {TextColor3 = AuroraTheme.Text}):Play()
end

local function auroraCreateTab(name)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageTransparency = 0.6
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = AuroraBody
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local btn = Instance.new("TextButton")
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0.5, -3, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Parent = AuroraTabBar
	
	local label = Instance.new("TextLabel")
	label.Text = name
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10.5
	label.TextColor3 = AuroraTheme.TextDim
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Parent = btn

	local tabData = {Name = name, Page = page, Button = btn, Label = label}
	table.insert(auroraTabs, tabData)
	btn.MouseButton1Click:Connect(function() auroraSelectTab(tabData) end)
	if not auroraActiveTab then auroraSelectTab(tabData) end

	local api = {}

	function api:AddToggle(opts)
		opts = opts or {}
		local state = opts.Default or false

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 58)
		row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		row.BackgroundTransparency = 0.965
		row.Parent = page
		local rowCorner = Instance.new("UICorner", row)
		rowCorner.CornerRadius = UDim.new(0, 16)
		local rowStroke = Instance.new("UIStroke", row)
		rowStroke.Color = AuroraTheme.AccentA
		rowStroke.Thickness = 1
		rowStroke.Transparency = 0.65

		local label1 = Instance.new("TextLabel")
		label1.Text = opts.Name or "Функция"
		label1.Font = Enum.Font.GothamBold
		label1.TextSize = 14
		label1.TextColor3 = AuroraTheme.Text
		label1.TextXAlignment = Enum.TextXAlignment.Left
		label1.Size = UDim2.new(1, -110, 0, 16)
		label1.Position = UDim2.fromOffset(16, 12)
		label1.BackgroundTransparency = 1
		label1.Parent = row

		local label2 = Instance.new("TextLabel")
		label2.Text = opts.Description or ""
		label2.Font = Enum.Font.Gotham
		label2.TextSize = 11
		label2.TextColor3 = AuroraTheme.TextDim
		label2.TextXAlignment = Enum.TextXAlignment.Left
		label2.Size = UDim2.new(1, -110, 0, 14)
		label2.Position = UDim2.fromOffset(16, 30)
		label2.BackgroundTransparency = 1
		label2.Parent = row

		local switch = Instance.new("Frame")
		switch.Size = UDim2.fromOffset(44, 26)
		switch.Position = UDim2.new(1, -56, 0.5, -13)
		switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		switch.BackgroundTransparency = 0.85
		switch.Parent = row
		local switchCorner = Instance.new("UICorner", switch)
		switchCorner.CornerRadius = UDim.new(0, 13)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(20, 20)
		knob.Position = UDim2.fromOffset(3, 3)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Parent = switch
		local knobCorner = Instance.new("UICorner", knob)
		knobCorner.CornerRadius = UDim.new(0, 10)

		local hitbox = Instance.new("TextButton")
		hitbox.Text = ""
		hitbox.AutoButtonColor = false
		hitbox.Size = UDim2.fromScale(1, 1)
		hitbox.BackgroundTransparency = 1
		hitbox.Parent = row

		local function render(animated)
			local info = animated and TweenInfo.new(0.42, Enum.EasingStyle.Back) or TweenInfo.new(0)
			if state then
				TweenService:Create(switch, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {BackgroundColor3 = AuroraTheme.AccentA, BackgroundTransparency = 0}):Play()
				TweenService:Create(knob, info, {Position = UDim2.fromOffset(21, 3)}):Play()
				TweenService:Create(rowStroke, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {Transparency = 0.35}):Play()
			else
				TweenService:Create(switch, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.85}):Play()
				TweenService:Create(knob, info, {Position = UDim2.fromOffset(3, 3)}):Play()
				TweenService:Create(rowStroke, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {Transparency = 0.65}):Play()
			end
		end
		render(false)

		hitbox.MouseButton1Click:Connect(function()
			state = not state
			render(true)
			if opts.Callback then task.spawn(opts.Callback, state) end
		end)
		return {Set = function(_, v) state = v; render(true) end, Get = function() return state end}
	end

	function api:AddProfileCard()
		local hero = Instance.new("Frame")
		hero.Size = UDim2.new(1, 0, 0, 150)
		hero.BackgroundTransparency = 1
		hero.Parent = page

		local avatar = Instance.new("ImageLabel")
		avatar.Size = UDim2.fromOffset(78, 78)
		avatar.Position = UDim2.new(0.5, -39, 0, 6)
		avatar.BackgroundColor3 = AuroraTheme.AccentA
		avatar.Parent = hero
		local avatarCorner = Instance.new("UICorner", avatar)
		avatarCorner.CornerRadius = UDim.new(0, 22)

		task.spawn(function()
			local ok, content = pcall(function()
				return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
			end)
			if ok and content then avatar.Image = content end
		end)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = lp.DisplayName
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 17
		nameLabel.TextColor3 = AuroraTheme.Text
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Position = UDim2.fromOffset(0, 90)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = hero

		local userLabel = Instance.new("TextLabel")
		userLabel.Text = "@" .. lp.Name .. " · ID " .. lp.UserId
		userLabel.Font = Enum.Font.Gotham
		userLabel.TextSize = 11.5
		userLabel.TextColor3 = AuroraTheme.TextDim
		userLabel.Size = UDim2.new(1, 0, 0, 16)
		userLabel.Position = UDim2.fromOffset(0, 112)
		userLabel.BackgroundTransparency = 1
		userLabel.Parent = hero
	end
	return api
end

local auroraFunctionsTab = auroraCreateTab("Функции")
local auroraProfileTab = auroraCreateTab("Профиль")

auroraFunctionsTab:AddToggle({Name = "InstaGrab", Description = "0-задержка на захват", Default = _G.BrosaHub.Flags.InstaGrabZeroDelay, Callback = function(v) _G.BrosaHub.Flags.InstaGrabZeroDelay = v end})
auroraFunctionsTab:AddToggle({Name = "Throw Under", Description = "Кинуть под карту", Default = _G.BrosaHub.Flags.ThrowUnderMap, Callback = function(v) _G.BrosaHub.Flags.ThrowUnderMap = v end})
auroraFunctionsTab:AddToggle({Name = "Auto-Intercept", Description = "Ответный захват", Default = _G.BrosaHub.Flags.AutoIntercept, Callback = function(v) _G.BrosaHub.Flags.AutoIntercept = v end})
auroraFunctionsTab:AddToggle({Name = "Anti-Ragdoll", Description = "Спам прыжка при падении", Default = _G.BrosaHub.Flags.AntiRagdollSpam, Callback = function(v) _G.BrosaHub.Flags.AntiRagdollSpam = v end})
auroraFunctionsTab:AddToggle({Name = "Anchor Pallet", Description = "Вбить поддон в землю", Default = _G.BrosaHub.Flags.AnchorPallet, Callback = function(v) _G.BrosaHub.Flags.AnchorPallet = v end})
auroraFunctionsTab:AddToggle({Name = "True 3D ESP", Description = "3D Коробки ESP", Default = _G.BrosaHub.Flags.True3DESP, Callback = function(v) _G.BrosaHub.Flags.True3DESP = v end})
auroraFunctionsTab:AddToggle({Name = "Fling Aura", Description = "Разброс игроков в радиусе", Default = _G.BrosaHub.Flags.FlingAura, Callback = function(v) _G.BrosaHub.Flags.FlingAura = v end})
auroraFunctionsTab:AddToggle({Name = "Click Fling", Description = "Флинг по клику", Default = _G.BrosaHub.Flags.ClickFling, Callback = function(v) _G.BrosaHub.Flags.ClickFling = v end})
auroraFunctionsTab:AddToggle({Name = "Fling All", Description = "Циклический флинг всех", Default = _G.BrosaHub.Flags.FlingAll, Callback = function(v) _G.BrosaHub.Flags.FlingAll = v end})

auroraProfileTab:AddProfileCard()
