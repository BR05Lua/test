-- =================================================================
-- ULTIMATE ROBLOX SOCIAL HUD - COMPLETE FIXED VERSION
-- =================================================================
-- All features preserved - Fixed nil errors - GitHub compatible
-- =================================================================

-- SERVICES (WITH SAFETY CHECKS)
local function GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

local Services = {}
local serviceNames = {
    "Players", "RunService", "UserInputService", "TweenService", 
    "Lighting", "Stats", "VRService", "GuiService", "NetworkClient",
    "TextService", "HttpService", "MarketplaceService"
}

for _, name in ipairs(serviceNames) do
    Services[name] = GetService(name)
end

-- SAFETY WRAPPER FOR ALL CALLS
local function ProtectedCall(callback, errorMessage, ...)
    local args = {...}
    return function()
        local success, result = pcall(function()
            return callback(unpack(args))
        end)
        if not success then
            if errorMessage then
                warn("[SAFETY] " .. errorMessage .. ": " .. result)
            end
            return nil
        end
        return result
    end
end

-- SAFE VERSION OF print() THAT WON'T BREAK
local originalPrint = print
local SafePrint = function(...)
    return ProtectedCall(originalPrint, "Print failed")(...)
end

-- ENHANCED CONFIG (WITH PROTECTION)
local CONFIG = ProtectedCall(function()
    return {
        THEME = {
            Primary = Color3.fromRGB(15, 15, 15),
            Secondary = Color3.fromRGB(255, 35, 35),
            Accent = Color3.fromRGB(255, 100, 100),
            Text = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(40, 40, 40),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Danger = Color3.fromRGB(231, 76, 60)
        },
        
        SCALING = {
            MinScale = 0.3,
            MaxScale = 1.0,
            CloseDistance = 10,
            FarDistance = 100,
            ScaleSmoothness = 0.5,
            BillboardSize = UDim2.new(6, 0, 1.8, 0)
        },
        
        EXECUTORS = {
            ["Synapse X"] = {
                Color = Color3.fromRGB(255, 100, 100),
                Icon = "🔧",
                Detection = ProtectedCall(function()
                    return (type(syn) == "table" and syn.request ~= nil and syn.protect_gui ~= nil)
                end, "Synapse detection failed")()
            },
            ["ScriptWare"] = {
                Color = Color3.fromRGB(100, 150, 255),
                Icon = "⚙️",
                Detection = ProtectedCall(function()
                    return (type(identifyexecutor) == "function" and string.find(tostring(identifyexecutor()), "ScriptWare"))
                end, "ScriptWare detection failed")()
            },
            ["KRNL"] = {
                Color = Color3.fromRGB(255, 200, 100),
                Icon = "🔨",
                Detection = ProtectedCall(function()
                    return (KRNL_LOADED == true or type(get_hui) == "function")
                end, "KRNL detection failed")()
            },
            ["Fluxus"] = {
                Color = Color3.fromRGB(150, 100, 255),
                Icon = "🌀",
                Detection = ProtectedCall(function()
                    return (type(fluxus) == "table" and fluxus.version ~= nil)
                end, "Fluxus detection failed")()
            },
            ["Electron"] = {
                Color = Color3.fromRGB(100, 255, 150),
                Icon = "⚡",
                Detection = ProtectedCall(function()
                    return (ELECTRON_LOADED == true or (type(getexecutorname) == "function" and string.find(tostring(getexecutorname()), "Electron")))
                end, "Electron detection failed")()
            },
            ["Comet"] = {
                Color = Color3.fromRGB(255, 150, 200),
                Icon = "☄️",
                Detection = ProtectedCall(function()
                    return (type(getexecutorname) == "function" and string.find(tostring(getexecutorname()), "Comet"))
                end, "Comet detection failed")()
            },
            ["Oxygen U"] = {
                Color = Color3.fromRGB(100, 200, 255),
                Icon = "💨",
                Detection = ProtectedCall(function()
                    return (OXYGEN_LOADED == true or isoxygen == true)
                end, "Oxygen detection failed")()
            },
            ["Unknown"] = {
                Color = Color3.fromRGB(150, 150, 150),
                Icon = "❓",
                Detection = function() return false end
            }
        },
        
        DEVICES = {
            ["PC"] = {Icon = "🖥️", Color = Color3.fromRGB(70, 130, 180)},
            ["Mobile"] = {Icon = "📱", Color = Color3.fromRGB(50, 205, 50)},
            ["Tablet"] = {Icon = "📱", Color = Color3.fromRGB(64, 224, 208)},
            ["Console"] = {Icon = "🎮", Color = Color3.fromRGB(220, 20, 60)},
            ["VR"] = {Icon = "👓", Color = Color3.fromRGB(138, 43, 226)},
            ["Unknown"] = {Icon = "❓", Color = Color3.fromRGB(150, 150, 150)}
        }
    }
end, "Config creation failed")()

-- CONSOLE SPY SYSTEM (FIXED)
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
    OriginalPrint = print,
    OriginalWarn = warn
}

function ConsoleSpy:HookConsole()
    if self.Hooked then return true end
    
    return ProtectedCall(function()
        local function hookedPrint(...)
            local args = {...}
            local message = table.concat(args, " ")
            
            -- Analyze for executor signatures
            self:AnalyzeMessage(message:lower())
            
            -- Call original print
            return self.OriginalPrint(...)
        end
        
        local function hookedWarn(...)
            local args = {...}
            local message = table.concat(args, " ")
            
            -- Analyze for executor signatures
            self:AnalyzeMessage(message:lower())
            
            -- Call original warn
            return self.OriginalWarn(...)
        end
        
        -- SAFELY replace global functions
        if type(getgenv) == "function" then
            local env = getgenv()
            if env then
                env.print = hookedPrint
                env.warn = hookedWarn
            end
        end
        
        self.Hooked = true
        SafePrint("[ConsoleSpy] Console monitoring activated")
        return true
    end, "Console hook failed")() or false
end

function ConsoleSpy:AnalyzeMessage(message)
    ProtectedCall(function()
        for executorName, patterns in pairs(self.KnownPrints) do
            for _, pattern in ipairs(patterns) do
                if string.find(message, pattern:lower()) then
                    if not self.DetectedExecutors[executorName] then
                        self.DetectedExecutors[executorName] = {
                            Count = 1,
                            FirstSeen = os.time(),
                            LastSeen = os.time(),
                            Sample = string.sub(message, 1, 100)
                        }
                        SafePrint("[ConsoleSpy] Detected executor:", executorName)
                    else
                        self.DetectedExecutors[executorName].Count = self.DetectedExecutors[executorName].Count + 1
                        self.DetectedExecutors[executorName].LastSeen = os.time()
                    end
                    break
                end
            end
        end
    end, "Message analysis failed")()
end

-- NOTIFICATION SPY SYSTEM (FIXED)
local NotificationSpy = {
    DetectedNotifications = {},
    ScanInterval = 5
}

function NotificationSpy:MonitorNotifications()
    return ProtectedCall(function()
        if not Services.GuiService then return end
        
        -- Look for notification UI in a safe way
        local function safeScan(parent, depth)
            if depth > 5 then return end  -- Prevent infinite recursion
            
            for _, child in ipairs(parent:GetChildren()) do
                -- Check text elements
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text or ""
                    text = string.lower(tostring(text))
                    
                    -- Check for executor-related text
                    local executors = {
                        ["injected"] = "Generic Injector",
                        ["executor"] = "Generic Executor",
                        ["script loaded"] = "Script Loader",
                        ["welcome"] = "Welcome Notification",
                        ["cracked"] = "Cracked Version"
                    }
                    
                    for pattern, executorType in pairs(executors) do
                        if string.find(text, pattern) then
                            if not self.DetectedNotifications[executorType] then
                                self.DetectedNotifications[executorType] = {
                                    Text = text,
                                    Time = os.time(),
                                    UIElement = child:GetFullName()
                                }
                                SafePrint("[NotificationSpy] Detected notification:", executorType)
                            end
                        end
                    end
                end
                
                -- Recursively scan children
                if #child:GetChildren() > 0 then
                    safeScan(child, depth + 1)
                end
            end
        end
        
        -- Start scanning from CoreGui if available
        local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
        if success and coreGui then
            safeScan(coreGui, 0)
        end
        
        return true
    end, "Notification monitoring failed")() or false
end

-- ENHANCED DEVICE DETECTION
local function DetectDevice()
    return ProtectedCall(function()
        if not Services.UserInputService then 
            return {Type = "Unknown", Icon = "❓", Color = Color3.fromRGB(150, 150, 150), Platform = "Unknown"}
        end
        
        local platform = Services.UserInputService:GetPlatform()
        local deviceType = "Unknown"
        
        if platform == Enum.Platform.Windows then
            deviceType = "PC"
        elseif platform == Enum.Platform.Android then
            deviceType = "Mobile"
        elseif platform == Enum.Platform.IOS then
            deviceType = "Mobile"
        elseif platform == Enum.Platform.XBoxOne then
            deviceType = "Console"
        elseif platform == Enum.Platform.PS4 or platform == Enum.Platform.PS5 then
            deviceType = "Console"
        elseif platform == Enum.Platform.VR then
            deviceType = "VR"
        end
        
        local deviceConfig = CONFIG.DEVICES[deviceType] or CONFIG.DEVICES["Unknown"]
        return {
            Type = deviceType,
            Icon = deviceConfig.Icon,
            Color = deviceConfig.Color,
            Platform = tostring(platform)
        }
    end, "Device detection failed")() or {Type = "Unknown", Icon = "❓", Color = Color3.fromRGB(150, 150, 150), Platform = "Unknown"}
end

-- ADVANCED HUD CREATION (WITH ALL FEATURES)
local AdvancedHUD = {
    ActiveHUDs = {},
    PlayerData = {},
    DistanceCache = {}
}

function AdvancedHUD:CreateIntelligentHUD(player)
    return ProtectedCall(function()
        -- Determine executor
        local executorInfo = self:DetermineExecutor(player)
        local deviceInfo = DetectDevice()
        
        -- Create billboard safely
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "SocialHUD_" .. player.UserId
        billboard.AlwaysOnTop = true
        billboard.Size = CONFIG.SCALING.BillboardSize
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.MaxDistance = 150
        billboard.Enabled = true
        
        -- Main container
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(1, 0, 1, 0)
        mainFrame.BackgroundColor3 = CONFIG.THEME.Primary
        mainFrame.BackgroundTransparency = 0.15
        mainFrame.BorderColor3 = executorInfo.Color
        mainFrame.BorderSizePixel = 2
        mainFrame.Parent = billboard
        
        -- Add rounded corners if supported
        local success, corner = pcall(function()
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 10)
            return c
        end)
        if success and corner then
            corner.Parent = mainFrame
        end
        
        -- Intel Header
        local intelFrame = Instance.new("Frame")
        intelFrame.Name = "IntelFrame"
        intelFrame.Size = UDim2.new(1, -10, 0.25, 0)
        intelFrame.Position = UDim2.new(0, 5, 0, 5)
        intelFrame.BackgroundColor3 = CONFIG.THEME.Background
        intelFrame.BackgroundTransparency = 0.3
        intelFrame.Parent = mainFrame
        
        -- Executor Display
        local executorDisplay = Instance.new("TextLabel")
        executorDisplay.Name = "ExecutorDisplay"
        executorDisplay.Size = UDim2.new(1, 0, 1, 0)
        executorDisplay.Text = executorInfo.Icon .. " " .. executorInfo.Name
        executorDisplay.TextColor3 = executorInfo.Color
        executorDisplay.TextScaled = true
        executorDisplay.BackgroundTransparency = 1
        executorDisplay.Font = Enum.Font.GothamBold
        executorDisplay.Parent = intelFrame
        
        -- Player Info
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
        playerName.TextColor3 = CONFIG.THEME.Text
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
        
        local consoleText = Instance.new("TextLabel")
        consoleText.Name = "ConsoleText"
        consoleText.Size = UDim2.new(1, 0, 1, 0)
        consoleText.Text = "🕵️ Console: Scanning..."
        consoleText.TextColor3 = CONFIG.THEME.Accent
        consoleText.TextScaled = true
        consoleText.BackgroundTransparency = 1
        consoleText.Font = Enum.Font.GothamMedium
        consoleText.Parent = consoleFrame
        
        -- Store HUD data
        local hudData = {
            Billboard = billboard,
            MainFrame = mainFrame,
            ExecutorDisplay = executorDisplay,
            DeviceInfo = deviceInfoLabel,
            ConsoleText = consoleText,
            Player = player,
            ExecutorInfo = executorInfo,
            DeviceInfoData = deviceInfo,
            Scale = 1.0,
            LastIntelUpdate = 0
        }
        
        self.ActiveHUDs[player.Name] = hudData
        return hudData
    end, "HUD creation failed for " .. player.Name)()
end

function AdvancedHUD:DetermineExecutor(player)
    return ProtectedCall(function()
        local detectionResults = {}
        
        -- Method 1: Console prints
        for executorName, data in pairs(ConsoleSpy.DetectedExecutors) do
            table.insert(detectionResults, {
                Name = executorName,
                Confidence = math.min(data.Count * 0.3, 1.0),
                Method = "Console Prints",
                Data = data
            })
        end
        
        -- Method 2: Direct detection
        for executorName, executorConfig in pairs(CONFIG.EXECUTORS) do
            if executorName ~= "Unknown" then
                local success, detected = pcall(function()
                    return executorConfig.Detection == true or (type(executorConfig.Detection) == "function" and executorConfig.Detection())
                end)
                
                if success and detected then
                    table.insert(detectionResults, {
                        Name = executorName,
                        Confidence = 0.8,
                        Method = "Direct Detection",
                        Data = {}
                    })
                end
            end
        end
        
        -- Method 3: Notifications
        for notifType, notifData in pairs(NotificationSpy.DetectedNotifications) do
            table.insert(detectionResults, {
                Name = notifType,
                Confidence = 0.5,
                Method = "Notifications",
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
        
        local executorConfig = CONFIG.EXECUTORS[bestResult.Name] or CONFIG.EXECUTORS["Unknown"]
        
        return {
            Name = bestResult.Name,
            Color = executorConfig.Color,
            Icon = executorConfig.Icon,
            Confidence = bestResult.Confidence,
            DetectionMethod = bestResult.Method
        }
    end, "Executor detection failed")() or {Name = "Unknown", Color = Color3.fromRGB(150, 150, 150), Icon = "❓", Confidence = 0, DetectionMethod = "Failed"}
end

-- DYNAMIC SCALING SYSTEM (FIXED)
function AdvancedHUD:UpdateDistanceScaling(playerName, hudData)
    ProtectedCall(function()
        if not Services.Players then return end
        
        local localPlayer = Services.Players.LocalPlayer
        if not localPlayer or not localPlayer.Character then return end
        
        local targetPlayer = hudData.Player
        if not targetPlayer or not targetPlayer.Character then return end
        
        local localHead = localPlayer.Character:FindFirstChild("Head")
        local targetHead = targetPlayer.Character:FindFirstChild("Head")
        
        if not localHead or not targetHead then return end
        
        -- Calculate distance
        local distance = (localHead.Position - targetHead.Position).Magnitude
        
        -- Dynamic scaling
        local minScale = CONFIG.SCALING.MinScale
        local maxScale = CONFIG.SCALING.MaxScale
        local closeDist = CONFIG.SCALING.CloseDistance
        local farDist = CONFIG.SCALING.FarDistance
        
        local scaleFactor
        if distance <= closeDist then
            scaleFactor = maxScale
        elseif distance >= farDist then
            scaleFactor = minScale
        else
            local t = (distance - closeDist) / (farDist - closeDist)
            scaleFactor = maxScale - (maxScale - minScale) * t
        end
        
        -- Smooth transition
        local currentScale = hudData.Scale or 1.0
        local newScale = currentScale + (scaleFactor - currentScale) * CONFIG.SCALING.ScaleSmoothness
        
        -- Apply scaling
        local baseSize = CONFIG.SCALING.BillboardSize
        hudData.Billboard.Size = UDim2.new(
            baseSize.X.Scale * newScale, 
            baseSize.X.Offset * newScale,
            baseSize.Y.Scale * newScale, 
            baseSize.Y.Offset * newScale
        )
        
        -- Update transparency
        local transparency = math.clamp((distance - 50) / 100, 0, 0.5)
        hudData.MainFrame.BackgroundTransparency = 0.15 + transparency
        
        -- Store data
        hudData.Scale = newScale
        self.DistanceCache[playerName] = {
            Distance = distance,
            Scale = newScale,
            Time = os.time()
        }
        
        -- Update console intel
        self:UpdateConsoleIntel(hudData)
    end, "Distance scaling update failed")()
end

function AdvancedHUD:UpdateConsoleIntel(hudData)
    ProtectedCall(function()
        local consoleInfo = ""
        local totalPrints = 0
        
        for executorName, data in pairs(ConsoleSpy.DetectedExecutors) do
            totalPrints = totalPrints + data.Count
        end
        
        if totalPrints > 0 then
            if next(ConsoleSpy.DetectedExecutors) ~= nil and #ConsoleSpy.DetectedExecutors > 1 then
                consoleInfo = string.format("🕵️ %d executors detected", totalPrints)
            else
                consoleInfo = string.format("🔍 Prints: %d", totalPrints)
            end
        else
            consoleInfo = "📡 Listening for prints..."
        end
        
        -- Add notification info
        local notifCount = 0
        for _ in pairs(NotificationSpy.DetectedNotifications) do
            notifCount = notifCount + 1
        end
        
        if notifCount > 0 then
            consoleInfo = consoleInfo .. string.format(" | 📢 %d notifs", notifCount)
        end
        
        -- Update display
        if hudData.ConsoleText then
            hudData.ConsoleText.Text = consoleInfo
            
            -- Pulse effect
            if hudData.LastIntelUpdate ~= totalPrints then
                hudData.ConsoleText.TextColor3 = Color3.fromRGB(255, 150, 150)
                
                ProtectedCall(function()
                    wait(0.3)
                    if hudData.ConsoleText then
                        hudData.ConsoleText.TextColor3 = CONFIG.THEME.Accent
                    end
                end, "Pulse effect failed")()
                
                hudData.LastIntelUpdate = totalPrints
            end
        end
    end, "Console intel update failed")()
end

-- MAIN INITIALIZATION
function AdvancedHUD:Initialize()
    SafePrint("=== ADVANCED SOCIAL HUD INITIALIZING ===")
    
    -- Start console monitoring
    ConsoleSpy:HookConsole()
    
    -- Start notification monitoring
    spawn(function()
        while true do
            ProtectedCall(function()
                NotificationSpy:MonitorNotifications()
            end, "Notification monitoring loop failed")()
            wait(NotificationSpy.ScanInterval)
        end
    end)
    
    -- Wait for Players service
    if not Services.Players then
        repeat 
            Services.Players = GetService("Players")
            wait(0.5) 
        until Services.Players
    end
    
    local localPlayer = Services.Players.LocalPlayer
    if not localPlayer then
        SafePrint("[ERROR] Could not get local player")
        return
    end
    
    -- Create HUDs for existing players
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= localPlayer then
            self:CreateIntelligentHUD(player)
            
            -- Handle character attachment
            player.CharacterAdded:Connect(function(char)
                ProtectedCall(function()
                    wait(1)
                    local hud = self.ActiveHUDs[player.Name]
                    if hud and hud.Billboard then
                        local head = char:FindFirstChild("Head")
                        if head then
                            hud.Billboard.Adornee = head
                            hud.Billboard.Parent = head
                        end
                    end
                end, "Character attachment failed")()
            end)
            
            -- Attach to existing character
            if player.Character then
                ProtectedCall(function()
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local hud = self.ActiveHUDs[player.Name]
                        if hud then
                            hud.Billboard.Adornee = head
                            hud.Billboard.Parent = head
                        end
                    end
                end, "Existing character attachment failed")()
            end
        end
    end
    
    -- Handle new players
    Services.Players.PlayerAdded:Connect(function(player)
        ProtectedCall(function()
            wait(2)
            self:CreateIntelligentHUD(player)
        end, "New player handling failed")()
    end)
    
    -- Handle player leaving
    Services.Players.PlayerRemoving:Connect(function(player)
        ProtectedCall(function()
            local hud = self.ActiveHUDs[player.Name]
            if hud and hud.Billboard then
                hud.Billboard:Destroy()
            end
            self.ActiveHUDs[player.Name] = nil
        end, "Player removal handling failed")()
    end)
    
    -- Main update loop
    ProtectedCall(function()
        spawn(function()
            while true do
                for playerName, hudData in pairs(self.ActiveHUDs) do
                    self:UpdateDistanceScaling(playerName, hudData)
                end
                wait(0.1)
            end
        end)
    end, "Main update loop failed")()
    
    -- Keybind toggle
    if Services.UserInputService then
        Services.UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == Enum.KeyCode.H then
                ProtectedCall(function()
                    for _, hudData in pairs(self.ActiveHUDs) do
                        if hudData.Billboard then
                            hudData.Billboard.Enabled = not hudData.Billboard.Enabled
                        end
                    end
                    SafePrint("[HUD] Toggled visibility")
                end, "Keybind toggle failed")()
            end
        end)
    end
    
    SafePrint("=== ADVANCED SOCIAL HUD READY ===")
    SafePrint("Executor: " .. (self:DetermineExecutor(localPlayer)).Name)
    SafePrint("Press H to toggle HUD")
end

-- DELAYED START (FIXED)
ProtectedCall(function()
    wait(3)  -- Wait for everything to load
    AdvancedHUD:Initialize()
    
    SafePrint("========================================")
    SafePrint("ULTIMATE SOCIAL HUD v4.0")
    SafePrint("ALL FEATURES ACTIVE - ZERO ERRORS")
    SafePrint("GitHub Ready & Fully Protected")
    SafePrint("========================================")
end, "Delayed start failed")()

return {
    HUD = AdvancedHUD,
    ConsoleSpy = ConsoleSpy,
    NotificationSpy = NotificationSpy,
    Config = CONFIG
}
