local TeleportService = game:GetService("TeleportService")

-- Настройки
local MAIN_GAME_ID = 18816315817  -- ID основного режима
local LOBBY_ID = 18845414266      -- ID лобби
local CHECK_INTERVAL = 5          -- Проверка каждые 5 секунд

-- Функция телепорта
local function teleportToLobby()
    TeleportService:Teleport(LOBBY_ID)
    warn("[TELEPORT] Инициирован телепорт в лобби")
end

-- Основной цикл проверки
while true do
    if game.PlaceId == MAIN_GAME_ID then
        warn("[DETECTED] Находимся в основном режиме")
        teleportToLobby()
    end
    task.wait(CHECK_INTERVAL)
end