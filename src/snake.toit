import bytes

import .display
import .map

UP ::= Pos 0 1
RIGHT ::= Pos 1 0
DOWN ::= Pos 0 -1
LEFT ::= Pos -1 0

class Game:

  display/Display
  width/int
  height/int
  block_size/int
  grid_/Bitmap

  food_/Pos? := null
  snake_/Snake? := null
  direction_/Pos? := RIGHT

  update_speed ::= Duration --ms=500

  constructor .display .width .height .block_size:
    grid_width := (width - block_size*2) / block_size
    grid_height := (height - block_size*2) / block_size
    grid_ = Bitmap grid_width grid_height

    init_draw

  init_draw:
    display.filled_rectangle display.black 0 0 width height
    display.filled_rectangle display.white block_size block_size (width-(block_size*2)) (height-(block_size*2))

    snake_start := Pos grid_.width / 2 grid_.height / 2
    snake_ = Snake snake_start
    spawn_food

    print "Snake at: $(snake_)"
    print "Food at: $(food_)"

    display.draw

  update_position pos/Pos v/bool:
    grid_.set pos v
    display.filled_rectangle (v ? display.black : display.white) (pos.x+1)*block_size (pos.y+1)*block_size block_size block_size

  get_direction -> Pos:
    return direction_

  change_direction direction/Pos:
    direction_ = direction

  run:
    update_speed.periodic:
      print "Updating"

      direction := get_direction
      new_head := snake_.head + direction

      // Check if there is food?
      if food_ == new_head:
        print "Got food"
      else if not grid_.valid new_head:
        print "hit wall"
        return
      else if grid_.get new_head:
        print "Hit myself"
        return
      else:
        update_position new_head true
        tail := snake_.move direction
        update_position tail false

      display.draw

  get_free_pos -> Pos:
    while true:
      x := random grid_.width
      y := random grid_.height
      if not grid_.get x y:
        p := Pos x y
        update_position p true
        return p

  spawn_food:
    food_ = get_free_pos


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
