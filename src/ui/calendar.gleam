// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/keyboard.{
  type Key, ArrowDown, ArrowLeft, ArrowRight, ArrowUp, End, Enter, Home,
  PageDown, PageUp, Space, decode_key,
}
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

/// Selection mode for calendar
pub type SelectionMode {
  Single
  Multiple
  Range
}

/// Messages for calendar keyboard navigation
pub type Msg {
  MoveDay(Int)
  SelectDate
  MoveWeek(Int)
  MoveMonth(Int)
  MoveToFirstDayOfWeek
  MoveToLastDayOfWeek
}

pub fn calendar(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("rounded-md border border-input bg-background p-3"),
      attribute("role", "application"),
      attribute("aria-label", "Calendar"),
      ..attributes
    ],
    children,
  )
}

pub fn grid(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.table(
    [class("w-full border-collapse"), attribute("role", "grid"), ..attributes],
    children,
  )
}

pub fn cell(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.td(
    [
      class("h-9 w-9 p-0 text-center"),
      attribute("role", "gridcell"),
      ..attributes
    ],
    children,
  )
}

pub fn day(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        [
          "inline-flex h-9 w-9 items-center justify-center rounded-md text-sm",
          "hover:bg-accent hover:text-accent-foreground",
          css.focus_ring(),
        ]
        |> string.join(" "),
      ),
      attribute("type", "button"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background text-foreground")
    Muted -> class("bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for calendar keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow keys**: Navigate dates (day by day)
/// - **Home**: First day of week
/// - **End**: Last day of week
/// - **PageUp**: Previous month
/// - **PageDown**: Next month
/// - **Space/Enter**: Select date
///
/// Follows WAI-ARIA [Grid](https://www.w3.org/WAI/ARIA/apg/patterns/grid/) pattern.
pub fn keymap(
  key_event: keyboard.KeyEvent,
  selection_mode: SelectionMode,
) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    ArrowLeft -> Some(MoveDay(-1))
    ArrowRight -> Some(MoveDay(1))
    ArrowUp -> Some(MoveWeek(-1))
    ArrowDown -> Some(MoveWeek(1))
    Home -> Some(MoveToFirstDayOfWeek)
    End -> Some(MoveToLastDayOfWeek)
    PageUp -> Some(MoveMonth(-1))
    PageDown -> Some(MoveMonth(1))
    Space | Enter -> Some(SelectDate)
    _ -> None
  }
  |> option.map(fn(msg) {
    case selection_mode {
      Single | Multiple | Range -> msg
    }
  })
}
