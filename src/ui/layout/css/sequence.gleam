// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute}
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
      css_utils.css_style([
        #("display", "flex"),
        #("flex-wrap", "wrap"),
        #("gap", css_utils.spacing_to_gap(spacing)),
      ]),
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
      css_utils.css_style([
        #("display", "flex"),
        #("flex-wrap", "wrap"),
        #("gap", css_utils.spacing_to_gap(spacing)),
      ]),
      ..attributes
    ],
    children,
  )
}

pub fn breakpoint(_value: String) -> Attribute(a) {
  css_utils.css_style([
    #("container-type", "inline-size"),
    #("container-name", "glizzy-sequence"),
  ])
}

pub fn split(_n: Int) -> Attribute(a) {
  css_utils.css_style([])
}

pub fn horizontal() -> Attribute(a) {
  css_utils.css_style([#("flex-direction", "row")])
}

pub fn vertical() -> Attribute(a) {
  css_utils.css_style([#("flex-direction", "column")])
}
