-- ========= CONFIG =========
local RAW_URL = "https://raw.githubusercontent.com/derdouryasser2-del/test.lua/refs/heads/main/test.lua"
local TARGET_CFRAME = CFrame.new(-51.3, 3.2, 62.9)
local DELAY_AFTER_TP = 1.5
-- ==========================

-- ===== AUTO REEXEC APRES TELEPORT =====
if queue_on_teleport then
    queue_on_teleport(([[ 
        loadstring(game:HttpGet("%s"))()
    ]]):format(RAW_URL))
end
-- =====================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- éviter doublon GUI
pcall(function()
    if game.CoreGui:FindFirstChild("DeltaTestTP_E") then
        game.CoreGui.DeltaTestTP_E:Destroy()
    end
end)

local enabled = false

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaTestTP_E"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- ===== Frame Auto TP =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 80)
frame.Position = UDim2.new(0.5, -120, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -10, 1, -10)
btn.Position = UDim2.new(0, 5, 0, 5)
btn.Text = "AUTO TP : OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(170,40,40)
btn.Parent = frame

-- ===== DRAG =====
local dragging, dragStart, startPos

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

-- ===== PROXIMITY PROMPT =====
local function getClosestPrompt(maxDistance)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

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

-- ===== TP + E =====
local function teleportAndInteract()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    char.HumanoidRootPart.CFrame = TARGET_CFRAME

    task.delay(DELAY_AFTER_TP, function()
        if not enabled then return end
        local prompt = getClosestPrompt(15)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.5)
            prompt:InputHoldEnd()
        end
    end)
end

-- ===== BUTTON AUTO TP =====
btn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        btn.Text = "AUTO TP : ON"
        btn.BackgroundColor3 = Color3.fromRGB(40,170,40)
        teleportAndInteract()
    else
        btn.Text = "AUTO TP : OFF"
        btn.BackgroundColor3 = Color3.fromRGB(170,40,40)
    end
end)

-- ===== RESPAWN =====
player.CharacterAdded:Connect(function()
    task.wait(0.3)
    if enabled then
        teleportAndInteract()
    end
end)

-- ===== FRAME MACRO =====
local macroFrame = Instance.new("Frame")
macroFrame.Size = UDim2.new(0, 300, 0, 120)
macroFrame.Position = UDim2.new(0.5, -150, 0.5, 50)
macroFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
macroFrame.Parent = gui

local macroLabel = Instance.new("TextLabel")
macroLabel.Size = UDim2.new(1, -10, 0, 20)
macroLabel.Position = UDim2.new(0, 5, 0, 5)
macroLabel.Text = "Macro Recorder"
macroLabel.TextScaled = true
macroLabel.BackgroundTransparency = 1
macroLabel.TextColor3 = Color3.fromRGB(255,255,255)
macroLabel.Parent = macroFrame

local recordBtn = Instance.new("TextButton")
recordBtn.Size = UDim2.new(1, -10, 0, 40)
recordBtn.Position = UDim2.new(0, 5, 0, 30)
recordBtn.Text = "RECORD"
recordBtn.TextScaled = true
recordBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
recordBtn.Parent = macroFrame

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(1, -10, 0, 40)
playBtn.Position = UDim2.new(0, 5, 0, 75)
playBtn.Text = "PLAY MACRO"
playBtn.TextScaled = true
playBtn.BackgroundColor3 = Color3.fromRGB(40,170,40)
playBtn.Parent = macroFrame

-- ===== DRAG MACRO FRAME =====
local macroDragging, macroDragStart, macroStartPos
macroFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        macroDragging = true
        macroDragStart = input.Position
        macroStartPos = macroFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        macroDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if macroDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - macroDragStart
        macroFrame.Position = UDim2.new(
            macroStartPos.X.Scale,
            macroStartPos.X.Offset + delta.X,
            macroStartPos.Y.Scale,
            macroStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== MACRO LOGIC =====
local recording = false
local macroActions = {}

local function recordAction(actionType, data)
    if recording then
        table.insert(macroActions, {type = actionType, data = data})
    end
end

-- Hook exemple pour les événements du jeu
local function hookGameEvents()
    -- Remplacer par tes RemoteEvents du jeu
    if game.ReplicatedStorage:FindFirstChild("PlaceUnit") then
        game.ReplicatedStorage.PlaceUnit.OnClientEvent:Connect(function(unitType, position)
            recordAction("place", {unitType = unitType, position = position})
        end)
    end
    if game.ReplicatedStorage:FindFirstChild("UpgradeUnit") then
        game.ReplicatedStorage.UpgradeUnit.OnClientEvent:Connect(function(unit)
            recordAction("upgrade", {unit = unit})
        end)
    end
end
hookGameEvents()

-- ===== BUTTONS MACRO =====
recordBtn.MouseButton1Click:Connect(function()
    recording = not recording
    if recording then
        recordBtn.Text = "RECORDING..."
        recordBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
        macroActions = {} -- reset
    else
        recordBtn.Text = "RECORD"
        recordBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
        print("Macro saved! Actions count:", #macroActions)
    end
end)

playBtn.MouseButton1Click:Connect(function()
    for _, action in ipairs(macroActions) do
        if action.type == "place" then
            game.ReplicatedStorage.PlaceUnit:FireServer(action.data.unitType, action.data.position)
        elseif action.type == "upgrade" then
            game.ReplicatedStorage.UpgradeUnit:FireServer(action.data.unit)
        end
        task.wait(0.3)
    end
end)
