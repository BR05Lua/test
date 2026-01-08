-- Advanced Roblox Social HUD with Executor Spy System
-- Detects executor via console prints and notifications

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Console Monitoring System
local ConsoleSpy = {
    DetectedExecutors = {},
    KnownPrints = {
        ["Synapse X"] = {"synapse", "synapse x", "cracked by synapse", "injected"},
        ["KRNL"] = {"krnl", "krnl.place", "welcome to krnl"},
        ["ScriptWare"] = {"scriptware", "script-ware", "sw"},
        ["Fluxus"] = {"fluxus", "fluxteam", "fluxus executor"},
        ["Electron"] = {"electron", "electron executor"},
        ["Comet"] = {"comet", "comet executor"},
        ["Oxygen U"] = {"oxygen", "oxygen u"},
        ["JJSploit"] = {"jjspoil", "wearedevs"},
        ["ProtoSmasher"] = {"protosmasher", "proto smasher"}
    },
    
    Hooked = false,
    OriginalPrint = nil,
    OriginalWarn = nil,
    OriginalError = nil
}

-- Hook into print functions
function ConsoleSpy:HookConsole()
    if self.Hooked then return end
    
    self.OriginalPrint = print
    self.OriginalWarn = warn
    self.OriginalError = error
    
    -- Hook print function
    local function hookedPrint(...)
        local args = {...}
        local message = table.concat(args, " ")
        
        -- Analyze for executor signatures
        self:AnalyzeMessage(message:lower())
        
        -- Call original print
        return self.OriginalPrint(...)
    end
    
    -- Hook warn function
    local function hookedWarn(...)
        local args = {...}
        local message = table.concat(args, " ")
        
        -- Analyze for executor signatures
        self:AnalyzeMessage(message:lower())
        
        -- Call original warn
        return self.OriginalWarn(...)
    end
    
    -- Replace global functions
    getgenv().print = hookedPrint
    getgenv().warn = hookedWarn
    
    self.Hooked = true
    print("[ConsoleSpy] Console monitoring activated")
end

-- Analyze messages for executor signatures
function ConsoleSpy:AnalyzeMessage(message)
    for executorName, patterns in pairs(self.KnownPrints) do
        for _, pattern in ipairs(patterns) do
            if message:find(pattern:lower()) then
                if not self.DetectedExecutors[executorName] then
                    self.DetectedExecutors[executorName] = {
                        Count = 1,
                        FirstSeen = os.time(),
                        LastSeen = os.time(),
                        Sample = message
                    }
                    print("[ConsoleSpy] Detected executor:", executorName)
                else
                    self.DetectedExecutors[executorName].Count += 1
                    self.DetectedExecutors[executorName].LastSeen = os.time()
                end
                break
            end
        end
    end
end

-- Notification Monitoring
local NotificationSpy = {
    DetectedNotifications = {},
    NotificationFrame = nil
}

function NotificationSpy:MonitorNotifications()
    -- Create invisible frame to detect notifications
    if not self.NotificationFrame and CoreGui:FindFirstChild("RobloxGui") then
        local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
        if RobloxGui then
            -- Check for notification containers
            self:ScanForNotifications(RobloxGui)
        end
    end
end

function NotificationSpy:ScanForNotifications(parent)
    -- Look for common notification UI patterns
    local function checkChild(child)
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
            local text = child.Text or child:GetFullName()
            if text then
                text = text:lower()
                
                -- Check for executor-related text in notifications
                local executors = {
                    ["injected"] = "Generic Injector",
                    ["executor"] = "Generic Executor",
                    ["script loaded"] = "Script Loader",
                    ["welcome"] = "Welcome Notification",
                    ["cracked"] = "Cracked Version"
                }
                
                for pattern, executorType in pairs(executors) do
                    if text:find(pattern) then
                        if not self.DetectedNotifications[executorType] then
                            self.DetectedNotifications[executorType] = {
                                Text = text,
                                Time = os.time(),
                                UIElement = child:GetFullName()
                            }
                            print("[NotificationSpy] Detected notification:", executorType)
                        end
                    end
                end
            end
        end
    end
    
    -- Recursively scan
    for _, child in ipairs(parent:GetChildren()) do
        checkChild(child)
        if #child:GetChildren() > 0 then
            self:ScanForNotifications(child)
        end
    end
end

-- Enhanced HUD with Console Intelligence
local AdvancedHUD = {
    ActiveHUDs = {},
    PlayerData = {},
    ConsoleIntel = {},
    DistanceCache = {}
}

function AdvancedHUD:Initialize()
    print("=== Advanced Social HUD Initialized ===")
    print("Console Spy System: ACTIVE")
    print("Notification Monitoring: ACTIVE")
    
    -- Start console monitoring
    ConsoleSpy:HookConsole()
    
    -- Start periodic notification scanning
    spawn(function()
        while wait(5) do
            NotificationSpy:MonitorNotifications()
        end
    end
    
    -- Main HUD loop
    self:MainLoop()
end

function AdvancedHUD:CreateIntelligentHUD(player)
    -- Determine executor using multiple methods
    local executorInfo = self:DetermineExecutor(player)
    local deviceInfo = self:DetectDevice(player)
    
    -- Create Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_IntelHUD"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(6, 0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.MaxDistance = 150
    billboard.Enabled = true
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderColor3 = executorInfo.Color
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Gradient effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    })
    gradient.Parent = mainFrame
    
    -- Intel Header
    local intelFrame = Instance.new("Frame")
    intelFrame.Name = "IntelFrame"
    intelFrame.Size = UDim2.new(1, -10, 0.25, 0)
    intelFrame.Position = UDim2.new(0, 5, 0, 5)
    intelFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    intelFrame.BackgroundTransparency = 0.3
    intelFrame.Parent = mainFrame
    
    local intelCorner = Instance.new("UICorner")
    intelCorner.CornerRadius = UDim.new(0, 6)
    intelCorner.Parent = intelFrame
    
    -- Executor Display
    local executorDisplay = Instance.new("TextLabel")
    executorDisplay.Name = "ExecutorDisplay"
    executorDisplay.Size = UDim2.new(1, 0, 1, 0)
    executorDisplay.Text = executorInfo.Icon .. " " .. executorInfo.Name
    executorDisplay.TextColor3 = executorInfo.Color
    executorDisplay.TextScaled = true
    executorDisplay.BackgroundTransparency = 1
    executorDisplay.Font = Enum.Font.GothamBold
    executorDisplay.TextStrokeTransparency = 0.7
    executorDisplay.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    executorDisplay.Parent = intelFrame
    
    -- Player Info Section
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(1, -10, 0.4, 0)
    infoFrame.Position = UDim2.new(0, 5, 0.3, 0)
    infoFrame.BackgroundTransparency = 1
    infoFrame.Parent = mainFrame
    
    -- Player Name
    local playerName = Instance.new("TextLabel")
    playerName.Name = "PlayerName"
    playerName.Size = UDim2.new(1, 0, 0.5, 0)
    playerName.Text = player.Name
    playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerName.TextScaled = true
    playerName.BackgroundTransparency = 1
    playerName.Font = Enum.Font.GothamSemibold
    playerName.Parent = infoFrame
    
    -- Device Info
    local deviceInfoLabel = Instance.new("TextLabel")
    deviceInfoLabel.Name = "DeviceInfo"
    deviceInfoLabel.Size = UDim2.new(1, 0, 0.5, 0)
    deviceInfoLabel.Position = UDim2.new(0, 0, 0.5, 0)
    deviceInfoLabel.Text = deviceInfo.Icon .. " " .. deviceInfo.Type
    deviceInfoLabel.TextColor3 = deviceInfo.Color
    deviceInfoLabel.TextScaled = true
    deviceInfoLabel.BackgroundTransparency = 1
    deviceInfoLabel.Font = Enum.Font.GothamMedium
    deviceInfoLabel.Parent = infoFrame
    
    -- Console Intel Section
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(1, -10, 0.3, 0)
    consoleFrame.Position = UDim2.new(0, 5, 0.75, 0)
    consoleFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    consoleFrame.BackgroundTransparency = 0.7
    consoleFrame.Parent = mainFrame
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 5)
    consoleCorner.Parent = consoleFrame
    
    -- Console Intel Text
    local consoleText = Instance.new("TextLabel")
    consoleText.Name = "ConsoleText"
    consoleText.Size = UDim2.new(1, 0, 1, 0)
    consoleText.Text = "🕵️ Console: Scanning..."
    consoleText.TextColor3 = Color3.fromRGB(255, 100, 100)
    consoleText.TextScaled = true
    consoleText.BackgroundTransparency = 1
    consoleText.Font = Enum.Font.GothamMedium
    consoleText.Parent = consoleFrame
    
    -- Store HUD data
    self.ActiveHUDs[player.Name] = {
        Billboard = billboard,
        MainFrame = mainFrame,
        ExecutorDisplay = executorDisplay,
        DeviceInfo = deviceInfoLabel,
        ConsoleText = consoleText,
        Player = player,
        ExecutorInfo = executorInfo,
        DeviceInfoData = deviceInfo,
        Scale = 1.0,
        LastUpdate = 0
    }
    
    return self.ActiveHUDs[player.Name]
end

function AdvancedHUD:DetermineExecutor(player)
    -- Multi-method executor detection
    local detectionResults = {}
    
    -- Method 1: Console print analysis
    for executorName, data in pairs(ConsoleSpy.DetectedExecutors) do
        table.insert(detectionResults, {
            Name = executorName,
            Confidence = math.min(data.Count * 0.3, 1.0),
            Method = "Console Prints",
            Data = data
        })
    end
    
    -- Method 2: Global variable checks
    local globalChecks = {
        ["Synapse X"] = function() return (syn and syn.request) and 0.8 or 0 end,
        ["KRNL"] = function() return (KRNL_LOADED or get_hui) and 0.7 or 0 end,
        ["ScriptWare"] = function() return (identifyexecutor and identifyexecutor():find("ScriptWare")) and 0.75 or 0 end,
        ["Fluxus"] = function() return (fluxus and fluxus.version) and 0.7 or 0 end,
        ["Electron"] = function() return (ELECTRON_LOADED) and 0.6 or 0 end
    }
    
    for executorName, checkFunc in pairs(globalChecks) do
        local confidence = checkFunc()
        if confidence > 0 then
            table.insert(detectionResults, {
                Name = executorName,
                Confidence = confidence,
                Method = "Global Variables",
                Data = {}
            })
        end
    end
    
    -- Method 3: Notification analysis
    for notifType, notifData in pairs(NotificationSpy.DetectedNotifications) do
        table.insert(detectionResults, {
            Name = notifType,
            Confidence = 0.5,
            Method = "UI Notifications",
            Data = notifData
        })
    end
    
    -- Select best result
    local bestResult = {Name = "Unknown", Confidence = 0}
    for _, result in ipairs(detectionResults) do
        if result.Confidence > bestResult.Confidence then
            bestResult = result
        end
    end
    
    -- Get executor info
    local executorConfig = CONFIG.EXECUTORS[bestResult.Name] or CONFIG.EXECUTORS["Unknown"]
    
    return {
        Name = bestResult.Name,
        Color = executorConfig.Color,
        Icon = executorConfig.Icon,
        Confidence = bestResult.Confidence,
        DetectionMethod = bestResult.Method,
        RawData = bestResult.Data
    }
end

function AdvancedHUD:DetectDevice(player)
    local platform = UserInputService:GetPlatform()
    local deviceType = "Unknown"
    
    if platform == Enum.Platform.Windows then
        deviceType = "PC"
    elseif platform == Enum.Platform.Android or platform == Enum.Platform.IOS then
        -- Check screen size for tablet vs phone
        local screenSize = workspace.CurrentCamera.ViewportSize
        if math.min(screenSize.X, screenSize.Y) > 1000 then
            deviceType = "Tablet"
        else
            deviceType = "Mobile"
        end
    elseif platform == Enum.Platform.XBoxOne or platform == Enum.Platform.PS4 or platform == Enum.Platform.PS5 then
        deviceType = "Console"
    elseif platform == Enum.Platform.VR then
        deviceType = "VR"
    end
    
    return {
        Type = deviceType,
        Icon = CONFIG.DEVICES[deviceType].Icon,
        Color = CONFIG.DEVICES[deviceType].Color,
        Platform = tostring(platform)
    }
end

function AdvancedHUD:UpdateDistanceScaling(playerName, hudData)
    local localPlayer = Players.LocalPlayer
    local localChar = localPlayer.Character
    local targetPlayer = hudData.Player
    local targetChar = targetPlayer.Character
    
    if not localChar or not targetChar then
        hudData.Billboard.Size = UDim2.new(6, 0, 2, 0)
        return
    end
    
    local localHead = localChar:FindFirstChild("Head")
    local targetHead = targetChar:FindFirstChild("Head")
    
    if not localHead or not targetHead then return end
    
    -- Calculate distance
    local distance = (localHead.Position - targetHead.Position).Magnitude
    
    -- Dynamic scaling based on distance
    local minScale = 0.4  -- 40% size at max distance
    local maxScale = 1.0  -- 100% size up close
    local closeDist = 15  -- Full scale at this distance
    local farDist = 100   -- Min scale at this distance
    
    -- Calculate scale factor (inverse relationship)
    local scaleFactor
    if distance <= closeDist then
        scaleFactor = maxScale
    elseif distance >= farDist then
        scaleFactor = minScale
    else
        -- Linear interpolation between distances
        local t = (distance - closeDist) / (farDist - closeDist)
        scaleFactor = maxScale - (maxScale - minScale) * t
    end
    
    -- Smooth scaling transition
    local currentScale = hudData.Scale or 1.0
    local newScale = currentScale + (scaleFactor - currentScale) * 0.1
    
    -- Apply scaling to billboard size
    local baseSize = UDim2.new(6, 0, 2, 0)
    hudData.Billboard.Size = UDim2.new(
        baseSize.X.Scale * newScale, 
        baseSize.X.Offset * newScale,
        baseSize.Y.Scale * newScale, 
        baseSize.Y.Offset * newScale
    )
    
    -- Update transparency based on distance
    local transparency = math.clamp((distance - 50) / 100, 0, 0.5)
    hudData.MainFrame.BackgroundTransparency = 0.15 + transparency
    
    -- Store current scale
    hudData.Scale = newScale
    self.DistanceCache[playerName] = {
        Distance = distance,
        Scale = newScale,
        Time = os.time()
    }
end

function AdvancedHUD:UpdateConsoleIntel(hudData)
    local consoleInfo = ""
    local playerName = hudData.Player.Name
    
    -- Check for console prints from this player's executor
    local totalPrints = 0
    local latestExecutor = nil
    
    for executorName, data in pairs(ConsoleSpy.DetectedExecutors) do
        totalPrints += data.Count
        if not latestExecutor or data.LastSeen > latestExecutor then
            latestExecutor = executorName
        end
    end
    
    -- Build console intelligence string
    if totalPrints > 0 then
        if #ConsoleSpy.DetectedExecutors > 1 then
            consoleInfo = string.format("🕵️ %d executors detected", totalPrints)
        else
            consoleInfo = string.format("🔍 Prints: %d", totalPrints)
        end
    else
        consoleInfo = "📡 Listening for prints..."
    end
    
    -- Add notification info if available
    local notifCount = 0
    for _ in pairs(NotificationSpy.DetectedNotifications) do
        notifCount += 1
    end
    
    if notifCount > 0 then
        consoleInfo = consoleInfo .. string.format(" | 📢 %d notifs", notifCount)
    end
    
    -- Update HUD display
    if hudData.ConsoleText then
        hudData.ConsoleText.Text = consoleInfo
        
        -- Pulse effect when new data arrives
        if hudData.LastIntelUpdate ~= totalPrints then
            hudData.ConsoleText.TextColor3 = Color3.fromRGB(255, 150, 150)
            
            spawn(function()
                wait(0.3)
                if hudData.ConsoleText then
                    hudData.ConsoleText.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end)
            
            hudData.LastIntelUpdate = totalPrints
        end
    end
end

function AdvancedHUD:MainLoop()
    -- Initialize for all existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:CreateIntelligentHUD(player)
            
            -- Attach to character
            player.CharacterAdded:Connect(function(char)
                wait(1) -- Wait for character to load
                local hud = self.ActiveHUDs[player.Name]
                if hud and hud.Billboard then
                    local head = char:FindFirstChild("Head")
                    if head then
                        hud.Billboard.Adornee = head
                        hud.Billboard.Parent = head
                    end
                end
            end)
            
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local hud = self.ActiveHUDs[player.Name]
                    if hud then
                        hud.Billboard.Adornee = head
                        hud.Billboard.Parent = head
                    end
                end
            end
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        wait(2) -- Give time for executor to load
        self:CreateIntelligentHUD(player)
    end)
    
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(player)
        local hud = self.ActiveHUDs[player.Name]
        if hud and hud.Billboard then
            hud.Billboard:Destroy()
        end
        self.ActiveHUDs[player.Name] = nil
    end)
    
    -- Main update loop
    spawn(function()
        while wait(0.1) do -- Update 10 times per second
            for playerName, hudData in pairs(self.ActiveHUDs) do
                -- Update distance scaling
                self:UpdateDistanceScaling(playerName, hudData)
                
                -- Update console intelligence
                self:UpdateConsoleIntel(hudData)
                
                -- Update executor confidence display
                if hudData.ExecutorDisplay and hudData.ExecutorInfo then
                    local confidenceText = ""
                    if hudData.ExecutorInfo.Confidence > 0.7 then
                        confidenceText = " 🔒"
                    elseif hudData.ExecutorInfo.Confidence > 0.4 then
                        confidenceText = " ⚠️"
                    else
                        confidenceText = " ❓"
                    end
                    
                    hudData.ExecutorDisplay.Text = 
                        hudData.ExecutorInfo.Icon .. " " .. 
                        hudData.ExecutorInfo.Name .. 
                        confidenceText
                end
            end
        end
    end)
    
    -- Keybind to toggle HUD
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.H then
            for _, hudData in pairs(self.ActiveHUDs) do
                if hudData.Billboard then
                    hudData.Billboard.Enabled = not hudData.Billboard.Enabled
                end
            end
            print("[HUD] Toggled visibility")
        end
    end)
end

-- Initialize everything
spawn(function()
    wait(2) -- Wait for game to fully load
    AdvancedHUD:Initialize()
    
    -- Print startup message
    print("==========================================")
    print("ADVANCED SOCIAL HUD v3.0")
    print("Console Spy System: ACTIVE")
    print("Notification Monitor: ACTIVE")
    print("Dynamic Scaling: ENABLED")
    print("Executor Intelligence: COLLECTING")
    print("Press H to toggle HUD visibility")
    print("==========================================")
end)

-- Return systems for external access
return {
    HUD = AdvancedHUD,
    ConsoleSpy = ConsoleSpy,
    NotificationSpy = NotificationSpy
}
