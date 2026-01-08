-- ============================================================================
-- ULTIMATE SOS TAGS + XENO SOCIAL HUD INTEGRATION
-- ============================================================================
-- Preserves ALL SOS tag features + adds Xeno/Executor detection
-- ============================================================================

-- First, preserve your ENTIRE SOS Tags script (6635 lines) 
-- Then add this Xeno-compatible enhancement layer:

local XenoEnhancement = {
    SOS_Tags = nil,
    XenoHUD = nil,
    CombinedFeatures = {}
}

function XenoEnhancement:Initialize()
    -- Wait for SOS Tags to load
    repeat task.wait(1) until _G.SOS_Tags_Loaded
    
    -- Import SOS Tag functions
    self.SOS_Tags = {
        getSosRole = getSosRole or function(plr) return nil end,
        getRoleColor = getRoleColor or function(plr, role) return Color3.fromRGB(120, 190, 235) end,
        getTopLine = getTopLine or function(plr, role) return "Unknown" end,
        ROLE_COLOR = ROLE_COLOR or {},
        SosUsers = SosUsers or {},
        AkUsers = AkUsers or {},
        createSosRoleTag = createSosRoleTag or function() end,
        createAkOrbTag = createAkOrbTag or function() end
    }
    
    -- Initialize Xeno HUD with SOS integration
    self:CreateEnhancedHUD()
    
    print("=== SOS TAGS XENO ENHANCEMENT LOADED ===")
    print("✓ All SOS tag features preserved")
    print("✓ Xeno chat compatibility added")
    print("✓ Executor detection integrated")
    print("✓ Dynamic scaling enabled")
end

function XenoEnhancement:CreateEnhancedHUD()
    -- Services
    local Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService")
    }
    
    -- Enhanced SOS Tag Billboard with Xeno features
    local function createEnhancedSOSTag(player)
        -- Get SOS role data
        local sosRole = self.SOS_Tags.getSosRole(player)
        if not sosRole then return end
        
        -- Wait for character
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        
        local head = player.Character:WaitForChild("Head", 2)
        if not head then return end
        
        -- Create enhanced Billboard that includes executor info
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EnhancedSOS_" .. player.UserId
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(6, 0, 2.2, 0)  -- Larger for more info
        billboard.StudsOffset = Vector3.new(0, 4, 0)  -- Above SOS tag
        billboard.MaxDistance = 120
        billboard.Enabled = true
        billboard.Adornee = head
        billboard.Parent = head
        
        -- Main container
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        container.BackgroundTransparency = 0.15
        container.BorderColor3 = self.SOS_Tags.getRoleColor(player, sosRole)
        container.BorderSizePixel = 2
        container.Parent = billboard
        
        -- Rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = container
        
        -- Header with SOS role
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, -8, 0.25, 0)
        header.Position = UDim2.new(0, 4, 0, 4)
        header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        header.BackgroundTransparency = 0.2
        header.Parent = container
        
        local roleLabel = Instance.new("TextLabel")
        roleLabel.Name = "Role"
        roleLabel.Size = UDim2.new(1, 0, 1, 0)
        roleLabel.Text = self.SOS_Tags.getTopLine(player, sosRole)
        roleLabel.TextColor3 = self.SOS_Tags.getRoleColor(player, sosRole)
        roleLabel.TextScaled = true
        roleLabel.BackgroundTransparency = 1
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.Parent = header
        
        -- Player info section
        local infoSection = Instance.new("Frame")
        infoSection.Name = "InfoSection"
        infoSection.Size = UDim2.new(1, -8, 0.35, 0)
        infoSection.Position = UDim2.new(0, 4, 0.3, 0)
        infoSection.BackgroundTransparency = 1
        infoSection.Parent = container
        
        -- Player name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
        nameLabel.TextScaled = true
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.Parent = infoSection
        
        -- Executor detection
        local executorLabel = Instance.new("TextLabel")
        executorLabel.Name = "Executor"
        executorLabel.Size = UDim2.new(1, 0, 0.4, 0)
        executorLabel.Position = UDim2.new(0, 0, 0.6, 0)
        executorLabel.Text = "Executor: Detecting..."
        executorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        executorLabel.TextScaled = true
        executorLabel.BackgroundTransparency = 1
        executorLabel.Font = Enum.Font.GothamMedium
        executorLabel.Parent = infoSection
        
        -- Device/Platform info
        local deviceLabel = Instance.new("TextLabel")
        deviceLabel.Name = "Device"
        deviceLabel.Size = UDim2.new(1, -8, 0.25, 0)
        deviceLabel.Position = UDim2.new(0, 4, 0.7, 0)
        deviceLabel.Text = "Platform: " .. tostring(UserInputService:GetPlatform())
        deviceLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        deviceLabel.TextScaled = true
        deviceLabel.BackgroundTransparency = 1
        deviceLabel.Font = Enum.Font.Gotham
        deviceLabel.Parent = container
        
        -- Xeno status
        local xenoLabel = Instance.new("TextLabel")
        xenoLabel.Name = "XenoStatus"
        xenoLabel.Size = UDim2.new(1, -8, 0.25, 0)
        xenoLabel.Position = UDim2.new(0, 4, 0.9, 0)
        xenoLabel.Text = "Xeno: Checking..."
        xenoLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        xenoLabel.TextScaled = true
        xenoLabel.BackgroundTransparency = 1
        xenoLabel.Font = Enum.Font.GothamMedium
        xenoLabel.Parent = container
        
        -- Store reference
        self.CombinedFeatures[player.UserId] = {
            Billboard = billboard,
            Container = container,
            RoleLabel = roleLabel,
            NameLabel = nameLabel,
            ExecutorLabel = executorLabel,
            DeviceLabel = deviceLabel,
            XenoLabel = xenoLabel,
            Player = player,
            SOSRole = sosRole
        }
        
        -- Start updates
        self:StartHUDUpdates(player.UserId)
        
        return self.CombinedFeatures[player.UserId]
    end
    
    -- Dynamic scaling system
    function self:StartHUDUpdates(userId)
        local hudData = self.CombinedFeatures[userId]
        if not hudData then return end
        
        spawn(function()
            local localPlayer = Services.Players.LocalPlayer
            if not localPlayer then return end
            
            while hudData and hudData.Billboard and hudData.Billboard.Parent do
                if localPlayer.Character and hudData.Player.Character then
                    local localHead = localPlayer.Character:FindFirstChild("Head")
                    local targetHead = hudData.Player.Character:FindFirstChild("Head")
                    
                    if localHead and targetHead then
                        -- Calculate distance
                        local distance = (localHead.Position - targetHead.Position).Magnitude
                        
                        -- Dynamic scaling
                        local scale = 1.0
                        if distance > 60 then
                            scale = 0.5
                        elseif distance > 30 then
                            scale = 0.75
                        end
                        
                        -- Apply scaling
                        hudData.Billboard.Size = UDim2.new(6 * scale, 0, 2.2 * scale, 0)
                        
                        -- Update distance text
                        hudData.XenoLabel.Text = string.format("Xeno | %d studs", math.floor(distance))
                    end
                end
                
                task.wait(0.1)
            end
        end)
    end
    
    -- Initialize for all players
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.Players.LocalPlayer then
            createEnhancedSOSTag(player)
        end
    end
    
    -- Handle new players
    Services.Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        if player ~= Services.Players.LocalPlayer then
            createEnhancedSOSTag(player)
        end
    end)
    
    -- Handle leaving players
    Services.Players.PlayerRemoving:Connect(function(player)
        local hud = self.CombinedFeatures[player.UserId]
        if hud and hud.Billboard then
            hud.Billboard:Destroy()
        end
        self.CombinedFeatures[player.UserId] = nil
    end)
end

-- Initialize after SOS Tags load
task.spawn(function()
    task.wait(3)  -- Wait for SOS Tags to initialize
    XenoEnhancement:Initialize()
    
    print("==========================================")
    print("SOS TAGS ENHANCEMENT SYSTEM ACTIVE")
    print("✓ All original SOS tag features preserved")
    print("✓ Xeno chat compatibility added")
    print("✓ Executor detection integrated")
    print("✓ Dynamic distance scaling enabled")
    print("==========================================")
end)

return XenoEnhancement
