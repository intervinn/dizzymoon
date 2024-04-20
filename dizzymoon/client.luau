local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

local _socket: net.WebSocket
local _token: string
local _heartbeatCoro: thread
local _recvCoro : thread

local client = {}
client.__index = client

export type InitParameters = {
    Token: string,
    Intents: number
}

function client.new(params: InitParameters)
    local self = setmetatable({}, client)
    _token = params.Token

    self.s = 0

    return self
end

function client:start()
    -- begin, get hello response
    _socket = net.socket("wss://gateway.discord.gg/?v=10")
    local hello = _socket.next()
    if not hello then error("couldnt start bot") end

    hello = serde.decode("json", hello)
    self.s = hello["s"]
    self.heartbeat_interval = hello["d"]["heartbeat_interval"] / 1000


    -- start the heartbeat loop
    _heartbeatCoro = coroutine.create(function()
        while true do
            _socket.send(serde.encode("json", {
                op = 1,
                d = self.s
            }))
            task.wait(self.heartbeat_interval)
        end
    end)
    coroutine.resume(_heartbeatCoro)

    -- identity
    _socket.send(serde.encode("json", {
        op = 2,
        d = {
            token = _token,
            intents = 513,
            properties = {
                os = process.os,
                browser = "",
                device = ""
            }
        }
    }))

    _recvCoro = coroutine.create(function()
        while true do
            if _socket.closeCode then break end
            local response = _socket.next()
            print(response)
        end
    end)
    coroutine.resume(_recvCoro)
end

function client:stop()
    coroutine.close(_heartbeatCoro)
    coroutine.close(_recvCoro)
end

return client