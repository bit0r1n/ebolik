import strutils
import pixie

const
  TNRFontPath = "fonts/times-new-roman.ttf"
  ArialFontPath = "fonts/Arial.ttf"
  GTAFontPath = "fonts/gtaprikol.ttf"

  TwemojiFontPath = "fonts/twemoji-color.ttf"
  NotoEmojiFontPath = "fonts/noto-emoji.ttf"

let
  TNRFont = readFont(TNRFontPath)
  ArialFont = readFont(ArialFontPath)
  GTAFont = readFont(GTAFontPath)

  NotoEmojiFont = readFont(NotoEmojiFontPath)

TNRFont.typeface.fallbacks.add(NotoEmojiFont.typeface)
ArialFont.typeface.fallbacks.add(NotoEmojiFont.typeface)
GTAFont.typeface.fallbacks.add(NotoEmojiFont.typeface)

proc newFont(typeface: Typeface, size: float32, paint: Paint): Font =
  result = newFont(typeface)
  result.size = size
  result.paint = paint

proc newFont(font: Font, size: float32, paint: Paint): Font =
  result = font.copy
  result.size = size
  result.paint = paint

proc wrapText(ctx: Context, srcFont: Font, text: string, maxWidth: float32): seq[string] =
  if maxWidth <= 0:
    return @[ text ]

  var
    currentLine = ""
    words = text.split(' ')
    font = srcFont.copy()
  font.size = ctx.fontSize
  font.paint = ctx.fillStyle

  for word in words:
    let wordWidth = typeset(font, word).layoutBounds().x

    if wordWidth > maxWidth:
      if currentLine.len > 0:
        result.add(currentLine)
        currentLine = ""

      var tempWord = word
      while tempWord.len > 0:
        var part = ""
        var bestPart = ""
        for i in 1..tempWord.len:
          let potentialPart = tempWord[0..<i]
          let partWidth = typeset(font, potentialPart).layoutBounds().x
          if partWidth <= maxWidth:
            bestPart = potentialPart
          else:
            break
        
        if bestPart.len > 0:
          result.add(bestPart)
          tempWord = tempWord[bestPart.len..^1]
        else:
          result.add(tempWord)
          tempWord = ""

    else:
      let testLine = if currentLine.len == 0: word else: currentLine & " " & word
      let width = typeset(font, testLine).layoutBounds().x

      if width <= maxWidth:
        if currentLine.len == 0:
          currentLine = word
        else:
          currentLine = currentLine & " " & word
      else:
        if currentLine.len > 0:
          result.add(currentLine)
        currentLine = word

  if currentLine.len > 0:
    result.add(currentLine)

proc fillText(ctx: Context, srcFont: Font, text: string, x, y: float32, maxWidth: float32 = 0) =
  var font = srcFont.copy()
  font.size = ctx.fontSize
  font.paint = ctx.fillStyle

  var
    at = vec2(x, y)
    lines = newSeq[string]()

  if maxWidth > 0:
    lines = ctx.wrapText(font, text, maxWidth)
  else:
    lines = @[ text ]

  for i, line in lines:
    var currentY = at.y + i.float * font.size
    case ctx.textBaseline:
    of TopBaseline, HangingBaseline:
      discard
    of MiddleBaseline:
      currentY -= round((font.typeface.ascent - font.typeface.descent) / 2 * font.scale)
    of AlphabeticBaseline:
      currentY -= round(font.typeface.ascent * font.scale)
    of IdeographicBaseline, BottomBaseline:
      currentY -= round((font.typeface.ascent - font.typeface.descent) * font.scale)

    ctx.image.fillText(
      font,
      line,
      mat3() * translate(vec2(at.x, currentY)),
      hAlign = ctx.textAlign
    )

proc demotivator*(topText: string, bottomText = "", customImage: Image): Image =
  const baseHeight = 490
  const baseWidth = 768
  let
    fontSize = baseWidth.float * 0.04
    bottomFontSize = fontSize * 0.85

  let
    baseImage = newImage(baseWidth, baseHeight)
    baseCtx = newContext(baseImage)

  baseCtx.fontSize = fontSize
  let
    topLines = baseCtx.wrapText(
      TNRFont,
      topText,
      baseWidth.float * 0.8
    )
    topFont = newFont(TNRFont, fontSize, color(1, 1, 1, 1))

  baseCtx.fontSize = bottomFontSize
  let
    bottomLines = baseCtx.wrapText(
      ArialFont,
      bottomText,
      baseWidth.float * 0.8
    )
    bottomFont = newFont(ArialFont, bottomFontSize, color(1, 1, 1, 1))

  result = baseImage.resize(
      baseWidth,
      baseHeight +
        int(topLines.len.float * fontSize) +
        int((bottomLines.len + int(bottomLines.len > 0)).float * bottomFontSize)
    )
  let ctx = newContext(result)

  result.fill(rgba(0, 0, 0, 255))

  ctx.fillStyle = rgba(0, 0, 0, 0)
  ctx.strokeStyle = rgba(255, 255, 255, 255)
  ctx.lineWidth = (baseWidth / baseHeight) * 2

  let
    rectX = baseWidth.float * 0.07
    rectY = baseHeight.float * 0.07
    rectWidth = baseWidth.float - rectX * 2
    rectHeight = baseHeight.float - rectY * 2
  # draw a rectangle/image corner
  ctx.strokeRect(rectX, rectY, rectWidth, rectHeight)

  # draw image
  let gap = rectWidth * 0.01;
  ctx.drawImage(customImage, rectX + gap, rectY + gap, rectWidth - gap * 2,
      rectHeight - gap * 2)

  # draw watermark
  ctx.fillStyle = color(0, 0, 0, 1)
  let
    watermarkX = (rectX + rectWidth) * 0.85
    watermarkY = (rectY + rectHeight) * 0.99
    watermarkWidth = rectWidth - watermarkX + (baseWidth * 0.02)
    watermarkHeight = baseHeight * 0.05

  ctx.fillRect(watermarkX, watermarkY, watermarkWidth, watermarkHeight)
  ctx.fillStyle = color(1, 1, 1, 1)
  ctx.fontSize = baseWidth * 0.02
  ctx.textAlign = LeftAlign
  ctx.font = ArialFontPath
  ctx.fillText("genai.bot", watermarkX * 1.005, watermarkY * 1.023)

  # setting style for top text
  ctx.textAlign = CenterAlign
  ctx.textBaseline = BottomBaseline
  ctx.fontSize = fontSize

  # draw top text
  let bottomSkip = (topLines.len.float + 0.5) * fontSize
  ctx.fillText(
    TNRFont,
    topText,
    baseWidth.float * 0.5,
    baseHeight.float + fontSize / 2,
    maxWidth = baseWidth.float * 0.8
  )

  # draw bottom text
  if bottomText.len > 0:
    ctx.fontSize = bottomFontSize
    ctx.fillText(
      ArialFont,
      bottomText,
      baseWidth.float * 0.5,
      bottomSkip + baseHeight.float,
      maxWidth = baseWidth.float * 0.8
    )

proc gta*(text: string, customImage: Image): Image =
  const
    baseHeight = 720
    baseWidth = 1280
    fontSize = baseHeight * 0.06

    imageHeight = baseHeight * (1 - 0.34)
    imageStartY = (baseHeight - imageHeight) / 2.7

  result = newImage(baseWidth, baseHeight)

  result.fill(rgba(0, 0, 0, 255))

  let ctx = newContext(result)
  ctx.drawImage(customImage, 0, imageStartY, baseWidth, imageHeight)


  ctx.textAlign = CenterAlign
  ctx.fillStyle = rgb(214, 214, 214)
  ctx.fontSize = fontSize
  ctx.textBaseline = BottomBaseline

  var lines = ctx.wrapText(
    GTAFont,
    text,
    baseWidth.float * 0.9
  )
  if lines.len > 2:
    lines = lines[0..1]

  ctx.fillText(
    GTAFont,
    lines.join(" "),
    baseWidth.float * 0.5,
    (baseHeight - imageStartY) + fontSize * 0.5,
    maxWidth = baseWidth.float * 0.9
  )
