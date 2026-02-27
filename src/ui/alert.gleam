// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{div, p}

pub type Variant {
  Default
  Success
  Warning
  Error
}

pub type LiveRegion {
  Assertive
  Polite
  Off
}

pub fn alert(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      class(
        "relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> "bg-background text-foreground border-input"
    Success ->
      "bg-green-50 text-green-900 border-green-200 dark:bg-green-950 dark:text-green-100 dark:border-green-800"
    Warning ->
      "bg-yellow-50 text-yellow-900 border-yellow-200 dark:bg-yellow-950 dark:text-yellow-100 dark:border-yellow-800"
    Error ->
      "bg-red-50 text-red-900 border-red-200 dark:bg-red-950 dark:text-red-100 dark:border-red-800"
  }
  |> class
}

pub fn role_alert() -> Attribute(a) {
  attribute("role", "alert")
}

pub fn role_status() -> Attribute(a) {
  attribute("role", "status")
}

pub fn aria_live(live: LiveRegion) -> Attribute(a) {
  case live {
    Assertive -> attribute("aria-live", "assertive")
    Polite -> attribute("aria-live", "polite")
    Off -> attribute("aria-live", "off")
  }
}

pub fn aria_atomic(value: Bool) -> Attribute(a) {
  attribute("aria-atomic", case value {
    True -> "true"
    False -> "false"
  })
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn live_region() -> List(Attribute(a)) {
  [
    attribute("role", "status"),
    attribute("aria-live", "polite"),
    attribute("aria-atomic", "true"),
  ]
}

pub fn critical_region() -> List(Attribute(a)) {
  [
    attribute("role", "alert"),
    attribute("aria-live", "assertive"),
    attribute("aria-atomic", "true"),
  ]
}

pub fn title(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  p(
    [class("mb-1 font-semibold leading-none tracking-tight"), ..attributes],
    children,
  )
}

pub fn description(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  p([class("text-sm [&_p]:leading-relaxed"), ..attributes], children)
}
