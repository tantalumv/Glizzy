// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

import ui/layout/css_utils
import ui/layout/types.{type Spacing}

pub fn stack(
  attributes: List(Attribute(a)),
  spacing: Spacing,
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      css_utils.css_style([
        #("display", "flex"),
        #("flex-direction", "column"),
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
        #("flex-direction", "column"),
        #("gap", css_utils.spacing_to_gap(spacing)),
      ]),
      ..attributes
    ],
    children,
  )
}

pub fn packed() -> Attribute(a) {
  css_utils.css_style([#("gap", "0")])
}

pub fn tight() -> Attribute(a) {
  css_utils.css_style([#("gap", "0.5rem")])
}

pub fn relaxed() -> Attribute(a) {
  css_utils.css_style([#("gap", "1rem")])
}

pub fn loose() -> Attribute(a) {
  css_utils.css_style([#("gap", "1.5rem")])
}

pub fn space(value: String) -> Attribute(a) {
  css_utils.css_style([#("gap", value)])
}
