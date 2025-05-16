local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SETTINGS = {
    RoomCode = "5325",  -- Ваш код лобби
    Delays = {
        AfterCreate = 0.5,  -- Задержка после создания лобби (0.5 сек)
        AfterStart = 15,    -- Задержка после старта игры (можно оставить)
        AfterVote = 5,      -- Задержка после голосования (если нужно)
        BeforeFarm = 8      -- Задержка перед загрузкой фарма (если нужно)
    },
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua"
}

-- Функция для вызова MainHandler
local function callMainHandler(command, ...)
    local args = {...}
    ReplicatedStorage.MainHandler:FireServer(table.unpack({
        {command, table.unpack(args)}
    }))
end

-- Создание лобби и запуск игры
local function setupGame()
    -- 1. Создаём лобби
    callMainHandler("CreateRoom", "", SETTINGS.RoomCode)
    warn("🔄 Лобби создано. Код: " .. SETTINGS.RoomCode)
    task.wait(SETTINGS.Delays.AfterCreate)

    -- 2. Запускаем игру
    callMainHandler("Start", "")
    warn("🚀 Игра начата!")
    task.wait(SETTINGS.Delays.AfterStart)

    -- 3. Активируем BossRush (если нужно)
    if ReplicatedStorage:FindFirstChild("Vote") then
        ReplicatedStorage.Vote:FireServer("BossRush")
        warn("🔥 BossRush активирован!")
        task.wait(SETTINGS.Delays.AfterVote)
    end

    -- 4. Подтверждаем готовность (если нужно)
    if ReplicatedStorage:FindFirstChild("GetReadyRemote") then
        ReplicatedStorage.GetReadyRemote:FireServer("1", true)
        warn("✅ Готовность подтверждена!")
    end

    -- 5. Загружаем автофарм (если нужно)
    if SETTINGS.AutofarmURL then
        task.wait(SETTINGS.Delays.BeforeFarm)
        loadstring(game:HttpGet(SETTINGS.AutofarmURL, true))()
        warn("🤖 Автофарм загружен!")
    end
end

-- Автозапуск при входе в игру
local function onPlayerAdded(player)
    if player.Character then
        setupGame()
    else
        player.CharacterAdded:Connect(function()
            task.wait(1)  -- Задержка для стабилизации
            setupGame()
        end)
    end
end

-- Подключаем обработчик
Players.PlayerAdded:Connect(onPlayerAdded)

-- Если игрок уже в игре (скрипт запущен позже)
if Players.LocalPlayer then
    onPlayerAdded(Players.LocalPlayer)
end
