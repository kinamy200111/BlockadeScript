-- autofarm.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Настройки
local SETTINGS = {
    height = 100,
    radius = 12,
    speed = 0.05,
    lookAngle = 85,
    attackDelay = 0.5,
    healThreshold = 300,
    pulseCannonCost = 500
}

-- Поиск цели
local function findTarget()
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    
    for _, obj in ipairs(living:GetChildren()) do
        if obj:FindFirstChild("HumanoidRootPart") then
            if string.match(obj.Name, "Toilet") 
            or string.match(obj.Name, "Fake Head") 
            or string.match(obj.Name, "Giant Robber")
            or string.match(obj.Name, "Militant Toilet")
            or string.match(obj.Name, "RocketToilet") then
                return obj
            end
        end
    end
    return nil
end

-- Атака
local function attack()
    local event = ReplicatedStorage:FindFirstChild("TargetShoots")
    if event then
        event:FireServer()
    end
end

-- Орбита
local function startOrbit(target)
    local angle = 0
    RunService.Heartbeat:Connect(function()
        if not target or not target.Parent then return end
        
        local targetPos = target.HumanoidRootPart.Position
        angle = angle + SETTINGS.speed
        
        humanoidRootPart.CFrame = CFrame.new(
            targetPos + Vector3.new(
                math.cos(angle) * SETTINGS.radius,
                SETTINGS.height,
                math.sin(angle) * SETTINGS.radius
            ),
            targetPos
        ) * CFrame.Angles(math.rad(-SETTINGS.lookAngle), 0, 0)
    end)
end

-- Автолечение
local function autoHeal()
    if character.Humanoid.Health < SETTINGS.healThreshold then
        ReplicatedStorage.ShopSystem:FireServer("Buy", "FillHP")
    end
end

-- Основной цикл
local target = findTarget()
if target then
    startOrbit(target)
    
    while true do
        attack()
        autoHeal()
        task.wait(SETTINGS.attackDelay)
    end
else
    warn("Цели не найдены!")
end