// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

import ui/layout/css_utils
import ui/layout/types.{type Spacing}

pub fn cluster(
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

pub fn align_start() -> Attribute(a) {
  css_utils.css_style([#("align-items", "flex-start")])
}

pub fn align_centre() -> Attribute(a) {
  css_utils.css_style([#("align-items", "center")])
}

pub fn align_end() -> Attribute(a) {
  css_utils.css_style([#("align-items", "flex-end")])
}

pub fn align_stretch() -> Attribute(a) {
  css_utils.css_style([#("align-items", "stretch")])
}

pub fn justify_start() -> Attribute(a) {
  css_utils.css_style([#("justify-content", "flex-start")])
}

pub fn justify_centre() -> Attribute(a) {
  css_utils.css_style([#("justify-content", "center")])
}

pub fn justify_end() -> Attribute(a) {
  css_utils.css_style([#("justify-content", "flex-end")])
}
