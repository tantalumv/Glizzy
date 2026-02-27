// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/keyboard
import lustre_utils/toggle_button_group as toggle_button_group_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn toggle_button_group_keymap_move_next_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowRight",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toggle_button_group_utils.keymap(event)
  |> should.equal(Some(toggle_button_group_utils.MoveNext))
}

pub fn toggle_button_group_keymap_toggle_with_space_test() {
  let event =
    keyboard.KeyEvent(
      key: " ",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toggle_button_group_utils.keymap(event)
  |> should.equal(Some(toggle_button_group_utils.Toggle(-1)))
}

pub fn toggle_button_group_keymap_toggle_with_enter_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toggle_button_group_utils.keymap(event)
  |> should.equal(Some(toggle_button_group_utils.Toggle(-1)))
}
