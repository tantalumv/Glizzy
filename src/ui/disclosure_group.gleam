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

pub fn disclosure_group(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [class("grid gap-2"), attribute("role", "group"), ..attributes],
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

/// Keyboard messages for disclosure group component.
pub type Msg {
  /// Toggle the currently focused disclosure (Enter or Space)
  Toggle
  /// Move to next disclosure (ArrowDown or ArrowRight)
  MoveNext
  /// Move to previous disclosure (ArrowUp or ArrowLeft)
  MovePrev
  /// Move to first disclosure (Home)
  MoveFirst
  /// Move to last disclosure (End)
  MoveLast
}

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
    keyboard.Enter | keyboard.Space -> Some(Toggle)
    _ -> None
  }
}

/// Get the element ID for a disclosure trigger at the given index.
pub fn disclosure_trigger_element_id(index: Int) -> String {
  "disclosure-trigger-" <> int.to_string(index)
}
