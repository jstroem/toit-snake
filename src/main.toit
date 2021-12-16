// Copyright (C) 2020 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import m5stack_core2
import gpio
import .snake
import .display
import .map

main:
  device := m5stack_core2.Device
  touch := device.touch
  tft := device.display
  width := 320
  height := 240

  display := TrueColorDisplay tft
  s := Game display width height 10

  left_boundary := width / 4
  right_boundary := width - width / 4
  // top_boundary := height / 4
  // bottom_boundary := height - height / 4

  while true:
    coord := touch.get_coords
    if coord.s:
      if s.running:
        if coord.x < left_boundary:
          print "Turn left"
          s.change_direction RIGHT_TURN
        else if right_boundary < coord.x:
          print "Turn right"
          s.change_direction LEFT_TURN
      else:
        if s.ready_box.in coord.x coord.y:
          s.start
        else:
          print "outside: $coord.x $coord.y"
    sleep --ms=20
