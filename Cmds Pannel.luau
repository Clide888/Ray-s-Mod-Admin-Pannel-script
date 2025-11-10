local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Original Functions (unchanged)
local function kickPlayer(targetName, reason)
    local args = {
        [1] = targetName,
        [2] = reason or "No reason provided."
    }
    ReplicatedStorage:WaitForChild("VoteKickInProgress"):WaitForChild("VoteEvent"):FireServer(unpack(args))
end

local function scaleplayer(size)
    local allsizes = size
    for _, part in ipairs({"Depth", "Width", "Height", "Head"}) do
        local args = {[1] = allsizes}
        ReplicatedStorage:WaitForChild("PlayerScale"):WaitForChild(part):FireServer(unpack(args))
        task.wait()
    end
end

local function winVote()
    for _, player in ipairs(Players:GetPlayers()) do
        ReplicatedStorage:WaitForChild("VoteKickInProgress"):WaitForChild("VoteAdded"):FireServer()
    end
end

local function kickAll(reason)
    local excludeLocalPlayer = {
        [LocalPlayer.Name] = true
    }

    for _, player in ipairs(Players:GetPlayers()) do
        if not excludeLocalPlayer[player.Name] then
            kickPlayer(player.Name, reason)
            for _, p in ipairs(Players:GetPlayers()) do
                task.wait()
                ReplicatedStorage:WaitForChild("VoteKickInProgress"):WaitForChild("VoteAdded"):FireServer()
            end
            task.wait(15.7)
        end
    end
end

local function addHealth(healthInput)
    local timesToFire = math.floor(healthInput / 100)
    for i = 1, timesToFire do
        task.spawn(function()
            ReplicatedStorage:WaitForChild("MoreHealth"):FireServer()
        end)
    end
end

local function giveAddons()
    local localAddons = LocalPlayer.PlayerGui.Spawner.SpawnFrame.Addons
    local RSAddons = ReplicatedStorage:WaitForChild("AddonStorage"):GetChildren()

    for _, addon in ipairs(RSAddons) do
        local clonedAddon = addon:Clone()
        clonedAddon.Parent = localAddons
    end
end

-- Solo Mode Function with Executor Support
local function activateSoloMode()
    -- Executor-compatible readonly bypass
    local success, error = pcall(function()
        -- Method 1: Standard setreadonly approach
        if setreadonly then
            setreadonly(game.Players, false)
            game.Players.MaxPlayersInternal = 1
            game.Players.MaxPlayers = 1
            setreadonly(game.Players, true)
        end
    end)
    
    if not success then
        -- Method 2: Alternative approach for different executors
        pcall(function()
            if getreadonly and not getreadonly(game.Players) then
                game.Players.MaxPlayersInternal = 1
                game.Players.MaxPlayers = 1
            end
        end)
        
        -- Method 3: Direct manipulation (some executors allow this)
        pcall(function()
            game.Players.MaxPlayersInternal = 1
            game.Players.MaxPlayers = 1
        end)
    end
    
    -- Set health to 0
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end)
    
    return success
end

-- Modern UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernTrashAdminUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame with modern styling (expanded to fit new button)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 250) -- Increased height for new button
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Add rounded corners
local MainFrameCorner = Instance.new("UICorner")
MainFrameCorner.CornerRadius = UDim.new(0, 12)
MainFrameCorner.Parent = MainFrame

-- Add shadow effect
local MainFrameShadow = Instance.new("ImageLabel")
MainFrameShadow.Name = "Shadow"
MainFrameShadow.Size = UDim2.new(1, 30, 1, 30)
MainFrameShadow.Position = UDim2.new(0, -15, 0, -15)
MainFrameShadow.BackgroundTransparency = 1
MainFrameShadow.Image = "rbxassetid://1316045217"
MainFrameShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainFrameShadow.ImageTransparency = 0.7
MainFrameShadow.ScaleType = Enum.ScaleType.Slice
MainFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
MainFrameShadow.ZIndex = MainFrame.ZIndex - 1
MainFrameShadow.Parent = MainFrame

-- Title Bar with gradient
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

-- Gradient for title bar
local TitleBarGradient = Instance.new("UIGradient")
TitleBarGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 85)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 65))
}
TitleBarGradient.Rotation = 90
TitleBarGradient.Parent = TitleBar

-- Title Label with modern typography
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎮 Shitty Ray Mod cmds"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Add subtle text stroke
local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Color3.fromRGB(0, 0, 0)
TitleStroke.Transparency = 0.5
TitleStroke.Thickness = 1
TitleStroke.Parent = TitleLabel

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -30, 1, -60)
ContentFrame.Position = UDim2.new(0, 15, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Modern Command Input with background
local InputBackground = Instance.new("Frame")
InputBackground.Name = "InputBackground"
InputBackground.Size = UDim2.new(1, 0, 0, 50)
InputBackground.Position = UDim2.new(0, 0, 0, 10)
InputBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
InputBackground.BorderSizePixel = 0
InputBackground.Parent = ContentFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputBackground

-- Modern TextBox
local CommandInput = Instance.new("TextBox")
CommandInput.Name = "CommandInput"
CommandInput.Size = UDim2.new(1, -20, 1, -10)
CommandInput.Position = UDim2.new(0, 10, 0, 5)
CommandInput.BackgroundTransparency = 1
CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandInput.PlaceholderText = "Enter command (kick, kickall, HP, addons, win, size)"
CommandInput.TextScaled = true
CommandInput.Font = Enum.Font.Gotham
CommandInput.ClearTextOnFocus = false
CommandInput.Parent = InputBackground

-- Status Label for feedback
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 70)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready • Type a command and press Enter"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = ContentFrame

-- Solo Mode Button
local SoloModeButton = Instance.new("TextButton")
SoloModeButton.Name = "Anti SpawnCooldown"
SoloModeButton.Size = UDim2.new(1, 0, 0, 45)
SoloModeButton.Position = UDim2.new(0, 0, 0, 105)
SoloModeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
SoloModeButton.BorderSizePixel = 0
SoloModeButton.Text = "🔒 ACTIVATE ANTI SPAWNCOOLDOWN"
SoloModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SoloModeButton.TextScaled = true
SoloModeButton.Font = Enum.Font.GothamBold
SoloModeButton.Parent = ContentFrame

-- Button corners
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = SoloModeButton

-- Button gradient
local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 70, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 30, 30))
}
ButtonGradient.Rotation = 90
ButtonGradient.Parent = SoloModeButton

-- Hover effects and animations
local function createHoverEffect(object, hoverColor, originalColor)
    object.MouseEnter:Connect(function()
        local tween = TweenService:Create(object, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor})
        tween:Play()
    end)
    
    object.MouseLeave:Connect(function()
        local tween = TweenService:Create(object, TweenInfo.new(0.2), {BackgroundColor3 = originalColor})
        tween:Play()
    end)
end

createHoverEffect(InputBackground, Color3.fromRGB(45, 45, 65), Color3.fromRGB(35, 35, 50))
createHoverEffect(SoloModeButton, Color3.fromRGB(250, 90, 90), Color3.fromRGB(220, 50, 50))

-- Focus effects
CommandInput.Focused:Connect(function()
    local tween = TweenService:Create(InputBackground, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    })
    tween:Play()
end)

CommandInput.FocusLost:Connect(function()
    local tween = TweenService:Create(InputBackground, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    })
    tween:Play()
end)

-- Update status with feedback
local function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 200)
    
    -- Fade out after 3 seconds
    task.spawn(function()
        task.wait(3)
        local fadeTween = TweenService:Create(StatusLabel, TweenInfo.new(1), {
            TextTransparency = 0.7
        })
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            StatusLabel.Text = "Ready • Type a command and press Enter"
            StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
            StatusLabel.TextTransparency = 0
        end)
    end)
end

-- Solo Mode Button Click Handler
SoloModeButton.MouseButton1Click:Connect(function()
    -- Button press animation
    local pressTween = TweenService:Create(SoloModeButton, TweenInfo.new(0.1), {
        Size = UDim2.new(1, 0, 0, 40)
    })
    pressTween:Play()
    pressTween.Completed:Connect(function()
        local releaseTween = TweenService:Create(SoloModeButton, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 0, 0, 45)
        })
        releaseTween:Play()
    end)
    
    -- Execute solo mode
    local success = activateSoloMode()
    
    if success then
        updateStatus("✓ Solo mode activated • Health reset to 0", Color3.fromRGB(255, 100, 100))
        SoloModeButton.Text = "✅ SOLO MODE ACTIVE"
        SoloModeButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Update button gradient to green
        ButtonGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 250, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 200, 30))
        }
    else
        updateStatus("Anti SpawningCooldown Active", Color3.fromRGB(255, 100, 100))
    end
end)

-- Original command processing (preserved)
CommandInput.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end

    local message = CommandInput.Text
    CommandInput.Text = ""

    local command, arg1, arg2 = string.match(message, "(%w+)%s*(%S*)%s*(.*)")

    if command == "kick" and arg1 then
        kickPlayer(arg1, arg2)
        updateStatus("✓ Kicked " .. arg1, Color3.fromRGB(100, 255, 100))
        for _, player in ipairs(Players:GetPlayers()) do
            task.wait()
            ReplicatedStorage:WaitForChild("VoteKickInProgress"):WaitForChild("VoteAdded"):FireServer()
        end

    elseif command == "kickall" then
        kickAll(arg1)
        updateStatus("✓ Kicked all players", Color3.fromRGB(255, 100, 100))

    elseif command == "HP" and tonumber(arg1) then
        addHealth(tonumber(arg1))
        updateStatus("✓ Added " .. arg1 .. " HP", Color3.fromRGB(100, 200, 255))

    elseif command == "addons" then
        giveAddons()
        updateStatus("✓ Unlocked all addons", Color3.fromRGB(255, 200, 100))

    elseif command == "win" then
        winVote()
        updateStatus("✓ Vote manipulation activated", Color3.fromRGB(255, 100, 255))

    elseif command == "size" and tonumber(arg1) then
        scaleplayer(tonumber(arg1))
        updateStatus("✓ Scaled player to " .. arg1, Color3.fromRGB(100, 255, 200))

    else
        updateStatus("This command doesnt exist", Color3.fromRGB(255, 100, 100))
    end
end)

-- Entrance animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local entranceTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 400, 0, 250),
    Position = UDim2.new(0.5, -200, 0.5, -125)
})
entranceTween:Play()

-- Keyboard shortcut (Toggle UI with F key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        if ScreenGui.Enabled then
            local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            hideTween:Play()
            hideTween.Completed:Connect(function()
                ScreenGui.Enabled = false
            end)
        else
            ScreenGui.Enabled = true
            local showTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 400, 0, 250),
                Position = UDim2.new(0.5, -200, 0.5, -125)
            })
            showTween:Play()
        end
    end
end)

print("🎮 Modern Trash Admin Commands loaded!")
print("📋 Commands: kick, kickall, HP, addons, win, size")
print("⌨️ Press F to toggle UI")
print("🔒 Anti Spawn Cooldown Active")
