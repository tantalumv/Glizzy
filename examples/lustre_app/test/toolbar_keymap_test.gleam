// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/keyboard
import lustre_utils/toolbar as toolbar_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn toolbar_keymap_move_next_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowRight",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toolbar_utils.keymap(event)
  |> should.equal(Some(toolbar_utils.MoveNext))
}

pub fn toolbar_keymap_move_prev_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowLeft",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toolbar_utils.keymap(event)
  |> should.equal(Some(toolbar_utils.MovePrev))
}

pub fn toolbar_keymap_activate_with_enter_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toolbar_utils.keymap(event)
  |> should.equal(Some(toolbar_utils.Activate))
}

pub fn toolbar_keymap_activate_with_space_test() {
  let event =
    keyboard.KeyEvent(
      key: " ",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  toolbar_utils.keymap(event)
  |> should.equal(Some(toolbar_utils.Activate))
}
