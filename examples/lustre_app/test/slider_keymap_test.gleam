// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/keyboard
import lustre_utils/slider as slider_utils
import ui/slider

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn slider_keymap_increase_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowRight",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(Some(slider_utils.Increase))
}

pub fn slider_keymap_decrease_test() {
  let event =
    keyboard.KeyEvent(
      key: "ArrowLeft",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(Some(slider_utils.Decrease))
}

pub fn slider_keymap_set_min_test() {
  let event =
    keyboard.KeyEvent(
      key: "Home",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(Some(slider_utils.SetMin))
}

pub fn slider_keymap_set_max_test() {
  let event =
    keyboard.KeyEvent(
      key: "End",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(Some(slider_utils.SetMax))
}

pub fn slider_keymap_page_increase_test() {
  let event =
    keyboard.KeyEvent(
      key: "PageUp",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(Some(slider_utils.PageIncrease))
}

pub fn slider_keymap_page_decrease_test() {
  let event =
    keyboard.KeyEvent(
      key: "PageDown",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(Some(slider_utils.PageDecrease))
}

pub fn slider_keymap_unhandled_test() {
  let event =
    keyboard.KeyEvent(
      key: "Enter",
      shift: False,
      ctrl: False,
      meta: False,
      alt: False,
    )
  slider_utils.keymap(event, slider.Horizontal)
  |> should.equal(None)
}
