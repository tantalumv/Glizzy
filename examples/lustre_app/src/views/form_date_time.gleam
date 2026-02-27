// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Date & Time Views
////
//// Renders date/time form components: date fields, time fields, date pickers, and date range pickers.

import gleam/bool
import gleam/option.{None, Some}
import gleam/time/calendar
import types.{type Model, type Msg, DatePickerMsg, DateRangePickerMsg}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, none, text}
import lustre/element/html
import lustre/event
import lib/tailwind
import lustre_utils/date_picker as dp_utils
import lustre_utils/date_range_picker as drp_utils
import lustre_utils/date_picker_view_utils
import ui/date_field
import ui/date_picker
import ui/date_range_picker
import ui/time_field

pub fn view_date_time_controls() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Date & Time Fields"),
    tailwind.gap_6([
      html.div(
        [
          class("space-y-1"),
          attribute("data-testid", "date-field"),
          attribute("role", "group"),
          attribute("aria-label", "Date field"),
        ],
        [
          tailwind.label_text("date-field-input", "Date field (required)"),
          date_field.datefield([
            attribute("id", "date-field-input"),
            attribute("data-testid", "date-field-input"),
            attribute("aria-describedby", "date-field-hint"),
            attribute("aria-required", "true"),
            attribute("placeholder", "YYYY-MM-DD"),
          ]),
          tailwind.helper_text_text("Use arrow keys to adjust year/month/day and Space to confirm."),
        ],
      ),
      html.div(
        [
          class("space-y-1"),
          attribute("data-testid", "time-field"),
          attribute("role", "group"),
          attribute("aria-label", "Time field"),
        ],
        [
          tailwind.label_text("time-field-input", "Time field (required)"),
          time_field.timefield([
            attribute("id", "time-field-input"),
            attribute("data-testid", "time-field-input"),
            attribute("aria-describedby", "time-field-hint"),
            attribute("aria-required", "true"),
            time_field.hour_cycle(time_field.Hour24),
            time_field.value(calendar.TimeOfDay(14, 30, 0, 0)),
          ]),
          tailwind.helper_text_text("Move between segments with Tab and increment/decrement with arrows."),
        ],
      ),
    ]),
  ])
}

pub fn view_date_pickers(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Pickers & Calendars"),
    tailwind.gap_6([
      html.div(
        [
          class("space-y-1"),
          attribute("data-testid", "date-picker-block"),
        ],
        [
          html.label([class("text-sm font-medium")], [text("Date picker")]),
          html.div([class("relative")], [
            date_picker.picker([
              attribute("data-testid", "date-picker-input"),
              attribute("aria-describedby", "date-picker-hint"),
              attribute("value", case dp_utils.get_value(model.date_picker) {
                Some(date) -> date_picker_view_utils.format_date(date)
                None -> ""
              }),
              attribute(
                "aria-expanded",
                case dp_utils.is_open(model.date_picker) {
                  True -> "true"
                  False -> "false"
                },
              ),
            ]),
            html.div(
              [
                class("absolute inset-0 z-10"),
                attribute("data-testid", "date-picker-trigger-overlay"),
                event.on_click(DatePickerMsg(dp_utils.ToggleOpen)),
              ],
              [],
            ),
            bool.guard(
              dp_utils.is_open(model.date_picker),
              date_picker.content(
                [
                  attribute("data-testid", "date-picker-content"),
                  attribute("aria-expanded", "true"),
                ],
                [
                  date_picker.calendar([], [
                    date_picker.header([], [
                      date_picker.nav_button(
                        [
                          attribute("aria-label", "Previous month"),
                          event.stop_propagation(
                            event.on_click(DatePickerMsg(dp_utils.NavigatePreviousMonth)),
                          ),
                        ],
                        [date_picker.chevron_left()],
                      ),
                      date_picker.title([], [
                        text(dp_utils.format_visible_month(model.date_picker)),
                      ]),
                      date_picker.nav_button(
                        [
                          attribute("aria-label", "Next month"),
                          event.stop_propagation(
                            event.on_click(DatePickerMsg(dp_utils.NavigateNextMonth)),
                          ),
                        ],
                        [date_picker.chevron_right()],
                      ),
                    ]),
                    date_picker.grid(
                      [],
                      [
                        date_picker.week([], [
                          date_picker.weekday([], [text("Su")]),
                          date_picker.weekday([], [text("Mo")]),
                          date_picker.weekday([], [text("Tu")]),
                          date_picker.weekday([], [text("We")]),
                          date_picker.weekday([], [text("Th")]),
                          date_picker.weekday([], [text("Fr")]),
                          date_picker.weekday([], [text("Sa")]),
                        ]),
                        date_picker_view_utils.render_calendar_grid(
                          model.date_picker,
                          DatePickerMsg,
                          date_picker.week,
                          date_picker.day,
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
              fn() { none() },
            ),
          ]),
          tailwind.helper_text_text("Click input to open calendar. Arrow keys navigate dates."),
        ],
      ),
      html.div(
        [
          class("space-y-1"),
          attribute("data-testid", "date-range-picker-block"),
        ],
        [
          html.label([class("text-sm font-medium")], [text("Date range picker")]),
          html.div([class("relative")], [
            date_range_picker.picker(
              [
                attribute("data-testid", "date-range-picker-input"),
                attribute("aria-describedby", "date-range-picker-hint"),
              ],
              [
                attribute("value", case drp_utils.get_start_date(model.date_range_picker) {
                  Some(start) -> date_picker_view_utils.format_date(start)
                  None -> ""
                }),
                attribute(
                  "aria-expanded",
                  case drp_utils.is_open(model.date_range_picker) {
                    True -> "true"
                    False -> "false"
                  },
                ),
              ],
              [
                attribute("value", case drp_utils.get_end_date(model.date_range_picker) {
                  Some(end) -> date_picker_view_utils.format_date(end)
                  None -> ""
                }),
              ],
            ),
            html.div(
              [
                class("absolute inset-0 z-10"),
                attribute("data-testid", "date-range-picker-trigger-overlay"),
                event.on_click(DateRangePickerMsg(drp_utils.ToggleOpen)),
              ],
              [],
            ),
            bool.guard(
              drp_utils.is_open(model.date_range_picker),
              date_range_picker.content(
                [
                  attribute("data-testid", "date-range-picker-content"),
                  attribute("aria-expanded", "true"),
                ],
                [
                  html.div([class("flex gap-4")], [
                    date_range_picker.calendar([class("w-64")], [
                      date_range_picker.header([], [
                        date_range_picker.nav_button(
                          [
                            attribute("aria-label", "Previous month"),
                            event.stop_propagation(
                              event.on_click(DateRangePickerMsg(drp_utils.NavigatePreviousMonth)),
                            ),
                          ],
                          [date_range_picker.chevron_left()],
                        ),
                        date_range_picker.title([], [
                          text(drp_utils.format_visible_month(model.date_range_picker)),
                        ]),
                        date_range_picker.nav_button(
                          [
                            attribute("aria-label", "Next month"),
                            event.stop_propagation(
                              event.on_click(DateRangePickerMsg(drp_utils.NavigateNextMonth)),
                            ),
                          ],
                          [date_range_picker.chevron_right()],
                        ),
                      ]),
                      date_range_picker.grid(
                        [],
                        [
                          date_range_picker.week([], [
                            date_range_picker.weekday([], [text("Su")]),
                            date_range_picker.weekday([], [text("Mo")]),
                            date_range_picker.weekday([], [text("Tu")]),
                            date_range_picker.weekday([], [text("We")]),
                            date_range_picker.weekday([], [text("Th")]),
                            date_range_picker.weekday([], [text("Fr")]),
                            date_range_picker.weekday([], [text("Sa")]),
                          ]),
                          date_picker_view_utils.render_date_range_calendar_grid(
                            model.date_range_picker,
                            DateRangePickerMsg,
                            False,
                            date_range_picker.week,
                            date_range_picker.day,
                          ),
                        ],
                      ),
                    ]),
                    date_range_picker.calendar([class("w-64")], [
                      date_range_picker.header([], [
                        date_range_picker.nav_button(
                          [
                            attribute("aria-label", "Previous month"),
                            event.stop_propagation(
                              event.on_click(DateRangePickerMsg(drp_utils.NavigatePreviousMonth)),
                            ),
                          ],
                          [date_range_picker.chevron_left()],
                        ),
                        date_range_picker.title([], [
                          text(drp_utils.format_visible_month(model.date_range_picker)),
                        ]),
                        date_range_picker.nav_button(
                          [
                            attribute("aria-label", "Next month"),
                            event.stop_propagation(
                              event.on_click(DateRangePickerMsg(drp_utils.NavigateNextMonth)),
                            ),
                          ],
                          [date_range_picker.chevron_right()],
                        ),
                      ]),
                      date_range_picker.grid(
                        [],
                        [
                          date_range_picker.week([], [
                            date_range_picker.weekday([], [text("Su")]),
                            date_range_picker.weekday([], [text("Mo")]),
                            date_range_picker.weekday([], [text("Tu")]),
                            date_range_picker.weekday([], [text("We")]),
                            date_range_picker.weekday([], [text("Th")]),
                            date_range_picker.weekday([], [text("Fr")]),
                            date_range_picker.weekday([], [text("Sa")]),
                          ]),
                          date_picker_view_utils.render_date_range_calendar_grid(
                            model.date_range_picker,
                            DateRangePickerMsg,
                            True,
                            date_range_picker.week,
                            date_range_picker.day,
                          ),
                        ],
                      ),
                    ]),
                  ]),
                ],
              ),
              fn() { none() },
            ),
          ]),
          tailwind.helper_text_text("Select start and end dates. Calendar shows two months."),
        ],
      ),
    ]),
  ])
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_date_time_controls(),
    view_date_pickers(model),
  ])
}
