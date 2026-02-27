// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, attribute, class, style}
import lustre/element.{type Element}
import lustre/element/html.{div, span}
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

/// Create a spinner with optional size and variant attributes.
/// The spinner includes inline styles for dimensions to work without CSS.
pub fn spinner(attributes: List(Attribute(a))) -> Element(a) {
  div(
    [
      class(
        "animate-spin inline-block rounded-full border-2 border-primary border-t-transparent",
      ),
      attribute("role", "status"),
      attribute("aria-live", "polite"),
      attribute("aria-busy", "true"),
      style("width", "24px"),
      style("height", "24px"),
      ..attributes
    ],
    [
      span(
        [
          class("block h-full w-full rounded-full bg-primary/10"),
          attribute("aria-hidden", "true"),
        ],
        [],
      ),
    ],
  )
}

/// Create a spinner with explicit size control.
/// Includes inline styles for dimensions to work without CSS.
pub fn spinner_with_size(
  size: Size,
  attributes: List(Attribute(a)),
) -> Element(a) {
  let dimensions = size_to_inline_style(size)
  div(
    [
      class(
        "animate-spin inline-block rounded-full border-2 border-primary border-t-transparent",
      ),
      attribute("role", "status"),
      attribute("aria-live", "polite"),
      attribute("aria-busy", "true"),
      style("width", dimensions),
      style("height", dimensions),
      ..attributes
    ],
    [
      span(
        [
          class("block h-full w-full rounded-full bg-primary/10"),
          attribute("aria-hidden", "true"),
        ],
        [],
      ),
    ],
  )
}

fn size_to_inline_style(size: Size) -> String {
  case size {
    Small -> "16px"
    Medium -> "24px"
    Large -> "32px"
  }
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-primary")
    Muted -> class("border-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.icon_class(size_helpers.Small))
    Medium -> class(size_helpers.icon_class(size_helpers.Medium))
    Large -> class("h-8 w-8 border-[3px]")
  }
}

pub fn border() -> Attribute(a) {
  class("rounded-full border-current border-t-transparent")
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_busy(busy: Bool) -> Attribute(a) {
  attribute("aria-busy", case busy {
    True -> "true"
    False -> "false"
  })
}

pub fn loading_text(text: String) -> Attribute(a) {
  attribute("aria-valuetext", text)
}
