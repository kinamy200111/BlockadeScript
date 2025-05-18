--= Ultimate Autofarm Script v8.0 (Locked View) =--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")

-- Конфигурация
local CONFIG = {
    -- Настройки фарма
    FARM_HEIGHT = 50,
    FARM_RADIUS = 25,
    FARM_SPEED = 1.00,
    ATTACK_DELAY = 0.5,
    HEAL_TRESHOLD = 700,
    HEAL_COOLDOWN = 0.2,
    UPGRADE_COST = 500,
    UPGRADE_CHECK_DELAY = 10,
    
    -- Имена событий
    ABILITY_EVENT = "TargetShoots",
    READY_EVENT = "GetReadyRemote",
    
    -- Remote Events
    REMOTE_EVENTS = {
        "LaserEyeTri",
        "LMB",
        "FlingTriSoilder",
        "SoundWaveTriSoilder",
        "TVTriSoilder"
    },
    REMOTE_DELAY = 1,
    
    -- Авто-действия
    AUTO_VOTE_MODE = "BossRush",
    AUTO_VOTE_DELAY = 5,
    AUTO_READY_DELAY = 8,
    
    -- Anti-AFK
    ANTI_AFK_INTERVAL = 30
}

-- Состояние системы
local STATE = {
    Active = true,
    Processes = {},
    CurrentTarget = nil
}

-- Инициализация игрока
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local abilityEvent = ReplicatedStorage:WaitForChild(CONFIG.ABILITY_EVENT)

-- Система Remote Events
local function setupRemotes()
    while STATE.Active do
        for _, eventName in ipairs(CONFIG.REMOTE_EVENTS) do
            local event = ReplicatedStorage:FindFirstChild(eventName)
            if event then
                event:FireServer()
            end
            task.wait(0.1)
        end
        task.wait(CONFIG.REMOTE_DELAY)
    end
end

-- Anti-AFK система
local function antiAFK()
    while STATE.Active do
        VirtualInput:SendMouseMoveEvent(math.random(50,500), math.random(50,500), workspace)
        task.wait(CONFIG.ANTI_AFK_INTERVAL)
    end
end

-- Авто-голосование
local function autoVote()
    local voteEvent = ReplicatedStorage:FindFirstChild("Vote") or ReplicatedStorage:FindFirstChild("VoteRemote")
    if voteEvent then
        task.wait(CONFIG.AUTO_VOTE_DELAY)
        voteEvent:FireServer(CONFIG.AUTO_VOTE_MODE)
        warn("[VOTE] Проголосовано за: "..CONFIG.AUTO_VOTE_MODE)
    end
end

-- Авто-реди
local function autoReady()
    local readyEvent = ReplicatedStorage:FindFirstChild(CONFIG.READY_EVENT)
    if readyEvent then
        task.wait(CONFIG.AUTO_READY_DELAY)
        readyEvent:FireServer("1", true)
        warn("[READY] Статус готовности отправлен")
    end
end

-- Поиск врагов
local function findTarget()
    local living = workspace:FindFirstChild("Living")
    if not living then return nil end
    
    local enemyPatterns = {
        "Toilet%d*", "Fake Head%d*", "Giant Robber", 
        "Militant Toilet", "RocketToilet", "Triplets toilet",
        "G toilet", "flying buzzsaw toilet", "Infected Titan Speaker",
        "Malware", "Rocket bathtub toilet", "Flamethrower toilet",
        "Astro assilant toilet", "Astro Detainer", "Giant Magnet",
        "Vacuum Toilet", "Skull toilet", "Ginger Toilet"
    }
    
    for _, enemy in ipairs(living:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
            for _, pattern in ipairs(enemyPatterns) do
                if string.match(enemy.Name, pattern) then
                    return enemy
                end
            end
        end
    end
    return nil
end

-- Орбитальное движение с фиксированным взглядом на врага
local function orbit(target)
    local angle = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        if not STATE.Active or not target or not target.Parent then
            connection:Disconnect()
            return
        end
        
        angle = angle + CONFIG.FARM_SPEED
        local targetPos = target.HumanoidRootPart.Position
        local orbitPos = targetPos + Vector3.new(
            math.cos(angle) * CONFIG.FARM_RADIUS,
            CONFIG.FARM_HEIGHT,
            math.sin(angle) * CONFIG.FARM_RADIUS
        )
        
        -- Фиксированный взгляд прямо на врага
        rootPart.CFrame = CFrame.new(orbitPos, targetPos)
    end)
    
    return connection
end

-- Автоатака
local function autoAttack(target)
    while STATE.Active and target and target.Parent do
        abilityEvent:FireServer()
        task.wait(CONFIG.ATTACK_DELAY)
    end
end

-- Автохил
local function autoHeal()
    local shopEvent = ReplicatedStorage:FindFirstChild("ShopSystem") or ReplicatedStorage:FindFirstChild("ShopRemote")
    if not shopEvent then return end
    
    while STATE.Active do
        if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health < CONFIG.HEAL_TRESHOLD then
            shopEvent:FireServer("Buy", "FillHP")
            warn("[HEAL] Использовано лечение")
        end
        task.wait(CONFIG.HEAL_COOLDOWN)
    end
end

-- Автопокупка улучшений
local function autoUpgrade()
    local skillsEvent = ReplicatedStorage:FindFirstChild("SkillTrees") or ReplicatedStorage:FindFirstChild("UpgradesRemote")
    if not skillsEvent then return end
    
    while STATE.Active do
        if player:FindFirstChild("Data") and player.Data:FindFirstChild("MoneysInShop") then
            if player.Data.MoneysInShop.Value >= CONFIG.UPGRADE_COST then
                skillsEvent:FireServer("Pulse Cannon")
                warn("[UPGRADE] Куплено улучшение")
                task.wait(10)
            end
        end
        task.wait(CONFIG.UPGRADE_CHECK_DELAY)
    end
end

-- Основной цикл фарма
local function farmLoop()
    while STATE.Active do
        local target = findTarget()
        if not target then
            warn("[SEARCH] Поиск врагов...")
            task.wait(1)
        else
            local orbitConn = orbit(target)
            local attackProcess = task.spawn(autoAttack, target)
            
            repeat task.wait(1) until not STATE.Active or not target or not target.Parent
            
            orbitConn:Disconnect()
            task.cancel(attackProcess)
        end
    end
end

-- Обработчик персонажа
local function onCharacterAdded(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    task.wait(3)
    if STATE.Active then farmLoop() end
end

-- Инициализация
local function initialize()
    -- Запуск системных процессов
    table.insert(STATE.Processes, task.spawn(antiAFK))
    table.insert(STATE.Processes, task.spawn(autoHeal))
    table.insert(STATE.Processes, task.spawn(autoUpgrade))
    table.insert(STATE.Processes, task.spawn(autoVote))
    table.insert(STATE.Processes, task.spawn(autoReady))
    table.insert(STATE.Processes, task.spawn(setupRemotes))
    
    -- Подписка на события
    player.CharacterAdded:Connect(onCharacterAdded)
    
    -- Запуск фарма если персонаж уже есть
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    warn("[SYSTEM] Автофарм с фиксированным взглядом активирован!")
end

-- Запуск системы
initialize()

-- Функция остановки
function _G.StopFarm()
    STATE.Active = false
    for _, process in ipairs(STATE.Processes) do
        task.cancel(process)
    end
    warn("[SYSTEM] Автофарм остановлен")
end
