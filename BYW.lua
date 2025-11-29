-- BYW SCRIPT
local aimbotEnabled = false
local aimbotConnection

local player = game.Players.LocalPlayer
player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotMenu"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local AimBotBtn = Instance.new("TextButton")
AimBotBtn.Name = "AimBotBtn"
AimBotBtn.Size = UDim2.new(0, 40, 0, 40)
AimBotBtn.Position = UDim2.new(0, 10, 0, 10)
AimBotBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AimBotBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
AimBotBtn.Text = "AIM"
AimBotBtn.TextSize = 24
AimBotBtn.Font = Enum.Font.GothamBold
AimBotBtn.BorderSizePixel = 0
AimBotBtn.Active = true
AimBotBtn.Draggable = true
AimBotBtn.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = AimBotBtn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function isVisible(target)
    local localChar = LocalPlayer.Character
    local targetChar = target.Character
    if not localChar or not targetChar then return false end
    
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetHead then return false end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetHead.Position
    
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localChar, targetChar}
    
    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    
    if raycastResult then
        local hitModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        if hitModel == targetChar then
            return true
        end
        return false
    end
    
    return true
end

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local head = char.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen and isVisible(player) then
                local distanceToPlayer = (head.Position - Camera.CFrame.Position).Magnitude
                
                if distanceToPlayer < closestDistance then
                    closestPlayer = player
                    closestDistance = distanceToPlayer
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtTarget(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    
    local targetPosition = head.Position
    local cameraPosition = currentCamera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    
    currentCamera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + direction)
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    
    if aimbotEnabled then
        AimBotBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Исправлено на AimBotBtn
        AimBotBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Исправлено на AimBotBtn
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local closestPlayer = getClosestPlayer()
            if closestPlayer then
                aimAtTarget(closestPlayer)
            end
        end)
        print("AimBot: ON")
    else
        AimBotBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Исправлено на AimBotBtn
        AimBotBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- Исправлено на AimBotBtn
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        print("AimBot: OFF")
    end
end

AimBotBtn.MouseButton1Click:Connect(toggleAimbot) -- Исправлено на AimBotBtn

UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
    AimBotBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) -- Исправлено на AimBotBtn
end

AimBotBtn.InputBegan:Connect(function(input) -- Исправлено на AimBotBtn
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = AimBotBtn.Position -- Исправлено на AimBotBtn
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

AimBotBtn.InputChanged:Connect(function(input) -- Исправлено на AimBotBtn
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.TouchMovement) then
        update(input)
    end
end)

print("BYW SCRIPT loaded!")
