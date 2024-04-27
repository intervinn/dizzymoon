local constants = {
    OpCode = {
        DISPATCH = 0,
        HEARTBEAT = 1,
        IDENTITY = 2,
        PRESENCE_UPDATE = 3,
        VOICE_STATE_UPDATE = 4,
        RESUME = 6,
        RECONNECT = 7,
        REQUEST_GUILD_MEMBERS = 8,
        INVALID_SESSION = 9,
        HELLO = 10,
        HEARTBEAT_ACK = 11
    },
    Intents = {
        GUILDS = 0,
        GUILD_MEMBERS = 1,
        GUILD_MODERATION = 2,
        GUILD_EMOJIS_AND_STICKERS = 3,
        GUILD_INTEGRATIONS = 4,
        GUILD_WEBHOOKS = 5,
        GUILD_INVITES = 6,
        GUILD_VOICE_STATES = 7,
        GUILD_PRESENCES = 8,
        GUILD_MESSAGES = 9,
        GUILD_MESSAGES_REACTIONS = 10,
        GUILD_MESSAGE_TYPING = 11,
        DIRECT_MESSAGES = 12,
        DIRECT_MESSAGE_REACTIONS = 13,
        DIRECT_MESSAGE_TYPING = 14,
        MESSAGE_CONTENT = 15,
        GUILD_SCHEDULED_EVENTS = 16,
        AUTO_MODERATION_CONFIGURATION = 20,
        AUTO_MODERATION_EXECUTION = 21,
        GUILD_MESSAGE_POLLS = 24,
        DIRECT_MESSAGE_POLLS = 25
    }
}

return constants