// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class}
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

pub fn toggle_button_group(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("inline-flex items-center gap-1"),
      attribute("role", "group"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("")
    Muted -> class("text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for toggle button group component.
pub type Msg {
  /// Move to next toggle button (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous toggle button (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first toggle button (Home)
  MoveFirst
  /// Move to last toggle button (End)
  MoveLast
  /// Toggle the currently focused button (Space or Enter)
  Toggle
}

/// Keymap for toggle button group keyboard navigation.
/// Follows WAI-ARIA toggle button group pattern:
/// - ArrowRight/ArrowDown: Move to next toggle button
/// - ArrowLeft/ArrowUp: Move to previous toggle button
/// - Home: Move to first toggle button
/// - End: Move to last toggle button
/// - Space/Enter: Toggle the currently focused button
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Space | keyboard.Enter -> Some(Toggle)
    _ -> None
  }
}

/// Get the element ID for a toggle button at the given index.
pub fn toggle_button_element_id(index: Int) -> String {
  "toggle-button-" <> int.to_string(index)
}
