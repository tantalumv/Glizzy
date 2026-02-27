//// Date Picker View Helpers
////
//// Provides rendering utilities for date picker components.
//// These helpers generate the calendar grid and day elements with proper
//// accessibility attributes and event handlers.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/date_picker_view
//// import lustre_utils/date_picker as dp
//// import ui/date_picker
////
//// // In your view function
//// pub fn view(model: dp.Model) -> Element(Msg) {
////   div([], [
////     date_picker_view.render_calendar_grid(
////       model,
////       fn(msg) { DatePickerMsg(msg) },
////       date_picker.week,
////       date_picker.day,
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
import lustre_utils/date_picker as dp
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

/// Render the calendar grid for a date picker with memoization.
/// Takes the date picker model, a message constructor function, and render functions.
/// Returns a memoized element that only re-renders when dependencies change.
pub fn render_calendar_grid(
  dp_model: dp.Model,
  to_msg: fn(dp.Msg) -> msg,
  week_fn: WeekFn(msg),
  day_fn: DayFn(msg),
) -> Element(msg) {
  memo(
    [
      ref(dp_model.visible_month),
      ref(dp_model.value),
      ref(dp_model.focused_date),
      ref(dp_model.today),
    ],
    fn() { render_calendar_grid_unmemoized(dp_model, to_msg, week_fn, day_fn) },
  )
}

/// Render the calendar grid for a date picker without memoization.
/// Internal helper used by the memoized version.
fn render_calendar_grid_unmemoized(
  dp_model: dp.Model,
  to_msg: fn(dp.Msg) -> msg,
  week_fn: WeekFn(msg),
  day_fn: DayFn(msg),
) -> Element(msg) {
  let weeks =
    dp.generate_calendar(dp_model)
    |> list.map(fn(week) {
      week_fn(
        [],
        list.map(week, fn(maybe_date) {
          case maybe_date {
            Some(date) -> {
              let is_selected = dp.is_selected(dp_model, date)
              let is_today = dp.is_today(dp_model, date)
              let is_current_month = dp.is_current_month(dp_model, date)
              let is_focused = dp.is_focused(dp_model, date)
              let day_num = int.to_string(date.day)

              create_date_picker_day(
                date,
                day_num,
                is_selected,
                is_today,
                is_current_month,
                is_focused,
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

/// Create a single day cell element with proper attributes and events.
/// This is an internal helper used by render_calendar_grid.
fn create_date_picker_day(
  date: calendar.Date,
  day_num: String,
  is_selected: Bool,
  is_today: Bool,
  is_current_month: Bool,
  is_focused: Bool,
  to_msg: fn(dp.Msg) -> msg,
  day_fn: DayFn(msg),
) -> Element(msg) {
  let full_date_label = format_full_date_aria(date)

  // Build base attributes
  let base_attrs = [
    attribute("aria-label", full_date_label),
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
    |> list.append(case is_focused {
      True -> [attribute("data-focused", "true")]
      False -> []
    })

  // Roving tabindex
  let tabindex_attr = [
    attribute("tabindex", case is_focused {
      True -> "0"
      False ->
        case is_current_month && !is_selected {
          True -> "-1"
          False -> "-1"
        }
    }),
  ]

  let event_attrs = [
    event.on_click(to_msg(dp.SelectDate(date))),
    event.on_keydown(fn(key) {
      to_msg(case key {
        "ArrowLeft" -> dp.FocusPreviousDay
        "ArrowRight" -> dp.FocusNextDay
        "ArrowUp" -> dp.FocusPreviousWeek
        "ArrowDown" -> dp.FocusNextWeek
        "Enter" | " " -> dp.SelectFocusedDate
        _ -> dp.NoOp
      })
    }),
  ]

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
