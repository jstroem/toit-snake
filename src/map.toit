import bytes

OUT_OF_BOUNDS ::= "OUT OF BOUNDS"

class BitArray:
  backing_/ByteArray
  size/int

  constructor .size/int:

    backing_size := size/8
    if size%8 != 0:
      backing_size++
    backing_ = ByteArray backing_size


  operator []= i/int v/bool -> none:
    if i < 0 or size < i:
      throw OUT_OF_BOUNDS
    idx := i/8
    mask := 1 << i%8
    if v:
      backing_[idx] |= mask
    else:
      backing_[idx] &= ~mask

  operator [] i/int -> bool:
    if i < 0 or size < i:
      throw OUT_OF_BOUNDS
    idx := i/8
    mask := 1 << i%8
    return backing_[idx] & mask != 0

  do [block]:
    for i := 0; i < size; i++:
      block.call this[i]

  to_string --from=0 --to=size -> string:
    buffer := bytes.Buffer

    buffer.write "["
    for i := from; i < to; i++:
      if i != 0:
        buffer.write ", "
      buffer.write (this[i] ? "1" : "0")
    buffer.write "]"

    return buffer.to_string

  stringify -> string:
    return to_string

class Bitmap:
  backing_/BitArray
  width/int
  height/int

  constructor .width .height:
    backing_ = BitArray width*height

  valid x/int y/int -> bool:
    return 0 <= x < width and 0 <= y < height

  valid pos/Pos -> bool:
    return valid pos.x pos.y

  get x/int y/int -> bool:
    return backing_[y*width + x]

  get pos/Pos -> bool:
    return get pos.x pos.y

  set x/int y/int v/bool -> none:
    backing_[y*width + x] = v

  set pos/Pos v/bool -> none:
    set pos.x pos.y v

  do [block]:
    height.repeat: |y|
      width.repeat: |x|
        block.call x y

class Pos:
  x/int
  y/int

  constructor .x .y:

  stringify -> string:
    return "($x, $y)"

  operator + other/Pos -> Pos:
    return Pos this.x+other.x this.y+other.y

  operator - other/Pos -> Pos:
    return Pos this.x-other.x this.y-other.y
