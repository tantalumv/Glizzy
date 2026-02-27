// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleeunit
import gleeunit/should
import lustre_utils/keyboard

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn is_navigation_key_arrow_up_test() {
  keyboard.is_navigation_key(keyboard.ArrowUp)
  |> should.be_true
}

pub fn is_navigation_key_arrow_down_test() {
  keyboard.is_navigation_key(keyboard.ArrowDown)
  |> should.be_true
}

pub fn is_navigation_key_home_test() {
  keyboard.is_navigation_key(keyboard.Home)
  |> should.be_true
}

pub fn is_navigation_key_end_test() {
  keyboard.is_navigation_key(keyboard.End)
  |> should.be_true
}

pub fn is_navigation_key_page_up_test() {
  keyboard.is_navigation_key(keyboard.PageUp)
  |> should.be_true
}

pub fn is_navigation_key_page_down_test() {
  keyboard.is_navigation_key(keyboard.PageDown)
  |> should.be_true
}

pub fn is_not_navigation_key_enter_test() {
  keyboard.is_navigation_key(keyboard.Enter)
  |> should.be_false
}

pub fn is_not_navigation_key_character_test() {
  keyboard.is_navigation_key(keyboard.Character("a"))
  |> should.be_false
}

pub fn is_activation_key_enter_test() {
  keyboard.is_activation_key(keyboard.Enter)
  |> should.be_true
}

pub fn is_activation_key_space_test() {
  keyboard.is_activation_key(keyboard.Space)
  |> should.be_true
}

pub fn is_not_activation_key_escape_test() {
  keyboard.is_activation_key(keyboard.Escape)
  |> should.be_false
}

pub fn is_character_key_lowercase_test() {
  keyboard.is_character_key(keyboard.Character("a"))
  |> should.be_true
}

pub fn is_character_key_uppercase_test() {
  keyboard.is_character_key(keyboard.Character("Z"))
  |> should.be_true
}

pub fn is_not_character_key_enter_test() {
  keyboard.is_character_key(keyboard.Enter)
  |> should.be_false
}
