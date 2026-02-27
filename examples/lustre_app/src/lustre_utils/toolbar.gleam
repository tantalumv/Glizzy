// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful toolbar component with keyboard navigation support.
////
//// Follows WAI-ARIA toolbar pattern with arrow key navigation and roving tabindex.
//// Supports both horizontal and vertical toolbars.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/toolbar
////
//// let items = ["cut", "copy", "paste"]
//// let model = toolbar.init(items)
//// let new_model = toolbar.update(model, toolbar.MoveNext)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre_utils/keyboard as keyboard
import ui/toolbar as ui_toolbar

// ============================================================================
// Types
// ============================================================================

/// Toolbar item type.
pub type ToolbarItem {
  ToolbarItem(
    id: String,
    label: String,
    disabled: Bool,
    item_type: ToolbarItemType,
  )
}

/// Toolbar item type classification.
pub type ToolbarItemType {
  Button
  Checkbox(checked: Bool)
  Radio(selected: Bool)
  Menu(has_popup: Bool)
}

/// Toolbar model containing items and navigation state.
pub type Model {
  Model(
    items: List(ToolbarItem),
    highlighted_index: Int,
    is_focused: Bool,
    orientation: ui_toolbar.Orientation,
  )
}

/// Toolbar messages for state updates.
pub type Msg {
  /// Focus the toolbar
  Focus
  /// Blur the toolbar
  Blur
  /// Activate the highlighted item
  Activate
  /// Move to next item (ArrowRight or ArrowDown based on orientation)
  MoveNext
  /// Move to previous item (ArrowLeft or ArrowUp based on orientation)
  MovePrev
  /// Move to first item (Home)
  MoveFirst
  /// Move to last item (End)
  MoveLast
  /// Set the highlighted index
  SetHighlightedIndex(Int)
  /// Set the items list
  SetItems(List(ToolbarItem))
  /// Set orientation
  SetOrientation(ui_toolbar.Orientation)
  /// Toggle checkbox at index
  ToggleCheckbox(Int)
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a toolbar model with items.
pub fn init(items: List(ToolbarItem)) -> Model {
  Model(
    items: items,
    highlighted_index: 0,
    is_focused: False,
    orientation: ui_toolbar.Horizontal,
  )
}

/// Initialize a toolbar with item IDs.
pub fn init_with_ids(item_ids: List(String)) -> Model {
  let items = list.map(item_ids, fn(id) {
    ToolbarItem(id: id, label: id, disabled: False, item_type: Button)
  })
  Model(
    items: items,
    highlighted_index: 0,
    is_focused: False,
    orientation: ui_toolbar.Horizontal,
  )
}

/// Initialize a vertical toolbar.
pub fn init_vertical(items: List(ToolbarItem)) -> Model {
  Model(
    items: items,
    highlighted_index: 0,
    is_focused: False,
    orientation: ui_toolbar.Vertical,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the toolbar state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  let item_count = list.length(model.items)
  
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, highlighted_index: -1)
    Activate -> {
      // Activate the highlighted item (could trigger callbacks in real usage)
      model
    }
    SetHighlightedIndex(index) -> {
      Model(..model, highlighted_index: index, is_focused: True)
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
    SetItems(new_items) -> {
      let new_index = int.min(model.highlighted_index, list.length(new_items) - 1)
      Model(..model, items: new_items, highlighted_index: new_index)
    }
    SetOrientation(orient) -> Model(..model, orientation: orient)
    ToggleCheckbox(index) -> {
      let new_items = update_item_at(model.items, index, fn(item) {
        case item.item_type {
          Checkbox(checked) -> ToolbarItem(..item, item_type: Checkbox(!checked))
          _ -> item
        }
      })
      Model(..model, items: new_items)
    }
  }
}

/// Update an item at a specific index.
fn update_item_at(
  items: List(ToolbarItem),
  index: Int,
  updater: fn(ToolbarItem) -> ToolbarItem,
) -> List(ToolbarItem) {
  case items {
    [] -> []
    [item, ..rest] -> {
      case index == 0 {
        True -> [updater(item), ..rest]
        False -> [item, ..update_item_at(rest, index - 1, updater)]
      }
    }
  }
}

// ============================================================================
// Getters
// ============================================================================

/// Get the toolbar items.
pub fn items(model: Model) -> List(ToolbarItem) {
  model.items
}

/// Get the highlighted index.
pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

/// Check if an item is highlighted.
pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Check if the toolbar is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the toolbar orientation.
pub fn orientation(model: Model) -> ui_toolbar.Orientation {
  model.orientation
}

/// Get the item at a specific index.
pub fn item_at(model: Model, index: Int) -> Option(ToolbarItem) {
  get_at(model.items, index)
}

/// Get the tabindex for an item (roving tabindex pattern).
pub fn tabindex_for(model: Model, index: Int) -> Int {
  case model.highlighted_index == index && model.is_focused {
    True -> 0
    False -> -1
  }
}

/// Check if an item is disabled.
pub fn is_disabled(model: Model, index: Int) -> Bool {
  case get_at(model.items, index) {
    Some(item) -> item.disabled
    None -> False
  }
}

/// Get the number of items.
pub fn item_count(model: Model) -> Int {
  list.length(model.items)
}

fn get_at(items: List(ToolbarItem), index: Int) -> Option(ToolbarItem) {
  case items {
    [] -> None
    [item, ..rest] -> {
      case index == 0 {
        True -> Some(item)
        False -> get_at(rest, index - 1)
      }
    }
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for toolbar keyboard navigation.
/// Follows WAI-ARIA toolbar pattern:
/// - ArrowRight/ArrowDown: Move to next item (based on orientation)
/// - ArrowLeft/ArrowUp: Move to previous item (based on orientation)
/// - Home: Move to first item
/// - End: Move to last item
/// - Enter/Space: Activate the currently focused item
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Enter | keyboard.Space -> Some(Activate)
    _ -> None
  }
}

/// Get the element ID for a toolbar item at the given index.
pub fn toolbar_item_element_id(index: Int) -> String {
  "toolbar-item-" <> int.to_string(index)
}

/// Get the element ID for the toolbar.
pub fn toolbar_element_id() -> String {
  "toolbar"
}

// ============================================================================
// Item Builders
// ============================================================================

/// Create a button toolbar item.
pub fn button_item(id: String, label: String) -> ToolbarItem {
  ToolbarItem(id: id, label: label, disabled: False, item_type: Button)
}

/// Create a disabled button toolbar item.
pub fn disabled_button_item(id: String, label: String) -> ToolbarItem {
  ToolbarItem(id: id, label: label, disabled: True, item_type: Button)
}

/// Create a checkbox toolbar item.
pub fn checkbox_item(id: String, label: String, checked: Bool) -> ToolbarItem {
  ToolbarItem(id: id, label: label, disabled: False, item_type: Checkbox(checked))
}

/// Create a radio toolbar item.
pub fn radio_item(id: String, label: String, selected: Bool) -> ToolbarItem {
  ToolbarItem(id: id, label: label, disabled: False, item_type: Radio(selected))
}

/// Create a menu toolbar item.
pub fn menu_item(id: String, label: String, has_popup: Bool) -> ToolbarItem {
  ToolbarItem(id: id, label: label, disabled: False, item_type: Menu(has_popup))
}
