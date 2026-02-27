// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

import ui/layout/css_utils

pub fn centre(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      css_utils.css_style([
        #("display", "flex"),
        #("align-items", "center"),
        #("justify-content", "center"),
      ]),
      ..attributes
    ],
    children,
  )
}

pub fn inline() -> Attribute(a) {
  css_utils.css_style([#("display", "inline-flex")])
}

pub fn full_height() -> Attribute(a) {
  css_utils.css_style([#("min-height", "100vh")])
}
