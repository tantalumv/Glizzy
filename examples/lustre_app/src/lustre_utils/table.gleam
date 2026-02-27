// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful table component with 2D keyboard navigation support.
////
//// Follows WAI-ARIA grid/table pattern with arrow key navigation in two dimensions,
//// row/cell selection, and optional edit mode. Supports single and multi-select modes
//// with Shift+Arrow range selection and Ctrl+Arrow for focus-only movement.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/table
////
//// let columns = ["Name", "Email", "Role"]
//// let data = [["John", "john@example.com", "Admin"], ["Jane", "jane@example.com", "User"]]
//// let model = table.init(columns, data, False)
//// let new_model = table.update(model, table.MoveDown)
//// ```

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

// ============================================================================
// Types
// ============================================================================

/// Sort direction for column sorting.
pub type SortDirection {
  Ascending
  Descending
}

/// Table cell position.
pub type CellPos {
  CellPos(row: Int, col: Int)
}

/// Table model containing data and 2D navigation state.
pub type Model {
  Model(
    columns: List(String),
    data: List(List(String)),
    rows: Int,
    cols: Int,
    focused_row: Int,
    focused_col: Int,
    selected_rows: List(Int),
    selected_cells: List(CellPos),
    anchor_row: Int,
    anchor_col: Int,
    multi_select: Bool,
    editable: Bool,
    is_editing: Bool,
    is_focused: Bool,
    sort_column: Option(Int),
    sort_direction: SortDirection,
  )
}

/// Table messages for state updates.
pub type Msg {
  /// Focus the table
  Focus
  /// Blur the table
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
  /// Move to table first cell (Ctrl+Home)
  MoveTableFirst
  /// Move to table last cell (Ctrl+End)
  MoveTableLast
  /// Select the focused row (Space when on row)
  SelectRow
  /// Select the cell at the specified position (from click)
  SelectCell(Int, Int)
  /// Select the focused cell (from keyboard)
  SelectFocusedCell
  /// Toggle row selection
  ToggleRowSelection
  /// Extend selection down (Shift+ArrowDown)
  ExtendSelectionDown
  /// Extend selection up (Shift+ArrowUp)
  ExtendSelectionUp
  /// Extend selection right (Shift+ArrowRight)
  ExtendSelectionRight
  /// Extend selection left (Shift+ArrowLeft)
  ExtendSelectionLeft
  /// Move focus only without selection (Ctrl+Arrow)
  MoveFocusDown
  /// Move focus only without selection (Ctrl+Arrow)
  MoveFocusUp
  /// Move focus only without selection (Ctrl+Arrow)
  MoveFocusRight
  /// Move focus only without selection (Ctrl+Arrow)
  MoveFocusLeft
  /// Enter edit mode (F2 or Enter on editable cell)
  EditCell
  /// Exit edit mode
  ExitEdit
  /// Set data
  SetData(List(List(String)))
  /// Set columns
  SetColumns(List(String))
  /// Toggle multi-select mode
  SetMultiSelect(Bool)
  /// Toggle editable mode
  SetEditable(Bool)
  /// Toggle sort on a column
  ToggleSort(Int)
  /// Set sort direction explicitly
  SetSort(Int, SortDirection)
  /// Clear sorting
  ClearSort
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a table model with columns and data.
pub fn init(columns: List(String), data: List(List(String)), multi_select: Bool) -> Model {
  let rows = list.length(data)
  let cols = list.length(columns)
  Model(
    columns: columns,
    data: data,
    rows: rows,
    cols: cols,
    focused_row: 0,
    focused_col: 0,
    selected_rows: [],
    selected_cells: [],
    anchor_row: -1,
    anchor_col: -1,
    multi_select: multi_select,
    editable: False,
    is_editing: False,
    is_focused: False,
    sort_column: None,
    sort_direction: Ascending,
  )
}

/// Initialize with editable mode.
pub fn init_editable(columns: List(String), data: List(List(String))) -> Model {
  let rows = list.length(data)
  let cols = list.length(columns)
  Model(
    columns: columns,
    data: data,
    rows: rows,
    cols: cols,
    focused_row: 0,
    focused_col: 0,
    selected_rows: [],
    selected_cells: [],
    anchor_row: -1,
    anchor_col: -1,
    multi_select: True,
    editable: True,
    is_editing: False,
    is_focused: False,
    sort_column: None,
    sort_direction: Ascending,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the table state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False, anchor_row: -1, anchor_col: -1, is_editing: False)
    MoveDown -> move_down(model, False)
    MoveUp -> move_up(model, False)
    MoveRight -> move_right(model, False)
    MoveLeft -> move_left(model, False)
    MoveRowStart -> Model(..model, focused_col: 0)
    MoveRowEnd -> Model(..model, focused_col: model.cols - 1)
    MoveTableFirst -> Model(..model, focused_row: 0, focused_col: 0)
    MoveTableLast -> {
      let last_row = model.rows - 1
      let last_col = model.cols - 1
      Model(..model, focused_row: last_row, focused_col: last_col)
    }
    MoveFocusDown -> move_down(model, False)
    MoveFocusUp -> move_up(model, False)
    MoveFocusRight -> move_right(model, False)
    MoveFocusLeft -> move_left(model, False)
    SelectRow -> select_row(model, model.focused_row)
    SelectCell(row, col) -> select_cell(model, row, col)
    SelectFocusedCell -> select_cell(model, model.focused_row, model.focused_col)
    ToggleRowSelection -> toggle_row_selection(model, model.focused_row)
    ExtendSelectionDown -> extend_selection(model, model.focused_row + 1, model.focused_col)
    ExtendSelectionUp -> extend_selection(model, model.focused_row - 1, model.focused_col)
    ExtendSelectionRight -> extend_selection(model, model.focused_row, model.focused_col + 1)
    ExtendSelectionLeft -> extend_selection(model, model.focused_row, model.focused_col - 1)
    EditCell -> Model(..model, is_editing: True)
    ExitEdit -> Model(..model, is_editing: False)
    SetData(new_data) -> {
      let new_rows = list.length(new_data)
      let new_row = int.min(model.focused_row, new_rows - 1)
      Model(..model, data: new_data, rows: new_rows, focused_row: new_row)
    }
    SetColumns(new_cols) -> {
      let new_cols_count = list.length(new_cols)
      let new_col = int.min(model.focused_col, new_cols_count - 1)
      Model(..model, columns: new_cols, cols: new_cols_count, focused_col: new_col)
    }
    SetMultiSelect(multi) -> Model(..model, multi_select: multi)
    SetEditable(editable) -> Model(..model, editable: editable)
    ToggleSort(col) -> toggle_sort(model, col)
    SetSort(col, direction) -> set_sort(model, col, direction)
    ClearSort -> Model(..model, sort_column: None)
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

/// Select a row.
fn select_row(model: Model, row: Int) -> Model {
  case model.multi_select {
    True -> {
      let new_selected = toggle_int(model.selected_rows, row)
      Model(..model, selected_rows: new_selected)
    }
    False -> Model(..model, selected_rows: [row], selected_cells: [])
  }
}

/// Select a cell.
fn select_cell(model: Model, row: Int, col: Int) -> Model {
  let pos = CellPos(row: row, col: col)
  case model.multi_select {
    True -> {
      let new_selected = toggle_cell_pos(model.selected_cells, pos)
      Model(..model, selected_cells: new_selected, selected_rows: [])
    }
    False -> Model(..model, selected_cells: [pos], selected_rows: [])
  }
}

/// Toggle row selection.
fn toggle_row_selection(model: Model, row: Int) -> Model {
  let new_selected = toggle_int(model.selected_rows, row)
  Model(..model, selected_rows: new_selected)
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
  
  let selected_cells = get_cells_in_rect(
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
    selected_cells: selected_cells,
    selected_rows: [],
  )
}

/// Get all cells in a rectangular range.
fn get_cells_in_rect(
  rows: Int,
  cols: Int,
  from_row: Int,
  from_col: Int,
  to_row: Int,
  to_col: Int,
) -> List(CellPos) {
  let min_row = int.min(from_row, to_row)
  let max_row = int.max(from_row, to_row)
  let min_col = int.min(from_col, to_col)
  let max_col = int.max(from_col, to_col)

  list.flat_map(
    list.range(min_row, max_row),
    fn(r) { list.map(list.range(min_col, max_col), fn(c) { CellPos(row: r, col: c) }) },
  )
}

fn toggle_int(items: List(Int), value: Int) -> List(Int) {
  case list.contains(items, value) {
    True -> list.filter(items, fn(v) { v != value })
    False -> [value, ..items]
  }
}

fn toggle_cell_pos(items: List(CellPos), value: CellPos) -> List(CellPos) {
  case list.contains(items, value) {
    True -> list.filter(items, fn(v) { v.row != value.row || v.col != value.col })
    False -> [value, ..items]
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
// Sorting
// ============================================================================

/// Toggle sort state for a column.
fn toggle_sort(model: Model, col: Int) -> Model {
  case model.sort_column {
    // Currently sorting this column - toggle direction
    Some(current_col) if current_col == col -> {
      let new_direction = case model.sort_direction {
        Ascending -> Descending
        Descending -> Ascending
      }
      let sorted_data = sort_by_column(model.data, col, new_direction)
      Model(
        ..model,
        sort_column: Some(col),
        sort_direction: new_direction,
        data: sorted_data,
      )
    }
    // New column - sort ascending
    _ -> {
      let sorted_data = sort_by_column(model.data, col, Ascending)
      Model(
        ..model,
        sort_column: Some(col),
        sort_direction: Ascending,
        data: sorted_data,
      )
    }
  }
}

/// Set sort on a column with explicit direction.
fn set_sort(model: Model, col: Int, direction: SortDirection) -> Model {
  let sorted_data = sort_by_column(model.data, col, direction)
  Model(
    ..model,
    sort_column: Some(col),
    sort_direction: direction,
    data: sorted_data,
  )
}

/// Sort data by column value.
fn sort_by_column(
  data: List(List(String)),
  col: Int,
  direction: SortDirection,
) -> List(List(String)) {
  let compare = fn(row_a: List(String), row_b: List(String)) {
    let val_a = get_column_value(row_a, col)
    let val_b = get_column_value(row_b, col)
    string.compare(val_a, val_b)
  }
  
  let sorted = list.sort(data, compare)
  case direction {
    Ascending -> sorted
    Descending -> list.reverse(sorted)
  }
}

/// Get the value of a column from a row.
fn get_column_value(row: List(String), col: Int) -> String {
  case list.drop(row, col) {
    [value, ..] -> value
    [] -> ""
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

/// Get the selected rows.
pub fn selected_rows(model: Model) -> List(Int) {
  model.selected_rows
}

/// Get the selected cells.
pub fn selected_cells(model: Model) -> List(CellPos) {
  model.selected_cells
}

/// Check if a row is selected.
pub fn is_row_selected(model: Model, row: Int) -> Bool {
  list.contains(model.selected_rows, row)
}

/// Check if a cell is selected.
pub fn is_cell_selected(model: Model, row: Int, col: Int) -> Bool {
  list.contains(model.selected_cells, CellPos(row: row, col: col))
}

/// Check if a position is focused.
pub fn is_focused_pos(model: Model, row: Int, col: Int) -> Bool {
  model.focused_row == row && model.focused_col == col
}

/// Check if the table is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Check if the table is in edit mode.
pub fn is_editing(model: Model) -> Bool {
  model.is_editing
}

/// Get the columns list.
pub fn columns(model: Model) -> List(String) {
  model.columns
}

/// Get the data.
pub fn data(model: Model) -> List(List(String)) {
  model.data
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

/// Check if editable mode is enabled.
pub fn is_editable(model: Model) -> Bool {
  model.editable
}

/// Get the anchor row for range selection.
pub fn anchor_row(model: Model) -> Int {
  model.anchor_row
}

/// Get the anchor column for range selection.
pub fn anchor_col(model: Model) -> Int {
  model.anchor_col
}

/// Get the cell value at a position.
pub fn cell_value(model: Model, row: Int, col: Int) -> Option(String) {
  case list.drop(model.data, row) {
    [] -> None
    [row_data, ..] -> {
      case list.drop(row_data, col) {
        [] -> None
        [value, ..] -> Some(value)
      }
    }
  }
}

/// Get the column header at an index.
pub fn column_header(model: Model, col: Int) -> Option(String) {
  case list.drop(model.columns, col) {
    [] -> None
    [header, ..] -> Some(header)
  }
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

/// Get the current sort column.
pub fn sort_column(model: Model) -> Option(Int) {
  model.sort_column
}

/// Get the current sort direction.
pub fn sort_direction(model: Model) -> SortDirection {
  model.sort_direction
}

/// Check if a column is sorted.
pub fn is_column_sorted(model: Model, col: Int) -> Bool {
  case model.sort_column {
    Some(c) -> c == col
    None -> False
  }
}

/// Get the aria-sort attribute value for a column.
pub fn aria_sort(model: Model, col: Int) -> String {
  case model.sort_column {
    Some(c) if c == col -> {
      case model.sort_direction {
        Ascending -> "ascending"
        Descending -> "descending"
      }
    }
    _ -> "none"
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for table keyboard navigation.
/// Follows WAI-ARIA table/grid pattern:
/// - ArrowDown: Move down one row
/// - ArrowUp: Move up one row
/// - ArrowRight: Move right one column
/// - ArrowLeft: Move left one column
/// - Home: Move to row start
/// - End: Move to row end
/// - Ctrl+Home: Move to table first cell
/// - Ctrl+End: Move to table last cell
/// - Space: Select row/cell
/// - Shift+Arrow: Extend selection
/// - Ctrl+Arrow: Move focus only
/// - F2: Enter edit mode (if editable)
pub fn keymap(key_event: keyboard.KeyEvent, multi_select: Bool, editable: Bool) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown if key_event.shift && multi_select -> Some(ExtendSelectionDown)
    keyboard.ArrowUp if key_event.shift && multi_select -> Some(ExtendSelectionUp)
    keyboard.ArrowRight if key_event.shift && multi_select -> Some(ExtendSelectionRight)
    keyboard.ArrowLeft if key_event.shift && multi_select -> Some(ExtendSelectionLeft)
    keyboard.ArrowDown if key_event.ctrl && multi_select -> Some(MoveFocusDown)
    keyboard.ArrowUp if key_event.ctrl && multi_select -> Some(MoveFocusUp)
    keyboard.ArrowRight if key_event.ctrl && multi_select -> Some(MoveFocusRight)
    keyboard.ArrowLeft if key_event.ctrl && multi_select -> Some(MoveFocusLeft)
    keyboard.ArrowDown -> Some(MoveDown)
    keyboard.ArrowUp -> Some(MoveUp)
    keyboard.ArrowRight -> Some(MoveRight)
    keyboard.ArrowLeft -> Some(MoveLeft)
    keyboard.Home if key_event.ctrl -> Some(MoveTableFirst)
    keyboard.End if key_event.ctrl -> Some(MoveTableLast)
    keyboard.Home -> Some(MoveRowStart)
    keyboard.End -> Some(MoveRowEnd)
    keyboard.Space -> Some(SelectFocusedCell)
    keyboard.F2 if editable -> Some(EditCell)
    keyboard.Enter if editable -> Some(EditCell)
    keyboard.Escape if editable -> Some(ExitEdit)
    _ -> None
  }
}

/// Get the element ID for a table cell at the given position.
pub fn table_cell_element_id(row: Int, col: Int) -> String {
  "table-cell-" <> int.to_string(row) <> "-" <> int.to_string(col)
}

/// Get the element ID for a table row.
pub fn table_row_element_id(row: Int) -> String {
  "table-row-" <> int.to_string(row)
}

/// Get the element ID for a table column header.
pub fn table_column_element_id(col: Int) -> String {
  "table-column-" <> int.to_string(col)
}

/// Get the element ID for the table.
pub fn table_element_id() -> String {
  "table"
}

/// Get ARIA sort attribute for a column (legacy helper).
pub fn aria_sort_value(sort_direction: Option(String)) -> Option(String) {
  sort_direction
}
