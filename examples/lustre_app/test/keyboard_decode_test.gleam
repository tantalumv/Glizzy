// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleeunit
import gleeunit/should
import lustre_utils/keyboard

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn decode_space_key_test() {
  keyboard.decode_key(" ")
  |> should.equal(keyboard.Space)
}

pub fn decode_enter_key_test() {
  keyboard.decode_key("Enter")
  |> should.equal(keyboard.Enter)
}

pub fn decode_escape_key_test() {
  keyboard.decode_key("Escape")
  |> should.equal(keyboard.Escape)
}

pub fn decode_arrow_up_key_test() {
  keyboard.decode_key("ArrowUp")
  |> should.equal(keyboard.ArrowUp)
}

pub fn decode_arrow_down_key_test() {
  keyboard.decode_key("ArrowDown")
  |> should.equal(keyboard.ArrowDown)
}

pub fn decode_arrow_left_key_test() {
  keyboard.decode_key("ArrowLeft")
  |> should.equal(keyboard.ArrowLeft)
}

pub fn decode_arrow_right_key_test() {
  keyboard.decode_key("ArrowRight")
  |> should.equal(keyboard.ArrowRight)
}

pub fn decode_home_key_test() {
  keyboard.decode_key("Home")
  |> should.equal(keyboard.Home)
}

pub fn decode_end_key_test() {
  keyboard.decode_key("End")
  |> should.equal(keyboard.End)
}

pub fn decode_page_up_key_test() {
  keyboard.decode_key("PageUp")
  |> should.equal(keyboard.PageUp)
}

pub fn decode_page_down_key_test() {
  keyboard.decode_key("PageDown")
  |> should.equal(keyboard.PageDown)
}

pub fn decode_character_key_test() {
  keyboard.decode_key("a")
  |> should.equal(keyboard.Character("a"))
}

pub fn decode_uppercase_character_key_test() {
  keyboard.decode_key("A")
  |> should.equal(keyboard.Character("A"))
}

pub fn decode_f1_key() {
  keyboard.decode_key("F1")
  |> should.equal(keyboard.F1)
}

pub fn decode_f12_key() {
  keyboard.decode_key("F12")
  |> should.equal(keyboard.F12)
}

pub fn decode_unknown_key_test() {
  keyboard.decode_key("UnknownKey")
  |> should.equal(keyboard.Character("UnknownKey"))
}
