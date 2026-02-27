// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{div, img}

pub type Size {
  Small
  Medium
  Large
}

pub fn avatar(attributes: List(Attribute(a))) -> Element(a) {
  img([
    class("inline-block h-10 w-10 rounded-full ring-2 ring-offset-2 ring-ring"),
    ..attributes
  ])
}

pub fn fallback(attributes: List(Attribute(a))) -> Element(a) {
  div(
    [
      class(
        "flex h-full w-full items-center justify-center rounded-full bg-muted",
      ),
      ..attributes
    ],
    [],
  )
}

pub fn group(avatars: List(Element(a))) -> Element(a) {
  div([class("flex -space-x-4")], avatars)
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("h-8 w-8")
    Medium -> class("h-10 w-10")
    Large -> class("h-14 w-14")
  }
}

pub fn radius(s: Size) -> Attribute(a) {
  case s {
    Small -> class("rounded-sm")
    Medium -> class("rounded-md")
    Large -> class("rounded-lg")
  }
}
