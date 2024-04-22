local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")
local process = require("@lune/process")

local types = require("types")

-- private properties and funcs
local _socket: net.WebSocket
local _token: string
local _heartbeatCoro: thread
local _recvCoro : thread

local _seq: number = 0
local _handlers : {types.Handler} = {}

local function _runEvent(event: types.Event)
    for _,v in pairs(_handlers) do
        if v.event == event then
            v.func()
            return
        end
    end
end


-- public, client class
local client = {}
client.__index = client

export type InitParameters = {
    Token: string,
    Intents: number
}

function client.new(params: InitParameters)
    local self = setmetatable({}, client)
    _token = params.Token
    return self
end

function client:on(event: types.Event, func: types.HandlerFunc)
    table.insert(_handlers, {event = event, func = func})
end

function client:start()
    -- begin, get hello response
    _socket = net.socket("wss://gateway.discord.gg/?v=10&encoding=json")
    local hello = _socket.next()

    hello = serde.decode("json", hello)
    _seq = hello["s"]
    self.heartbeat_interval = hello["d"]["heartbeat_interval"] / 1000

    _heartbeatCoro = coroutine.create(function()
        while true do
            _socket.send(serde.encode("json", {
                op = 1,
                d = _seq or 0
            }))
            task.wait(self.heartbeat_interval)
        end
    end)
    coroutine.resume(_heartbeatCoro)

    _socket.send(serde.encode("json", {
        op = 2,
        d = {
            token = _token,
            intents = 513,
            properties = {
                os = process.os,
                browser = "firefox",
                device = "pc"
            }
        }
    }))

    _recvCoro = coroutine.create(function()
        while true do
            if _socket.closeCode then
                print("status",_socket.closeCode)
                self:stop()
            end

            local recv = _socket.next()
            if not recv then continue end

            local res = serde.decode("json", recv)

            if res["s"] then _seq = res["s"] end
            if res["t"] then _runEvent(res["t"])  end
        end
    end)
    coroutine.resume(_recvCoro)
end


return client