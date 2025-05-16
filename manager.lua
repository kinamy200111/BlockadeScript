local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Настройки
local SETTINGS = {
    MAIN_GAME_ID = 18816546575,  -- ID основного игрового плейса
    LOBBY_ID = 18845414266,      -- ID лобби
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua"
}

-- Проверка текущего места
local function isInMainGame()
    return game.PlaceId == SETTINGS.MAIN_GAME_ID
end

local function isInLobby()
    return game.PlaceId == SETTINGS.LOBBY_ID
end

-- Загрузка автофарма (ТОЛЬКО в основном плейсе)
local function loadAutofarm()
    if not isInMainGame() then
        warn(isInLobby() and "🛑 В лобби автофарм отключен" or "⚠️ Неизвестный плейс: автофарм не запущен")
        return
    end

    loadstring(game:HttpGet(SETTINGS.AutofarmURL, true))()
    warn("✅ Автофарм запущен в основном плейсе")
    
    -- Телепортация в лобби при смерти
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
            TeleportService:Teleport(SETTINGS.LOBBY_ID)
        end)
    end)
end

-- Автозапуск
if isInMainGame() then
    loadAutofarm()
elseif isInLobby() then
    warn("🔁 Ожидание перехода в основной плейс...")
else
    warn("❓ Текущий плейс не распознан")
end
