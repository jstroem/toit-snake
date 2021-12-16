import pixel_display
import pixel_display.texture
import pixel_display.true_color
import pixel_display.two_color
import font

interface Display:
  black -> int
  white -> int

  remove_all -> none
  text font/font.Font color/int x/int y/int text/string -> none
  filled_rectangle color/int x/int y/int width/int height/int -> none
  draw --speed/int=50 -> none


class TrueColorDisplay implements Display:
  display/pixel_display.TrueColorPixelDisplay

  black ::= true_color.BLACK
  white ::= true_color.WHITE

  constructor .display:

  remove_all -> none:
    display.remove_all

  filled_rectangle color/int x/int y/int width/int height/int -> none:
    ctx := display.context --color=color
    display.filled_rectangle ctx x y width height

  text font/font.Font color/int x/int y/int text/string -> none:
    ctx := display.context --color=color --font=font --alignment=texture.TEXT_TEXTURE_ALIGN_CENTER
    display.text ctx x y text

  draw --speed/int=50 -> none:
    display.draw --speed=speed

class TwoColorDisplay implements Display:
  display/pixel_display.TwoColorPixelDisplay

  black ::= two_color.BLACK
  white ::= two_color.WHITE

  constructor .display:

  remove_all -> none:
    display.remove_all

  filled_rectangle color/int x/int y/int width/int height/int -> none:
    ctx := display.context --color=color
    display.filled_rectangle ctx x y width height

  text font/font.Font color/int x/int y/int text/string -> none:
    ctx := display.context --color=color --font=font
    display.text ctx x y text

  draw --speed/int=50 -> none:
    display.draw --speed=speed
