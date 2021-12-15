// Copyright (C) 2020 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import m5stack_core2
import gpio
import .snake
import .display
import .map

main:
  clock := gpio.Pin 22
  data := gpio.Pin 21

  // Create the power object and initialize the power config
  // to its default values.  Resets the LCD display and switches
  // on the LCD backlight and the green power LED.
  power := m5stack_core2.Power --clock=clock --data=data

  // left_button := m5stack_core2.

  // Get TFT driver.
  tft := m5stack_core2.display
  width := 320
  height := 240

  display := TrueColorDisplay tft
  s := Game display width height 10
  s.run
