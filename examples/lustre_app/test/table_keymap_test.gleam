// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/keyboard
import lustre_utils/table as table_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn table_keymap_move_down_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  table_utils.keymap(event, False, False)
  |> should.equal(Some(table_utils.MoveDown))
}

pub fn table_keymap_move_up_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowUp",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  table_utils.keymap(event, False, False)
  |> should.equal(Some(table_utils.MoveUp))
}

pub fn table_keymap_edit_mode_test() {
  let event =
    keyboard.KeyEvent(
      key: "F2",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  table_utils.keymap(event, False, True)
  |> should.equal(Some(table_utils.EditCell))
}

pub fn table_keymap_select_row_test() {
  let event =
    keyboard.KeyEvent(
      key: " ",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  table_utils.keymap(event, False, False)
  |> should.equal(Some(table_utils.SelectFocusedCell))
}

pub fn table_keymap_extend_selection_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: True,
      ctrl: False,
      meta: False,
      alt: False,
    )
  table_utils.keymap(event, True, False)
  |> should.equal(Some(table_utils.ExtendSelectionDown))
}

pub fn table_keymap_move_focus_only_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: False,
      ctrl: True,
      meta: False,
      alt: False,
    )
  table_utils.keymap(event, True, False)
  |> should.equal(Some(table_utils.MoveFocusDown))
}
