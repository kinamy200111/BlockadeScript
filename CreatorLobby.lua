local Event = game:GetService("ReplicatedStorage").MainHandler
Event:FireServer(table.unpack({
    {
        "CreateRoom",
        "",
        "241535"
    }
}))
task.wait(0.5)
local Event = game:GetService("ReplicatedStorage").MainHandler
Event:FireServer(table.unpack({
    {
        "Start",
        "",
    }
}))
