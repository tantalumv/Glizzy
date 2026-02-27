// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{div}
import ui/keyboard.{type Key, Escape, decode_key}
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

pub type Position {
  Top
  Bottom
  Left
  Right
}

/// Messages for tooltip keyboard navigation
pub type Msg {
  Close
}

pub fn tooltip(
  attributes: List(Attribute(a)),
  _children: List(Element(a)),
  trigger: Element(a),
) -> Element(a) {
  div(
    [
      class(
        [
          "relative inline-flex",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    [trigger],
  )
}

pub fn content(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      class(
        [
          "absolute z-50 whitespace-nowrap rounded-md bg-primary px-3 py-1.5 text-primary-foreground text-sm",
          "shadow-md",
        ]
        |> string.join(" "),
      ),
      attribute("role", "tooltip"),
      ..attributes
    ],
    children,
  )
}

pub fn trigger(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      class(
        [
          "inline-flex",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> "bg-primary text-primary-foreground"
    Muted -> "bg-muted text-muted-foreground"
  }
  |> class
}

pub fn position(p: Position) -> Attribute(a) {
  case p {
    Top -> class("bottom-full left-1/2 -translate-x-1/2 mb-3")
    Bottom -> class("top-full left-1/2 -translate-x-1/2 mt-3")
    Left -> class("right-full top-1/2 -translate-y-1/2 mr-3")
    Right -> class("left-full top-1/2 -translate-y-1/2 ml-3")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.tag_class(size_helpers.Small))
    Medium -> class("px-3 py-1 text-sm")
    Large -> class("px-4 py-1.5 text-base")
  }
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_describedby(id: String) -> Attribute(a) {
  attribute("aria-describedby", id)
}

pub fn role_tooltip() -> Attribute(a) {
  attribute("role", "tooltip")
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for tooltip keyboard navigation
///
/// ## Keyboard interactions:
/// - **Escape**: Close tooltip
///
/// Follows WAI-ARIA [Tooltip](https://www.w3.org/WAI/ARIA/apg/patterns/tooltip/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    Escape -> Some(Close)
    _ -> None
  }
}
