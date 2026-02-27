// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
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

/// Selection mode for range calendar
pub type SelectionMode {
  Single
  Range
}

/// Messages for range calendar keyboard navigation
pub type Msg {
  MoveDay(Int)
  SelectDate
  MoveWeek(Int)
  MoveMonth(Int)
  MoveToFirstDayOfWeek
  MoveToLastDayOfWeek
  SelectRangeStart
  SelectRangeEnd
}

pub fn range_calendar(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("rounded-md border border-input bg-background p-3"),
      attribute("role", "application"),
      attribute("aria-label", "Range calendar"),
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

/// Keymap for range calendar keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow keys**: Navigate dates (day by day)
/// - **Home**: First day of week
/// - **End**: Last day of week
/// - **PageUp**: Previous month
/// - **PageDown**: Next month
/// - **Space/Enter**: Select date (start or end of range)
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
    Space | Enter -> {
      case selection_mode {
        Single -> Some(SelectDate)
        Range -> Some(SelectRangeStart)
      }
    }
    _ -> None
  }
}
