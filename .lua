-- Modern Black & Red Social HUD with Executor Detection
-- Compatible with any executor (Synapse, ScriptWare, KRNL, etc.)

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
	THEME = {
		Primary = Color3.fromRGB(0, 0, 0),      -- Black
		Secondary = Color3.fromRGB(255, 42, 42), -- Red
		Text = Color3.fromRGB(255, 255, 255),   -- White
		Background = Color3.fromRGB(30, 30, 30) -- Dark Gray
	},
	
	EXECUTORS = {
		["Synapse X"] = {Color = Color3.fromRGB(255, 100, 100), Icon = "🔧"},
		["ScriptWare"] = {Color = Color3.fromRGB(100, 150, 255), Icon = "⚙️"},
		["KRNL"] = {Color = Color3.fromRGB(255, 200, 100), Icon = "🔨"},
		["Fluxus"] = {Color = Color3.fromRGB(150, 100, 255), Icon = "🌀"},
		["Electron"] = {Color = Color3.fromRGB(100, 255, 150), Icon = "⚡"},
		["Comet"] = {Color = Color3.fromRGB(255, 150, 200), Icon = "☄️"},
		["Oxygen U"] = {Color = Color3.fromRGB(100, 200, 255), Icon = "💨"},
		["Unknown"] = {Color = Color3.fromRGB(150, 150, 150), Icon = "❓"}
	},
	
	HUD_SETTINGS = {
		Offset = Vector3.new(0, 3, 0), -- Above player's head
		BillboardSize = UDim2.new(6, 0, 1.5, 0),
		FadeDistance = 100 -- Distance at which HUD fades out
	}
}

-- Executor Detection
local function detectExecutor()
	-- Check for known executor signatures
	if syn and syn.request then
		return "Synapse X"
	elseif identifyexecutor and identifyexecutor():find("ScriptWare") then
		return "ScriptWare"
	elseif KRNL_LOADED then
		return "KRNL"
	elseif fluxus and fluxus.version then
		return "Fluxus"
	elseif ELECTRON_LOADED then
		return "Electron"
	elseif getexecutorname and getexecutorname():find("Comet") then
		return "Comet"
	elseif OXYGEN_LOADED then
		return "Oxygen U"
	else
		-- Try to detect by checking various executor-specific functions
		if PROTOSMASHER_LOADED then
			return "ProtoSmasher"
		elseif is_sirhurt_closure then
			return "SirHurt"
		elseif is_sentinel_closure then
			return "Sentinel"
		elseif secure_load then
			return "Calamari"
		elseif crypt then
			return "Crypt"
		end
		
		-- If we can't detect, check common global variables
		for executorName in pairs(CONFIG.EXECUTORS) do
			if _G[executorName:gsub(" ", "_")] then
				return executorName
			end
		end
		
		return "Unknown"
	end
end

-- Create Social HUD Billboard
local function createHUD(player)
	local executor = detectExecutor()
	local executorInfo = CONFIG.EXECUTORS[executor] or CONFIG.EXECUTORS["Unknown"]
	
	-- Create Billboard GUI
	local billboard = Instance.new("BillboardGui")
	billboard.Name = player.Name .. "_SocialHUD"
	billboard.AlwaysOnTop = true
	billboard.Size = CONFIG.HUD_SETTINGS.BillboardSize
	billboard.StudsOffset = CONFIG.HUD_SETTINGS.Offset
	billboard.MaxDistance = CONFIG.HUD_SETTINGS.FadeDistance
	billboard.Enabled = false -- Start hidden
	billboard.Adornee = player.Character and player.Character:FindFirstChild("Head")
	billboard.Parent = player.Character and player.Character.Head or nil
	
	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = CONFIG.THEME.Primary
	mainFrame.BackgroundTransparency = 0.2
	mainFrame.BorderColor3 = executorInfo.Color
	mainFrame.BorderSizePixel = 2
	mainFrame.Parent = billboard
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = mainFrame
	
	-- Inner Frame (for content)
	local innerFrame = Instance.new("Frame")
	innerFrame.Name = "InnerFrame"
	innerFrame.Size = UDim2.new(1, -10, 1, -10)
	innerFrame.Position = UDim2.new(0, 5, 0, 5)
	innerFrame.BackgroundColor3 = CONFIG.THEME.Background
	innerFrame.BackgroundTransparency = 0.1
	innerFrame.Parent = mainFrame
	
	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 6)
	innerCorner.Parent = innerFrame
	
	-- Executor Display
	local executorFrame = Instance.new("Frame")
	executorFrame.Name = "ExecutorFrame"
	executorFrame.Size = UDim2.new(1, 0, 0.3, 0)
	executorFrame.BackgroundTransparency = 1
	executorFrame.Parent = innerFrame
	
	local executorIcon = Instance.new("TextLabel")
	executorIcon.Name = "ExecutorIcon"
	executorIcon.Size = UDim2.new(0.3, 0, 1, 0)
	executorIcon.Text = executorInfo.Icon
	executorIcon.TextColor3 = executorInfo.Color
	executorIcon.TextScaled = true
	executorIcon.BackgroundTransparency = 1
	executorIcon.Font = Enum.Font.GothamBold
	executorIcon.Parent = executorFrame
	
	local executorText = Instance.new("TextLabel")
	executorText.Name = "ExecutorText"
	executorText.Size = UDim2.new(0.7, 0, 1, 0)
	executorText.Position = UDim2.new(0.3, 0, 0, 0)
	executorText.Text = executor
	executorText.TextColor3 = executorInfo.Color
	executorText.TextScaled = true
	executorText.BackgroundTransparency = 1
	executorText.Font = Enum.Font.GothamSemibold
	executorText.TextXAlignment = Enum.TextXAlignment.Left
	executorText.Parent = executorFrame
	
	-- User Info
	local userFrame = Instance.new("Frame")
	userFrame.Name = "UserFrame"
	userFrame.Size = UDim2.new(1, 0, 0.4, 0)
	userFrame.Position = UDim2.new(0, 0, 0.3, 0)
	userFrame.BackgroundTransparency = 1
	userFrame.Parent = innerFrame
	
	local userName = Instance.new("TextLabel")
	userName.Name = "UserName"
	userName.Size = UDim2.new(1, 0, 0.6, 0)
	userName.Text = player.Name
	userName.TextColor3 = CONFIG.THEME.Text
	userName.TextScaled = true
	userName.BackgroundTransparency = 1
	userName.Font = Enum.Font.GothamBold
	userName.Parent = userFrame
	
	local userId = Instance.new("TextLabel")
	userId.Name = "UserId"
	userId.Size = UDim2.new(1, 0, 0.4, 0)
	userId.Position = UDim2.new(0, 0, 0.6, 0)
	userId.Text = "ID: " .. player.UserId
	userId.TextColor3 = CONFIG.THEME.Secondary
	userId.TextScaled = true
	userId.BackgroundTransparency = 1
	userId.Font = Enum.Font.GothamMedium
	userId.Parent = userFrame
	
	-- Status Indicator
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "StatusFrame"
	statusFrame.Size = UDim2.new(1, 0, 0.3, 0)
	statusFrame.Position = UDim2.new(0, 0, 0.7, 0)
	statusFrame.BackgroundTransparency = 1
	statusFrame.Parent = innerFrame
	
	local micIcon = Instance.new("TextLabel")
	micIcon.Name = "MicIcon"
	micIcon.Size = UDim2.new(0.3, 0, 1, 0)
	micIcon.Text = "🎤"
	micIcon.TextColor3 = CONFIG.THEME.Secondary
	micIcon.TextScaled = true
	micIcon.BackgroundTransparency = 1
	micIcon.Parent = statusFrame
	
	local statusText = Instance.new("TextLabel")
	statusText.Name = "StatusText"
	statusText.Size = UDim2.new(0.7, 0, 1, 0)
	statusText.Position = UDim2.new(0.3, 0, 0, 0)
	statusText.Text = "Mic: Active"
	statusText.TextColor3 = CONFIG.THEME.Text
	statusText.TextScaled = true
	statusText.BackgroundTransparency = 1
	statusText.Font = Enum.Font.GothamMedium
	statusText.TextXAlignment = Enum.TextXAlignment.Left
	statusText.Parent = statusFrame
	
	-- Animation for mic activity
	local pulseAnimation = Instance.new("BoolValue")
	pulseAnimation.Name = "PulseAnimation"
	pulseAnimation.Value = false
	pulseAnimation.Parent = micIcon
	
	-- Return HUD components
	return {
		Billboard = billboard,
		MainFrame = mainFrame,
		ExecutorText = executorText,
		ExecutorIcon = executorIcon,
		UserName = userName,
		UserId = userId,
		MicIcon = micIcon,
		StatusText = statusText,
		ExecutorInfo = executorInfo,
		Player = player
	}
end

-- HUD Manager
local HUDManager = {
	ActiveHUDs = {},
	LocalExecutor = detectExecutor(),
	LocalHUD = nil
}

function HUDManager:Initialize()
	print("Social HUD Initialized | Executor: " .. self.LocalExecutor)
	
	-- Create HUD for local player
	local localPlayer = Players.LocalPlayer
	self.LocalHUD = createHUD(localPlayer)
	
	-- Handle character added
	localPlayer.CharacterAdded:Connect(function(character)
		self:UpdateHUDAdornee(localPlayer, character)
	end)
	
	-- Create HUDs for existing players
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			self:AddPlayerHUD(player)
		end
	end
	
	-- Handle new players
	Players.PlayerAdded:Connect(function(player)
		self:AddPlayerHUD(player)
	end)
	
	-- Handle player leaving
	Players.PlayerRemoving:Connect(function(player)
		self:RemovePlayerHUD(player)
	end)
	
	-- Toggle visibility with keybind
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
			self:ToggleHUDVisibility()
		end
	end)
	
	-- Update mic status randomly (simulating voice activity)
	spawn(function()
		while wait(math.random(3, 10)) do
			self:UpdateMicStatus()
		end
	end)
	
	-- Enable local HUD after a delay
	wait(2)
	if self.LocalHUD and self.LocalHUD.Billboard then
		self.LocalHUD.Billboard.Enabled = true
		print("Local player HUD activated")
	end
end

function HUDManager:AddPlayerHUD(player)
	local hud = createHUD(player)
	self.ActiveHUDs[player.Name] = hud
	
	-- Handle character added for other players
	player.CharacterAdded:Connect(function(character)
		self:UpdateHUDAdornee(player, character)
	end)
	
	-- Enable HUD after character loads
	if player.Character then
		self:UpdateHUDAdornee(player, player.Character)
	end
	
	-- Enable HUD after delay
	spawn(function()
		wait(1)
		if hud and hud.Billboard then
			hud.Billboard.Enabled = true
		end
	end)
	
	print("HUD created for " .. player.Name)
end

function HUDManager:RemovePlayerHUD(player)
	local hud = self.ActiveHUDs[player.Name]
	if hud and hud.Billboard then
		hud.Billboard:Destroy()
	end
	self.ActiveHUDs[player.Name] = nil
end

function HUDManager:UpdateHUDAdornee(player, character)
	local hud = (player == Players.LocalPlayer) and self.LocalHUD or self.ActiveHUDs[player.Name]
	
	if hud and hud.Billboard then
		-- Wait for head to exist
		repeat wait(0.1) until character:FindFirstChild("Head")
		
		hud.Billboard.Adornee = character.Head
		hud.Billboard.Parent = character.Head
		
		-- Update player name
		if hud.UserName then
			hud.UserName.Text = player.Name
		end
	end
end

function HUDManager:ToggleHUDVisibility()
	local isVisible = self.LocalHUD.Billboard.Enabled
	self.LocalHUD.Billboard.Enabled = not isVisible
	
	-- Toggle other HUDs
	for _, hud in pairs(self.ActiveHUDs) do
		if hud and hud.Billboard then
			hud.Billboard.Enabled = not isVisible
		end
	end
	
	print("HUD Visibility: " .. tostring(not isVisible))
end

function HUDManager:UpdateMicStatus()
	-- Simulate mic activity
	local statuses = {"Active", "Muted", "Talking", "Inactive"}
	local randomStatus = statuses[math.random(1, #statuses)]
	
	-- Update local HUD
	if self.LocalHUD and self.LocalHUD.StatusText then
		self.LocalHUD.StatusText.Text = "Mic: " .. randomStatus
		
		-- Pulse animation for talking
		if randomStatus == "Talking" then
			self:AnimateMicIcon(self.LocalHUD.MicIcon)
		end
	end
	
	-- Update random player HUDs
	for _, hud in pairs(self.ActiveHUDs) do
		if hud and hud.StatusText and math.random(1, 3) == 1 then
			local playerStatus = statuses[math.random(1, #statuses)]
			hud.StatusText.Text = "Mic: " .. playerStatus
			
			if playerStatus == "Talking" then
				self:AnimateMicIcon(hud.MicIcon)
			end
		end
	end
end

function HUDManager:AnimateMicIcon(micIcon)
	if not micIcon then return end
	
	spawn(function()
		local originalSize = micIcon.Size
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true)
		
		local tween = TweenService:Create(micIcon, tweenInfo, {
			TextColor3 = Color3.fromRGB(255, 255, 100),
			TextTransparency = 0
		})
		
		tween:Play()
		wait(1)
		
		-- Reset
		TweenService:Create(micIcon, TweenInfo.new(0.5), {
			TextColor3 = CONFIG.THEME.Secondary
		}):Play()
	end)
end

-- Initialize HUD Manager
spawn(function()
	wait(1) -- Wait for game to load
	HUDManager:Initialize()
	
	-- Welcome message
	print("==========================================")
	print("Modern Social HUD v2.0")
	print("Executor Detected: " .. HUDManager.LocalExecutor)
	print("Press H to toggle HUD visibility")
	print("Black & Red Theme - Compatible with Xenomorph")
	print("==========================================")
end)

-- Return HUD Manager for external access
return HUDManager
