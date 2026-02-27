// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Test combobox update handler, especially Select preserving highlighted_index

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/combobox as combobox_utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn combobox_update_select_preserves_highlighted_index_test() {
  let options = [
    combobox_utils.option("apple", "Apple"),
    combobox_utils.option("banana", "Banana"),
    combobox_utils.option("cherry", "Cherry"),
  ]
  let _model = combobox_utils.init_empty(options)

  // Simulate navigating to index 1 (Banana) and selecting
  let model_with_highlight = combobox_utils.Model(
    options: options,
    filtered_options: options,
    selected: None,
    input_value: "",
    highlighted_index: 1,
    is_open: True,
    is_focused: True,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Type to search...",
    allow_custom_value: True,
  )

  // Select the highlighted option
  let new_model = combobox_utils.update(model_with_highlight, combobox_utils.SelectHighlighted, 0)

  // Should select banana and preserve highlighted_index
  new_model.selected
  |> should.equal(Some("banana"))
  new_model.is_open
  |> should.equal(False)
  // highlighted_index should NOT be -1, should be 1 (the selected option's index)
  new_model.highlighted_index
  |> should.equal(1)
}

pub fn combobox_update_select_highlighted_test() {
  let options = [
    combobox_utils.option("apple", "Apple"),
    combobox_utils.option("banana", "Banana"),
  ]
  let _model = combobox_utils.init_empty(options)

  // Set highlighted to index 1
  let model_with_highlight = combobox_utils.Model(
    options: options,
    filtered_options: options,
    selected: None,
    input_value: "",
    highlighted_index: 1,
    is_open: True,
    is_focused: True,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Type to search...",
    allow_custom_value: True,
  )

  // Use SelectHighlighted message
  let new_model = combobox_utils.update(model_with_highlight, combobox_utils.SelectHighlighted, 0)

  // Should select the highlighted option
  new_model.selected
  |> should.equal(Some("banana"))
}

pub fn combobox_update_move_next_sets_highlighted_test() {
  let options = [
    combobox_utils.option("apple", "Apple"),
    combobox_utils.option("banana", "Banana"),
    combobox_utils.option("cherry", "Cherry"),
  ]
  let model = combobox_utils.init_empty(options)

  // Open and move next
  let model_opened = combobox_utils.update(model, combobox_utils.Open, 0)
  let new_model = combobox_utils.update(model_opened, combobox_utils.MoveNext, 0)

  // Should move to next option
  new_model.highlighted_index
  |> should.equal(1)
  new_model.is_open
  |> should.equal(True)
}

pub fn combobox_update_input_change_filters_options_test() {
  let options = [
    combobox_utils.option("apple", "Apple"),
    combobox_utils.option("banana", "Banana"),
    combobox_utils.option("cherry", "Cherry"),
  ]
  let model = combobox_utils.init_empty(options)

  // Type "ap" to filter
  let new_model = combobox_utils.update(model, combobox_utils.InputChange("ap"), 0)

  // Should filter to only apple
  new_model.filtered_options
  |> should.equal([combobox_utils.ComboboxOption("apple", "Apple", False)])
  new_model.is_open
  |> should.equal(True)
}
