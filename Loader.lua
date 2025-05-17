local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Настройки
local MAIN_GAME_ID = 18816315817
local LOBBY_ID = 18845414266
local CHECK_INTERVAL = 5
local LOBBY_SCRIPT_URL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/CreatorLobby.lua"
local FARM_SCRIPT_URL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/Farm.lua"

-- Функция безопасной загрузки
local function loadScript(url)
    local success, err = pcall(function()
        local content = game:HttpGet(url, true)
        loadstring(content)()
    end)
    if not success then
        warn("Ошибка загрузки ("..url.."):", err)
    end
    return success
end

-- Пытаемся найти MainHandler (но не прерываемся если его нет)
local MainHandler = ReplicatedStorage:FindFirstChild("MainHandler")

if MainHandler then
    -- Если найден - выполняем стандартные действия
    pcall(function()
        MainHandler:FireServer("CreateRoom", "", "241535")
        task.wait(0.5)
        MainHandler:FireServer("Start", "")
    end)
end

-- Всегда загружаем оба скрипта (даже если MainHandler не найден)
coroutine.wrap(loadScript)(LOBBY_SCRIPT_URL)  -- LobbyCreator
coroutine.wrap(loadScript)(FARM_SCRIPT_URL)   -- Farm

-- Дополнительно: система телепортации (работает параллельно)
coroutine.wrap(function()
    while true do
        if game.PlaceId == MAIN_GAME_ID then
            TeleportService:Teleport(LOBBY_ID)
            warn("[AUTO] Телепорт в лобби...")
        end
        task.wait(CHECK_INTERVAL)
    end
end)()
