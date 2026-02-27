// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, Some}
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html
import ui/keyboard
import ui/size as size_helpers

pub type Variant {
  Default
  Bordered
}

pub type Size {
  Small
  Medium
  Large
}

pub type SelectionMode {
  None
  Single
  Multiple
}

pub fn table(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.table(
    [class("w-full caption-bottom text-sm"), role("grid"), ..attributes],
    children,
  )
}

pub fn table_header(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.thead([class("border-b bg-muted/50"), ..attributes], children)
}

pub fn table_header_row(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.tr(
    [
      role("row"),
      class(
        "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn table_column_header(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.th(
    [
      class(
        "h-10 px-2 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0",
      ),
      role("columnheader"),
      attribute("aria-sort", "none"),
      ..attributes
    ],
    children,
  )
}

pub fn table_body(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.tbody([class(""), ..attributes], children)
}

pub fn table_row(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.tr(
    [
      role("row"),
      class(
        "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn table_cell(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.td(
    [
      class("p-2 align-middle [&:has([role=checkbox])]:pr-0"),
      role("gridcell"),
      ..attributes
    ],
    children,
  )
}

pub fn table_head_cell(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.td(
    [
      class("p-2 align-middle font-medium [&:has([role=checkbox])]:pr-0"),
      role("gridcell"),
      ..attributes
    ],
    children,
  )
}

pub fn table_caption(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.caption(
    [class("mt-4 text-sm text-muted-foreground"), ..attributes],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("")
    Bordered -> class("border")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

pub fn selection_mode(m: SelectionMode) -> Attribute(a) {
  case m {
    None -> attribute("aria-multiselectable", "false")
    Single -> attribute("aria-multiselectable", "false")
    Multiple -> attribute("aria-multiselectable", "true")
  }
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for table component.
pub type Msg {
  /// Move to next row (ArrowDown)
  MoveDown
  /// Move to previous row (ArrowUp)
  MoveUp
  /// Move to next cell (ArrowRight)
  MoveRight
  /// Move to previous cell (ArrowLeft)
  MoveLeft
  /// Move to first cell in row (Home)
  MoveRowStart
  /// Move to last cell in row (End)
  MoveRowEnd
  /// Move to first cell in table (Ctrl+Home)
  MoveTableFirst
  /// Move to last cell in table (Ctrl+End)
  MoveTableLast
  /// Select the currently focused row (Space)
  SelectRow
  /// Select the currently focused cell (Enter)
  SelectCell
  /// Toggle row selection (Ctrl+Space)
  ToggleRowSelection
  /// Extend selection with Shift+Arrow (multi-select mode)
  ExtendSelectionDown
  /// Extend selection with Shift+Arrow (multi-select mode)
  ExtendSelectionUp
  /// Enter cell editing mode (F2 or Enter for editable cells)
  EditCell
}

/// Keymap for table keyboard navigation.
/// Follows WAI-ARIA grid pattern for tables:
/// - ArrowDown: Move to next row
/// - ArrowUp: Move to previous row
/// - ArrowRight: Move to next cell
/// - ArrowLeft: Move to previous cell
/// - Home: Move to first cell in row
/// - End: Move to last cell in row
/// - Ctrl+Home: Move to first cell in table
/// - Ctrl+End: Move to last cell in table
/// - Space: Select focused row
/// - Ctrl+Space: Toggle row selection
/// - Enter: Select cell or enter edit mode
/// - F2: Enter cell edit mode (for editable tables)
pub fn keymap(
  key_event: keyboard.KeyEvent,
  multi_select: Bool,
  editable: Bool,
) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown if key_event.shift && multi_select ->
      Some(ExtendSelectionDown)
    keyboard.ArrowUp if key_event.shift && multi_select ->
      Some(ExtendSelectionUp)
    keyboard.ArrowDown -> Some(MoveDown)
    keyboard.ArrowUp -> Some(MoveUp)
    keyboard.ArrowRight -> Some(MoveRight)
    keyboard.ArrowLeft -> Some(MoveLeft)
    keyboard.Home if key_event.ctrl -> Some(MoveTableFirst)
    keyboard.End if key_event.ctrl -> Some(MoveTableLast)
    keyboard.Home -> Some(MoveRowStart)
    keyboard.End -> Some(MoveRowEnd)
    keyboard.Space if key_event.ctrl -> Some(ToggleRowSelection)
    keyboard.Space -> Some(SelectRow)
    keyboard.Enter if editable -> Some(EditCell)
    keyboard.Enter -> Some(SelectCell)
    keyboard.F2 if editable -> Some(EditCell)
    _ -> option.None
  }
}

/// Get the element ID for a table cell at the given row and column.
pub fn table_cell_element_id(row: Int, col: Int) -> String {
  "table-cell-" <> int.to_string(row) <> "-" <> int.to_string(col)
}

/// Get the element ID for a table row at the given index.
pub fn table_row_element_id(row: Int) -> String {
  "table-row-" <> int.to_string(row)
}

/// Get the element ID for a table column header at the given index.
pub fn table_column_header_element_id(col: Int) -> String {
  "table-column-" <> int.to_string(col)
}

/// Attribute to indicate the currently active descendant.
pub fn aria_activedescendant(id: String) -> Attribute(a) {
  attribute("aria-activedescendant", id)
}

/// Attribute to indicate sort direction.
pub fn aria_sort(sort: String) -> Attribute(a) {
  attribute("aria-sort", sort)
}
