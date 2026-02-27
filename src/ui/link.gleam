// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/size as size_helpers

pub type Variant {
  Default
  Muted
}

pub type Size {
  Small
  Medium
  Large
}

pub type Underline {
  Hover
  Always
  Never
}

pub fn link(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.a(
    [
      class(
        "inline-flex items-center gap-1 text-primary underline-offset-4 transition-colors hover:underline",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("text-primary")
    Muted -> class("text-muted-foreground hover:text-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

pub fn underline(u: Underline) -> Attribute(a) {
  case u {
    Hover -> class("hover:underline")
    Always -> class("underline")
    Never -> class("no-underline")
  }
}

pub fn icon() -> Attribute(a) {
  class("h-4 w-4")
}
