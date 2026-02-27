// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html

pub type Size {
  Small
  Medium
  Large
}

pub fn form(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.form([class("grid gap-4"), ..attributes], children)
}

pub fn field(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("grid gap-2"), ..attributes], children)
}

pub fn label(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.label([class("text-sm font-medium"), ..attributes], children)
}

pub fn helper_text(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.p([class("text-xs text-muted-foreground"), ..attributes], children)
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("gap-2")
    Medium -> class("gap-4")
    Large -> class("gap-6")
  }
}
