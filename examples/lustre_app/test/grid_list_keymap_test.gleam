// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/grid_list as grid_list_utils
import lustre_utils/keyboard

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn grid_list_keymap_move_down_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  grid_list_utils.keymap(event, False)
  |> should.equal(Some(grid_list_utils.MoveDown))
}

pub fn grid_list_keymap_move_up_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowUp",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  grid_list_utils.keymap(event, False)
  |> should.equal(Some(grid_list_utils.MoveUp))
}

pub fn grid_list_keymap_move_right_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowRight",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  grid_list_utils.keymap(event, False)
  |> should.equal(Some(grid_list_utils.MoveRight))
}

pub fn grid_list_keymap_move_left_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowLeft",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  grid_list_utils.keymap(event, False)
  |> should.equal(Some(grid_list_utils.MoveLeft))
}

pub fn grid_list_keymap_select_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  grid_list_utils.keymap(event, False)
  |> should.equal(Some(grid_list_utils.SelectFocused))
}

pub fn grid_list_keymap_extend_selection_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowDown",
      shift: True,
      ctrl: False,
      meta: False,
      alt: False,
    )
  grid_list_utils.keymap(event, True)
  |> should.equal(Some(grid_list_utils.ExtendSelectionDown))
}
