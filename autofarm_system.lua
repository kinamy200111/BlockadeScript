local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Настройки
local SETTINGS = {
    -- Лобби
    RoomCode = "1683968",
    MainHandlerName = "MainHandler",
    
    -- Автофарм
    AttackEventName = "TargetShoots",
    OrbitHeight = 100,
    OrbitRadius = 12,
    
    -- Система
    RespawnPlaceID = 18845414266,
    LoadTime = 10, -- 10 сек на загрузку
    ScriptURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm_system.lua" -- Самоперезагрузка
}

-- Логирование
local function log(message)
    warn("[AUTOFARM] " .. message)
end

-- 1. Функция создания лобби
local function createLobby()
    local MainHandler = ReplicatedStorage:WaitForChild(SETTINGS.MainHandlerName)
    
    -- Создание комнаты
    MainHandler:FireServer("CreateRoom", "", SETTINGS.RoomCode)
    log("Лобби создано. Код: " .. SETTINGS.RoomCode)
    task.wait(1)
    
    -- Старт игры
    MainHandler:FireServer("Start", "")
    log("Игра начата")
end

-- 2. Основной автофарм
local function startAutoFarm()
    local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local attackEvent = ReplicatedStorage:WaitForChild(SETTINGS.AttackEventName)

    -- Поиск цели
    local function findTarget()
        for _, enemy in ipairs(workspace.Living:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") then
                return enemy
            end
        end
    end

    -- Орбитальное движение
    local function orbit(target)
        local angle = 0
        RunService.Heartbeat:Connect(function()
            local pos = target.HumanoidRootPart.Position
            angle += 0.05
            
            humanoidRootPart.CFrame = CFrame.new(
                pos + Vector3.new(
                    math.cos(angle) * SETTINGS.OrbitRadius,
                    SETTINGS.OrbitHeight,
                    math.sin(angle) * SETTINGS.OrbitRadius
                ),
                pos
            )
        end)
    end

    -- Запуск
    local target = findTarget()
    if target then
        orbit(target)
        while task.wait(0.5) do
            attackEvent:FireServer()
        end
    end
end

-- 3. Обработчик смерти и перезапуска
local function setupDeathHandler()
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
            TeleportService:Teleport(SETTINGS.RespawnPlaceID)
            task.wait(SETTINGS.LoadTime)
            loadstring(game:HttpGet(SETTINGS.ScriptURL))()
        end)
    end)
end

-- Главная функция
local function main()
    createLobby()       -- Сначала создаем лобби
    task.wait(3)        -- Ждем загрузку
    setupDeathHandler() -- Настраиваем перезапуск
    startAutoFarm()     -- Запускаем фарм
end

-- Запуск системы
main()
log("Система активирована")