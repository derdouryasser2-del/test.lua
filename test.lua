-- =====================================
-- AUTO REEXEC APRES TELEPORT
-- =====================================
local RAW_URL = "https://raw.githubusercontent.com/derdouryasser2-del/test.lua/refs/heads/main/test.lua"

if queue_on_teleport then
    queue_on_teleport(([[ 
        loadstring(game:HttpGet("%s"))()
    ]]):format(RAW_URL))
end
-- =====================================

-- ========= CONFIG AUTO TP =========
local TARGET_CFRAME =
    CFrame.new(-51.3, 3.2, 62.9)
    * CFrame.Angles(0, math.rad(180), 0)

local E_REPEAT = 5
local E_INTERVAL = 1
-- =================================

-- ========= SERVICES =========
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ========= NETWORK MODULE (FIX DELTA) =========
local Network = require(
    ReplicatedStorage
        :WaitForChild("GenericModules")
        :WaitForChild("Service")
        :WaitForChild("Network")
)

local PlaceTower = Network.PlayerPlaceTower
local UpgradeTower = Network.PlayerUpgradeTower
-- ============================================

-- ========= CLEAN GUI =========
pcall(function()
    game.CoreGui.AutoTP_MACRO:Destroy()
end)

-- ========= GUI =========
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoTP_MACRO"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 240)
frame.Position = UDim2.new(0.5, -150, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- ========= DRAG =========
do
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + d.X,
                startPos.Y.Scale,
                startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ========= UTIL =========
local function button(txt, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 40)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = txt
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    return b
end

-- ========= AUTO TP + E =========
local function getClosestPrompt(maxDist)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    local closest, dist = nil, maxDist or 15
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local p = obj.Parent
            if p:IsA("BasePart") then
                local d = (p.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = obj
                end
            end
        end
    end
    return closest
end

local function autoTP()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    char.HumanoidRootPart.CFrame = TARGET_CFRAME
    task.wait(0.3)

    for i = 1, E_REPEAT do
        local prompt = getClosestPrompt(15)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.4)
            prompt:InputHoldEnd()
        end
        task.wait(E_INTERVAL)
    end
end

-- ========= MACRO MANUELLE =========
-- ✍️ TU MODIFIES ICI
local MACRO = {
    {type="place", unit="3881493602:7449", pos=Vector3.new(-76.7,126.2,-215.5), r=0},
    {type="upgrade", id=1},
    {type="upgrade", id=1},
}

local macroRunning = false

local function playMacro()
    macroRunning = true
    while macroRunning do
        for _, step in ipairs(MACRO) do
            if step.type == "place" and PlaceTower then
                PlaceTower:FireServer(step.unit, step.pos, step.r)
            elseif step.type == "upgrade" and UpgradeTower then
                UpgradeTower:FireServer(step.id)
            end
            task.wait(0.4)
        end
        task.wait(1)
    end
end

-- ========= BUTTONS =========
local tpBtn   = button("AUTO TP + E", 10)
local playBtn = button("PLAY MACRO (∞)", 60)
local stopBtn = button("STOP MACRO", 110)

tpBtn.MouseButton1Click:Connect(autoTP)

playBtn.MouseButton1Click:Connect(function()
    if not macroRunning then
        task.spawn(playMacro)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    macroRunning = false
end)

print("✅ SCRIPT CHARGÉ SANS ERREUR (DELTA OK)")
