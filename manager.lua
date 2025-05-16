-- manager.lua (исправленная версия)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
    RoomCode = "53267",
    Delays = {
        AfterCreate = 1,
        AfterStart = 15,
        AfterVote = 5,
        BeforeFarm = 8
    },
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua"
}

local function setupAutofarm()
    -- Создание лобби
    ReplicatedStorage.MainHandler:FireServer("CreateRoom", "", SETTINGS.RoomCode)
    warn("Лобби создано. Код: " .. SETTINGS.RoomCode)
    task.wait(SETTINGS.Delays.AfterCreate)

    -- Запуск игры
    ReplicatedStorage.MainHandler:FireServer("Start", "")
    warn("Игра начата")
    task.wait(SETTINGS.Delays.AfterStart)

    -- Активация BossRush
    ReplicatedStorage.Vote:FireServer("BossRush")
    warn("BossRush активирован")
    task.wait(SETTINGS.Delays.AfterVote)

    -- Подтверждение готовности
    ReplicatedStorage.GetReadyRemote:FireServer("1", true)
    warn("Готовность подтверждена")

    -- Загрузка фарма
    task.wait(SETTINGS.Delays.BeforeFarm)
    loadstring(game:HttpGet(SETTINGS.AutofarmURL, true))()
    warn("Автофарм загружается...")
end

-- Обработчик перезахода
local function onPlayerAdded(player)
    -- Ждем пока персонаж загрузится
    if player.Character then
        setupAutofarm()
    else
        player.CharacterAdded:Connect(function()
            task.wait(2) -- Небольшая задержка для стабилизации
            setupAutofarm()
        end)
    end
end

-- Подключение обработчиков
Players.PlayerAdded:Connect(onPlayerAdded)

-- Запуск для текущего игрока (если скрипт запущен после входа в игру)
if Players.LocalPlayer then
    onPlayerAdded(Players.LocalPlayer)
end
