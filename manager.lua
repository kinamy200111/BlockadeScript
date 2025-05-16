local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- Конфигурация
local CONFIG = {
    AutofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua",
    LOBBY_ID = 18845414266,
    AntiAFK = {
        Enabled = true,          -- Включить защиту от AFK
        MoveMouse = true,        -- Двигать курсор
        PressKeys = true,        -- Нажимать случайные клавиши
        Interval = 30            -- Интервал действий (сек)
    }
}

-- Глобальный контроль
if not _G.AutoFarmSystem then
    _G.AutoFarmSystem = {
        Loaded = false,
        AntiAFKActive = false
    }
end

-- ===== ANTI-AFK SYSTEM =====
local function setupAntiAFK()
    if not CONFIG.AntiAFK.Enabled or _G.AutoFarmSystem.AntiAFKActive then return end
    
    _G.AutoFarmSystem.AntiAFKActive = true
    
    -- Движение курсора
    local function moveMouse()
        if not CONFIG.AntiAFK.MoveMouse then return end
        local x = math.random(100, 500)
        local y = math.random(100, 500)
        VirtualInputManager:SendMouseMoveEvent(x, y, game:GetService("Workspace"))
    end

    -- Имитация нажатия клавиш
    local function pressKeys()
        if not CONFIG.AntiAFK.PressKeys then return end
        local keys = {"W", "A", "S", "D", "Space"}
        VirtualInputManager:SendKeyEvent(true, keys[math.random(1, #keys)], false, nil)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, keys[math.random(1, #keys)], false, nil)
    end

    -- Основной цикл
    while _G.AutoFarmSystem.AntiAFKActive do
        moveMouse()
        pressKeys()
        task.wait(CONFIG.AntiAFK.Interval)
    end
end

-- ===== MAIN SYSTEM =====
local function loadScript()
    if _G.AutoFarmSystem.Loaded then return true end
    
    local success = pcall(function()
        loadstring(game:HttpGet(CONFIG.AutofarmURL, true))()
        _G.AutoFarmSystem.Loaded = true
        
        -- Инжект в CoreGui для надежности
        if not CoreGui:FindFirstChild("AutoFarmInjected") then
            local marker = Instance.new("Folder")
            marker.Name = "AutoFarmInjected"
            marker.Parent = CoreGui
        end
    end)
    
    return success
end

local function initialize()
    -- Загрузка скрипта
    if not loadScript() then
        warn("⚠️ Первая загрузка не удалась, повтор через 5 сек...")
        task.wait(5)
        loadScript()
    end

    -- Активация Anti-AFK
    if CONFIG.AntiAFK.Enabled then
        task.spawn(setupAntiAFK)
    end

    -- Телепортация при смерти
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
            TeleportService:Teleport(CONFIG.LOBBY_ID)
        end)
    end)
end

-- ===== AUTOSTART =====
if not _G.AutoFarmSystem.Initialized then
    _G.AutoFarmSystem.Initialized = true
    
    -- Основная инициализация
    task.spawn(initialize)
    
    -- Резервная загрузка через 15 сек
    task.delay(15, function()
        if not _G.AutoFarmSystem.Loaded then
            warn("🔄 Резервная инициализация...")
            initialize()
        end
    end)
end

warn("🚀 Система запущена | Anti-AFK: "..(CONFIG.AntiAFK.Enabled and "ON" or "OFF"))
