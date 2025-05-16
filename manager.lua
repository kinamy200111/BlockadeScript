local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local SETTINGS = {
    RoomCode = "5325",
    TargetPlaceId = 18845414266, -- ID лобби, куда телепортируемся
    Delays = {
        AfterCreate = 0.5,
        AfterStart = 15,
        AfterVote = 5,
        BeforeFarm = 8
    },
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua"
}

-- Ключ для сохранения в Datastore
local DATASTORE_KEY = "AutoFarmEnabled_"..tostring(Players.LocalPlayer.UserId)

-- Проверяем, нужно ли запускать автофарм
local function shouldRunAutofarm()
    -- Можно добавить дополнительные проверки здесь
    return true
end

-- Основная функция настройки игры
local function setupGame()
    -- 1. Создаем лобби
    ReplicatedStorage.MainHandler:FireServer(table.unpack({{"CreateRoom", "", SETTINGS.RoomCode}}))
    warn("Лобби создано. Код: "..SETTINGS.RoomCode)
    task.wait(SETTINGS.Delays.AfterCreate)

    -- 2. Запускаем игру
    ReplicatedStorage.MainHandler:FireServer(table.unpack({{"Start", ""}}))
    warn("Игра начата")
    task.wait(SETTINGS.Delays.AfterStart)

    -- 3. Активируем BossRush
    if ReplicatedStorage:FindFirstChild("Vote") then
        ReplicatedStorage.Vote:FireServer("BossRush")
        warn("BossRush активирован")
        task.wait(SETTINGS.Delays.AfterVote)
    end

    -- 4. Загружаем автофарм
    if shouldRunAutofarm() then
        task.wait(SETTINGS.Delays.BeforeFarm)
        loadstring(game:HttpGet(SETTINGS.AutofarmURL, true))()
        warn("Автофарм загружен")
    end
end

-- Обработчик телепортации
local function onTeleport()
    -- Сохраняем данные для следующего плейса
    local teleportData = {
        autofarm = true,
        roomCode = SETTINGS.RoomCode
    }
    
    TeleportService:SetTeleportSetting(DATASTORE_KEY, teleportData)
    
    -- Телепортируемся в целевой плейс
    TeleportService:Teleport(SETTINGS.TargetPlaceId, Players.LocalPlayer)
end

-- Обработчик входа в игру
local function onPlayerAdded(player)
    -- Проверяем, были ли сохранены данные
    local success, teleportData = pcall(function()
        return TeleportService:GetTeleportSetting(DATASTORE_KEY)
    end)
    
    if success and teleportData and teleportData.autofarm then
        -- Если данные есть, запускаем автофарм
        task.wait(3) -- Даем время на загрузку
        setupGame()
    end
    
    -- Обработчик смерти персонажа
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(onTeleport)
    end)
end

-- Инициализация
Players.PlayerAdded:Connect(onPlayerAdded)
if Players.LocalPlayer then
    onPlayerAdded(Players.LocalPlayer)
end

warn("Система автофарма инициализирована")
