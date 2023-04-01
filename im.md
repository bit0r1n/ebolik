imagemagick -size 768x{CANVAS_HEIGHT} xc:black -fill white -stroke black -strokewidth {LINE_WIDTH} -draw "rectangle {rectX},{rectY} {rectXEnd},{rectYEnd}" -draw "image over {rectX + GAP},{rectY + GAP},{RECT_WIDTH - GAP * 2},{RECT_HEIGHT - GAP * 2} '{INPUT_FILE}'" {OUTPUT_FILE}

let BASE_WIDTH = 768
let BASE_HEIGHT = 490
let rectX = BASE_WIDTH * 0.07
let rectY = BASE_HEIGHT * 0.07
let rectWidth = BASE_WIDTH - rectX * 2
let rectHeight = BASE_HEIGHT - rectY * 2
let gap = rectWidth * 0.01

let textLines = 0

`magick -size ${BASE_WIDTH}x${BASE_HEIGHT} \
xc:black -fill black -stroke white -strokewidth 2 \
-draw "rectangle ${rectX | 0},${rectY | 0} ${(rectWidth + rectX) | 0},${(rectHeight + rectY) | 0}"\
-draw "image over ${(rectX + gap) | 0},${(rectY + gap) | 0},${(rectWidth - gap * 2) | 0},${(rectHeight - gap * 2) | 0} gavno.png" \
test.png`