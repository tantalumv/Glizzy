// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{span}
import ui/size as size_helpers

pub type Variant {
  Default
  Secondary
  Destructive
  Outline
}

pub type Size {
  Small
  Medium
  Large
}

pub fn badge(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  span(
    [
      class(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default ->
      "border-transparent bg-primary text-primary-foreground hover:bg-primary/80"
    Secondary ->
      "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80"
    Destructive ->
      "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80"
    Outline -> "text-foreground"
  }
  |> class
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.tag_class(size_helpers.Small))
    Medium -> class("px-2.5 py-0.5 text-sm")
    Large -> class("px-3 py-1 text-base")
  }
}

pub fn role_status() -> Attribute(a) {
  attribute("role", "status")
}

pub fn aria_live_polite() -> Attribute(a) {
  attribute("aria-live", "polite")
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}
