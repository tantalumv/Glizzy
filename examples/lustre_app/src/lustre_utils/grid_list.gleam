// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful grid list component with 2D keyboard navigation support.
////
//// Follows WAI-ARIA grid pattern with arrow key navigation in two dimensions,
//// Home/End for row start/end, and Ctrl+Home/End for grid start/end.
//// Supports single and multi-select modes with Shift+Arrow range selection.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/grid_list
////
//// let items = ["item1", "item2", "item3", "item4"]
//// let model = grid_list.init(items, 2, 2, False)
//// let new_model = grid_list.update(model, grid_list.MoveDown)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Grid list model containing items and 2D navigation state.
pub type Model {
  Model(
    items: List(String),
    rows: Int,
    cols: Int,
    focused_row: Int,
    focused_col: Int,
    selected: Option(String),
    selected_items: List(String),
    anchor_row: Int,
    anchor_col: Int,
    multi_select: Bool,
    is_focused: Bool,
  )
}

/// Grid list messages for state updates.
pub type Msg {
  /// Focus the grid
  Focus
  /// Blur the grid
  Blur
  /// Move focus down (ArrowDown)
  MoveDown
  /// Move focus up (ArrowUp)
  MoveUp
  /// Move focus right (ArrowRight)
  MoveRight
  /// Move focus left (ArrowLeft)
  MoveLeft
  /// Move to row start (Home)
  MoveRowStart
  /// Move to row end (End)
  MoveRowEnd
  /// Move to grid first item (Ctrl+Home)
  MoveGridFirst
  /// Move to grid last item (Ctrl+End)
  MoveGridLast
  /// Select the item at the specified position (from click)
  Select(Int, Int)
  /// Select the focused item (from keyboard)
  SelectFocused
  /// Extend selection down (Shift+ArrowDown)
  ExtendSelectionDown
  /// Extend selection up (Shift+ArrowUp)
  ExtendSelectionUp
  /// Extend selection right (Shift+ArrowRight)
  ExtendSelectionRight
  /// Extend selection left (Shift+ArrowLeft)
  ExtendSelectionLeft
  /// Set items
  SetItems(List(String))
  /// Set grid dimensions
  SetDimensions(Int, Int)
  /// Toggle multi-select mode
  SetMultiSelect(Bool)
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a grid list model with items and dimensions.
pub fn init(items: List(String), rows: Int, cols: Int, multi_select: Bool) -> Model {
  Model(
    items: items,
    rows: rows,
    cols: cols,
    focused_row: 0,
    focused_col: 0,
    selected: None,
    selected_items: [],
    anchor_row: -1,
    anchor_col: -1,
    multi_select: multi_select,
    is_focused: False,
  )
}

/// Initialize with first item selected.
pub fn init_first(items: List(String), rows: Int, cols: Int) -> Model {
  let first_item = case items {
    [] -> None
    [first, ..] -> Some(first)
  }
  Model(
    items: items,
    rows: rows,
    cols: cols,
    focused_row: 0,
    focused_col: 0,
    selected: first_item,
    selected_items: case first_item { Some(item) -> [item] None -> [] },
    anchor_row: 0,
    anchor_col: 0,
    multi_select: False,
    is_focused: False,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the grid list state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, anchor_row: -1, anchor_col: -1)
    MoveDown -> move_down(model, False)
    MoveUp -> move_up(model, False)
    MoveRight -> move_right(model, False)
    MoveLeft -> move_left(model, False)
    MoveRowStart -> Model(..model, focused_col: 0)
    MoveRowEnd -> Model(..model, focused_col: model.cols - 1)
    MoveGridFirst -> Model(..model, focused_row: 0, focused_col: 0)
    MoveGridLast -> {
      let last_row = model.rows - 1
      let last_col = model.cols - 1
      Model(..model, focused_row: last_row, focused_col: last_col)
    }
    Select(row, col) -> {
      let item = get_item_at(model.items, model.rows, model.cols, row, col)
      let new_selected_items = case model.multi_select, item {
        True, Some(selected_item) -> toggle_item(model.selected_items, selected_item)
        True, None -> model.selected_items
        False, Some(selected_item) -> [selected_item]
        False, None -> []
      }
      Model(..model, selected: item, selected_items: new_selected_items, focused_row: row, focused_col: col, anchor_row: row, anchor_col: col)
    }
    SelectFocused -> {
      let item = get_item_at(model.items, model.rows, model.cols, model.focused_row, model.focused_col)
      let new_selected_items = case model.multi_select, item {
        True, Some(selected_item) -> toggle_item(model.selected_items, selected_item)
        True, None -> model.selected_items
        False, Some(selected_item) -> [selected_item]
        False, None -> []
      }
      Model(..model, selected: item, selected_items: new_selected_items, anchor_row: model.focused_row, anchor_col: model.focused_col)
    }
    ExtendSelectionDown -> extend_selection(model, model.focused_row + 1, model.focused_col)
    ExtendSelectionUp -> extend_selection(model, model.focused_row - 1, model.focused_col)
    ExtendSelectionRight -> extend_selection(model, model.focused_row, model.focused_col + 1)
    ExtendSelectionLeft -> extend_selection(model, model.focused_row, model.focused_col - 1)
    SetItems(new_items) -> Model(..model, items: new_items)
    SetDimensions(rows, cols) -> Model(..model, rows: rows, cols: cols)
    SetMultiSelect(multi) -> Model(..model, multi_select: multi)
  }
}

/// Move focus down one row.
fn move_down(model: Model, _extend: Bool) -> Model {
  let new_row = int.min(model.focused_row + 1, model.rows - 1)
  Model(..model, focused_row: new_row)
}

/// Move focus up one row.
fn move_up(model: Model, _extend: Bool) -> Model {
  let new_row = int.max(model.focused_row - 1, 0)
  Model(..model, focused_row: new_row)
}

/// Move focus right one column.
fn move_right(model: Model, _extend: Bool) -> Model {
  let new_col = int.min(model.focused_col + 1, model.cols - 1)
  Model(..model, focused_col: new_col)
}

/// Move focus left one column.
fn move_left(model: Model, _extend: Bool) -> Model {
  let new_col = int.max(model.focused_col - 1, 0)
  Model(..model, focused_col: new_col)
}

/// Toggle an item in the selected items list.
fn toggle_item(items: List(String), item: String) -> List(String) {
  case list.contains(items, item) {
    True -> list.filter(items, fn(i) { i != item })
    False -> [item, ..items]
  }
}

/// Extend selection to a new position.
fn extend_selection(model: Model, new_row: Int, new_col: Int) -> Model {
  let clamped_row = clamp(new_row, 0, model.rows - 1)
  let clamped_col = clamp(new_col, 0, model.cols - 1)
  
  let anchor_r = case model.anchor_row {
    -1 -> model.focused_row
    _ -> model.anchor_row
  }
  let anchor_c = case model.anchor_col {
    -1 -> model.focused_col
    _ -> model.anchor_col
  }
  
  let selected_items = get_items_in_rect(
    model.items,
    model.rows,
    model.cols,
    anchor_r,
    anchor_c,
    clamped_row,
    clamped_col,
  )
  
  Model(
    ..model,
    focused_row: clamped_row,
    focused_col: clamped_col,
    anchor_row: anchor_r,
    anchor_col: anchor_c,
    selected: case selected_items {
      [] -> None
      [first, ..] -> Some(first)
    },
  )
}

/// Get all items in a rectangular range.
fn get_items_in_rect(
  items: List(String),
  rows: Int,
  cols: Int,
  from_row: Int,
  from_col: Int,
  to_row: Int,
  to_col: Int,
) -> List(String) {
  let min_row = int.min(from_row, to_row)
  let max_row = int.max(from_row, to_row)
  let min_col = int.min(from_col, to_col)
  let max_col = int.max(from_col, to_col)

  let indices = list.flat_map(
    list.range(min_row, max_row),
    fn(r) { list.map(list.range(min_col, max_col), fn(c) { #(r, c) }) },
  )

  indices
  |> list.map(fn(pos) { get_item_at(items, rows, cols, pos.0, pos.1) })
  |> list.filter_map(fn(opt) {
    case opt {
      Some(item) -> Ok(item)
      None -> Error(Nil)
    }
  })
}

/// Get item at a specific grid position.
fn get_item_at(items: List(String), rows: Int, cols: Int, row: Int, col: Int) -> Option(String) {
  case row < 0 || row >= rows || col < 0 || col >= cols {
    True -> None
    False -> {
      let index = row * cols + col
      get_at(items, index)
    }
  }
}

fn get_at(items: List(String), index: Int) -> Option(String) {
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

fn clamp(value: Int, min: Int, max: Int) -> Int {
  case value {
    v if v < min -> min
    v if v > max -> max
    _ -> value
  }
}

// ============================================================================
// Getters
// ============================================================================

/// Get the focused row.
pub fn focused_row(model: Model) -> Int {
  model.focused_row
}

/// Get the focused column.
pub fn focused_col(model: Model) -> Int {
  model.focused_col
}

/// Get the selected item.
pub fn selected(model: Model) -> Option(String) {
  model.selected
}

/// Check if an item is selected.
pub fn is_selected(model: Model, item: String) -> Bool {
  case model.selected {
    Some(v) -> v == item
    None -> False
  }
}

/// Check if a position is focused.
pub fn is_focused_pos(model: Model, row: Int, col: Int) -> Bool {
  model.focused_row == row && model.focused_col == col
}

/// Check if the grid is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the items list.
pub fn items(model: Model) -> List(String) {
  model.items
}

/// Get the number of rows.
pub fn rows(model: Model) -> Int {
  model.rows
}

/// Get the number of columns.
pub fn cols(model: Model) -> Int {
  model.cols
}

/// Check if multi-select is enabled.
pub fn is_multi_select(model: Model) -> Bool {
  model.multi_select
}

/// Get the anchor row for range selection.
pub fn anchor_row(model: Model) -> Int {
  model.anchor_row
}

/// Get the anchor column for range selection.
pub fn anchor_col(model: Model) -> Int {
  model.anchor_col
}

/// Check if a position is in the selection range.
pub fn is_in_selection_range(model: Model, row: Int, col: Int) -> Bool {
  case model.anchor_row == -1 && model.anchor_col == -1 {
    True -> False
    False -> {
      let min_row = int.min(model.anchor_row, model.focused_row)
      let max_row = int.max(model.anchor_row, model.focused_row)
      let min_col = int.min(model.anchor_col, model.focused_col)
      let max_col = int.max(model.anchor_col, model.focused_col)
      row >= min_row && row <= max_row && col >= min_col && col <= max_col
    }
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for grid list keyboard navigation.
/// Follows WAI-ARIA grid pattern:
/// - ArrowDown: Move down one row
/// - ArrowUp: Move up one row
/// - ArrowRight: Move right one column
/// - ArrowLeft: Move left one column
/// - Home: Move to row start
/// - End: Move to row end
/// - Ctrl+Home: Move to grid first item
/// - Ctrl+End: Move to grid last item
/// - Enter/Space: Select the focused item
/// - Shift+Arrow: Extend selection
pub fn keymap(key_event: keyboard.KeyEvent, multi_select: Bool) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown if key_event.shift && multi_select -> Some(ExtendSelectionDown)
    keyboard.ArrowUp if key_event.shift && multi_select -> Some(ExtendSelectionUp)
    keyboard.ArrowRight if key_event.shift && multi_select -> Some(ExtendSelectionRight)
    keyboard.ArrowLeft if key_event.shift && multi_select -> Some(ExtendSelectionLeft)
    keyboard.ArrowDown -> Some(MoveDown)
    keyboard.ArrowUp -> Some(MoveUp)
    keyboard.ArrowRight -> Some(MoveRight)
    keyboard.ArrowLeft -> Some(MoveLeft)
    keyboard.Home if key_event.ctrl -> Some(MoveGridFirst)
    keyboard.End if key_event.ctrl -> Some(MoveGridLast)
    keyboard.Home -> Some(MoveRowStart)
    keyboard.End -> Some(MoveRowEnd)
    keyboard.Enter | keyboard.Space -> Some(SelectFocused)
    _ -> None
  }
}

/// Get the element ID for a grid item at the given position.
pub fn grid_item_element_id(row: Int, col: Int) -> String {
  "grid-item-" <> int.to_string(row) <> "-" <> int.to_string(col)
}

/// Get the element ID for a grid row.
pub fn grid_row_element_id(row: Int) -> String {
  "grid-row-" <> int.to_string(row)
}

/// Get the element ID for the grid.
pub fn grid_element_id() -> String {
  "grid-list"
}
