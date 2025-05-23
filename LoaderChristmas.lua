local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Настройки
local MAIN_GAME_ID = 18816315817
local LOBBY_ID = 18845414266
local CHECK_INTERVAL = 5
local LOBBY_SCRIPT_URL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/CreatorLobbyChristmas.lua"
local FARM_SCRIPT_URL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/FarmChristmas.lua"
local LOAD_DELAY = 5 -- 5 секунд задержки

-- Принудительная задержка загрузки
do
    warn(string.format("[LOADER] Начало загрузки (ожидание %ds)...", LOAD_DELAY))
    local startTime = os.clock()
    
    -- Счетчик обратного отсчета
    while os.clock() - startTime < LOAD_DELAY do
        local remaining = LOAD_DELAY - (os.clock() - startTime)
        warn(string.format("[LOADER] Осталось %.1fs", remaining))
        task.wait(1)
    end
    
    warn("[LOADER] Загрузка скриптов...")
end

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

warn("[LOADER] Все компоненты успешно запущены!")
