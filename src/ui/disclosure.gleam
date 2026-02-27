// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
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

pub fn disclosure(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("rounded-md border border-input"), ..attributes], children)
}

pub fn trigger(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        [
          "flex w-full items-center justify-between px-4 py-2 text-left text-sm font-medium",
          css.focus_ring(),
        ]
        |> string.join(" "),
      ),
      attribute("type", "button"),
      attribute("aria-expanded", "false"),
      attribute("aria-controls", "disclosure-panel"),
      ..attributes
    ],
    children,
  )
}

pub fn panel(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("px-4 pb-4 text-sm"),
      attribute("id", "disclosure-panel"),
      attribute("role", "region"),
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

pub fn aria_controls(id: String) -> Attribute(a) {
  attribute("aria-controls", id)
}

pub fn aria_expanded(expanded: Bool) -> Attribute(a) {
  attribute("aria-expanded", case expanded {
    True -> "true"
    False -> "false"
  })
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for disclosure component.
pub type Msg {
  /// Toggle expanded/collapsed state (Enter or Space)
  Toggle
}

/// Keymap for disclosure keyboard navigation.
/// Follows WAI-ARIA disclosure pattern:
/// - Enter: Toggle expanded/collapsed state
/// - Space: Toggle expanded/collapsed state
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.Enter | keyboard.Space -> Some(Toggle)
    _ -> None
  }
}
