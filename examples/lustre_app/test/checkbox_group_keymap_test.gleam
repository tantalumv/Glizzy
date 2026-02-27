// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/checkbox_group as checkbox_group_utils
import lustre_utils/keyboard

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn checkbox_group_keymap_move_next_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  checkbox_group_utils.keymap(event)
  |> should.equal(Some(checkbox_group_utils.MoveNext))
}

pub fn checkbox_group_keymap_move_prev_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowUp",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  checkbox_group_utils.keymap(event)
  |> should.equal(Some(checkbox_group_utils.MovePrev))
}

pub fn checkbox_group_keymap_toggle_test() {
  let event =
    keyboard.KeyEvent(
      key: " ",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  checkbox_group_utils.keymap(event)
  |> should.equal(Some(checkbox_group_utils.Toggle("")))
}
