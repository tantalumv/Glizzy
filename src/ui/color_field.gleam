// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/list
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, type_}
import lustre/element.{type Element}
import lustre/element/html
import ui/size.{type Size, input_class}

// ============================================================================
// Types
// ============================================================================

pub type Variant {
  Default
  Muted
}

// ============================================================================
// Color Field Component (Presentational - controlled by parent)
// ============================================================================

pub fn color_field(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("grid gap-2"), ..attributes], children)
}

pub fn input(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      [
        "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
        "focus:outline-none focus:ring-2 focus:ring-ring",
      ]
      |> string.join(" "),
    ),
    type_("text"),
    attribute("role", "textbox"),
    attribute("aria-label", "Color value"),
    ..attributes
  ])
}

pub fn swatch(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class("h-8 w-8 rounded border border-border"),
      attribute("aria-hidden", "true"),
      ..attributes
    ],
    [],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("text-foreground")
    Muted -> class("text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  class(input_class(s))
}

pub fn value(val: String) -> Attribute(a) {
  attribute("value", val)
}

pub fn placeholder(placeholder: String) -> Attribute(a) {
  attribute("placeholder", placeholder)
}

pub fn label(lbl: String) -> Attribute(a) {
  attribute("aria-label", lbl)
}

pub fn disabled() -> Attribute(a) {
  attribute("aria-disabled", "true")
}

pub fn invalid() -> Attribute(a) {
  attribute("aria-invalid", "true")
}

pub fn required() -> Attribute(a) {
  attribute("aria-required", "true")
}

// ============================================================================
// Helper Functions
// ============================================================================

pub fn is_valid_hex_color(value: String) -> Bool {
  let normalized = string.lowercase(value)
  case string.starts_with(normalized, "#") {
    False -> False
    True -> {
      let hex_part = string.slice(normalized, 1, string.length(normalized) - 1)
      case string.length(hex_part) {
        3 | 6 | 8 -> is_valid_hex_chars(hex_part)
        _ -> False
      }
    }
  }
}

fn is_valid_hex_chars(chars: String) -> Bool {
  let valid_chars = "0123456789abcdef"
  chars
  |> string.lowercase
  |> string.to_graphemes
  |> list.all(fn(c) { string.contains(valid_chars, c) })
}

pub fn swatch_style(color: String) -> Attribute(a) {
  attribute("style", "background-color: " <> color)
}
