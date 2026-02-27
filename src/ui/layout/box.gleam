// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html

pub fn box(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("p-4"), ..attributes], children)
}

pub fn padding(value: String) -> Attribute(a) {
  class("p-[" <> value <> "]")
}

pub fn padding_x(value: String) -> Attribute(a) {
  class("px-[" <> value <> "]")
}

pub fn padding_y(value: String) -> Attribute(a) {
  class("py-[" <> value <> "]")
}

pub fn margin(value: String) -> Attribute(a) {
  class("m-[" <> value <> "]")
}

pub fn margin_x(value: String) -> Attribute(a) {
  class("mx-[" <> value <> "]")
}

pub fn margin_y(value: String) -> Attribute(a) {
  class("my-[" <> value <> "]")
}

pub fn border() -> Attribute(a) {
  class("border border-border rounded-lg")
}

pub fn shadow() -> Attribute(a) {
  class("shadow-md")
}

pub fn background(value: String) -> Attribute(a) {
  class("bg-[" <> value <> "]")
}
