// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/bool
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/size as size_helpers

pub type Variant {
  Default
  Secondary
  Destructive
  Outline
  Ghost
  Link
}

pub type Size {
  Small
  Medium
  Large
}

pub fn button(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        [
          "flex gap-2 items-center justify-center whitespace-nowrap",
          "rounded-md text-sm font-medium transition-colors h-10 px-4 py-2",
          css.focus_ring(),
          "disabled:pointer-events-none " <> css.disabled(),
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> "bg-primary text-primary-foreground hover:bg-primary/90"
    Secondary -> "bg-secondary text-secondary-foreground hover:bg-secondary/80"
    Destructive ->
      "bg-destructive text-destructive-foreground hover:bg-destructive/90"
    Outline ->
      "border border-input bg-background hover:bg-accent hover:text-accent-foreground"
    Ghost -> "hover:bg-accent hover:text-accent-foreground"
    Link -> "text-primary underline-offset-4 hover:underline"
  }
  |> class
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.button_class(size_helpers.Small))
    Medium -> class(size_helpers.button_class(size_helpers.Medium))
    Large -> class(size_helpers.button_class(size_helpers.Large))
  }
}

pub fn icon() -> Attribute(a) {
  class("h-9 w-9")
}

pub fn pressed(is_pressed: Bool) -> Attribute(a) {
  attribute("aria-pressed", bool.to_string(is_pressed))
}
