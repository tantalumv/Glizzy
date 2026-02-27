// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful radio group component with keyboard navigation support.
////
//// Follows WAI-ARIA radio group pattern with roving tabindex and arrow key navigation.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/radio_group
////
//// let options = ["option1", "option2", "option3"]
//// let model = radio_group.init(options, "option1")
//// let new_model = radio_group.update(model, radio_group.MoveNext)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Radio group model containing selected value and navigation state.
pub type Model {
  Model(
    selected_value: Option(String),
    highlighted_index: Int,
    is_focused: Bool,
    options: List(String),
  )
}

/// Radio group messages for state updates.
pub type Msg {
  /// Focus the radio group
  Focus
  /// Blur the radio group
  Blur
  /// Select a radio button by value
  Select(String)
  /// Move to next radio button (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous radio button (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first radio button (Home)
  MoveFirst
  /// Move to last radio button (End)
  MoveLast
  /// Set the options list
  SetOptions(List(String))
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a radio group model with options and initial selection.
pub fn init(options: List(String), initial_value: Option(String)) -> Model {
  let initial_index = case initial_value {
    Some(val) -> index_of(options, val)
    None -> 0
  }
  Model(
    selected_value: initial_value,
    highlighted_index: initial_index,
    is_focused: False,
    options: options,
  )
}

/// Initialize a radio group with no initial selection.
pub fn init_empty(options: List(String)) -> Model {
  Model(
    selected_value: None,
    highlighted_index: 0,
    is_focused: False,
    options: options,
  )
}

/// Initialize a radio group with the first option selected.
pub fn init_first(options: List(String)) -> Model {
  let initial = case options {
    [] -> None
    [first, ..] -> Some(first)
  }
  Model(
    selected_value: initial,
    highlighted_index: 0,
    is_focused: False,
    options: options,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the radio group state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  let item_count = list.length(model.options)

  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, highlighted_index: -1)
    Select(value) -> {
      // If value is empty, select the highlighted option
      let selected_value = case string.is_empty(value) {
        True -> get_at(model.options, model.highlighted_index)
        False -> Some(value)
      }
      let index = case selected_value {
        Some(v) -> index_of(model.options, v)
        None -> model.highlighted_index
      }
      Model(..model, selected_value: selected_value, highlighted_index: index)
    }
    MoveNext -> {
      let new_index = keyboard.next_index(model.highlighted_index, item_count, True)
      let new_value = get_at(model.options, new_index)
      Model(..model, highlighted_index: new_index, selected_value: new_value)
    }
    MovePrev -> {
      let new_index = keyboard.prev_index(model.highlighted_index, item_count, True)
      let new_value = get_at(model.options, new_index)
      Model(..model, highlighted_index: new_index, selected_value: new_value)
    }
    MoveFirst -> {
      let new_index = keyboard.first_index(item_count)
      let new_value = get_at(model.options, new_index)
      Model(..model, highlighted_index: new_index, selected_value: new_value)
    }
    MoveLast -> {
      let new_index = keyboard.last_index(item_count)
      let new_value = get_at(model.options, new_index)
      Model(..model, highlighted_index: new_index, selected_value: new_value)
    }
    SetOptions(new_options) -> {
      let new_index = case model.selected_value {
        Some(val) -> index_of(new_options, val)
        None -> 0
      }
      Model(..model, options: new_options, highlighted_index: new_index)
    }
  }
}

/// Find the index of a value in a list.
fn index_of(items: List(String), value: String) -> Int {
  case items {
    [] -> 0
    [x, ..rest] if x == value -> 0
    [_x, ..rest] -> 1 + index_of(rest, value)
  }
}

/// Get the value at an index.
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
// Getters
// ============================================================================

/// Get the selected value.
pub fn selected_value(model: Model) -> Option(String) {
  model.selected_value
}

/// Get the highlighted index.
pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

/// Check if an option is selected.
pub fn is_selected(model: Model, value: String) -> Bool {
  case model.selected_value {
    Some(v) -> v == value
    None -> False
  }
}

/// Check if an option is highlighted.
pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Check if the radio group is focused.
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

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for radio group keyboard navigation.
/// Follows WAI-ARIA radio group pattern:
/// - ArrowRight/ArrowDown: Move to next radio button (wraps)
/// - ArrowLeft/ArrowUp: Move to previous radio button (wraps)
/// - Home: Move to first radio button
/// - End: Move to last radio button
/// - Space: Select the currently focused radio button
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Space -> Some(Select(""))
    _ -> None
  }
}

/// Get the element ID for a radio button at the given index.
pub fn radio_element_id(index: Int) -> String {
  "radio-" <> int.to_string(index)
}

/// Get the element ID for the radio group.
pub fn group_element_id() -> String {
  "radio-group"
}
