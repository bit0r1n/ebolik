import std/unicode
import pixie

const TNRFont = "fonts/times-new-roman.ttf"
const ArialFont = "fonts/Arial.ttf"
const GTAFont = "fonts/gtaprikol.ttf"

let
  TNRTypeface = readTypeface(TNRFont)
  GTATypeface = readTypeface(GTAFont)

proc newFont(typeface: Typeface, size: float32, color: Color): Font =
  result = newFont(typeface)
  result.size = size
  result.paint.color = color

proc getDemotivatorHeight*(topText = "", bottomText = ""): int =
  const baseHeight = 490
  const baseWidth = 768
  let
    fontSize = baseWidth.float * 0.04
    bottomFontSize = fontSize * 0.75

  let topArrangement = typeset(
    newFont(TNRTypeface, fontSize, color(1, 1, 1, 1)),
    topText,
    vec2(baseWidth.float * 0.8, 0)
  )

  let bottomArrangement = typeset(
    newFont(TNRTypeface, bottomFontSize, color(1, 1, 1, 1)),
    if bottomText.len != 0: ("\n" & bottomText) else: "",
    vec2(baseWidth.float * 0.8, 0)
  )

  return baseHeight +
          int(topArrangement.lines.len.float * fontSize) +
          int(bottomArrangement.lines.len.float * bottomFontSize)

proc demotivator*(topText: string, bottomText = "", customImage: Image): Image =
  const baseHeight = 490
  const baseWidth = 768
  let
    fontSize = baseWidth.float * 0.04
    bottomFontSize = fontSize * 0.85

  let topArrangement = typeset(
    newFont(TNRTypeface, fontSize, color(1, 1, 1, 1)),
    topText,
    vec2(baseWidth.float * 0.8, 0)
  )

  let bottomArrangement = typeset(
    newFont(TNRTypeface, bottomFontSize, color(1, 1, 1, 1)),
    if bottomText.len != 0: ("\n" & bottomText) else: "",
    vec2(baseWidth.float * 0.8, 0)
  )

  let image = newImage(
      baseWidth,
      baseHeight +
        int(topArrangement.lines.len.float * fontSize) +
        int(bottomArrangement.lines.len.float * bottomFontSize)
    )
  image.fill(rgba(0, 0, 0, 255))

  let ctx = newContext(image)
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
  ctx.font = ArialFont
  ctx.fillText("genai.bot", watermarkX * 1.005, watermarkY * 1.023)

  # setting style for top text
  ctx.fillStyle = rgba(255, 255, 255, 255)
  ctx.textAlign = CenterAlign
  ctx.fontSize = fontSize
  ctx.font = TNRFont
  ctx.textBaseline = BottomBaseline

  var bottomSkip = baseHeight.float

  # draw top text
  for lineIndex, lineRuneIndexes in topArrangement.lines:
    bottomSkip = baseHeight.float + (lineIndex.float + 0.5) * fontSize
    ctx.fillText(
      $topArrangement.runes[lineRuneIndexes[0]..lineRuneIndexes[1]],
      baseWidth.float * 0.5,
      baseHeight.float + (lineIndex.float + 0.5) * fontSize
    )

  # draw bottom text
  ctx.fontSize = bottomFontSize
  ctx.font = ArialFont
  for lineIndex, lineRuneIndexes in bottomArrangement.lines:
    ctx.fillText(
      $bottomArrangement.runes[lineRuneIndexes[0]..lineRuneIndexes[1]],
      baseWidth.float * 0.5,
      bottomSkip + (lineIndex.float + 0.5) * bottomFontSize
    )

  return image

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

  let textArrangement = typeset(
    newFont(GTATypeface, fontSize, color(0.84, 0.84, 0.84)),
    text,
    vec2(baseWidth * 0.8, 0)
  )

  ctx.textAlign = CenterAlign
  ctx.fillStyle = rgb(214, 214, 214)
  ctx.fontSize = fontSize
  ctx.textBaseline = BottomBaseline
  ctx.font = GTAFont

  for lineIndex, lineRuneIndexes in textArrangement.lines:
    if lineIndex > 1: break
    ctx.fillText(
      $textArrangement.runes[lineRuneIndexes[0]..lineRuneIndexes[1]],
      baseWidth.float * 0.5,
      (baseHeight - imageStartY) + fontSize * lineIndex.float
    )