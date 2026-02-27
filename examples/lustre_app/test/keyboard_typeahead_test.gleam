// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleeunit
import gleeunit/should
import lustre_utils/keyboard

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn typeahead_buffer_first_char_test() {
  let #(buffer, reset) = keyboard.update_typeahead_buffer("", 0, 1000, "c", 500)
  buffer |> should.equal("c")
  reset |> should.be_true
}

pub fn typeahead_buffer_append_within_timeout_test() {
  let #(buffer, reset) =
    keyboard.update_typeahead_buffer("c", 1000, 1200, "h", 500)
  buffer |> should.equal("ch")
  reset |> should.be_false
}

pub fn typeahead_buffer_reset_after_timeout_test() {
  let #(buffer, reset) =
    keyboard.update_typeahead_buffer("ch", 1200, 2000, "a", 500)
  buffer |> should.equal("a")
  reset |> should.be_true
}

pub fn typeahead_buffer_exact_timeout_boundary_test() {
  let #(buffer, reset) =
    keyboard.update_typeahead_buffer("c", 1000, 1500, "h", 500)
  buffer |> should.equal("ch")
  reset |> should.be_false
}

pub fn typeahead_buffer_one_ms_over_timeout_test() {
  let #(buffer, reset) =
    keyboard.update_typeahead_buffer("c", 1000, 1501, "h", 500)
  buffer |> should.equal("h")
  reset |> should.be_true
}

pub fn typeahead_match_first_item_test() {
  let items = ["Apple", "Banana", "Cherry", "Date"]
  keyboard.typeahead_match(items, 0, "ap")
  |> should.equal(0)
}

pub fn typeahead_match_middle_item_test() {
  let items = ["Apple", "Banana", "Cherry", "Date"]
  keyboard.typeahead_match(items, 0, "ch")
  |> should.equal(2)
}

pub fn typeahead_match_last_item_test() {
  let items = ["Apple", "Banana", "Cherry", "Date"]
  keyboard.typeahead_match(items, 2, "da")
  |> should.equal(3)
}

pub fn typeahead_match_wraps_around_test() {
  let items = ["Apple", "Banana", "Cherry", "Date"]
  keyboard.typeahead_match(items, 3, "ap")
  |> should.equal(0)
}

pub fn typeahead_match_case_insensitive_test() {
  let items = ["Apple", "Banana", "Cherry", "Date"]
  keyboard.typeahead_match(items, 0, "CH")
  |> should.equal(2)
}

pub fn typeahead_match_no_match_stays_current_test() {
  let items = ["Apple", "Banana", "Cherry", "Date"]
  keyboard.typeahead_match(items, 2, "xyz")
  |> should.equal(2)
}

pub fn typeahead_match_empty_list_test() {
  let items: List(String) = []
  keyboard.typeahead_match(items, 0, "a")
  |> should.equal(0)
}

pub fn typeahead_match_partial_match_test() {
  let items = ["Application", "Apple", "Apricot", "Banana"]
  keyboard.typeahead_match(items, 0, "app")
  |> should.equal(1)
}

pub fn typeahead_match_finds_second_match_test() {
  let items = ["Application", "Apple", "Apricot", "Banana"]
  keyboard.typeahead_match(items, 0, "apr")
  |> should.equal(2)
}
