-- УНИВЕРСАЛЬНЫЙ АВТОЗАГРУЗЧИК (аналог Infinity Yield)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Конфигурация
local CONFIG = {
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua",
    LOBBY_ID = 18845414266,  -- ID лобби для телепорта
    LoadDelay = 3,  -- Задержка перед загрузкой (сек)
    RetryAttempts = 3  -- Количество попыток загрузки
}

-- Глобальный контроль
if not _G.AutoFarmSystem then
    _G.AutoFarmSystem = {
        Loaded = false,
        Attempts = 0
    }
end

-- Улучшенная загрузка с повторами
local function loadScript()
    if _G.AutoFarmSystem.Loaded then return end
    
    for attempt = 1, CONFIG.RetryAttempts do
        local success, err = pcall(function()
            loadstring(game:HttpGet(CONFIG.AutofarmURL, true))()
            _G.AutoFarmSystem.Loaded = true
            warn("✅ Автофарм загружен (Попытка "..attempt..")")
            return true
        end)
        
        if not success then
            warn("⚠️ Ошибка загрузки ("..attempt.."):", err)
            task.wait(2)  -- Задержка между попытками
        end
    end
    return false
end

-- Телепортация при смерти
local function setupDeathHandler()
    local character = Players.LocalPlayer.Character
    if character then
        character:WaitForChild("Humanoid").Died:Connect(function()
            TeleportService:Teleport(CONFIG.LOBBY_ID)
        end)
    end
end

-- Основной инициализатор
local function initialize()
    task.wait(CONFIG.LoadDelay)  -- Важная задержка!
    
    -- 1. Загружаем скрипт
    if not loadScript() then
        warn("❌ Критическая ошибка загрузки!")
        return
    end
    
    -- 2. Настраиваем обработчик смерти
    pcall(setupDeathHandler)
    
    -- 3. Контроль перезагрузки
    Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        setupDeathHandler()
    end)
end

-- Автозапуск системы
if not _G.AutoFarmSystem.Initialized then
    _G.AutoFarmSystem.Initialized = true
    initialize()
    
    -- Альтернативный запуск через 10 сек (на случай лагов)
    task.delay(10, function()
        if not _G.AutoFarmSystem.Loaded then
            warn("🔄 Альтернативная загрузка...")
            initialize()
        end
    end)
end

warn("🚀 Система автозагрузки активирована")
