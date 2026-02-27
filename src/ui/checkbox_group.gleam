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

pub fn checkbox_group(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [class("grid gap-2"), attribute("role", "group"), ..attributes],
    children,
  )
}

pub fn label(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.p([class("text-sm font-medium"), ..attributes], children)
}

pub fn description(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.p([class("text-xs text-muted-foreground"), ..attributes], children)
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

/// Keyboard messages for checkbox group component.
pub type Msg {
  /// Move to next checkbox (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous checkbox (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first checkbox (Home)
  MoveFirst
  /// Move to last checkbox (End)
  MoveLast
  /// Toggle the currently focused checkbox (Space)
  Toggle
}

/// Keymap for checkbox group keyboard navigation.
/// Follows WAI-ARIA checkbox group pattern:
/// - ArrowRight/ArrowDown: Move to next checkbox
/// - ArrowLeft/ArrowUp: Move to previous checkbox
/// - Home: Move to first checkbox
/// - End: Move to last checkbox
/// - Space: Toggle the currently focused checkbox
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowRight | keyboard.ArrowDown -> Some(MoveNext)
    keyboard.ArrowLeft | keyboard.ArrowUp -> Some(MovePrev)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Space -> Some(Toggle)
    _ -> None
  }
}

/// Get the element ID for a checkbox at the given index.
pub fn checkbox_element_id(index: Int) -> String {
  "checkbox-" <> int.to_string(index)
}
