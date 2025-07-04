import std/[
  asyncdispatch, options, tables,
  httpclient, nre, strutils, unicode
]
import dimscord, pixie, pixie/fileformats/png
import images

let
  slashCommands* = @[
    ApplicationCommand(
      kind: atSlash,
      name: "gta",
      description: "крутая катсцена жта са",
      options: @[
        ApplicationCommandOption(
          kind: acotStr,
          name: "text",
          description: "текст епта",
          required: some true
        ),
        ApplicationCommandOption(
          kind: acotAttachment,
          name: "image",
          description: "пикча"
        )
      ]
    ),
    ApplicationCommand(
      kind: atSlash,
      name: "demotivator",
      description: "МОТИВАТОР",
      options: @[
        ApplicationCommandOption(
          kind: acotStr,
          name: "top",
          description: "текст (сверху !)",
          required: some true
        ),
        ApplicationCommandOption(
          kind: acotStr,
          name: "bottom",
          description: "снизу епт е!)"
        ),
        ApplicationCommandOption(
          kind: acotAttachment,
          name: "image",
          description: "пикча"
        )
      ]
    )
  ]
  admCommand* = ApplicationCommand(
    kind: atSlash,
    name: "adm",
    description: "Enter to admin control panel"
  )

proc authorAvatarUrl(i: Interaction): string =
  result = if i.user.isSome: i.user.get().avatarUrl(size = 512)
    else: Guild(id: i.guild_id.get).memberAvatarUrl(i.member.get)

proc gtaSlash*(i: Interaction, s: Shard, discord: DiscordClient) {.async.} =
  let
    data = i.data.get
    text = data.options["text"].str
    imageOption = data.options.getOrDefault("image")
    imageUrl = if imageOption.kind == acotNothing:
      i.authorAvatarUrl
    else: data.resolved.attachments[data.options["image"].aval].url

  if permAttachFiles notin i.app_permissions:
    await discord.api.createInteractionResponse(
      i.id, i.token,
      InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionCallbackDataMessage(
          content: "yrJleNJlacTNk, MHe 6E3 TPAXAHNR nPAB KAPAKyJlNs",
          flags: { mfEphemeral }
        )
      )
    )
    return

  if not imageUrl.contains(re"\.(png|jpe?g|gif)"):
    await discord.api.createInteractionResponse(
      i.id, i.token,
      InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionCallbackDataMessage(
          content: "TPAXAHNE TBOErO fANJlA",
          flags: { mfEphemeral }
        )
      )
    )
    return

  await discord.api.createInteractionResponse(
    i.id, i.token,
    InteractionResponse(
      kind: irtDeferredChannelMessageWithSource
    )
  )

  let
    httpClient = newAsyncHttpClient()
    rawImage = await httpClient.getContent(imageUrl)

  var image: Image

  try:
    image = decodeImage(rawImage)
  except:
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      content = some "HeroD9N, TBON fANJl fAJlbLL|NBKA"
    )
    return

  let fText = text.findAll(re"(*UTF8)[a-zA-Zа-яА-Я0-9!#\(\),\-\.\?ёЁ¶ЇЄ\xA9\xAE\x{2000}-\x{3300}\x{1F000}-\x{1FBFF} ]").join("")
  if fText.len == 0:
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      content = some "TPAXAHNE TBOErO TEKCTOB OKOJlO rPyNTA"
    )
    return

  try:
    let file = gta(unicode.toUpper(fText), image).encodePng()
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      attachments = @[
        Attachment(
          id: "0",
          filename: "gta.png",
          file: file
        )
      ]
    )
  except:
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      content = some "не получилось не фортануло)"
    )

  return

proc demotivatorSlash*(i: Interaction, s: Shard, discord: DiscordClient) {.async.} =
  let
    data = i.data.get
    topText = data.options["top"].str
    bottomTextOption = data.options.getOrDefault("bottom")
    bottomText = if bottomTextOption.kind == acotNothing: "" else: data.options["bottom"].str
    imageOption = data.options.getOrDefault("image")
    imageUrl = if imageOption.kind == acotNothing:
      i.authorAvatarUrl
    else: data.resolved.attachments[data.options["image"].aval].url

  if permAttachFiles notin i.app_permissions:
    await discord.api.createInteractionResponse(
      i.id, i.token,
      InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionCallbackDataMessage(
          content: "их мысли\n\nблять где права на пикчи",
          flags: { mfEphemeral }
        )
      )
    )
    return

  if not imageUrl.contains(re"\.(png|jpe?g|gif)"):
    await discord.api.createInteractionResponse(
      i.id, i.token,
      InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionCallbackDataMessage(
          content: "без картинки не начинаем",
          flags: { mfEphemeral }
        )
      )
    )
    return

  await discord.api.createInteractionResponse(
    i.id, i.token,
    InteractionResponse(
      kind: irtDeferredChannelMessageWithSource
    )
  )

  let
    httpClient = newAsyncHttpClient()
    rawImage = await httpClient.getContent(imageUrl)

  var image: Image

  try:
    image = decodeImage(rawImage)
  except:
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      content = some "их файлы\n\nблять что это"
    )
    return

  try:
    let file = demotivator(topText, bottomText, image).encodePng()
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      attachments = @[
        Attachment(
          id: "0",
          filename: "demotivator.png",
          file: file
        )
      ]
    )
  except CatchableError:
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      content = some "не получилось не фортануло)"
    )

proc admSlash*(i: Interaction, s: Shard, discord: DiscordClient) {.async.} =
  if permKickMembers notin i.app_permissions:
    await discord.api.createInteractionResponse(
      i.id, i.token,
      InteractionResponse(
        kind: irtChannelMessageWithSource,
        data: some InteractionCallbackDataMessage(
          content: "ладно, иди наху, без админки будешь",
          flags: { mfEphemeral }
        )
      )
    )
    return

  await discord.api.createInteractionResponse(
    i.id, i.token,
    InteractionResponse(
      kind: irtDeferredChannelMessageWithSource
    )
  )

  try:
    await discord.api.removeGuildMember(i.guild_id.get, i.member.get().user.id, "+admin")
  except CatchableError:
    discard
  finally:
    discard await discord.api.sendMessage(i.channel_id.get, "+admin " & i.member.get().user.username)
    asyncCheck discord.api.editWebhookMessage(
      discord.shards[0].user.id, i.token, "@original",
      content = some "xd"
    )