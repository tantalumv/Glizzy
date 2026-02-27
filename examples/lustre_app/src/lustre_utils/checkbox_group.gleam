// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful checkbox group component with keyboard navigation support.
////
//// Follows WAI-ARIA checkbox group pattern with roving tabindex and arrow key navigation.
//// Allows multiple checkboxes to be checked independently.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/checkbox_group
////
//// let options = ["option1", "option2", "option3"]
//// let model = checkbox_group.init(options, ["option1"])
//// let new_model = checkbox_group.update(model, checkbox_group.MoveNext)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Checkbox group model containing checked values and navigation state.
pub type Model {
  Model(
    checked_values: List(String),
    highlighted_index: Int,
    is_focused: Bool,
    options: List(String),
  )
}

/// Checkbox group messages for state updates.
pub type Msg {
  /// Focus the checkbox group
  Focus
  /// Blur the checkbox group
  Blur
  /// Toggle a checkbox by value
  Toggle(String)
  /// Move to next checkbox (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous checkbox (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first checkbox (Home)
  MoveFirst
  /// Move to last checkbox (End)
  MoveLast
  /// Set the options list
  SetOptions(List(String))
  /// Check all checkboxes
  CheckAll
  /// Uncheck all checkboxes
  UncheckAll
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a checkbox group model with options and initial checked values.
pub fn init(options: List(String), initial_checked: List(String)) -> Model {
  Model(
    checked_values: initial_checked,
    highlighted_index: 0,
    is_focused: False,
    options: options,
  )
}

/// Initialize a checkbox group with no initial checked values.
pub fn init_empty(options: List(String)) -> Model {
  Model(
    checked_values: [],
    highlighted_index: 0,
    is_focused: False,
    options: options,
  )
}

/// Initialize a checkbox group with all options checked.
pub fn init_all_checked(options: List(String)) -> Model {
  Model(
    checked_values: options,
    highlighted_index: 0,
    is_focused: False,
    options: options,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the checkbox group state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  let item_count = list.length(model.options)

  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, highlighted_index: -1)
    Toggle(value) -> {
      // If value is empty, toggle the highlighted option
      let value_to_toggle = case string.is_empty(value) {
        True -> get_at(model.options, model.highlighted_index) |> option.unwrap("")
        False -> value
      }
      let new_checked = toggle_item(model.checked_values, value_to_toggle)
      Model(..model, checked_values: new_checked)
    }
    MoveNext -> {
      let new_index = keyboard.next_index(model.highlighted_index, item_count, True)
      Model(..model, highlighted_index: new_index)
    }
    MovePrev -> {
      let new_index = keyboard.prev_index(model.highlighted_index, item_count, True)
      Model(..model, highlighted_index: new_index)
    }
    MoveFirst -> {
      let new_index = keyboard.first_index(item_count)
      Model(..model, highlighted_index: new_index)
    }
    MoveLast -> {
      let new_index = keyboard.last_index(item_count)
      Model(..model, highlighted_index: new_index)
    }
    SetOptions(new_options) -> {
      // Filter checked values to only include valid options
      let new_checked = list.filter(model.checked_values, fn(v) {
        list.contains(new_options, v)
      })
      Model(..model, options: new_options, checked_values: new_checked)
    }
    CheckAll -> Model(..model, checked_values: model.options)
    UncheckAll -> Model(..model, checked_values: [])
  }
}

/// Toggle a value in the checked list.
fn toggle_item(items: List(String), value: String) -> List(String) {
  case list.contains(items, value) {
    True -> list.filter(items, fn(v) { v != value })
    False -> [value, ..items]
  }
}

// ============================================================================
// Getters
// ============================================================================

/// Get the checked values.
pub fn checked_values(model: Model) -> List(String) {
  model.checked_values
}

/// Get the highlighted index.
pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

/// Check if a value is checked.
pub fn is_checked(model: Model, value: String) -> Bool {
  list.contains(model.checked_values, value)
}

/// Check if a value is highlighted.
pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Check if the checkbox group is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the options list.
pub fn options(model: Model) -> List(String) {
  model.options
}

/// Get the option at a specific index.
pub fn option_at(model: Model, index: Int) -> Option(String) {
  get_at(model.options, index)
}

/// Get the tabindex for an option (roving tabindex pattern).
pub fn tabindex_for(model: Model, index: Int) -> Int {
  case model.highlighted_index == index {
    True -> 0
    False -> -1
  }
}

/// Check if all options are checked.
pub fn all_checked(model: Model) -> Bool {
  list.length(model.checked_values) == list.length(model.options)
  && model.options != []
}

/// Check if some options are checked (indeterminate state).
pub fn some_checked(model: Model) -> Bool {
  let checked_count = list.length(model.checked_values)
  let total_count = list.length(model.options)
  checked_count > 0 && checked_count < total_count
}

/// Get the number of checked options.
pub fn checked_count(model: Model) -> Int {
  list.length(model.checked_values)
}

fn get_at(items: List(String), index: Int) -> Option(String) {
  case items {
    [] -> None
    [x, ..rest] -> {
      case index == 0 {
        True -> Some(x)
        False -> get_at(rest, index - 1)
      }
    }
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for checkbox group keyboard navigation.
/// Follows WAI-ARIA checkbox group pattern:
/// - ArrowRight/ArrowDown: Move to next checkbox
/// - ArrowLeft/ArrowUp: Move to previous checkbox
/// - Home: Move to first checkbox
/// - End: Move to last checkbox
/// - Space/Enter: Toggle the currently focused checkbox
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Space | keyboard.Enter -> Some(Toggle(""))
    _ -> None
  }
}

/// Get the element ID for a checkbox at the given index.
pub fn checkbox_element_id(index: Int) -> String {
  "checkbox-" <> int.to_string(index)
}

/// Get the element ID for the checkbox group.
pub fn group_element_id() -> String {
  "checkbox-group"
}
