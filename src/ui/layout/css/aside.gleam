// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

import ui/layout/css_utils
import ui/layout/types.{type Spacing}

pub fn aside(
  attributes: List(Attribute(a)),
  spacing: Spacing,
  sidebar: Element(a),
  content: Element(a),
) -> Element(a) {
  html.div(
    [
      css_utils.css_style([
        #("display", "flex"),
        #("gap", css_utils.spacing_to_gap(spacing)),
      ]),
      ..attributes
    ],
    [
      html.aside(
        [css_utils.css_style([#("width", "16rem"), #("flex-shrink", "0")])],
        [sidebar],
      ),
      html.main([css_utils.css_style([#("flex", "1"), #("min-width", "0")])], [
        content,
      ]),
    ],
  )
}

pub fn sidebar_start() -> Attribute(a) {
  css_utils.css_style([#("flex-direction", "row")])
}

pub fn sidebar_end() -> Attribute(a) {
  css_utils.css_style([#("flex-direction", "row-reverse")])
}

pub fn sidebar_width(value: String) -> Attribute(a) {
  css_utils.css_style([#("width", value)])
}

pub fn collapsible() -> Attribute(a) {
  css_utils.css_style([])
}
