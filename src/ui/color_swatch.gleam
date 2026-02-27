// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/size as size_helpers

pub type Size {
  Small
  Medium
  Large
}

pub fn color_swatch(attributes: List(Attribute(a))) -> Element(a) {
  html.div([class("rounded border border-border"), ..attributes], [])
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.icon_class(size_helpers.Small))
    Medium -> class(size_helpers.icon_class(size_helpers.Medium))
    Large -> class(size_helpers.icon_class(size_helpers.Large))
  }
}
