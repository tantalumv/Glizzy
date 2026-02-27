// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful combobox component with keyboard navigation, filtering, and type-ahead support.
////
//// Follows WAI-ARIA combobox pattern with arrow key navigation, input filtering, and escape to close.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/combobox
////
//// let options = [("value1", "Option 1"), ("value2", "Option 2")]
//// let model = combobox.init(options, "")
//// let new_model = combobox.update(model, combobox.Open, current_time)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Combobox option with value and label.
pub type ComboboxOption {
  ComboboxOption(value: String, label: String, disabled: Bool)
}

/// Combobox model containing options, input value, and type-ahead buffer.
pub type Model {
  Model(
    options: List(ComboboxOption),
    filtered_options: List(ComboboxOption),
    selected: Option(String),
    input_value: String,
    highlighted_index: Int,
    is_open: Bool,
    is_focused: Bool,
    typeahead_buffer: String,
    typeahead_timeout: Int,
    placeholder: String,
    allow_custom_value: Bool,
  )
}

/// Combobox messages for state updates.
pub type Msg {
  /// Focus the combobox
  Focus
  /// Blur the combobox
  Blur
  /// Open the dropdown
  Open
  /// Close the dropdown
  Close
  /// Toggle open/close
  Toggle
  /// Select a value
  Select(String)
  /// Select the highlighted option
  SelectHighlighted
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
  /// Input value changed
  InputChange(String)
  /// Set options
  SetOptions(List(ComboboxOption))
  /// Set selected value
  SetSelected(Option(String))
  /// Set placeholder text
  SetPlaceholder(String)
  /// Set allow custom value
  SetAllowCustomValue(Bool)
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a combobox model with options.
pub fn init(options: List(ComboboxOption), initial_value: String) -> Model {
  let filtered = filter_options(options, initial_value)
  let initial_index = case initial_value {
    "" -> -1
    _ -> index_of_value(filtered, initial_value)
  }
  Model(
    options: options,
    filtered_options: filtered,
    selected: None,
    input_value: initial_value,
    highlighted_index: initial_index,
    is_open: False,
    is_focused: False,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Type to search...",
    allow_custom_value: True,
  )
}

/// Initialize with no initial value.
pub fn init_empty(options: List(ComboboxOption)) -> Model {
  Model(
    options: options,
    filtered_options: options,
    selected: None,
    input_value: "",
    highlighted_index: -1,
    is_open: False,
    is_focused: False,
    typeahead_buffer: "",
    typeahead_timeout: 0,
    placeholder: "Type to search...",
    allow_custom_value: True,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the combobox state based on a message.
pub fn update(model: Model, msg: Msg, current_time: Int) -> Model {
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, highlighted_index: -1, is_open: False, typeahead_buffer: "")
    Open -> Model(..model, is_open: True, highlighted_index: get_first_enabled_index(model.filtered_options, 0))
    Close -> Model(..model, is_open: False, highlighted_index: -1, typeahead_buffer: "")
    Toggle -> Model(..model, is_open: !model.is_open)
    Select(value) -> {
      let label = get_label_for_value(model.filtered_options, value)
      Model(
        ..model,
        selected: Some(value),
        input_value: label |> option.unwrap(value),
        is_open: False,
        highlighted_index: index_of_value(model.filtered_options, value),
        typeahead_buffer: "",
      )
    }
    SelectHighlighted -> {
      case option_at(model, model.highlighted_index) {
        Some(opt) -> update(model, Select(opt.value), current_time)
        None -> model
      }
    }
    MoveNext -> {
      let item_count = list.length(model.filtered_options)
      let new_index = keyboard.next_index(model.highlighted_index, item_count, True)
      let wrapped_index = get_next_enabled_index(model.filtered_options, new_index)
      Model(..model, highlighted_index: wrapped_index, is_open: True, typeahead_buffer: "")
    }
    MovePrev -> {
      let item_count = list.length(model.filtered_options)
      let new_index = keyboard.prev_index(model.highlighted_index, item_count, True)
      let wrapped_index = get_prev_enabled_index(model.filtered_options, new_index)
      Model(..model, highlighted_index: wrapped_index, is_open: True, typeahead_buffer: "")
    }
    MoveFirst -> {
      let new_index = keyboard.first_index(list.length(model.filtered_options))
      let enabled_index = get_first_enabled_index(model.filtered_options, new_index)
      Model(..model, highlighted_index: enabled_index, is_open: True, typeahead_buffer: "")
    }
    MoveLast -> {
      let new_index = keyboard.last_index(list.length(model.filtered_options))
      let enabled_index = get_last_enabled_index(model.filtered_options, new_index)
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
      let new_index = keyboard.typeahead_match(get_labels(model.filtered_options), model.highlighted_index, new_buffer)
      Model(
        ..model,
        highlighted_index: new_index,
        is_open: True,
        typeahead_buffer: new_buffer,
        typeahead_timeout: current_time,
      )
    }
    InputChange(value) -> {
      let filtered = filter_options(model.options, value)
      let is_match = is_exact_match(filtered, value)
      let new_selected = case is_match {
        True -> Some(get_value_for_label(filtered, value) |> option.unwrap(value))
        False -> None
      }
      Model(
        ..model,
        input_value: value,
        filtered_options: filtered,
        selected: new_selected,
        is_open: True,
        highlighted_index: case filtered { [] -> -1 _ -> 0 },
        typeahead_buffer: "",
      )
    }
    SetOptions(new_options) -> {
      let filtered = filter_options(new_options, model.input_value)
      Model(..model, options: new_options, filtered_options: filtered)
    }
    SetSelected(value) -> {
      let label = case value {
        Some(v) -> get_label_for_value(model.options, v)
        None -> None
      }
      Model(
        ..model,
        selected: value,
        input_value: label |> option.unwrap(model.input_value),
      )
    }
    SetPlaceholder(placeholder) -> Model(..model, placeholder: placeholder)
    SetAllowCustomValue(allow) -> Model(..model, allow_custom_value: allow)
  }
}

/// Filter options by input value (case-insensitive contains match).
fn filter_options(options: List(ComboboxOption), value: String) -> List(ComboboxOption) {
  let normalized_value = string.lowercase(value)
  case string.is_empty(normalized_value) {
    True -> options
    False -> {
      list.filter(options, fn(opt) {
        string.contains(string.lowercase(opt.label), normalized_value)
      })
    }
  }
}

/// Check if there's an exact match for the value.
fn is_exact_match(options: List(ComboboxOption), value: String) -> Bool {
  list.any(options, fn(opt) {
    string.lowercase(opt.label) == string.lowercase(value)
    || string.lowercase(opt.value) == string.lowercase(value)
  })
}

/// Find the index of a value in options.
fn index_of_value(options: List(ComboboxOption), value: String) -> Int {
  case options {
    [] -> -1
    [opt, ..rest] if opt.value == value -> 0
    [_opt, ..rest] -> 1 + index_of_value(rest, value)
  }
}

/// Get option labels as a list.
fn get_labels(options: List(ComboboxOption)) -> List(String) {
  list.map(options, fn(opt) { opt.label })
}

/// Get the next enabled option index.
fn get_next_enabled_index(options: List(ComboboxOption), start: Int) -> Int {
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
fn get_prev_enabled_index(options: List(ComboboxOption), start: Int) -> Int {
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
fn get_first_enabled_index(options: List(ComboboxOption), _start: Int) -> Int {
  case options {
    [] -> -1
    [_opt, ..] -> find_first_enabled(options, 0)
  }
}

fn find_first_enabled(options: List(ComboboxOption), index: Int) -> Int {
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
fn get_last_enabled_index(options: List(ComboboxOption), _start: Int) -> Int {
  let reversed = options |> list.reverse
  let len = list.length(options)
  case find_first_enabled(reversed, 0) {
    -1 -> -1
    idx -> len - 1 - idx
  }
}

/// Get label for a value.
fn get_label_for_value(options: List(ComboboxOption), value: String) -> Option(String) {
  case find_option(options, value) {
    Some(opt) -> Some(opt.label)
    None -> None
  }
}

/// Get value for a label.
fn get_value_for_label(options: List(ComboboxOption), label: String) -> Option(String) {
  case list.find(options, fn(opt) { string.lowercase(opt.label) == string.lowercase(label) }) {
    Ok(opt) -> Some(opt.value)
    Error(_) -> None
  }
}

fn get_at(options: List(ComboboxOption), index: Int) -> Option(ComboboxOption) {
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

fn find_option(options: List(ComboboxOption), value: String) -> Option(ComboboxOption) {
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
// Getters
// ============================================================================

/// Get the selected value.
pub fn selected(model: Model) -> Option(String) {
  model.selected
}

/// Get the input value.
pub fn input_value(model: Model) -> String {
  model.input_value
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

/// Check if the combobox is open.
pub fn is_open(model: Model) -> Bool {
  model.is_open
}

/// Check if the combobox is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get all options.
pub fn options(model: Model) -> List(ComboboxOption) {
  model.options
}

/// Get filtered options.
pub fn filtered_options(model: Model) -> List(ComboboxOption) {
  model.filtered_options
}

/// Get the option at a specific index from filtered options.
pub fn option_at(model: Model, index: Int) -> Option(ComboboxOption) {
  get_at(model.filtered_options, index)
}

/// Get the placeholder text.
pub fn placeholder(model: Model) -> String {
  model.placeholder
}

/// Check if custom values are allowed.
pub fn allows_custom_value(model: Model) -> Bool {
  model.allow_custom_value
}

/// Check if there are no filtered results.
pub fn has_no_results(model: Model) -> Bool {
  model.filtered_options == []
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for combobox keyboard navigation.
/// Follows WAI-ARIA combobox pattern:
/// - ArrowDown: Open and move to next option
/// - ArrowUp: Open and move to previous option
/// - Home: Move to first option
/// - End: Move to last option
/// - Enter/Space: Select the highlighted option (when open)
/// - Escape: Close without selecting
/// - Character keys: Type-ahead and filter
/// - Tab: Pass through (don't intercept - allows focus to move)
pub fn keymap(key_event: keyboard.KeyEvent, is_open: Bool) -> Option(Msg) {
  case keyboard.decode_key(key_event.key), is_open {
    keyboard.Tab, _ -> None  // Explicitly don't handle Tab (let it pass through)
    keyboard.ArrowDown, False -> Some(Open)
    keyboard.ArrowDown, True -> Some(MoveNext)
    keyboard.ArrowUp, _ -> Some(MovePrev)
    keyboard.Home, _ -> Some(MoveFirst)
    keyboard.End, _ -> Some(MoveLast)
    keyboard.Enter, True -> Some(SelectHighlighted)
    keyboard.Space, True -> Some(SelectHighlighted)
    keyboard.Escape, True -> Some(Close)
    keyboard.Character(c), _ -> Some(InputChange(c))
    _, _ -> None
  }
}

/// Get the element ID for an option at the given index.
pub fn option_element_id(index: Int) -> String {
  "combobox-option-" <> int.to_string(index)
}

/// Get the element ID for the combobox input.
pub fn input_element_id() -> String {
  "combobox-input"
}

/// Get the element ID for the combobox listbox.
pub fn listbox_element_id() -> String {
  "combobox-listbox"
}

// ============================================================================
// Option Builders
// ============================================================================

/// Create a combobox option.
pub fn option(value: String, label: String) -> ComboboxOption {
  ComboboxOption(value: value, label: label, disabled: False)
}

/// Create a disabled combobox option.
pub fn disabled_option(value: String, label: String) -> ComboboxOption {
  ComboboxOption(value: value, label: label, disabled: True)
}
