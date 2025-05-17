local Event = game:GetService("ReplicatedStorage").MainHandler

-- Создание комнаты
Event:FireServer(table.unpack({
    "CreateRoom",
    "",
    "15452"
}))

task.wait(0.5)  -- Лучше использовать task.wait вместо wait

-- Запуск игры
Event:FireServer(table.unpack({
    "Start",
    ""
}))

-- Загрузка скрипта для фарма с обработкой ошибок
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/Farm.lua"))()
end)

if not success then
    warn("Ошибка загрузки Farm.lua: " .. tostring(err))
end
