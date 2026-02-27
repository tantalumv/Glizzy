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

pub fn radio_group(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [class("grid gap-2"), attribute("role", "radiogroup"), ..attributes],
    children,
  )
}

pub fn option(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([attribute("role", "radio"), ..attributes], children)
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("text-foreground")
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

/// Keyboard messages for radio group component.
pub type Msg {
  /// Move to next radio button (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous radio button (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first radio button (Home)
  MoveFirst
  /// Move to last radio button (End)
  MoveLast
  /// Select the currently focused radio button (Space)
  Select
}

/// Keymap for radio group keyboard navigation.
/// Follows WAI-ARIA radio group pattern:
/// - ArrowRight/ArrowDown: Move to next radio button (wraps)
/// - ArrowLeft/ArrowUp: Move to previous radio button (wraps)
/// - Home: Move to first radio button
/// - End: Move to last radio button
/// - Space: Select the currently focused radio button
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Space -> Some(Select)
    _ -> None
  }
}

/// Get the element ID for a radio button at the given index.
pub fn radio_element_id(index: Int) -> String {
  "radio-" <> int.to_string(index)
}
