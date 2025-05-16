local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Настройки
local SETTINGS = {
    height = 120,
    radius = 17,
    speed = 0.05,
    lookAngle = 85,
    attackDelay = 0.5,  -- Уменьшенная задержка атаки
    healThreshold = 300,
    pulseCannonCost = 500,
    respawnPlaceId = 18816546575,
    abilityEventName = "TargetShoots"  -- Имя ивента для абилки
}

-- Шаблоны врагов
local ENEMY_PATTERNS = {
    "Toilet%d*", "Fake Head%d*", "Giant Robber", 
    "Militant Toilet", "RocketToilet", "Ginger Toilet",
    "Malware", "flying buzzsaw toilet", "G-Toilet",
    "G-Toilet 2.0", "Infected Titan Speaker"
}

-- Инициализация
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local abilityEvent = ReplicatedStorage:WaitForChild(SETTINGS.abilityEventName)

-- Обработчик смерти
character:WaitForChild("Humanoid").Died:Connect(function()
    TeleportService:Teleport(SETTINGS.respawnPlaceId, player)
end)

-- Поиск врага
local function findEnemy()
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    
    for _, obj in ipairs(living:GetChildren()) do
        for _, pattern in ipairs(ENEMY_PATTERNS) do
            if string.match(obj.Name or "", pattern) and obj:FindFirstChild("HumanoidRootPart") then
                return obj
            end
        end
    end
    return nil
end

-- Активация абилки
local function useAbility()
    pcall(function()
        abilityEvent:FireServer()
        warn("Абилка активирована!")
    end)
end

-- Орбитальное движение
local function orbitTarget(target)
    local angle = 0
    return RunService.Heartbeat:Connect(function()
        if not target or not target.Parent then return end
        
        local targetPos = target.HumanoidRootPart.Position
        angle = angle + SETTINGS.speed
        
        local orbitPos = targetPos + Vector3.new(
            math.cos(angle) * SETTINGS.radius,
            SETTINGS.height,
            math.sin(angle) * SETTINGS.radius
        )
        
        humanoidRootPart.CFrame = CFrame.new(orbitPos, targetPos) * 
                                CFrame.Angles(math.rad(-SETTINGS.lookAngle), 0, 0)
    end)
end

-- Основной цикл
local function main()
    local target = findEnemy()
    if not target then
        warn("Враги не найдены! Ожидание...")
        workspace.Living.ChildAdded:Wait()
        target = findEnemy()
    end

    local orbitConn = orbitTarget(target)
    
    -- Атака при появлении новых врагов
    local attackConn = workspace.Living.ChildAdded:Connect(function(child)
        for _, pattern in ipairs(ENEMY_PATTERNS) do
            if string.match(child.Name or "", pattern) then
                task.delay(SETTINGS.attackDelay, useAbility)
                break
            end
        end
    end)

    -- Периодическая атака текущей цели
    while true do
        useAbility()
        task.wait(1)  -- Интервал между атаками
    end
end

-- Автоперезапуск
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid").Died:Connect(function()
        TeleportService:Teleport(SETTINGS.respawnPlaceId, player)
    end)
    main()
end)

-- Запуск
main()
warn("Автофарм запущен! Абилка будет автоматически активироваться.")