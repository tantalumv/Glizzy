// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful toggle button group component with keyboard navigation support.
////
//// Follows WAI-ARIA toggle button group pattern with roving tabindex and arrow key navigation.
//// Supports single-select and multi-select modes.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/toggle_button_group
////
//// let buttons = ["Bold", "Italic", "Underline"]
//// let model = toggle_button_group.init(buttons, ["Bold"])
//// let new_model = toggle_button_group.update(model, toggle_button_group.MoveNext)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/effect.{type Effect}
import lustre_utils/keyboard as keyboard
import lustre_utils/interactions/focus

// ============================================================================
// Types
// ============================================================================

/// Toggle button group model containing toggled states and navigation state.
pub type Model {
  Model(
    toggled_indices: List(Int),
    highlighted_index: Int,
    is_focused: Bool,
    button_count: Int,
    multi_select: Bool,
  )
}

/// Toggle button group messages for state updates.
pub type Msg {
  /// Focus the toggle button group
  Focus
  /// Blur the toggle button group
  Blur
  /// Toggle a button by index
  Toggle(Int)
  /// Move to next button (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous button (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first button (Home)
  MoveFirst
  /// Move to last button (End)
  MoveLast
  /// Set the button count
  SetButtonCount(Int)
  /// Set multi-select mode
  SetMultiSelect(Bool)
  /// Toggle all buttons
  ToggleAll
  /// Clear all toggles
  ClearAll
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a toggle button group model with button count.
pub fn init(button_count: Int, multi_select: Bool) -> Model {
  Model(
    toggled_indices: [],
    highlighted_index: 0,
    is_focused: False,
    button_count: button_count,
    multi_select: multi_select,
  )
}

/// Initialize with specific buttons toggled.
pub fn init_with_toggled(button_count: Int, toggled: List(Int), multi_select: Bool) -> Model {
  Model(
    toggled_indices: toggled,
    highlighted_index: 0,
    is_focused: False,
    button_count: button_count,
    multi_select: multi_select,
  )
}

/// Initialize with first button toggled (single-select mode).
pub fn init_first(button_count: Int) -> Model {
  Model(
    toggled_indices: case button_count > 0 { True -> [0] False -> [] },
    highlighted_index: 0,
    is_focused: False,
    button_count: button_count,
    multi_select: False,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the toggle button group state based on a message.
/// Returns a tuple of (new_model, effect) where effect focuses the highlighted button.
pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let #(new_model, needs_focus) = case msg {
    Focus -> #(Model(..model, is_focused: True), False)
    Blur -> #(Model(..model, is_focused: False, highlighted_index: -1), False)
    Toggle(index) -> {
      // If index is -1, toggle the highlighted button
      let index_to_toggle = case index < 0 {
        True -> model.highlighted_index
        False -> index
      }
      let new_toggled = toggle_index(model.toggled_indices, index_to_toggle, model.multi_select)
      #(Model(..model, toggled_indices: new_toggled), True)
    }
    MoveNext -> {
      let new_index = keyboard.next_index(model.highlighted_index, model.button_count, True)
      #(Model(..model, highlighted_index: new_index), True)
    }
    MovePrev -> {
      let new_index = keyboard.prev_index(model.highlighted_index, model.button_count, True)
      #(Model(..model, highlighted_index: new_index), True)
    }
    MoveFirst -> {
      let new_index = keyboard.first_index(model.button_count)
      #(Model(..model, highlighted_index: new_index), True)
    }
    MoveLast -> {
      let new_index = keyboard.last_index(model.button_count)
      #(Model(..model, highlighted_index: new_index), True)
    }
    SetButtonCount(count) -> {
      // Filter toggled indices to only include valid indices
      let new_toggled = list.filter(model.toggled_indices, fn(i) { i < count })
      #(Model(..model, button_count: count, toggled_indices: new_toggled), False)
    }
    SetMultiSelect(multi) -> #(Model(..model, multi_select: multi), False)
    ToggleAll -> {
      let all_indices = list.range(0, model.button_count - 1)
      #(Model(..model, toggled_indices: all_indices), False)
    }
    ClearAll -> #(Model(..model, toggled_indices: []), False)
  }
  
  let effect = case needs_focus && new_model.highlighted_index >= 0 {
    True -> focus.focus_by_id(toggle_button_element_id(new_model.highlighted_index))
    False -> effect.none()
  }
  #(new_model, effect)
}

/// Toggle an index in the toggled list.
fn toggle_index(indices: List(Int), index: Int, multi_select: Bool) -> List(Int) {
  case multi_select {
    True -> {
      case list.contains(indices, index) {
        True -> list.filter(indices, fn(i) { i != index })
        False -> [index, ..indices]
      }
    }
    False -> {
      case list.contains(indices, index) {
        True -> []
        False -> [index]
      }
    }
  }
}

// ============================================================================
// Getters
// ============================================================================

/// Get the toggled indices.
pub fn toggled_indices(model: Model) -> List(Int) {
  model.toggled_indices
}

/// Get the highlighted index.
pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

/// Check if a button is toggled.
pub fn is_toggled(model: Model, index: Int) -> Bool {
  list.contains(model.toggled_indices, index)
}

/// Check if a button is highlighted.
pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Check if the toggle button group is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the button count.
pub fn button_count(model: Model) -> Int {
  model.button_count
}

/// Check if multi-select mode is enabled.
pub fn is_multi_select(model: Model) -> Bool {
  model.multi_select
}

/// Get the tabindex for a button (roving tabindex pattern).
pub fn tabindex_for(model: Model, index: Int) -> Int {
  case model.highlighted_index == index {
    True -> 0
    False -> -1
  }
}

/// Check if all buttons are toggled.
pub fn all_toggled(model: Model) -> Bool {
  list.length(model.toggled_indices) == model.button_count
  && model.button_count > 0
}

/// Check if some buttons are toggled.
pub fn some_toggled(model: Model) -> Bool {
  let toggled_count = list.length(model.toggled_indices)
  toggled_count > 0 && toggled_count < model.button_count
}

/// Get the number of toggled buttons.
pub fn toggled_count(model: Model) -> Int {
  list.length(model.toggled_indices)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for toggle button group keyboard navigation.
/// Follows WAI-ARIA toggle button group pattern:
/// - ArrowRight/ArrowDown: Move to next button
/// - ArrowLeft/ArrowUp: Move to previous button
/// - Home: Move to first button
/// - End: Move to last button
/// - Space/Enter: Toggle the currently focused button
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Space | keyboard.Enter -> Some(Toggle(-1))
    _ -> None
  }
}

/// Get the element ID for a toggle button at the given index.
pub fn toggle_button_element_id(index: Int) -> String {
  "toggle-button-" <> int.to_string(index)
}

/// Get the element ID for the toggle button group.
pub fn group_element_id() -> String {
  "toggle-button-group"
}
