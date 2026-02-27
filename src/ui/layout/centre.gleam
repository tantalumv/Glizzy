// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html

pub fn centre(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("flex items-center justify-center"), ..attributes], children)
}

pub fn inline() -> Attribute(a) {
  class("inline-flex")
}

pub fn full_height() -> Attribute(a) {
  class("min-h-screen")
}
