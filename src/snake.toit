import bytes
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import font.x11_100dpi.sans.sans_14_bold as sans_14_bold
import font

import .display
import .map

UP ::= Pos 0 1
RIGHT ::= Pos 1 0
DOWN ::= Pos 0 -1
LEFT ::= Pos -1 0

LEFT_TURN ::= {
  UP: LEFT,
  RIGHT: UP,
  DOWN: RIGHT,
  LEFT: DOWN,
}

RIGHT_TURN ::= {
  UP: RIGHT,
  RIGHT: DOWN,
  DOWN: LEFT,
  LEFT: UP,
}

ALREADY_RUNNING ::= "ALREADY RUNNING"
NOT_RUNNING ::= "NOT RUNNING"

class Game:

  display/Display
  width/int
  height/int
  block_size/int
  ready_box/Box

  grid_/Bitmap? := null
  food_/Pos? := null
  snake_/Snake? := null
  direction_/Pos := RIGHT
  new_direction_/Pos := RIGHT

  static BIG_FONT ::= font.Font [sans_24_bold.ASCII]
  static SMALL_FONT ::= font.Font [sans_14_bold.ASCII]
  static UPDATE_SPEED ::= Duration --ms=300

  score/int? := null
  running := false

  constructor .display .width .height .block_size:
    box_width := 250
    box_height := 120
    box_x := (width - box_width) / 2
    box_y := (height - box_height) / 2

    ready_box = Box box_x box_y box_width box_height

    reset_

  setup_grid_:
    grid_width := (width - block_size*2) / block_size
    grid_height := (height - block_size*2) / block_size
    grid_ = Bitmap grid_width grid_height

  reset_:
    setup_grid_
    running = false
    draw_ready_

  draw_border_ x/int y/int width/int height/int border_size/int=block_size:
    display.filled_rectangle display.black x y width height
    display.filled_rectangle display.white x+border_size y+border_size (width-border_size*2) (height-border_size*2)

  draw_ready_:
    display.remove_all
    draw_border_ 0 0 width height
    draw_border_ ready_box.x ready_box.y ready_box.width ready_box.height
    if score != null:
      display.text SMALL_FONT display.black (ready_box.x + ready_box.width / 2) ready_box.y + 40 "Score: $score"
      display.text BIG_FONT display.black (ready_box.x + ready_box.width / 2) ready_box.y + 80 "Play again?"
    else:
      display.text BIG_FONT display.black (ready_box.x + ready_box.width / 2) ready_box.y + 70 "Press to play"

    display.draw

  draw_init_game_:
    display.remove_all
    draw_border_  0 0 width height

    snake_start := Pos grid_.width / 2 grid_.height / 2
    snake_ = Snake snake_start
    spawn_food

    print "Snake at: $(snake_)"
    print "Food at: $(food_)"

    display.draw

  update_position_ pos/Pos v/bool:
    grid_.set pos v
    display.filled_rectangle (v ? display.black : display.white) (pos.x+1)*block_size (pos.y+1)*block_size block_size block_size

  get_direction -> Pos:
    direction_ = new_direction_
    return direction_

  change_direction turn_map/Map/*<Pos, Pos>*/:
    new_direction_ = turn_map[direction_]

  start:
    print "starting game"
    if running:
      throw ALREADY_RUNNING

    running = true
    score = 0
    draw_init_game_
    task::
      run_

  run_:
    UPDATE_SPEED.periodic:
      if not running:
        print "game was stopped"
        reset_

      direction := get_direction
      new_head := snake_.head + direction

      // Check if there is food?
      if food_ == new_head:
        print "Got food"
        score++
        snake_.eat
        snake_.move direction
        spawn_food
      else if not grid_.valid new_head:
        print "hit wall"
        reset_
        return
      else if grid_.get new_head:
        print "Hit myself"
        reset_
        return
      else:
        update_position_ new_head true
        tail := snake_.move direction
        update_position_ tail false

      display.draw

  get_free_pos_ -> Pos:
    while true:
      x := random grid_.width
      y := random grid_.height
      if not grid_.get x y:
        p := Pos x y
        update_position_ p true
        return p

  spawn_food:
    food_ = get_free_pos_

class Box:
  x/int
  y/int
  width/int
  height/int

  constructor .x .y .width .height:

  in pos/Pos -> bool:
    return in pos.x pos.y

  in x/int y/int -> bool:
    return this.x <= x <= this.x+width and this.y <= y <= this.y + height

  stringify -> string:
    return "Box{x: $x, y: $y, width: $width, height: $height}"

class Snake:
  body/List/*<Pos>*/ := []

  eating_/int := 0
  eating_size_ ::= 5

  constructor start/Pos:
    body.add start

  eat:
    eating_ += eating_size_

  move direction/Pos -> Pos:
    tail := this.tail
    head := this.head
    if eating_ > 0:
      eating_--
    else:
      body = body.copy 1
    body.add head + direction
    return tail

  head -> Pos:
    return body.last

  tail -> Pos:
    return body.first

  stringify -> string:
    buffer := bytes.Buffer

    buffer.write "["
    body.size.repeat:
      if it != 0:
        buffer.write ", "
      buffer.write body[it].stringify
    buffer.write "]"

    return buffer.to_string
