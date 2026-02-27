// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

import ui/layout/css_utils

pub fn box(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [css_utils.css_style([#("padding", "1rem")]), ..attributes],
    children,
  )
}

pub fn padding(value: String) -> Attribute(a) {
  css_utils.css_style([#("padding", value)])
}

pub fn padding_x(value: String) -> Attribute(a) {
  css_utils.css_style([#("padding-left", value), #("padding-right", value)])
}

pub fn padding_y(value: String) -> Attribute(a) {
  css_utils.css_style([#("padding-top", value), #("padding-bottom", value)])
}

pub fn margin(value: String) -> Attribute(a) {
  css_utils.css_style([#("margin", value)])
}

pub fn margin_x(value: String) -> Attribute(a) {
  css_utils.css_style([#("margin-left", value), #("margin-right", value)])
}

pub fn margin_y(value: String) -> Attribute(a) {
  css_utils.css_style([#("margin-top", value), #("margin-bottom", value)])
}

pub fn border() -> Attribute(a) {
  css_utils.css_style([
    #("border", "1px solid #e5e7eb"),
    #("border-radius", "0.5rem"),
  ])
}

pub fn shadow() -> Attribute(a) {
  css_utils.css_style([#("box-shadow", "0 4px 6px -1px rgb(0 0 0 / 0.1)")])
}

pub fn background(value: String) -> Attribute(a) {
  css_utils.css_style([#("background-color", value)])
}
