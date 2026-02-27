// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/keyboard
import lustre_utils/radio_group as radio_group_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn radio_group_keymap_move_next_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowRight",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  radio_group_utils.keymap(event)
  |> should.equal(Some(radio_group_utils.MoveNext))
}

pub fn radio_group_keymap_move_prev_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowLeft",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  radio_group_utils.keymap(event)
  |> should.equal(Some(radio_group_utils.MovePrev))
}

pub fn radio_group_keymap_move_first_test() {
  let event =
    keyboard.KeyEvent(
      key: "Home",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  radio_group_utils.keymap(event)
  |> should.equal(Some(radio_group_utils.MoveFirst))
}

pub fn radio_group_keymap_move_last_test() {
  let event =
    keyboard.KeyEvent(
      key: "End",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  radio_group_utils.keymap(event)
  |> should.equal(Some(radio_group_utils.MoveLast))
}

pub fn radio_group_keymap_select_test() {
  let event =
    keyboard.KeyEvent(
      key: " ",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  radio_group_utils.keymap(event)
  |> should.equal(Some(radio_group_utils.Select("")))
}

pub fn radio_group_keymap_unhandled_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  radio_group_utils.keymap(event)
  |> should.equal(None)
}
