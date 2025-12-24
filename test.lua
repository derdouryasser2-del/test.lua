local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- POSITION DE TEST
local TARGET_CFRAME = CFrame.new(-51.3,3.2, 62.9)

local enabled = false

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaTestTP_E"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 80)
frame.Position = UDim2.new(0.5, -120, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -10, 1, -10)
btn.Position = UDim2.new(0, 5, 0, 5)
btn.Text = "AUTO TP : OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
btn.Parent = frame

-- 🔹 DRAG SYSTEM
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- 🔍 ProximityPrompt le plus proche
local function getClosestPrompt(maxDistance)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local root = char.HumanoidRootPart
    local closest, dist = nil, maxDistance or 15

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part:IsA("BasePart") then
                local d = (part.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = obj
                end
            end
        end
    end

    return closest
end

-- TP + E après 4s
local function teleportAndInteract()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- TP client (test anti-cheat)
    char.HumanoidRootPart.CFrame = TARGET_CFRAME

    task.delay(4, function()
        if not enabled then return end

        local prompt = getClosestPrompt(15)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.5)
            prompt:InputHoldEnd()
        end
    end)
end

-- Bouton
btn.MouseButton1Click:Connect(function()
    enabled = not enabled

    if enabled then
        btn.Text = "AUTO TP : ON"
        btn.BackgroundColor3 = Color3.fromRGB(40, 170, 40)
        teleportAndInteract()
    else
        btn.Text = "AUTO TP : OFF"
        btn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    end
end)

-- Retest après respawn
player.CharacterAdded:Connect(function()
    task.wait(0.3)
    if enabled then
        teleportAndInteract()
    end
end)


