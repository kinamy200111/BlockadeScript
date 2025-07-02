--= Ultimate Autofarm Script v8.3 (Wave Detection Edition) =--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")

-- Конфигурация
local CONFIG = {
    -- Настройки фарма
    FARM_HEIGHT = 1,
    FARM_RADIUS = 23,
    FARM_SPEED = 0.09,
    ATTACK_DELAY = 0.1,
    HEAL_THRESHOLD = 700,
    HEAL_COOLDOWN = 0.2,
    UPGRADE_COST = 500,
    UPGRADE_CHECK_DELAY = 10,
    TARGET_SWITCH_DELAY = 3,
    
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
    AUTO_VOTE_MODE = "Christmas",
    SPECIAL_WAVE_MODE = "18816315817", -- Режим для 6 волны
    AUTO_VOTE_DELAY = 5,
    AUTO_READY_DELAY = 8,
    
    -- Anti-AFK
    ANTI_AFK_INTERVAL = 30,
    
    -- Список врагов
    ENEMY_PATTERNS = {
        "Armored Snow Toilet",
        "Rocket Helicopter",
        "Snow Solider Rocket Toilet",
        "SnowToilet%[?BigV?%d?%]?",
        "SnowToilet%[?NormalV?%d?%]?",
        "Transmitter toilet",
        "Shooter Snow Toilet",
        "Speaker Snow Toilet",
        "Vacuum Toilet",
        "Toilet%d*",
        "RocketToilet",
        "G toilet",
        "flying buzzsaw toilet",
        "Flamethrower toilet",
        "Vacuum Toilet",
        "Skull toilet",
        "Ginger Toilet"
    }
}

-- Состояние системы
local STATE = {
    Active = true,
    Processes = {},
    CurrentTarget = nil,
    TargetsQueue = {},
    LastHealTime = 0,
    CurrentWave = 0,
    SpecialWaveActive = false
}

-- Инициализация игрока
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local abilityEvent = ReplicatedStorage:WaitForChild(CONFIG.ABILITY_EVENT)

-- Мониторинг волны
local function monitorWave()
    while STATE.Active do
        local wave = workspace:FindFirstChild("Wave")
        if wave and wave:IsA("IntValue") then
            STATE.CurrentWave = wave.Value
            
            -- Проверка на 6 волну
            if wave.Value == 6 and not STATE.SpecialWaveActive then
                STATE.SpecialWaveActive = true
                local voteEvent = ReplicatedStorage:FindFirstChild("Vote") or ReplicatedStorage:FindFirstChild("VoteRemote")
                if voteEvent then
                    voteEvent:FireServer(CONFIG.SPECIAL_WAVE_MODE)
                    warn("[SPECIAL WAVE] Активирован режим: "..CONFIG.SPECIAL_WAVE_MODE)
                end
            elseif wave.Value ~= 6 and STATE.SpecialWaveActive then
                STATE.SpecialWaveActive = false
            end
        end
        task.wait(1)
    end
end

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
        if not STATE.SpecialWaveActive then -- Не голосуем если активна специальная волна
            voteEvent:FireServer(CONFIG.AUTO_VOTE_MODE)
            warn("[VOTE] Проголосовано за: "..CONFIG.AUTO_VOTE_MODE)
        end
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

-- Поиск врагов и обновление очереди
local function updateTargetsQueue()
    while STATE.Active do
        local living = workspace:FindFirstChild("Living")
        if living then
            local newTargets = {}
            
            for _, enemy in ipairs(living:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                    for _, pattern in ipairs(CONFIG.ENEMY_PATTERNS) do
                        if string.match(enemy.Name, pattern) then
                            table.insert(newTargets, enemy)
                            break
                        end
                    end
                end
            end
            
            STATE.TargetsQueue = newTargets
            if #newTargets > 0 then
                warn("[TARGETS] Найдено врагов: "..#newTargets)
            end
        end
        task.wait(1)
    end
end

-- Орбитальное движение
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
        
        rootPart.CFrame = CFrame.new(orbitPos, targetPos)
    end)
    
    return connection
end

-- Автоатака с очередью целей
local function autoAttack()
    while STATE.Active do
        if #STATE.TargetsQueue > 0 then
            local target = STATE.TargetsQueue[1]
            
            if target and target.Parent then
                local orbitConn = orbit(target)
                local startTime = tick()
                
                while STATE.Active and target and target.Parent and 
                      (tick() - startTime) < CONFIG.TARGET_SWITCH_DELAY do
                    abilityEvent:FireServer()
                    task.wait(CONFIG.ATTACK_DELAY)
                end
                
                orbitConn:Disconnect()
                
                -- Перемещаем цель в конец очереди
                table.remove(STATE.TargetsQueue, 1)
                table.insert(STATE.TargetsQueue, target)
            else
                table.remove(STATE.TargetsQueue, 1)
            end
        else
            task.wait(1)
        end
    end
end

-- Автохил
local function autoHeal()
    local shopEvent = ReplicatedStorage:FindFirstChild("ShopSystem") or ReplicatedStorage:FindFirstChild("ShopRemote")
    if not shopEvent then return end
    
    while STATE.Active do
        if humanoid and humanoid.Health < CONFIG.HEAL_THRESHOLD and 
           (tick() - STATE.LastHealTime) > CONFIG.HEAL_COOLDOWN then
            shopEvent:FireServer("Buy", "FillHP")
            STATE.LastHealTime = tick()
            warn("[HEAL] Использовано лечение")
        end
        task.wait(1)
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
        if #STATE.TargetsQueue > 0 then
            autoAttack()
        else
            warn("[SEARCH] Поиск врагов...")
            task.wait(1)
        end
    end
end

-- Обработчик персонажа
local function onCharacterAdded(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
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
    table.insert(STATE.Processes, task.spawn(updateTargetsQueue))
    table.insert(STATE.Processes, task.spawn(monitorWave)) -- Добавлен мониторинг волн
    
    -- Подписка на события
    player.CharacterAdded:Connect(onCharacterAdded)
    
    -- Запуск фарма если персонаж уже есть
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    -- Запуск основного цикла
    task.spawn(farmLoop)
    
    warn("[SYSTEM] Автофарм активирован!")
    warn("[TARGETS] Режим голосования: "..CONFIG.AUTO_VOTE_MODE)
    warn("[WAVE] Мониторинг волн активирован")
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
