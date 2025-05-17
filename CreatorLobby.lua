local Event = game:GetService("ReplicatedStorage").MainHandler
Event:FireServer(table.unpack({
    {
        "CreateRoom",
        "",
        "15452"
    }
}))
wait(0.5)
local Event = game:GetService("ReplicatedStorage").MainHandler
Event:FireServer(table.unpack({
    {
        "Start",
        "",
    }
}))
loadstring(game:HttpGet("https://raw.githubusercontent.com/kinamy200111/BlockadeScript/main/Farm.lua"))()