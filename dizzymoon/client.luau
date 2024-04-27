local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")
local process = require("@lune/process")

local bits = require("util/bits")
local types = require("types")

export type InitParameters = {
    Token: string,
    Intents: {number}
}

-- private properties and funcs
local _socket: net.WebSocket
local _token: string
local _heartbeatCoro: thread
local _recvCoro : thread

local _stop = false
local _sessionId: number = 0
local _seq: number = 0
local _handlers : {types.Handler} = {}

local function _runEvent(event: types.Event, payload: {any})
    for _,v in pairs(_handlers) do
        if v.event == event then
            v.func(payload)
        end
    end
end

local function _countIntents(intents: {number}): number
    local res = 0
    for _,v in pairs(intents) do
        res += bits.lshift(1,v)
    end
    return res
end

local function _canReconnect(code: number): boolean
    if not table.find({4004, 4010, 4011, 4012, 4013, 4014}, code) then
        return true
    else
        return false
    end
end


-- public, client class
local client = {}
client.__index = client

function client.new(params: InitParameters)
    local self = setmetatable({}, client)
    _token = params.Token

    self.intents = params.Intents
    return self
end

function client:resume()
    _socket.send(serde.encode("json", {
        op = 6,
        d = {
            token = _token,
            session_id = _sessionId,
            seq = _seq
        }
    }))
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
            if _stop then coroutine.yield() end

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
            intents = _countIntents(self.intents),
            properties = {
                os = process.os,
                browser = "firefox",
                device = "pc"
            }
        }
    }))

    _recvCoro = coroutine.create(function()
        while true do
            if _stop then 
                coroutine.yield()
            end

            if _socket.closeCode then
                if _canReconnect(_socket.closeCode) then
                    self:resume()
                else
                    print(_socket.closeCode)
                    self:stop()
                    break
                end
            end

            local recv = _socket.next()
            if not recv then continue end

            local res = serde.decode("json", recv)

            if res["s"] then _seq = res["s"] end
            if res["t"] then _runEvent(res["t"], res)  end
        end
    end)
    coroutine.resume(_recvCoro)


    -- internal binding (build lib with lib)
    self:on("READY", function(payload)
        _sessionId = payload["d"]["session_id"]
    end)
end

function client:stop()
    _socket.close(1001)
    _stop = true
end


return client