// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
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

pub fn progress_bar(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("h-2 w-full overflow-hidden rounded-full bg-muted"),
      attribute("role", "progressbar"),
      attribute("aria-valuemin", "0"),
      attribute("aria-valuemax", "100"),
      attribute("aria-live", "polite"),
      ..attributes
    ],
    children,
  )
}

pub fn indicator(attributes: List(Attribute(a))) -> Element(a) {
  html.div([class("h-full bg-primary transition-all"), ..attributes], [])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-primary")
    Muted -> class("bg-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.track_class(size_helpers.Small))
    Medium -> class(size_helpers.track_class(size_helpers.Medium))
    Large -> class(size_helpers.track_class(size_helpers.Large))
  }
}

pub fn aria_valuenow(value: Int) -> Attribute(a) {
  attribute("aria-valuenow", int.to_string(value))
}

pub fn aria_valuemin(value: Int) -> Attribute(a) {
  attribute("aria-valuemin", int.to_string(value))
}

pub fn aria_valuemax(value: Int) -> Attribute(a) {
  attribute("aria-valuemax", int.to_string(value))
}

pub fn aria_valuetext(text: String) -> Attribute(a) {
  attribute("aria-valuetext", text)
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}
