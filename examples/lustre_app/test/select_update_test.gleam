// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Test select update handler, especially the Select("") sentinel pattern

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/select as select_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn select_update_select_empty_string_uses_highlighted_option_test() {
  let options = [
    select_utils.option("react", "React"),
    select_utils.option("vue", "Vue"),
    select_utils.option("svelte", "Svelte"),
  ]
  // Model with highlighted_index = 1 (Vue), but no selected value
  let model = select_utils.Model(
    options: options,
    selected: None,
    highlighted_index: 1,
    is_open: True,
    is_focused: True,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Select an option",
  )

  // Select with empty string (sentinel pattern from keyboard Enter/Space)
  let new_model = select_utils.update(model, select_utils.Select(""), 0)

  // Should select the highlighted option (Vue)
  new_model.selected
  |> should.equal(Some("vue"))
  new_model.is_open
  |> should.equal(False)
}

pub fn select_update_select_empty_string_with_no_highlighted_test() {
  let options = [
    select_utils.option("react", "React"),
    select_utils.option("vue", "Vue"),
  ]
  // Model with highlighted_index = -1 (nothing highlighted)
  let model = select_utils.Model(
    options: options,
    selected: Some("react"),
    highlighted_index: -1,
    is_open: True,
    is_focused: True,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Select an option",
  )

  // Select with empty string when nothing is highlighted
  let new_model = select_utils.update(model, select_utils.Select(""), 0)

  // Should keep the existing selection
  new_model.selected
  |> should.equal(Some("react"))
}

pub fn select_update_select_with_value_test() {
  let options = [
    select_utils.option("react", "React"),
    select_utils.option("vue", "Vue"),
  ]
  let model = select_utils.init_empty(options)

  // Select with explicit value
  let new_model = select_utils.update(model, select_utils.Select("vue"), 0)

  // Should select the specified value
  new_model.selected
  |> should.equal(Some("vue"))
  new_model.is_open
  |> should.equal(False)
}

pub fn select_update_open_sets_highlighted_to_first_enabled_test() {
  let options = [
    select_utils.option("react", "React"),
    select_utils.option("vue", "Vue"),
    select_utils.option("svelte", "Svelte"),
  ]
  let model = select_utils.init_empty(options)

  // Open the dropdown
  let new_model = select_utils.update(model, select_utils.Open, 0)

  // Should set highlighted_index to first option (0)
  new_model.highlighted_index
  |> should.equal(0)
  new_model.is_open
  |> should.equal(True)
}
