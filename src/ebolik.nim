import std/[os, options, asyncdispatch, strutils]
import dimscord
import ./commands

let discord = newDiscordClient(getEnv("DISCORD_TOKEN"))

proc interactionCreate(s: Shard, i: Interaction) {.event(discord).} =
  let data = i.data.get
  case data.name:
  of "gta": gtaSlash(i, s, discord)
  of "demotivator": demotivatorSlash(i, s, discord)
  of "adm": await admSlash(i, s, discord)

proc onReady(s: Shard, r: Ready) {.event(discord).} =
  echo "Ready as: " & $r.user
  await s.updateStatus(activity = some ActivityStatus(
    name: "nim power 💪",
    kind: atPlaying
  ), status = "online")

  discard await discord.api.bulkOverwriteApplicationCommands(r.user.id, slashCommands)
  if getEnv("DEBUG_GUILD_ID") != "":
    discard await discord.api.bulkOverwriteApplicationCommands(r.user.id, slashCommands,
      guild_id = getEnv("DEBUG_GUILD_ID")
    )

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
  if m.kind == mtUserGuildBoost and getEnv("BOOST_CHANNEL_ID") != "":
    discard await discord.api.sendMessage(m.channel_id, "<@" & m.author.id & ">",
      files = @[
        DiscordFile(
          name: "thx.mp3",
          body: readFile("sounds/thx.mp3")
        )
      ]
    )

waitFor discord.startSession(
  gateway_intents = { giGuilds, giGuildMessages, giGuildMessageReactions },
  cache_users = false, guild_subscriptions = false,
  cache_guild_channels = false, cache_dm_channels = false,
  max_message_size = 0, large_message_threshold = 0
)