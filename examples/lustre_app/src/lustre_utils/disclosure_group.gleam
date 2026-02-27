// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful disclosure group (accordion) component with keyboard navigation support.
////
//// Follows WAI-ARIA accordion pattern with arrow key navigation between disclosure headers.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/disclosure_group
////
//// let model = disclosure_group.init(3, [0])
//// let new_model = disclosure_group.update(model, disclosure_group.MoveNext)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Disclosure group model containing expanded states and navigation state.
pub type Model {
  Model(
    expanded_indices: List(Int),
    highlighted_index: Int,
    is_focused: Bool,
    item_count: Int,
    allow_multiple: Bool,
  )
}

/// Disclosure group messages for state updates.
pub type Msg {
  /// Focus the disclosure group
  Focus
  /// Blur the disclosure group
  Blur
  /// Toggle a disclosure by index
  Toggle(Int)
  /// Move to next disclosure (ArrowDown or ArrowRight)
  MoveNext
  /// Move to previous disclosure (ArrowUp or ArrowLeft)
  MovePrev
  /// Move to first disclosure (Home)
  MoveFirst
  /// Move to last disclosure (End)
  MoveLast
  /// Expand all disclosures
  ExpandAll
  /// Collapse all disclosures
  CollapseAll
  /// Set the item count
  SetItemCount(Int)
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a disclosure group model with item count.
pub fn init(item_count: Int, initial_expanded: List(Int)) -> Model {
  Model(
    expanded_indices: initial_expanded,
    highlighted_index: 0,
    is_focused: False,
    item_count: item_count,
    allow_multiple: True,
  )
}

/// Initialize with first disclosure expanded.
pub fn init_first(item_count: Int) -> Model {
  Model(
    expanded_indices: case item_count > 0 { True -> [0] False -> [] },
    highlighted_index: 0,
    is_focused: False,
    item_count: item_count,
    allow_multiple: False,
  )
}

/// Initialize with all disclosures collapsed.
pub fn init_collapsed(item_count: Int) -> Model {
  Model(
    expanded_indices: [],
    highlighted_index: 0,
    is_focused: False,
    item_count: item_count,
    allow_multiple: True,
  )
}

/// Initialize with all disclosures expanded.
pub fn init_expanded(item_count: Int) -> Model {
  let all_indices = list.range(0, item_count - 1)
  Model(
    expanded_indices: all_indices,
    highlighted_index: 0,
    is_focused: False,
    item_count: item_count,
    allow_multiple: True,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the disclosure group state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, highlighted_index: -1)
    Toggle(index) -> {
      let new_expanded = toggle_disclosure(
        model.expanded_indices,
        index,
        model.allow_multiple,
      )
      Model(..model, expanded_indices: new_expanded)
    }
    MoveNext -> {
      let new_index = keyboard.next_index(model.highlighted_index, model.item_count, True)
      Model(..model, highlighted_index: new_index)
    }
    MovePrev -> {
      let new_index = keyboard.prev_index(model.highlighted_index, model.item_count, True)
      Model(..model, highlighted_index: new_index)
    }
    MoveFirst -> {
      let new_index = keyboard.first_index(model.item_count)
      Model(..model, highlighted_index: new_index)
    }
    MoveLast -> {
      let new_index = keyboard.last_index(model.item_count)
      Model(..model, highlighted_index: new_index)
    }
    ExpandAll -> {
      let all_indices = list.range(0, model.item_count - 1)
      Model(..model, expanded_indices: all_indices)
    }
    CollapseAll -> Model(..model, expanded_indices: [])
    SetItemCount(count) -> {
      // Filter expanded indices to only include valid indices
      let new_expanded = list.filter(model.expanded_indices, fn(i) { i < count })
      Model(..model, item_count: count, expanded_indices: new_expanded)
    }
  }
}

/// Toggle a disclosure index in the expanded list.
fn toggle_disclosure(indices: List(Int), index: Int, allow_multiple: Bool) -> List(Int) {
  case allow_multiple {
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

/// Get the expanded indices.
pub fn expanded_indices(model: Model) -> List(Int) {
  model.expanded_indices
}

/// Get the highlighted index.
pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

/// Check if a disclosure is expanded.
pub fn is_expanded(model: Model, index: Int) -> Bool {
  list.contains(model.expanded_indices, index)
}

/// Check if a disclosure is highlighted.
pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Check if the disclosure group is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the item count.
pub fn item_count(model: Model) -> Int {
  model.item_count
}

/// Check if multiple expansions are allowed.
pub fn allows_multiple(model: Model) -> Bool {
  model.allow_multiple
}

/// Get the tabindex for a disclosure trigger (roving tabindex pattern).
pub fn tabindex_for(model: Model, index: Int) -> Int {
  case model.highlighted_index == index {
    True -> 0
    False -> -1
  }
}

/// Check if all disclosures are expanded.
pub fn all_expanded(model: Model) -> Bool {
  list.length(model.expanded_indices) == model.item_count
  && model.item_count > 0
}

/// Check if some disclosures are expanded.
pub fn some_expanded(model: Model) -> Bool {
  let expanded_count = list.length(model.expanded_indices)
  expanded_count > 0 && expanded_count < model.item_count
}

/// Get the number of expanded disclosures.
pub fn expanded_count(model: Model) -> Int {
  list.length(model.expanded_indices)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for disclosure group keyboard navigation.
/// Follows WAI-ARIA accordion pattern:
/// - ArrowDown/ArrowRight: Move to next disclosure
/// - ArrowUp/ArrowLeft: Move to previous disclosure
/// - Home: Move to first disclosure
/// - End: Move to last disclosure
/// - Enter/Space: Toggle the currently focused disclosure
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown | keyboard.ArrowRight -> Some(MoveNext)
    keyboard.ArrowUp | keyboard.ArrowLeft -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Enter | keyboard.Space -> Some(Toggle(-1))
    _ -> None
  }
}

/// Get the element ID for a disclosure trigger at the given index.
pub fn disclosure_trigger_element_id(index: Int) -> String {
  "disclosure-trigger-" <> int.to_string(index)
}

/// Get the element ID for a disclosure content at the given index.
pub fn disclosure_content_element_id(index: Int) -> String {
  "disclosure-content-" <> int.to_string(index)
}

/// Get the element ID for the disclosure group.
pub fn group_element_id() -> String {
  "disclosure-group"
}
