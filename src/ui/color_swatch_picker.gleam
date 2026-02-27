// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

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

pub fn color_swatch_picker(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("flex flex-wrap gap-2"),
      attribute("role", "radiogroup"),
      attribute("aria-label", "Color swatches"),
      ..attributes
    ],
    children,
  )
}

pub fn swatch_option(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class("h-6 w-6 rounded-full border border-border"),
      attribute("type", "button"),
      attribute("role", "radio"),
      attribute("aria-checked", "false"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("")
    Muted -> class("opacity-80")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.icon_class(size_helpers.Small))
    Medium -> class(size_helpers.icon_class(size_helpers.Medium))
    Large -> class(size_helpers.icon_class(size_helpers.Large))
  }
}
