// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import checkbox_group_keymap_test
import disclosure_group_keymap_test
import gleeunit
import grid_list_keymap_test
import keyboard_classify_test
import keyboard_decode_test
import keyboard_navigation_test
import keyboard_typeahead_test
import radio_group_keymap_test
import select_keymap_test
import slider_keymap_test
import table_keymap_test
import toggle_button_group_keymap_test
import toolbar_keymap_test

pub fn main() -> Nil {
  keyboard_decode_test.main()
  keyboard_classify_test.main()
  keyboard_navigation_test.main()
  keyboard_typeahead_test.main()
  slider_keymap_test.main()
  radio_group_keymap_test.main()
  checkbox_group_keymap_test.main()
  toggle_button_group_keymap_test.main()
  disclosure_group_keymap_test.main()
  toolbar_keymap_test.main()
  select_keymap_test.main()
  grid_list_keymap_test.main()
  table_keymap_test.main()
  gleeunit.main()
}
