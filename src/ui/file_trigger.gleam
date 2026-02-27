// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/keyboard.{type Key, Enter, Space, decode_key}
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

/// Messages for file trigger keyboard navigation
pub type Msg {
  Activate
}

pub fn file_trigger(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.label(
    [
      class(
        [
          "inline-flex cursor-pointer items-center justify-center rounded-md text-sm font-medium",
          "bg-primary text-primary-foreground hover:bg-primary/90",
          "focus-within:outline-none focus-within:ring-2 focus-within:ring-ring",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn input(attributes: List(Attribute(a))) -> Element(a) {
  html.input([class("sr-only"), attribute("type", "file"), ..attributes])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-primary text-primary-foreground")
    Muted -> class("bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.button_class(size_helpers.Small))
    Medium -> class(size_helpers.button_class(size_helpers.Medium))
    Large -> class(size_helpers.button_class(size_helpers.Large))
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for file trigger keyboard navigation
///
/// ## Keyboard interactions:
/// - **Enter**: Open file picker
/// - **Space**: Open file picker
///
/// Follows WAI-ARIA [Button](https://www.w3.org/WAI/ARIA/apg/patterns/button/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    Enter | Space -> Some(Activate)
    _ -> None
  }
}
