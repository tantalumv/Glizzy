// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/size as size_helpers

pub type Variant {
  Default
  Secondary
  Outline
}

pub type Size {
  Small
  Medium
  Large
}

pub fn toggle_button(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        [
          "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors",
          css.focus_ring(),
          "h-10 px-4 py-2",
        ]
        |> string.join(" "),
      ),
      attribute("type", "button"),
      attribute("aria-pressed", "false"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-primary text-primary-foreground hover:bg-primary/90")
    Secondary ->
      class("bg-secondary text-secondary-foreground hover:bg-secondary/80")
    Outline -> class("border border-input bg-background hover:bg-accent")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.toggle_button_class(size_helpers.Small))
    Medium -> class(size_helpers.toggle_button_class(size_helpers.Medium))
    Large -> class(size_helpers.toggle_button_class(size_helpers.Large))
  }
}

pub fn pressed(is_pressed: Bool) -> Attribute(a) {
  case is_pressed {
    True -> attribute("aria-pressed", "true")
    False -> attribute("aria-pressed", "false")
  }
}
