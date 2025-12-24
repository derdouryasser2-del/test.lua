-- ========= CONFIG =========
local RAW_URL = "https://raw.githubusercontent.com/derdouryasser2-del/test.lua/refs/heads/main/test.lua"
local TARGET_CFRAME = CFrame.new(-51.3, 3.2, 62.9)
local DELAY_AFTER_TP = 1.5
-- ==========================

if queue_on_teleport then
    queue_on_teleport(([[loadstring(game:HttpGet("%s"))()]]):format(RAW_URL))
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

pcall(function()
    if game.CoreGui:FindFirstChild("DeltaTestTP_E") then
        game.CoreGui.DeltaTestTP_E:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaTestTP_E"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- ===== FRAME PRINCIPAL =====
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 300)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
mainFrame.Parent = gui

-- ===== Onglets =====
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1,0,0,30)
tabsFrame.Position = UDim2.new(0,0,0,0)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame

local autoTPBtn = Instance.new("TextButton")
autoTPBtn.Size = UDim2.new(0.5,0,1,0)
autoTPBtn.Position = UDim2.new(0,0,0,0)
autoTPBtn.Text = "AUTO TP"
autoTPBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
autoTPBtn.TextScaled = true
autoTPBtn.Parent = tabsFrame

local macroBtn = Instance.new("TextButton")
macroBtn.Size = UDim2.new(0.5,0,1,0)
macroBtn.Position = UDim2.new(0.5,0,0,0)
macroBtn.Text = "MACRO"
macroBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
macroBtn.TextScaled = true
macroBtn.Parent = tabsFrame

-- ===== Frames des onglets =====
local autoTPFrame = Instance.new("Frame")
autoTPFrame.Size = UDim2.new(1,0,1,-30)
autoTPFrame.Position = UDim2.new(0,0,0,30)
autoTPFrame.BackgroundTransparency = 1
autoTPFrame.Parent = mainFrame

local macroFrame = Instance.new("Frame")
macroFrame.Size = UDim2.new(1,0,1,-30)
macroFrame.Position = UDim2.new(0,0,0,30)
macroFrame.BackgroundTransparency = 1
macroFrame.Visible = false
macroFrame.Parent = mainFrame

-- ===== DRAG PRINCIPAL =====
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
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
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== SWITCH ONGLET =====
autoTPBtn.MouseButton1Click:Connect(function()
    autoTPFrame.Visible = true
    macroFrame.Visible = false
    autoTPBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    macroBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
end)
macroBtn.MouseButton1Click:Connect(function()
    autoTPFrame.Visible = false
    macroFrame.Visible = true
    autoTPBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    macroBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
end)

-- ===== CONTENU AUTO TP (inchangé) =====
local enabled = false
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -10, 0, 60)
btn.Position = UDim2.new(0,5,0,10)
btn.Text = "AUTO TP : OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(170,40,40)
btn.Parent = autoTPFrame

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

local function teleportAndInteract()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = TARGET_CFRAME
    task.delay(DELAY_AFTER_TP,function()
        if not enabled then return end
        local prompt = getClosestPrompt(15)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.5)
            prompt:InputHoldEnd()
        end
    end)
end

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

player.CharacterAdded:Connect(function()
    task.wait(0.3)
    if enabled then
        teleportAndInteract()
    end
end)

-- ===== CONTENU MACRO =====
local macroLabel = Instance.new("TextLabel")
macroLabel.Size = UDim2.new(1,-10,0,20)
macroLabel.Position = UDim2.new(0,5,0,10)
macroLabel.Text = "Macro Recorder"
macroLabel.TextScaled = true
macroLabel.BackgroundTransparency = 1
macroLabel.TextColor3 = Color3.fromRGB(255,255,255)
macroLabel.Parent = macroFrame

local recordBtn = Instance.new("TextButton")
recordBtn.Size = UDim2.new(1,-10,0,50)
recordBtn.Position = UDim2.new(0,5,0,40)
recordBtn.Text = "RECORD"
recordBtn.TextScaled = true
recordBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
recordBtn.Parent = macroFrame

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(1,-10,0,50)
playBtn.Position = UDim2.new(0,5,0,100)
playBtn.Text = "PLAY MACRO"
playBtn.TextScaled = true
playBtn.BackgroundColor3 = Color3.fromRGB(40,170,40)
playBtn.Parent = macroFrame

local recording = false
local macroActions = {}

local function recordAction(actionType,data)
    if recording then
        table.insert(macroActions,{type=actionType,data=data})
    end
end

-- ===== Hook des boutons du jeu pour enregistrer automatiquement =====
-- Remplacez ces chemins par les vrais boutons de votre jeu
local function hookGameButtons()
    -- Exemple : tous les boutons de placement d'unités
    for _, button in ipairs(player.PlayerGui.MainUI:GetDescendants()) do
        if button:IsA("TextButton") and button.Name:match("PlaceUnit") then
            button.MouseButton1Click:Connect(function()
                local unitType = button.Name -- ou récupère le type exact
                local position = Vector3.new(0,0,0) -- si le jeu fournit la position, la mettre ici
                recordAction("place",{unitType=unitType,position=position})
            end)
        end
        -- Exemple : boutons d'amélioration
        if button:IsA("TextButton") and button.Name:match("UpgradeUnit") then
            button.MouseButton1Click:Connect(function()
                local unit = {} -- récupère l'instance de l'unité correspondante
                recordAction("upgrade",{unit=unit})
            end)
        end
    end
end

hookGameButtons()

recordBtn.MouseButton1Click:Connect(function()
    recording = not recording
    if recording then
        recordBtn.Text = "RECORDING..."
        recordBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
        macroActions = {}
    else
        recordBtn.Text = "RECORD"
        recordBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
        print("Macro saved! Actions count:",#macroActions)
    end
end)

playBtn.MouseButton1Click:Connect(function()
    for _,action in ipairs(macroActions) do
        if action.type=="place" then
            -- Rejouer placement via RemoteEvent
            if game.ReplicatedStorage:FindFirstChild("PlaceUnit") then
                game.ReplicatedStorage.PlaceUnit:FireServer(action.data.unitType,action.data.position)
            end
        elseif action.type=="upgrade" then
            if game.ReplicatedStorage:FindFirstChild("UpgradeUnit") then
                game.ReplicatedStorage.UpgradeUnit:FireServer(action.data.unit)
            end
        end
        task.wait(0.3)
    end
end)
