// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class, type_}
import lustre/element.{type Element}
import lustre/element/html.{input, label, span}
import ui/css
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

pub fn checkbox(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  label([class("flex items-center gap-2 cursor-pointer")], [
    input([
      type_("checkbox"),
      class(
        [
          size_helpers.indicator_class(size_helpers.Medium)
            <> " rounded border-gray-300 text-primary",
          "focus:ring-2 focus:ring-ring focus:ring-offset-2",
          css.disabled(),
        ]
        |> string.join(" "),
      ),
      ..attributes
    ]),
    span(
      [
        class(
          "text-sm leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
        ),
      ],
      children,
    ),
  ])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-gray-300 text-primary")
    Muted -> class("border-input text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.indicator_class(size_helpers.Small))
    Medium -> class(size_helpers.indicator_class(size_helpers.Medium))
    Large -> class(size_helpers.indicator_class(size_helpers.Large))
  }
}

pub fn aria_checked(checked: Bool) -> Attribute(a) {
  attribute("aria-checked", case checked {
    True -> "true"
    False -> "false"
  })
}
