// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html

pub type Variant {
  Default
  Muted
}

pub type Orientation {
  Horizontal
  Vertical
}

pub fn separator(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class("shrink-0 bg-border"),
      attribute("role", "separator"),
      attribute("aria-orientation", "horizontal"),
      ..attributes
    ],
    [],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-border")
    Muted -> class("bg-muted")
  }
}

pub fn orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> class("h-px w-full")
    Vertical -> class("h-full w-px")
  }
}
