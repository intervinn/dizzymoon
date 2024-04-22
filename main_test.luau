
local client = require("dizzymoon/client")

local bot = client.new({
    Token = "MTA2NTM0MjMxNTc2NzUzMzY2MA.GwbNDE.mSXbdTMxGHkFOs7hyvaSV0yDkKArlGpcwNXSNk",
    Intents = 513
})

bot:on("READY", function()
    print("bot is ready")
end)

bot:on("MESSAGE_CREATE", function()
    print("new message")
end)

bot:start()

