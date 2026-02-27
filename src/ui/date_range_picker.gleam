// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class, type_}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/size.{type Size, input_class}

// ============================================================================
// Types
// ============================================================================

pub type Variant {
  Default
  Muted
}

// ============================================================================
// Date Range Picker Component (Presentational - controlled by parent)
// ============================================================================

pub fn picker(
  attributes: List(Attribute(a)),
  start_attributes: List(Attribute(a)),
  end_attributes: List(Attribute(a)),
) -> Element(a) {
  html.div([class("relative"), ..attributes], [
    html.div([class("flex items-center gap-2")], [
      start_field(start_attributes),
      html.span([class("text-muted-foreground")], [html.text("→")]),
      end_field(end_attributes),
      calendar_button([]),
    ]),
  ])
}

pub fn start_field(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      "flex h-10 w-full rounded-md border border-input bg-background px-4 py-2.5 text-sm placeholder:text-muted-foreground "
      <> css.focus_ring()
      <> " "
      <> css.disabled(),
    ),
    type_("text"),
    attribute("role", "combobox"),
    attribute("aria-label", "Start date"),
    attribute("aria-haspopup", "dialog"),
    attribute("aria-expanded", "false"),
    attribute("autocomplete", "off"),
    attribute("placeholder", "Start date"),
    ..attributes
  ])
}

pub fn end_field(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      "flex h-10 w-full rounded-md border border-input bg-background px-4 py-2.5 text-sm placeholder:text-muted-foreground "
      <> css.focus_ring()
      <> " "
      <> css.disabled(),
    ),
    type_("text"),
    attribute("role", "combobox"),
    attribute("aria-label", "End date"),
    attribute("aria-haspopup", "dialog"),
    attribute("aria-expanded", "false"),
    attribute("autocomplete", "off"),
    attribute("placeholder", "End date"),
    ..attributes
  ])
}

pub fn calendar_button(attributes: List(Attribute(a))) -> Element(a) {
  html.button(
    [
      class(
        "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors "
        <> css.focus_ring()
        <> " disabled:pointer-events-none "
        <> css.disabled()
        <> " border border-input bg-background hover:bg-accent hover:text-accent-foreground h-10 w-10 ",
      ),
      type_("button"),
      attribute("aria-label", "Choose date range"),
      attribute("data-date-range-picker-trigger", "true"),
      ..attributes
    ],
    [calendar_icon()],
  )
}

pub fn content(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        "absolute top-full left-0 z-50 mt-2 w-auto min-w-[560px] border border-input bg-background rounded-md shadow-lg p-3 ",
      ),
      attribute("data-date-range-picker-content", "true"),
      attribute("role", "dialog"),
      attribute("aria-modal", "true"),
      attribute("aria-label", "Select date range"),
      ..attributes
    ],
    children,
  )
}

pub fn calendar(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("space-y-3"),
      attribute("role", "grid"),
      attribute("aria-label", "Calendar"),
      attribute("aria-readonly", "true"),
      ..attributes
    ],
    children,
  )
}

pub fn header(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [class("flex items-center justify-between mb-2"), ..attributes],
    children,
  )
}

pub fn title(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("text-base font-semibold text-foreground tracking-wide"),
      attribute("role", "heading"),
      attribute("aria-live", "polite"),
      ..attributes
    ],
    children,
  )
}

pub fn nav_button(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors "
        <> css.focus_ring()
        <> " disabled:pointer-events-none "
        <> css.disabled()
        <> " h-7 w-7 hover:bg-accent hover:text-accent-foreground ",
      ),
      type_("button"),
      attribute("data-date-picker-nav", "true"),
      ..attributes
    ],
    children,
  )
}

/// Navigation button for previous month with proper aria-label.
pub fn nav_button_prev(attributes: List(Attribute(a))) -> Element(a) {
  nav_button([attribute("aria-label", "Previous month"), ..attributes], [
    chevron_left(),
  ])
}

/// Navigation button for next month with proper aria-label.
pub fn nav_button_next(attributes: List(Attribute(a))) -> Element(a) {
  nav_button([attribute("aria-label", "Next month"), ..attributes], [
    chevron_right(),
  ])
}

pub fn weekday(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "h-8 w-9 text-[11px] p-0 font-medium uppercase tracking-wider text-muted-foreground/70",
          "flex items-center justify-center",
        ]
        |> string.join(" "),
      ),
      attribute("role", "columnheader"),
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
          // Base sizing - ensure consistent cell size and perfect centering
          "relative h-9 w-9 p-0 font-normal text-sm rounded-md",
          "transition-colors duration-150 ease-in-out",
          css.focus_ring(),
          "disabled:pointer-events-none " <> css.disabled(),
          "hover:bg-accent hover:text-accent-foreground",
          // Selected dates (range start/end) - primary color with rounded ends
          "[&[data-selected='true']]:bg-primary",
          "[&[data-selected='true']]:text-primary-foreground",
          "[&[data-selected='true']]:hover:bg-primary",
          "[&[data-selected='true']]:hover:text-primary-foreground",
          "[&[data-selected='true']]:font-medium",
          // Range start - rounded right only
          "[&[data-range-start='true']]:rounded-r-none",
          "[&[data-range-start='true']]:rounded-l-md",
          "[&[data-range-start='true']]:bg-primary",
          "[&[data-range-start='true']]:text-primary-foreground",
          // Range end - rounded left only
          "[&[data-range-end='true']]:rounded-l-none",
          "[&[data-range-end='true']]:rounded-r-md",
          "[&[data-range-end='true']]:bg-primary",
          "[&[data-range-end='true']]:text-primary-foreground",
          // In-range dates - accent color with square edges
          "[&[data-in-range='true']]:bg-accent",
          "[&[data-in-range='true']]:text-accent-foreground",
          "[&[data-in-range='true']]:rounded-none",
          // Today indicator - subtle ring
          "[&[data-today='true']]:ring-1 [&[data-today='true']]:ring-primary [&[data-today='true']]:ring-offset-1",
          "[&[data-today='true']]:font-semibold",
          // Disabled dates
          "[&[data-disabled='true']]:opacity-30",
          "[&[data-disabled='true']]:pointer-events-none",
          // Outside month dates
          "[&[data-outside-month='true']]:text-muted-foreground/40",
        ]
        |> string.join(" "),
      ),
      type_("button"),
      attribute("role", "gridcell"),
      attribute("data-date-picker-day", "true"),
      ..attributes
    ],
    children,
  )
}

pub fn week(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      attribute("style", "display: contents"),
      attribute("role", "row"),
      ..attributes
    ],
    children,
  )
}

pub fn grid(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("grid grid-cols-7 gap-0.5"),
      attribute("role", "grid"),
      attribute("aria-label", "Days"),
      ..attributes
    ],
    children,
  )
}

pub fn weekdays(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("grid grid-cols-7 gap-0.5 mb-1"),
      attribute("role", "row"),
      attribute("aria-label", "Weekdays"),
      ..attributes
    ],
    children,
  )
}

pub fn range_calendar(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("grid grid-cols-2 gap-4"), ..attributes], children)
}

// ============================================================================
// Presets Component
// ============================================================================

pub fn presets(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("flex flex-wrap gap-2 p-3 border-t"), ..attributes], children)
}

pub fn preset_button(
  attributes: List(Attribute(a)),
  label: String,
) -> Element(a) {
  html.button(
    [
      class(
        "inline-flex items-center justify-center whitespace-nowrap rounded-md text-xs font-medium transition-colors "
        <> css.focus_ring()
        <> " disabled:pointer-events-none "
        <> css.disabled()
        <> " border border-input bg-background hover:bg-accent hover:text-accent-foreground h-8 px-3 ",
      ),
      type_("button"),
      attribute("data-date-range-picker-preset", "true"),
      ..attributes
    ],
    [html.text(label)],
  )
}

// ============================================================================
// Variant & Size Helpers
// ============================================================================

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input bg-background")
    Muted -> class("border-input bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  class(input_class(s))
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

pub fn value(val: String) -> Attribute(a) {
  attribute("value", val)
}

pub fn start_value(val: String) -> Attribute(a) {
  attribute("data-start-value", val)
}

pub fn end_value(val: String) -> Attribute(a) {
  attribute("data-end-value", val)
}

// ============================================================================
// Icons
// ============================================================================

pub fn calendar_icon() -> Element(a) {
  html.i(
    [class("ri ri-calendar-line h-4 w-4"), attribute("aria-hidden", "true")],
    [],
  )
}

pub fn chevron_left() -> Element(a) {
  html.i(
    [class("ri ri-arrow-left-s-line h-4 w-4"), attribute("aria-hidden", "true")],
    [],
  )
}

pub fn chevron_right() -> Element(a) {
  html.i(
    [
      class("ri ri-arrow-right-s-line h-4 w-4"),
      attribute("aria-hidden", "true"),
    ],
    [],
  )
}
