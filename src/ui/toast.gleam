// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/keyboard.{type Key, Escape, decode_key}
import ui/size as size_helpers

pub type Variant {
  Default
  Success
  Warning
  Error
}

pub type Size {
  Small
  Medium
  Large
}

/// Messages for toast keyboard navigation
pub type Msg {
  Dismiss
}

pub fn toast(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "rounded-md border p-4 shadow-md",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
        ]
        |> string.join(" "),
      ),
      attribute("role", "status"),
      attribute("aria-live", "polite"),
      ..attributes
    ],
    children,
  )
}

pub fn title(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.p([class("text-sm font-semibold"), ..attributes], children)
}

pub fn description(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.p([class("text-sm text-muted-foreground"), ..attributes], children)
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background text-foreground")
    Success -> class("border-green-500/30 bg-green-500/10 text-green-900")
    Warning -> class("border-amber-500/30 bg-amber-500/10 text-amber-900")
    Error -> class("border-red-500/30 bg-red-500/10 text-red-900")
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

/// Keymap for toast keyboard navigation
///
/// ## Keyboard interactions:
/// - **Escape**: Dismiss toast
///
/// Follows WAI-ARIA [Status Message](https://www.w3.org/WAI/ARIA/apg/patterns/statusmessage/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    Escape -> Some(Dismiss)
    _ -> None
  }
}
