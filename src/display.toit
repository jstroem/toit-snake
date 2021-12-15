import pixel_display
import pixel_display.true_color
import pixel_display.two_color

interface Display:
  black -> int
  white -> int

  filled_rectangle color/int x/int y/int width/int height/int -> none
  draw --speed/int=50 -> none


class TrueColorDisplay implements Display:

  display/pixel_display.TrueColorPixelDisplay
  constructor .display:

  black ::= true_color.BLACK
  white ::= true_color.WHITE

  filled_rectangle color/int x/int y/int width/int height/int -> none:
    ctx := display.context --color=color
    display.filled_rectangle ctx x y width height

  draw --speed/int=50 -> none:
    display.draw --speed=speed

class TwoColorDisplay implements Display:

  display/pixel_display.TwoColorPixelDisplay
  constructor .display:

  black ::= two_color.BLACK
  white ::= two_color.WHITE

  filled_rectangle color/int x/int y/int width/int height/int -> none:
    display.filled_rectangle (display.context --color=color) x y width height

  draw --speed/int=50 -> none:
    display.draw --speed=speed
