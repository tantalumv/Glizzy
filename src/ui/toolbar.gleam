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

pub fn toolbar(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        "inline-flex items-center gap-1 rounded-md border border-input bg-background p-1",
      ),
      attribute("role", "toolbar"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background text-foreground")
    Muted -> class("bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for toolbar component.
pub type Msg {
  /// Move to next toolbar item (ArrowRight or ArrowDown)
  MoveNext
  /// Move to previous toolbar item (ArrowLeft or ArrowUp)
  MovePrev
  /// Move to first toolbar item (Home)
  MoveFirst
  /// Move to last toolbar item (End)
  MoveLast
  /// Activate the currently focused item (Enter or Space)
  Activate
}

/// Keymap for toolbar keyboard navigation.
/// Follows WAI-ARIA toolbar pattern:
/// - ArrowRight/ArrowDown: Move to next toolbar item
/// - ArrowLeft/ArrowUp: Move to previous toolbar item
/// - Home: Move to first toolbar item
/// - End: Move to last toolbar item
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

/// Toolbar orientation for keyboard navigation.
pub type Orientation {
  Horizontal
  Vertical
}

/// Set toolbar orientation.
pub fn orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> attribute("aria-orientation", "horizontal")
    Vertical -> attribute("aria-orientation", "vertical")
  }
}
