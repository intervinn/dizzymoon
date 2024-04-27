local task = require("@lune/task")
local dz = require("dizzymoon")

local bot = dz.client.new({
    Token = "MTA2NTM0MjMxNTc2NzUzMzY2MA.GwbNDE.mSXbdTMxGHkFOs7hyvaSV0yDkKArlGpcwNXSNk",
    Intents = {
        dz.intents.GUILDS,
        dz.intents.GUILD_MESSAGES
    }
})

bot:on("READY", function(payload)
    print("bot is ready")
end)

bot:on("MESSAGE_CREATE", function(payload)
    print(payload)
end)

task.delay(5, function()
    bot:stop()
end)

bot:start()