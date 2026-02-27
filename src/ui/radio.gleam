// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role, type_}
import lustre/element.{type Element}
import lustre/element/html.{fieldset, input, label, span}
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

pub fn radio(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  label([class("flex items-center gap-2 cursor-pointer")], [
    input([
      type_("radio"),
      class(
        [
          "aspect-square "
            <> size_helpers.indicator_class(size_helpers.Medium)
            <> " rounded-full border border-input text-primary",
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

pub fn group(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  fieldset([role("group"), class("space-y-2"), ..attributes], children)
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input text-primary")
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

pub fn aria_labelledby(id: String) -> Attribute(a) {
  attribute("aria-labelledby", id)
}
