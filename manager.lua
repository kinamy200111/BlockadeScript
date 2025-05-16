local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Настройки
local SETTINGS = {
    RoomCode = "5325",
    TargetPlaceId = 18845414266, -- ID лобби, куда телепортируемся
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua",
    Delays = {
        AfterCreate = 0.5,
        AfterStart = 15,
        AfterVote = 5,
        BeforeFarm = 8
    }
}

-- Генерируем уникальный ключ для сохранения данных
local DATA_KEY = "AutoFarm_"..Players.LocalPlayer.UserId

-- Функция для запуска игры и фарма
local function startAutofarm()
    -- Создаем лобби
    ReplicatedStorage.MainHandler:FireServer(table.unpack({{"CreateRoom", "", SETTINGS.RoomCode}}))
    warn("🔄 Лобби создано. Код: "..SETTINGS.RoomCode)
    task.wait(SETTINGS.Delays.AfterCreate)

    -- Запускаем игру
    ReplicatedStorage.MainHandler:FireServer(table.unpack({{"Start", ""}}))
    warn("🚀 Игра начата")
    task.wait(SETTINGS.Delays.AfterStart)

    -- Активируем BossRush (если есть)
    if ReplicatedStorage:FindFirstChild("Vote") then
        ReplicatedStorage.Vote:FireServer("BossRush")
        warn("🔥 BossRush активирован")
        task.wait(SETTINGS.Delays.AfterVote)
    end

    -- Загружаем фарм
    task.wait(SETTINGS.Delays.BeforeFarm)
    loadstring(game:HttpGet(SETTINGS.AutofarmURL, true))()
    warn("🤖 Автофарм загружен")
end

-- Функция для телепортации и сохранения данных
local function teleportToLobby()
    local teleportData = {
        autofarm = true,
        timestamp = os.time()
    }

    -- Сохраняем данные для следующего плейса
    TeleportService:SetTeleportSetting(DATA_KEY, HttpService:JSONEncode(teleportData))

    -- Телепортируемся
    TeleportService:Teleport(SETTINGS.TargetPlaceId, Players.LocalPlayer)
end

-- Проверяем сохраненные данные при входе в игру
local function checkSavedData()
    local success, savedData = pcall(function()
        return HttpService:JSONDecode(TeleportService:GetTeleportSetting(DATA_KEY) or "{}")
    end)

    if success and savedData.autofarm then
        -- Если данные есть, запускаем фарм
        task.wait(3) -- Даем время на загрузку
        startAutofarm()
    end
end

-- Обработчик смерти персонажа
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(teleportToLobby)
end

-- Инициализация
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end)

-- Проверяем данные при первом запуске
if Players.LocalPlayer then
    checkSavedData()
    if Players.LocalPlayer.Character then
        onCharacterAdded(Players.LocalPlayer.Character)
    end
end

warn("✅ Система автофарма готова к работе")
