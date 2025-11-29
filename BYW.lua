-- BYW SCRIPT
local aimbotEnabled = false
local aimbotConnection

local player = game.Players.LocalPlayer
player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotMenu"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Name = "AimbotBtn"
aimbotBtn.Size = UDim2.new(0, 40, 0, 40)
aimbotBtn.Position = UDim2.new(0, 10, 0, 10)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
aimbotBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
aimbotBtn.Text = "AIM"
aimbotBtn.TextSize = 24
aimbotBtn.Font = Enum.Font.GothamBold
aimbotBtn.BorderSizePixel = 0
aimbotBtn.Active = true
aimbotBtn.Draggable = true
aimbotBtn.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = aimbotBtn

local function isVisible(targetPart)
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = character.HumanoidRootPart.Position
    local target = targetPart.Position
    local direction = (target - origin).Unit
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = workspace:Raycast(origin, direction * 500, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        return hitPart:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function findNearestEnemy()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local nearestEnemy = nil
    local nearestDistance = math.huge
    local localRoot = character.HumanoidRootPart
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local enemyRoot = player.Character.HumanoidRootPart
            local enemyHead = player.Character.Head
            local distance = (localRoot.Position - enemyRoot.Position).Magnitude
            
            if distance < nearestDistance and isVisible(enemyHead) then
                nearestEnemy = enemyHead
                nearestDistance = distance
            end
        end
    end
    
    return nearestEnemy
end

local function aimAtTarget(targetHead)
    if not targetHead then return end
    
    local camera = workspace.CurrentCamera
    if camera then
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
    end
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    
    if aimbotEnabled then
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        aimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local nearestEnemy = findNearestEnemy()
            if nearestEnemy then
                aimAtTarget(nearestEnemy)
            end
        end)
        print("AimBot: ON")
    else
        aimbotBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        aimbotBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        print("AimBot: OFF")
    end
end

aimbotBtn.MouseButton1Click:Connect(toggleAimbot)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        toggleAimbot()
    end
end)

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    aimbotBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

aimbotBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = aimbotBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

aimbotBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.TouchMovement) then
        update(input)
    end
end)

print("BYW AIMBOT SCRIPT loaded!")
