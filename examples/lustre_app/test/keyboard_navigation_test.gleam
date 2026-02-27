// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleeunit
import gleeunit/should
import lustre_utils/keyboard

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn next_index_wraps_test() {
  keyboard.next_index(2, 5, True)
  |> should.equal(3)
}

pub fn next_index_wraps_to_start_test() {
  keyboard.next_index(4, 5, True)
  |> should.equal(0)
}

pub fn next_index_no_wrap_at_end_test() {
  keyboard.next_index(4, 5, False)
  |> should.equal(4)
}

pub fn next_index_no_wrap_middle_test() {
  keyboard.next_index(2, 5, False)
  |> should.equal(3)
}

pub fn next_index_zero_count_test() {
  keyboard.next_index(0, 0, True)
  |> should.equal(0)
}

pub fn prev_index_wraps_test() {
  keyboard.prev_index(2, 5, True)
  |> should.equal(1)
}

pub fn prev_index_wraps_to_end_test() {
  keyboard.prev_index(0, 5, True)
  |> should.equal(4)
}

pub fn prev_index_no_wrap_at_start_test() {
  keyboard.prev_index(0, 5, False)
  |> should.equal(0)
}

pub fn prev_index_no_wrap_middle_test() {
  keyboard.prev_index(2, 5, False)
  |> should.equal(1)
}

pub fn prev_index_zero_count_test() {
  keyboard.prev_index(0, 0, True)
  |> should.equal(0)
}

pub fn first_index_test() {
  keyboard.first_index(5)
  |> should.equal(0)
}

pub fn first_index_zero_count_test() {
  keyboard.first_index(0)
  |> should.equal(0)
}

pub fn last_index_test() {
  keyboard.last_index(5)
  |> should.equal(4)
}

pub fn last_index_single_item_test() {
  keyboard.last_index(1)
  |> should.equal(0)
}

pub fn last_index_zero_count_test() {
  keyboard.last_index(0)
  |> should.equal(0)
}
