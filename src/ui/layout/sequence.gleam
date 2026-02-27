// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import gleam/string
import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html

import ui/layout/css_utils
import ui/layout/types.{type Spacing}

pub fn sequence(
  attributes: List(Attribute(a)),
  spacing: Spacing,
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "flex flex-wrap",
          css_utils.spacing_to_tw(spacing),
          "@container",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn of(
  element: fn(List(Attribute(a)), List(Element(a))) -> Element(a),
  attributes: List(Attribute(a)),
  spacing: Spacing,
  children: List(Element(a)),
) -> Element(a) {
  element(
    [
      class(
        [
          "flex flex-wrap",
          css_utils.spacing_to_tw(spacing),
          "@container",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn breakpoint(value: String) -> Attribute(a) {
  class("@min-" <> value <> ":flex-row")
}

pub fn split(_n: Int) -> Attribute(a) {
  class("")
}

pub fn horizontal() -> Attribute(a) {
  class("flex-row")
}

pub fn vertical() -> Attribute(a) {
  class("flex-col")
}
