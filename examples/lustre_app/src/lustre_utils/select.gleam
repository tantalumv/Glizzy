// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful custom select component with keyboard navigation and type-ahead support.
////
//// Follows WAI-ARIA select pattern with arrow key navigation, type-ahead, and escape to close.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/select
////
//// let options = [("value1", "Option 1"), ("value2", "Option 2")]
//// let model = select.init(options, None)
//// let new_model = select.update(model, select.Open, current_time)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Select option with value and label.
pub type SelectOption {
  SelectOption(value: String, label: String, disabled: Bool)
}

/// Select model containing options, selection state, and type-ahead buffer.
pub type Model {
  Model(
    options: List(SelectOption),
    selected: Option(String),
    highlighted_index: Int,
    is_open: Bool,
    is_focused: Bool,
    typeahead_buffer: String,
    typeahead_timeout: Int,
    placeholder: String,
  )
}

/// Select messages for state updates.
pub type Msg {
  /// Focus the select
  Focus
  /// Blur the select
  Blur
  /// Open the dropdown
  Open
  /// Close the dropdown
  Close
  /// Toggle open/close
  Toggle
  /// Select a value
  Select(String)
  /// Move to next option (ArrowDown)
  MoveNext
  /// Move to previous option (ArrowUp)
  MovePrev
  /// Move to first option (Home)
  MoveFirst
  /// Move to last option (End)
  MoveLast
  /// Type-ahead character input
  TypeAhead(String)
  /// Set options
  SetOptions(List(SelectOption))
  /// Set selected value
  SetSelected(Option(String))
  /// Set placeholder text
  SetPlaceholder(String)
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a select model with options.
pub fn init(options: List(SelectOption), initial_value: Option(String)) -> Model {
  let initial_index = case initial_value {
    Some(val) -> index_of_value(options, val)
    None -> -1
  }
  Model(
    options: options,
    selected: initial_value,
    highlighted_index: initial_index,
    is_open: False,
    is_focused: False,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Select an option",
  )
}

/// Initialize with no initial selection.
pub fn init_empty(options: List(SelectOption)) -> Model {
  Model(
    options: options,
    selected: None,
    highlighted_index: -1,
    is_open: False,
    is_focused: False,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Select an option",
  )
}

/// Initialize with first option selected.
pub fn init_first(options: List(SelectOption)) -> Model {
  let initial = case options {
    [] -> None
    [first, ..] -> Some(first.value)
  }
  Model(
    options: options,
    selected: initial,
    highlighted_index: case initial { Some(_) -> 0 None -> -1 },
    is_open: False,
    is_focused: False,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Select an option",
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the select state based on a message.
pub fn update(model: Model, msg: Msg, current_time: Int) -> Model {
  let item_count = list.length(model.options)
  
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, highlighted_index: -1, is_open: False, typeahead_buffer: "")
    Open -> Model(..model, is_open: True, highlighted_index: get_first_enabled_index(model.options, model.highlighted_index))
    Close -> Model(..model, is_open: False, highlighted_index: get_highlighted_or_selected(model), typeahead_buffer: "")
    Toggle -> {
      // When toggling open, highlight the first option
      // When toggling closed, keep the current selection
      case model.is_open {
        False -> Model(..model, is_open: True, highlighted_index: get_first_enabled_index(model.options, model.highlighted_index))
        True -> Model(..model, is_open: False, highlighted_index: get_highlighted_or_selected(model), typeahead_buffer: "")
      }
    }
    Select(value) -> {
      // If value is empty, select the highlighted option (sentinel pattern for keyboard selection)
      let value_to_select = case string.is_empty(value) {
        True -> case option_at(model, model.highlighted_index) {
          Some(opt) -> opt.value
          None -> model.selected |> option.unwrap("")
        }
        False -> value
      }
      Model(
        ..model,
        selected: Some(value_to_select),
        is_open: False,
        highlighted_index: index_of_value(model.options, value_to_select),
        typeahead_buffer: "",
      )
    }
    MoveNext -> {
      let new_index = keyboard.next_index(model.highlighted_index, item_count, True)
      let wrapped_index = get_next_enabled_index(model.options, new_index)
      Model(..model, highlighted_index: wrapped_index, is_open: True, typeahead_buffer: "")
    }
    MovePrev -> {
      let new_index = keyboard.prev_index(model.highlighted_index, item_count, True)
      let wrapped_index = get_prev_enabled_index(model.options, new_index)
      Model(..model, highlighted_index: wrapped_index, is_open: True, typeahead_buffer: "")
    }
    MoveFirst -> {
      let new_index = keyboard.first_index(item_count)
      let enabled_index = get_first_enabled_index(model.options, new_index)
      Model(..model, highlighted_index: enabled_index, is_open: True, typeahead_buffer: "")
    }
    MoveLast -> {
      let new_index = keyboard.last_index(item_count)
      let enabled_index = get_last_enabled_index(model.options, new_index)
      Model(..model, highlighted_index: enabled_index, is_open: True, typeahead_buffer: "")
    }
    TypeAhead(char) -> {
      let #(new_buffer, _reset) = keyboard.update_typeahead_buffer(
        model.typeahead_buffer,
        model.typeahead_timeout,
        current_time,
        char,
        keyboard.default_typeahead_timeout_ms,
      )
      let new_index = keyboard.typeahead_match(get_labels(model.options), model.highlighted_index, new_buffer)
      Model(
        ..model,
        highlighted_index: new_index,
        is_open: True,
        typeahead_buffer: new_buffer,
        typeahead_timeout: current_time,
      )
    }
    SetOptions(new_options) -> {
      let new_index = case model.selected {
        Some(val) -> index_of_value(new_options, val)
        None -> -1
      }
      Model(..model, options: new_options, highlighted_index: new_index)
    }
    SetSelected(value) -> Model(..model, selected: value)
    SetPlaceholder(placeholder) -> Model(..model, placeholder: placeholder)
  }
}

/// Find the index of a value in options.
fn index_of_value(options: List(SelectOption), value: String) -> Int {
  case options {
    [] -> -1
    [opt, ..rest] if opt.value == value -> 0
    [_opt, ..rest] -> 1 + index_of_value(rest, value)
  }
}

/// Get option labels as a list.
fn get_labels(options: List(SelectOption)) -> List(String) {
  list.map(options, fn(opt) { opt.label })
}

/// Get the next enabled option index.
fn get_next_enabled_index(options: List(SelectOption), start: Int) -> Int {
  let len = list.length(options)
  case len == 0 {
    True -> -1
    False -> {
      let index = start % len
      case get_at(options, index) {
        Some(opt) if !opt.disabled -> index
        _ -> get_next_enabled_index(options, start + 1)
      }
    }
  }
}

/// Get the previous enabled option index.
fn get_prev_enabled_index(options: List(SelectOption), start: Int) -> Int {
  let len = list.length(options)
  case len == 0 {
    True -> -1
    False -> {
      let index = { start % len + len } % len
      case get_at(options, index) {
        Some(opt) if !opt.disabled -> index
        _ -> get_prev_enabled_index(options, start - 1)
      }
    }
  }
}

/// Get the first enabled option index.
fn get_first_enabled_index(options: List(SelectOption), _start: Int) -> Int {
  case options {
    [] -> -1
    [opt, ..rest] -> find_first_enabled(options, 0)
  }
}

fn find_first_enabled(options: List(SelectOption), index: Int) -> Int {
  case options {
    [] -> -1
    [opt, ..rest] -> {
      case !opt.disabled {
        True -> index
        False -> find_first_enabled(rest, index + 1)
      }
    }
  }
}

/// Get the last enabled option index.
fn get_last_enabled_index(options: List(SelectOption), _start: Int) -> Int {
  let reversed = options |> list.reverse
  let len = list.length(options)
  case find_first_enabled(reversed, 0) {
    -1 -> -1
    idx -> len - 1 - idx
  }
}

/// Get highlighted index or selected index.
fn get_highlighted_or_selected(model: Model) -> Int {
  case model.highlighted_index {
    -1 -> index_of_value(model.options, model.selected |> option.unwrap(""))
    idx -> idx
  }
}

fn get_at(options: List(SelectOption), index: Int) -> Option(SelectOption) {
  case options {
    [] -> None
    [opt, ..rest] -> {
      case index == 0 {
        True -> Some(opt)
        False -> get_at(rest, index - 1)
      }
    }
  }
}

// ============================================================================
// Getters
// ============================================================================

/// Get the selected value.
pub fn selected(model: Model) -> Option(String) {
  model.selected
}

/// Get the selected label.
pub fn selected_label(model: Model) -> Option(String) {
  case model.selected {
    Some(val) -> {
      case find_option(model.options, val) {
        Some(opt) -> Some(opt.label)
        None -> None
      }
    }
    None -> None
  }
}

/// Get the highlighted index.
pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

/// Check if an option is selected.
pub fn is_selected(model: Model, value: String) -> Bool {
  case model.selected {
    Some(v) -> v == value
    None -> False
  }
}

/// Check if an option is highlighted.
pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Check if the select is open.
pub fn is_open(model: Model) -> Bool {
  model.is_open
}

/// Check if the select is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the options list.
pub fn options(model: Model) -> List(SelectOption) {
  model.options
}

/// Get the option at a specific index.
pub fn option_at(model: Model, index: Int) -> Option(SelectOption) {
  get_at(model.options, index)
}

/// Get the placeholder text.
pub fn placeholder(model: Model) -> String {
  model.placeholder
}

/// Get the display text (selected label or placeholder).
pub fn display_text(model: Model) -> String {
  case selected_label(model) {
    Some(label) -> label
    None -> model.placeholder
  }
}

fn find_option(options: List(SelectOption), value: String) -> Option(SelectOption) {
  case options {
    [] -> None
    [opt, ..rest] -> {
      case opt.value == value {
        True -> Some(opt)
        False -> find_option(rest, value)
      }
    }
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for select keyboard navigation.
/// Follows WAI-ARIA select pattern:
/// - ArrowDown: Open and move to next option
/// - ArrowUp: Open and move to previous option
/// - Home: Move to first option
/// - End: Move to last option
/// - Enter/Space: Select the highlighted option
/// - Escape: Close without selecting
/// - Character keys: Type-ahead to find option
pub fn keymap(key_event: keyboard.KeyEvent, is_open: Bool) -> Option(Msg) {
  case keyboard.decode_key(key_event.key), is_open {
    keyboard.ArrowDown, _ -> Some(MoveNext)
    keyboard.ArrowUp, _ -> Some(MovePrev)
    keyboard.Home, _ -> Some(MoveFirst)
    keyboard.End, _ -> Some(MoveLast)
    keyboard.Enter, True -> Some(Select(""))
    keyboard.Space, True -> Some(Select(""))
    keyboard.Enter, False -> Some(Open)
    keyboard.Space, False -> Some(Open)
    keyboard.Escape, True -> Some(Close)
    keyboard.Character(c), _ -> Some(TypeAhead(c))
    _, _ -> None
  }
}

/// Get the element ID for an option at the given index.
pub fn option_element_id(index: Int) -> String {
  "select-option-" <> int.to_string(index)
}

/// Get the element ID for the select trigger.
pub fn trigger_element_id() -> String {
  "select-trigger"
}

/// Get the element ID for the select listbox.
pub fn listbox_element_id() -> String {
  "select-listbox"
}

// ============================================================================
// Option Builders
// ============================================================================

/// Create a select option.
pub fn option(value: String, label: String) -> SelectOption {
  SelectOption(value: value, label: label, disabled: False)
}

/// Create a disabled select option.
pub fn disabled_option(value: String, label: String) -> SelectOption {
  SelectOption(value: value, label: label, disabled: True)
}
