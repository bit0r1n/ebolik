# Package

version       = "0.1.0"
author        = "bit0r1n"
description   = "ALTIR BOT REAL (ebolik)"
license       = "Proprietary"
srcDir        = "src"
bin           = @[ "ebolik" ]
binDir        = "bin"


# Dependencies

requires "nim >= 1.6.10"
requires "pixie, dimscord == 1.8.0", "https://github.com/bit0r1n/boticordnim#1.0.5"
