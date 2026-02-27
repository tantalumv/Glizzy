// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import gleam/string
import lustre/attribute.{type Attribute, class}
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
      class(
        ["flex flex-wrap", css_utils.spacing_to_tw(spacing)]
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
        ["flex flex-wrap", css_utils.spacing_to_tw(spacing)]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn align_start() -> Attribute(a) {
  class("items-start")
}

pub fn align_centre() -> Attribute(a) {
  class("items-center")
}

pub fn align_end() -> Attribute(a) {
  class("items-end")
}

pub fn align_stretch() -> Attribute(a) {
  class("items-stretch")
}

pub fn justify_start() -> Attribute(a) {
  class("justify-start")
}

pub fn justify_centre() -> Attribute(a) {
  class("justify-center")
}

pub fn justify_end() -> Attribute(a) {
  class("justify-end")
}
