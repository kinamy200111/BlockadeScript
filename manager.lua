-- manager.lua
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local MainHandler = ReplicatedStorage:WaitForChild("MainHandler")

local SETTINGS = {
    respawnPlaceId = 18845414266,  -- Была опечатка в "respawnPlaced"
    loadTime = 10,
    roomCode = "1683968",
    autofarmURL = "https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/autofarm.lua"
}

local function createLobby()
    for i = 1, 3 do
        pcall(function()
            MainHandler:FireServer("CreateRoom", "", SETTINGS.roomCode)
            task.wait(1)
            MainHandler:FireServer("Start", "")
            warn("Лобби создано успешно!")
            return true
        end)
        task.wait(2)
    end
    return false
end

local function init()
    local character = player.Character or player.CharacterAdded:Wait()
    
    character:WaitForChild("Humanoid").Died:Connect(function()
        TeleportService:Teleport(SETTINGS.respawnPlaceId, player)
        warn("Ожидание загрузки нового режима...")
        
        for i = SETTINGS.loadTime, 1, -1 do
            warn(i.."..")
            task.wait(1)
        end
        
        if createLobby() then
            warn("Загрузка автофарма...")
            loadstring(game:HttpGet(SETTINGS.autofarmURL))()
        end
    end)
end

-- Первый запуск
init()
loadstring(game:HttpGet(SETTINGS.autofarmURL))()
warn("Система автофарма активирована!")