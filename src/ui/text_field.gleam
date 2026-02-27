// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class, name, type_}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
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

pub fn textfield(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      [
        "flex h-10 w-full rounded-md border border-input bg-background px-4 py-2.5 text-sm",
        "placeholder:text-muted-foreground",
        css.focus_ring(),
        css.disabled(),
      ]
      |> string.join(" "),
    ),
    name(""),
    type_("text"),
    attribute("role", "textbox"),
    ..attributes
  ])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input bg-background")
    Muted -> class("border-input bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.input_class(size_helpers.Small))
    Medium -> class(size_helpers.input_class(size_helpers.Medium))
    Large -> class(size_helpers.input_class(size_helpers.Large))
  }
}

pub fn required() -> Attribute(a) {
  attribute("aria-required", "true")
}
