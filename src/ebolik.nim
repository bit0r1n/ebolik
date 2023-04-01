import std/[
  os, options, asyncdispatch,
  tables, sequtils, strutils
]
import dimscord
import ./commands

type
  RoleReactionEntity = object
    emoji: Emoji
    language, description, roleId: string

let
  discord = newDiscordClient(getEnv("DISCORD_TOKEN"))
  languageChannelId = getEnv("LANGUAGE_CHANNEL")
  languageRoles = {
    "🇺🇸": RoleReactionEntity(
      emoji: Emoji(name: some "🇺🇸"),
      language: "English",
      description: "React to get access to english channels",
      roleId: "1013007272676438026"
    ),
    "🇷🇺": RoleReactionEntity(
      emoji: Emoji(name: some "🇷🇺"),
      language: "Русский",
      description: "Поставь реакцию для получения доступа к каналам на русском языке",
      roleId: "1013007155651162152"
    )
  }.toTable

proc messageReactionAdd(s: Shard, m: Message, u: User, e: Emoji, exists: bool) {.async event(discord).} =
  if m.channel_id != languageChannelId: return
  if u.id == discord.shards[0].user.id: return
  if e.name.get notin languageRoles: return

  await discord.api.addGuildMemberRole(
    m.guild_id.get(), u.id, languageRoles[e.name.get].roleId,
    "language selected"
  )

proc messageReactionRemove(s: Shard, m: Message, u: User, r: Reaction, exists: bool) {.async event(discord).} =
  if m.channel_id != languageChannelId: return
  if u.id == discord.shards[0].user.id: return
  if $r.emoji notin languageRoles: return

  await discord.api.removeGuildMemberRole(
    m.guild_id.get(), u.id, languageRoles[$r.emoji].roleId,
    "language deselected"
  )

proc createReactionsMessage(): Future[Message] {.async.} =
  result = await discord.api.sendMessage(
    languageChannelId,
    embeds = @[
      Embed(
        color: some 0x6d42be,
        description: some toSeq(languageRoles.values)
          .map(
            proc(x: RoleReactionEntity): string = $x.emoji & " " & x.description
          ).join("\n")
      )
    ]
  )

proc recheckReactions(msg: Message) {.async.} =
  for e in languageRoles.values:
    if $e.emoji notin msg.reactions:
      await discord.api.addMessageReaction(msg.channel_id, msg.id, $e.emoji)

proc initLanguageReactions() {.async.} =
  var languageMessage: Message

  let messages = await discord.api.getChannelMessages(languageChannelId)
  if messages.len != 0: languageMessage = messages[^1]
  else: languageMessage = await createReactionsMessage()

  await recheckReactions(languageMessage)

  discord.events.message_delete = proc(s: Shard, m: Message, exists: bool) {.async.} =
    if m.id != languageMessage.id: return
    languageMessage = await createReactionsMessage()
    await recheckReactions(languageMessage)


proc interactionCreate(s: Shard, i: Interaction) {.async event(discord).} =
  let data = i.data.get
  case data.name:
  of "gta": await gtaSlash(i, s, discord)
  of "demotivator": await demotivatorSlash(i, s, discord)
  of "adm": await admSlash(i, s, discord)

proc onReady(s: Shard, r: Ready) {.async event(discord).} =
  echo "Ready as: " & $r.user
  await s.updateStatus(activity = some ActivityStatus(
    name: "nim power 💪",
    kind: atPlaying
  ), status = "online")

waitFor initLanguageReactions()
waitFor discord.startSession(gateway_intents = {giGuilds, giGuildMessages,
    giGuildMessageReactions})
