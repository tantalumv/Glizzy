// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{div}

pub fn skeleton(attributes: List(Attribute(a))) -> Element(a) {
  div(
    [
      class("animate-pulse rounded-md bg-muted"),
      attribute("role", "status"),
      attribute("aria-live", "polite"),
      attribute("aria-busy", "true"),
      ..attributes
    ],
    [],
  )
}

pub fn circle(size: Int) -> Attribute(a) {
  class(
    "h-"
    <> int.to_string(size)
    <> " w-"
    <> int.to_string(size)
    <> " rounded-full",
  )
}

pub fn rect(width: String, height: String) -> Attribute(a) {
  class("w-" <> width <> " h-" <> height <> " rounded-md")
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_busy(busy: Bool) -> Attribute(a) {
  attribute("aria-busy", case busy {
    True -> "true"
    False -> "false"
  })
}
