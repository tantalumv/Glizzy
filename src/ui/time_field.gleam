// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/string
import gleam/time/calendar
import lustre/attribute.{type Attribute, attribute, class, name, type_}
import lustre/element.{type Element}
import lustre/element/html
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

pub type HourCycle {
  Hour12
  Hour24
}

pub fn timefield(attributes: List(Attribute(a))) -> Element(a) {
  html.div([class("flex items-center gap-1")], [
    html.input([
      class(
        [
          "flex h-10 w-full rounded-md border border-input bg-background px-4 py-2.5 text-sm",
          "placeholder:text-muted-foreground",
          css.focus_ring(),
          css.disabled(),
        ]
        |> string.join(" "),
      ),
      name(""),
      type_("time"),
      attribute("role", "combobox"),
      attribute("aria-label", "Time"),
      attribute("aria-haspopup", "listbox"),
      attribute("aria-expanded", "false"),
      ..attributes
    ]),
  ])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input bg-background")
    Muted -> class("border-input bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.input_class(size_helpers.Small))
    Medium -> class(size_helpers.input_class(size_helpers.Medium))
    Large -> class(size_helpers.input_class(size_helpers.Large))
  }
}

pub fn hour_cycle(hc: HourCycle) -> Attribute(a) {
  case hc {
    Hour12 -> attribute("data-hour-cycle", "12")
    Hour24 -> attribute("data-hour-cycle", "24")
  }
}

pub fn required() -> Attribute(a) {
  attribute("aria-required", "true")
}

pub fn disabled() -> Attribute(a) {
  attribute("aria-disabled", "true")
}

pub fn invalid() -> Attribute(a) {
  attribute("aria-invalid", "true")
}

pub fn placeholder(placeholder: String) -> Attribute(a) {
  attribute("placeholder", placeholder)
}

pub fn value(time: calendar.TimeOfDay) -> Attribute(a) {
  attribute("value", format_time_of_day(time))
}

pub fn min_value(time: calendar.TimeOfDay) -> Attribute(a) {
  attribute("min", format_time_of_day(time))
}

pub fn max_value(time: calendar.TimeOfDay) -> Attribute(a) {
  attribute("max", format_time_of_day(time))
}

fn format_time_of_day(time: calendar.TimeOfDay) -> String {
  let calendar.TimeOfDay(hours:, minutes:, seconds:, nanoseconds: _) = time
  let hh = pad2(hours)
  let mm = pad2(minutes)
  let ss = pad2(seconds)
  hh <> ":" <> mm <> ":" <> ss
}

fn pad2(value: Int) -> String {
  int.to_string(value) |> string.pad_start(2, "0")
}
