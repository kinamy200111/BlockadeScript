local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Настройки
local SETTINGS = {
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua",
    LOBBY_ID = 18845414266, -- ID лобби
    MAIN_GAME_ID = 18816546575, -- ID основного плейса
    ForceLoadEverywhere = true -- Принудительная загрузка везде
}

-- Глобальный флаг для отслеживания загрузки
if not _G.AutoFarmManager then _G.AutoFarmManager = {Loaded = false} end

-- Улучшенная функция загрузки
local function loadAutofarm()
    if _G.AutoFarmManager.Loaded then return end
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(SETTINGS.AutofarmURL, true))()
        _G.AutoFarmManager.Loaded = true
        warn("✅ Автофарм загружен (Принудительный режим)")
    end)
    
    if not success then
        warn("❌ Ошибка загрузки:", err)
        task.wait(5)
        loadAutofarm() -- Повторная попытка через 5 сек
    end
end

-- Обработчик игрока
local function onPlayerAdded(player)
    -- Автозагрузка без проверки плейса
    if SETTINGS.ForceLoadEverywhere then
        loadAutofarm()
    else
        -- Стандартная логика (если ForceLoadEverywhere = false)
        if game.PlaceId == SETTINGS.MAIN_GAME_ID then
            loadAutofarm()
        end
    end

    -- Телепортация при смерти
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
            TeleportService:Teleport(SETTINGS.LOBBY_ID)
        end)
    end)
end

-- Инициализация
Players.PlayerAdded:Connect(onPlayerAdded)
if Players.LocalPlayer then
    onPlayerAdded(Players.LocalPlayer)
end

-- Автоперезагрузка при телепортации
TeleportService.LocalPlayerTeleporting:Connect(function()
    _G.AutoFarmManager.Loaded = false
    warn("🔄 Подготовка к перезагрузке в новом плейсе...")
end)

warn(string.format(
    "🚀 Менеджер автофарма запущен (Режим: %s)",
    SETTINGS.ForceLoadEverywhere and "ПРИНУДИТЕЛЬНЫЙ" or "СТАНДАРТНЫЙ"
))
