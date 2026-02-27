// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html.{div}

pub type Variant {
  Default
  Muted
}

pub type Orientation {
  Horizontal
  Vertical
}

pub fn divider(attributes: List(Attribute(a))) -> Element(a) {
  div([role("separator"), class("shrink-0 bg-border"), ..attributes], [])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-border")
    Muted -> class("bg-muted")
  }
}

pub fn orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> class("w-full h-[1px]")
    Vertical -> class("h-full w-[1px]")
  }
}

pub fn aria_orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> attribute("aria-orientation", "horizontal")
    Vertical -> attribute("aria-orientation", "vertical")
  }
}

pub fn size(s: Int) -> Attribute(a) {
  class("border-" <> int.to_string(s))
}
