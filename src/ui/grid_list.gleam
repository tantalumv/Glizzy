// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html
import ui/keyboard
import ui/size as size_helpers

pub type Variant {
  Default
  Muted
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

pub fn grid_list(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("overflow-auto rounded-md border border-input bg-background"),
      role("grid"),
      attribute("tabindex", "0"),
      attribute("aria-activedescendant", ""),
      ..attributes
    ],
    children,
  )
}

pub fn grid_list_item(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "flex w-full items-center rounded-sm py-1.5 pl-2 pr-4 text-sm",
          "outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:bg-accent focus:text-accent-foreground",
        ]
        |> string.join(" "),
      ),
      role("row"),
      attribute("tabindex", "-1"),
      attribute("aria-selected", "false"),
      ..attributes
    ],
    [
      html.div(
        [
          class("flex-1"),
          role("gridcell"),
        ],
        children,
      ),
    ],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input bg-background")
    Muted -> class("border-input bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small ->
      class("min-h-[150px] " <> size_helpers.text_class(size_helpers.Small))
    Medium ->
      class("min-h-[200px] " <> size_helpers.text_class(size_helpers.Medium))
    Large ->
      class("min-h-[250px] " <> size_helpers.text_class(size_helpers.Large))
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

pub fn activedescendant(id: String) -> Attribute(a) {
  attribute("aria-activedescendant", id)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for grid list component.
pub type Msg {
  /// Move to next row (ArrowDown)
  MoveDown
  /// Move to previous row (ArrowUp)
  MoveUp
  /// Move to next column (ArrowRight)
  MoveRight
  /// Move to previous column (ArrowLeft)
  MoveLeft
  /// Move to first item in row (Home)
  MoveRowStart
  /// Move to last item in row (End)
  MoveRowEnd
  /// Move to first item in grid (Ctrl+Home)
  MoveGridFirst
  /// Move to last item in grid (Ctrl+end)
  MoveGridLast
  /// Select the currently focused item (Enter or Space)
  Select
  /// Extend selection with Shift+Arrow (multi-select mode)
  ExtendSelectionDown
  /// Extend selection with Shift+Arrow (multi-select mode)
  ExtendSelectionUp
  /// Extend selection with Shift+Arrow (multi-select mode)
  ExtendSelectionRight
  /// Extend selection with Shift+Arrow (multi-select mode)
  ExtendSelectionLeft
}

/// Keymap for grid list keyboard navigation.
/// Follows WAI-ARIA grid pattern:
/// - ArrowDown: Move to next row
/// - ArrowUp: Move to previous row
/// - ArrowRight: Move to next column
/// - ArrowLeft: Move to previous column
/// - Home: Move to first item in row
/// - End: Move to last item in row
/// - Ctrl+Home: Move to first item in grid
/// - Ctrl+End: Move to last item in grid
/// - Enter/Space: Select focused item
/// - Shift+Arrow: Extend selection (multi-select mode)
pub fn keymap(key_event: keyboard.KeyEvent, multi_select: Bool) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown if key_event.shift && multi_select ->
      Some(ExtendSelectionDown)
    keyboard.ArrowUp if key_event.shift && multi_select ->
      Some(ExtendSelectionUp)
    keyboard.ArrowRight if key_event.shift && multi_select ->
      Some(ExtendSelectionRight)
    keyboard.ArrowLeft if key_event.shift && multi_select ->
      Some(ExtendSelectionLeft)
    keyboard.ArrowDown -> Some(MoveDown)
    keyboard.ArrowUp -> Some(MoveUp)
    keyboard.ArrowRight -> Some(MoveRight)
    keyboard.ArrowLeft -> Some(MoveLeft)
    keyboard.Home if key_event.ctrl -> Some(MoveGridFirst)
    keyboard.End if key_event.ctrl -> Some(MoveGridLast)
    keyboard.Home -> Some(MoveRowStart)
    keyboard.End -> Some(MoveRowEnd)
    keyboard.Enter | keyboard.Space -> Some(Select)
    _ -> option.None
  }
}

/// Get the element ID for a grid item at the given row and column.
pub fn grid_item_element_id(row: Int, col: Int) -> String {
  "grid-item-" <> int.to_string(row) <> "-" <> int.to_string(col)
}

/// Get the element ID for a grid row at the given index.
pub fn grid_row_element_id(row: Int) -> String {
  "grid-row-" <> int.to_string(row)
}
