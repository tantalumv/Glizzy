// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/keyboard
import lustre_utils/select as select_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn select_keymap_open_when_closed_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  select_utils.keymap(event, False)
  |> should.equal(Some(select_utils.Open))
}

pub fn select_keymap_select_when_open_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  select_utils.keymap(event, True)
  |> should.equal(Some(select_utils.Select("")))
}

pub fn select_keymap_move_next_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  select_utils.keymap(event, False)
  |> should.equal(Some(select_utils.MoveNext))
}

pub fn select_keymap_move_prev_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowUp",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  select_utils.keymap(event, False)
  |> should.equal(Some(select_utils.MovePrev))
}

pub fn select_keymap_close_with_escape_test() {
  let event =
    keyboard.KeyEvent(
      key: "Escape",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  select_utils.keymap(event, True)
  |> should.equal(Some(select_utils.Close))
}

pub fn select_keymap_typeahead_test() {
  let event =
    keyboard.KeyEvent(
      key: "a",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  select_utils.keymap(event, False)
  |> should.equal(Some(select_utils.TypeAhead("a")))
}
