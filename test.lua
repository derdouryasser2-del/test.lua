-- ===== GUI pour Macro =====
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

-- ===== Variables Macro =====
local recording = false
local macroActions = {}

-- ===== Fonctions Macro =====
local function recordAction(actionType, data)
    if recording then
        table.insert(macroActions, {type = actionType, data = data})
    end
end

-- Exemples de hook sur les événements du jeu pour enregistrer
-- Ici tu dois remplacer avec les vrais événements de ton jeu pour placement et amélioration d'unités
local function hookGameEvents()
    -- Exemple : Placement d'unités
    game.ReplicatedStorage.PlaceUnit.OnClientEvent:Connect(function(unitType, position)
        recordAction("place", {unitType = unitType, position = position})
    end)
    
    -- Exemple : Amélioration d'unités
    game.ReplicatedStorage.UpgradeUnit.OnClientEvent:Connect(function(unit)
        recordAction("upgrade", {unit = unit})
    end)
end

hookGameEvents()

-- ===== Buttons =====
recordBtn.MouseButton1Click:Connect(function()
    recording = not recording
    if recording then
        recordBtn.Text = "RECORDING..."
        recordBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
        macroActions = {} -- reset la macro
    else
        recordBtn.Text = "RECORD"
        recordBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
        print("Macro saved! Actions count:", #macroActions)
    end
end)

playBtn.MouseButton1Click:Connect(function()
    for _, action in ipairs(macroActions) do
        if action.type == "place" then
            -- Remplacer avec la vraie fonction placement dans ton jeu
            game.ReplicatedStorage.PlaceUnit:FireServer(action.data.unitType, action.data.position)
        elseif action.type == "upgrade" then
            -- Remplacer avec la vraie fonction upgrade dans ton jeu
            game.ReplicatedStorage.UpgradeUnit:FireServer(action.data.unit)
        end
        task.wait(0.3) -- petit délai entre actions
    end
end)
