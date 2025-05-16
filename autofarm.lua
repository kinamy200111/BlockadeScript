local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Настройки
local SETTINGS = {
    -- Орбита
    height = 115,
    radius = 15,
    speed = 0.05,
    lookAngle = 85,
    
    -- Атака
    attackDelay = 0.5,
    
    -- Авто-хил
    healThreshold = 300,  -- Порог HP для лечения
    healCooldown = 3,     -- Задержка между проверками
    
    -- Авто-покупка
    pulseCannonCost = 500,  -- Стоимость улучшения
    upgradeCheckDelay = 10, -- Задержка между проверками денег
    
    -- Система
    respawnPlaceId = 18845414266,
    abilityEventName = "TargetShoots"
}

-- Шаблоны врагов
local ENEMY_PATTERNS = {
    "Toilet%d*", "Fake Head%d*", "Giant Robber", 
    "Militant Toilet", "RocketToilet", "Triplets toilet",
    "G toilet", "flying buzzsaw toilet", "Infected Titan Speaker",
    "Malware", "Rocket bathtub toilet", "Flamethrower toilet",
    "Astro assilant toilet", "Astro Detainer", "Giant Magnet",
    "Vacuum Toilet", "Skull toilet"
}

-- Инициализация
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local abilityEvent = ReplicatedStorage:WaitForChild(SETTINGS.abilityEventName)
local shopEvent = ReplicatedStorage:WaitForChild("ShopSystem")
local skillsEvent = ReplicatedStorage:WaitForChild("SkillTrees")

-- Авто-хил
local function autoHeal()
    if character.Humanoid.Health < SETTINGS.healThreshold then
        shopEvent:FireServer("Buy", "FillHP")
        warn("Авто-хил активирован!")
    end
end

-- Авто-покупка улучшений
local function buyUpgrade()
    if player:FindFirstChild("Data") and player.Data:FindFirstChild("MoneysInShop") then
        if player.Data.MoneysInShop.Value >= SETTINGS.pulseCannonCost then
            skillsEvent:FireServer("Pulse Cannon")
            warn("Улучшение куплено!")
        end
    end
end

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

-- Орбитальное движение
local function orbitTarget(target)
    local angle = 0
    RunService.Heartbeat:Connect(function()
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
    while true do
        local target = findEnemy()
        if not target then
            warn("Ожидание появления врагов...")
            workspace.Living.ChildAdded:Wait()
            target = findEnemy()
        end

        orbitTarget(target)
        
        -- Параллельные процессы
        local attackLoop = task.spawn(function()
            while true do
                if not target or not target.Parent then break end
                abilityEvent:FireServer()
                task.wait(SETTINGS.attackDelay)
            end
        end)
        
        local healLoop = task.spawn(function()
            while true do
                autoHeal()
                task.wait(SETTINGS.healCooldown)
            end
        end)
        
        local upgradeLoop = task.spawn(function()
            while true do
                buyUpgrade()
                task.wait(SETTINGS.upgradeCheckDelay)
            end
        end)

        -- Ожидание потери цели
        repeat task.wait() until not target or not target.Parent
        task.cancel(attackLoop)
        task.cancel(healLoop)
        task.cancel(upgradeLoop)
        warn("Поиск новой цели...")
    end
end

-- Обработчик смерти
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid").Died:Connect(function()
        TeleportService:Teleport(SETTINGS.respawnPlaceId, player)
    end)
    task.wait(3) -- Задержка для стабилизации
    main()
end)

-- Первый запуск
main()
warn("Автофарм запущен! Системы:")
warn("- Орбитальное движение")
warn("- Авто-атака ("..SETTINGS.attackDelay.."s)")
warn("- Авто-хил (<"..SETTINGS.healThreshold.." HP)")
warn("- Авто-покупка (>="..SETTINGS.pulseCannonCost.." $)")
