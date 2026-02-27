//// Date Range Picker View Helpers
////
//// Provides rendering utilities for date range picker components.
//// These helpers generate the calendar grid and day elements with proper
//// accessibility attributes and event handlers for range selection.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/date_range_picker_view
//// import lustre_utils/date_range_picker as drp
//// import ui/date_range_picker
////
//// // In your view function
//// pub fn view(model: drp.Model) -> Element(Msg) {
////   div([], [
////     date_range_picker_view.render_calendar_grid(
////       model,
////       fn(msg) { DateRangePickerMsg(msg) },
////       date_range_picker.week,
////       date_range_picker.day,
////       False, // is_second_month
////     )
////   ])
//// }
//// ```

// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/time/calendar
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element, fragment, memo, ref, text}
import lustre/event
import lustre_utils/date_range_picker as drp
import lustre_utils/date_utils

// ============================================================================
// Type Aliases for Render Functions
// ============================================================================

type WeekFn(msg) =
  fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg)

type DayFn(msg) =
  fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg)

// ============================================================================
// Calendar Grid Rendering
// ============================================================================

/// Render the calendar grid for a date range picker with memoization.
/// Takes the date range picker model, a message constructor function, render functions,
/// and a flag indicating if this is the second month in a dual-month view.
/// Returns a memoized element that only re-renders when dependencies change.
pub fn render_calendar_grid(
  drp_model: drp.Model,
  to_msg: fn(drp.Msg) -> msg,
  week_fn: WeekFn(msg),
  day_fn: DayFn(msg),
  is_second_month: Bool,
) -> Element(msg) {
  memo(
    [
      ref(drp_model.start_date),
      ref(drp_model.end_date),
      ref(drp_model.visible_month),
      ref(drp_model.focused_date),
      ref(drp_model.today),
      ref(is_second_month),
    ],
    fn() {
      render_calendar_grid_unmemoized(
        drp_model,
        to_msg,
        week_fn,
        day_fn,
        is_second_month,
      )
    },
  )
}

/// Render the calendar grid for a date range picker without memoization.
/// Internal helper used by the memoized version.
fn render_calendar_grid_unmemoized(
  drp_model: drp.Model,
  to_msg: fn(drp.Msg) -> msg,
  week_fn: WeekFn(msg),
  day_fn: DayFn(msg),
  is_second_month: Bool,
) -> Element(msg) {
  let calendar_data = case is_second_month {
    True -> drp.generate_calendar_2(drp_model)
    False -> drp.generate_calendar(drp_model)
  }
  let is_current_month_fn = case is_second_month {
    True -> drp.is_current_month_2
    False -> drp.is_current_month
  }

  let weeks =
    calendar_data
    |> list.map(fn(week) {
      week_fn(
        [],
        list.map(week, fn(maybe_date) {
          case maybe_date {
            Some(date) -> {
              let is_selected = drp.is_selected(drp_model, date)
              let is_today = drp.is_today(drp_model, date)
              let is_in_range = drp.is_in_range(drp_model, date)
              let is_range_start = drp.is_range_start(drp_model, date)
              let is_range_end = drp.is_range_end(drp_model, date)
              let is_current = is_current_month_fn(drp_model, date)
              let day_num = int.to_string(date.day)

              create_date_range_picker_day(
                drp_model,
                date,
                day_num,
                is_selected,
                is_today,
                is_in_range,
                is_range_start,
                is_range_end,
                is_current,
                to_msg,
                day_fn,
              )
            }
            None -> {
              day_fn([attribute("aria-disabled", "true")], [])
            }
          }
        }),
      )
    })

  // Wrap weeks in a fragment
  fragment(weeks)
}

// ============================================================================
// Day Cell Creation
// ============================================================================

/// Create a single day cell element for date range picker with proper attributes and events.
/// This is an internal helper used by render_calendar_grid.
fn create_date_range_picker_day(
  drp_model: drp.Model,
  date: calendar.Date,
  day_num: String,
  is_selected: Bool,
  is_today: Bool,
  is_in_range: Bool,
  is_range_start: Bool,
  is_range_end: Bool,
  is_current: Bool,
  to_msg: fn(drp.Msg) -> msg,
  day_fn: DayFn(msg),
) -> Element(msg) {
  let is_disabled = drp.is_disabled(drp_model, date)
  let is_focused = drp.is_focused(drp_model, date)
  let is_outside_month = !is_current
  let full_date_label = format_full_date_aria(date)

  // Build base attributes list
  let base_attrs = [
    attribute("aria-label", full_date_label),
    attribute("aria-selected", case is_selected {
      True -> "true"
      False -> "false"
    }),
    attribute("aria-disabled", case is_disabled {
      True -> "true"
      False -> "false"
    }),
  ]

  // Conditionally add data attributes only when true
  let data_attrs =
    []
    |> list.append(case is_today {
      True -> [attribute("data-today", "true")]
      False -> []
    })
    |> list.append(case is_selected {
      True -> [attribute("data-selected", "true")]
      False -> []
    })
    |> list.append(case is_range_start {
      True -> [attribute("data-range-start", "true")]
      False -> []
    })
    |> list.append(case is_range_end {
      True -> [attribute("data-range-end", "true")]
      False -> []
    })
    |> list.append(case is_in_range {
      True -> [attribute("data-in-range", "true")]
      False -> []
    })
    |> list.append(case is_outside_month {
      True -> [attribute("data-outside-month", "true")]
      False -> []
    })
    |> list.append(case is_focused {
      True -> [attribute("data-focused", "true")]
      False -> []
    })

  // Roving tabindex
  let tabindex_attr = [
    attribute("tabindex", case is_focused {
      True -> "0"
      False ->
        case is_current && !is_selected {
          True -> "-1"
          False -> "-1"
        }
    }),
  ]

  // Add event handlers only if not disabled
  let event_attrs = case is_disabled {
    True -> []
    False -> [
      event.on_click(to_msg(drp.SelectDate(date))),
      event.on_mouse_enter(to_msg(drp.SetHoverDate(date))),
      event.on_mouse_leave(to_msg(drp.ClearHoverDate)),
      event.on_keydown(fn(key) {
        to_msg(case key {
          "ArrowLeft" -> drp.FocusPreviousDay
          "ArrowRight" -> drp.FocusNextDay
          "ArrowUp" -> drp.FocusPreviousWeek
          "ArrowDown" -> drp.FocusNextWeek
          "Enter" | " " -> drp.SelectFocusedDate
          _ -> drp.NoOp
        })
      }),
    ]
  }

  day_fn(
    base_attrs
      |> list.append(data_attrs)
      |> list.append(tabindex_attr)
      |> list.append(event_attrs),
    [text(day_num)],
  )
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Format a date for aria-label accessibility attribute.
/// Returns a human-readable date string like "Monday, January 15, 2024".
pub fn format_full_date_aria(date: calendar.Date) -> String {
  date_utils.format_full_date_aria(date)
}
