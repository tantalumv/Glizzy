// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import gleam/string
import lustre/attribute.{type Attribute, class}
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
      class(
        ["flex flex-col", css_utils.spacing_to_tw(spacing)]
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
        ["flex flex-col", css_utils.spacing_to_tw(spacing)]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn packed() -> Attribute(a) {
  class("gap-0")
}

pub fn tight() -> Attribute(a) {
  class("gap-2")
}

pub fn relaxed() -> Attribute(a) {
  class("gap-4")
}

pub fn loose() -> Attribute(a) {
  class("gap-6")
}

pub fn space(value: String) -> Attribute(a) {
  class("gap-[" <> value <> "]")
}
