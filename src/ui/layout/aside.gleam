// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import gleam/string
import lustre/attribute.{type Attribute, class}
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
      class(
        ["flex", css_utils.spacing_to_tw(spacing)]
        |> string.join(" "),
      ),
      ..attributes
    ],
    [
      html.aside([class("w-64 shrink-0")], [sidebar]),
      html.main([class("flex-1 min-w-0")], [content]),
    ],
  )
}

pub fn sidebar_start() -> Attribute(a) {
  class("flex-row")
}

pub fn sidebar_end() -> Attribute(a) {
  class("flex-row-reverse")
}

pub fn sidebar_width(value: String) -> Attribute(a) {
  class("w-[" <> value <> "]")
}

pub fn collapsible() -> Attribute(a) {
  class("")
}
