import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/time/calendar
import lustre_utils/date_utils
import lustre_utils/keyboard

// ============================================================================
// Types
// ============================================================================

pub type SelectionState {
  Idle
  SelectingStart
  SelectingEnd
}

pub type Model {
  Model(
    start_date: Option(calendar.Date),
    end_date: Option(calendar.Date),
    hover_date: Option(calendar.Date),
    focused_date: Option(calendar.Date),
    is_open: Bool,
    visible_month: calendar.Date,
    today: calendar.Date,
    selection_state: SelectionState,
    min_date: Option(calendar.Date),
    max_date: Option(calendar.Date),
    // Multi-char type-ahead for day input
    typeahead_buffer: String,
    typeahead_timeout: Int,
  )
}

pub type Msg {
  ToggleOpen
  Open
  Close
  SelectDate(calendar.Date)
  SetHoverDate(calendar.Date)
  ClearHoverDate
  NavigatePreviousMonth
  NavigateNextMonth
  NavigatePreviousMonth2
  NavigateNextMonth2
  GoToToday
  ClearSelection
  // Keyboard navigation
  FocusPreviousDay
  FocusNextDay
  FocusPreviousWeek
  FocusNextWeek
  FocusFirstDayOfMonth
  FocusLastDayOfMonth
  SelectFocusedDate
  TypeAhead(String)
  NoOp
  // Presets
  SelectPreset(Preset)
}

pub type Preset {
  Today
  Yesterday
  Last7Days
  Last30Days
  ThisMonth
}

// ============================================================================
// Initialization
// ============================================================================

pub fn init(today: calendar.Date) -> Model {
  let first_month = date_utils.get_first_day_of_month(today)
  Model(
    start_date: None,
    end_date: None,
    hover_date: None,
    focused_date: None,
    is_open: False,
    visible_month: first_month,
    today: today,
    selection_state: Idle,
    min_date: None,
    max_date: None,
    typeahead_buffer: "",
    typeahead_timeout: 0,
  )
}

pub fn init_with_limits(
  today: calendar.Date,
  _min_date: Option(calendar.Date),
  _max_date: Option(calendar.Date),
) -> Model {
  let first_month = date_utils.get_first_day_of_month(today)
  Model(
    start_date: None,
    end_date: None,
    hover_date: None,
    focused_date: None,
    is_open: False,
    visible_month: first_month,
    today: today,
    selection_state: Idle,
    min_date: None,
    max_date: None,
    typeahead_buffer: "",
    typeahead_timeout: 0,
  )
}

// ============================================================================
// Update
// ============================================================================

pub fn update(model: Model, msg: Msg, current_time: Int) -> Model {
  case msg {
    ToggleOpen -> Model(..model, is_open: !model.is_open)
    Open -> Model(..model, is_open: True)
    Close -> Model(..model, is_open: False, hover_date: None)

    SelectDate(date) -> {
      case is_disabled(model, date) {
        True -> model
        False -> handle_date_selection(model, date)
      }
    }

    SetHoverDate(date) -> Model(..model, hover_date: Some(date))
    ClearHoverDate -> Model(..model, hover_date: None)

    NavigatePreviousMonth -> {
      let new_month = date_utils.add_months(model.visible_month, -1)
      case model.min_date {
        Some(min) -> {
          case date_utils.compare_dates(new_month, min) {
            order.Lt -> model
            _ -> Model(..model, visible_month: new_month)
          }
        }
        None -> Model(..model, visible_month: new_month)
      }
    }

    NavigateNextMonth -> {
      let new_month = date_utils.add_months(model.visible_month, 1)
      let first_of_new_month = date_utils.get_first_day_of_month(new_month)
      case model.max_date {
        Some(max) -> {
          case date_utils.compare_dates(first_of_new_month, max) == order.Gt {
            True -> model
            False -> Model(..model, visible_month: new_month)
          }
        }
        None -> Model(..model, visible_month: new_month)
      }
    }

    NavigatePreviousMonth2 -> {
      let new_month = date_utils.add_months(model.visible_month, -1)
      case model.min_date {
        Some(min) -> {
          case date_utils.compare_dates(new_month, min) {
            order.Lt -> model
            _ -> Model(..model, visible_month: new_month)
          }
        }
        None -> Model(..model, visible_month: new_month)
      }
    }

    NavigateNextMonth2 -> {
      let new_month = date_utils.add_months(model.visible_month, 1)
      let first_of_new_month = date_utils.get_first_day_of_month(new_month)
      case model.max_date {
        Some(max) -> {
          case date_utils.compare_dates(first_of_new_month, max) == order.Gt {
            True -> model
            False -> Model(..model, visible_month: new_month)
          }
        }
        None -> Model(..model, visible_month: new_month)
      }
    }

    GoToToday -> {
      let first_month = date_utils.get_first_day_of_month(model.today)
      Model(..model, visible_month: first_month)
    }

    ClearSelection -> {
      Model(
        ..model,
        start_date: None,
        end_date: None,
        hover_date: None,
        focused_date: None,
      )
    }

    // Keyboard navigation
    FocusPreviousDay -> focus_day(model, -1) |> clear_typeahead
    FocusNextDay -> focus_day(model, 1) |> clear_typeahead
    FocusPreviousWeek -> focus_day(model, -7) |> clear_typeahead
    FocusNextWeek -> focus_day(model, 7) |> clear_typeahead
    FocusFirstDayOfMonth -> {
      let first = date_utils.get_first_day_of_month(model.visible_month)
      Model(..model, focused_date: Some(first), typeahead_buffer: "")
    }
    FocusLastDayOfMonth -> {
      let last = date_utils.get_last_day_of_month(model.visible_month)
      Model(..model, focused_date: Some(last), typeahead_buffer: "")
    }
    SelectFocusedDate -> {
      case model.focused_date {
        Some(date) -> handle_date_selection(model, date) |> clear_typeahead
        None -> model
      }
    }
    TypeAhead(char) -> {
      let #(new_buffer, _reset) =
        keyboard.update_typeahead_buffer(
          model.typeahead_buffer,
          model.typeahead_timeout,
          current_time,
          char,
          keyboard.default_typeahead_timeout_ms,
        )
      // Parse buffer as day number and focus that day in current month
      case int.parse(new_buffer) {
        Ok(day) if day >= 1 && day <= 31 -> {
          let calendar.Date(year, month, _) = model.visible_month
          // Create date by starting at day 1 and adding offset
          let base_date = calendar.Date(year, month, 1)
          let target_date = date_utils.add_days(base_date, day - 1)
          Model(
            ..model,
            focused_date: Some(target_date),
            typeahead_buffer: new_buffer,
            typeahead_timeout: current_time,
          )
        }
        _ ->
          Model(
            ..model,
            typeahead_buffer: new_buffer,
            typeahead_timeout: current_time,
          )
      }
    }

    NoOp -> model

    SelectPreset(preset) -> select_preset(model, preset)
  }
}

fn clear_typeahead(model: Model) -> Model {
  Model(..model, typeahead_buffer: "")
}

fn focus_day(model: Model, days: Int) -> Model {
  case model.focused_date {
    Some(current) -> {
      let new_date = date_utils.add_days(current, days)
      Model(..model, focused_date: Some(new_date))
    }
    None -> {
      case model.start_date {
        Some(start) -> Model(..model, focused_date: Some(start))
        None -> Model(..model, focused_date: Some(model.today))
      }
    }
  }
}

fn handle_date_selection(model: Model, date: calendar.Date) -> Model {
  case model.selection_state {
    Idle -> {
      // Start new selection from idle state
      Model(
        ..model,
        start_date: Some(date),
        end_date: None,
        focused_date: Some(date),
        selection_state: SelectingEnd,
        hover_date: None,
      )
    }
    SelectingEnd -> {
      // Complete the range or toggle off
      case model.start_date {
        Some(start) -> {
          case date_utils.compare_dates(date, start) {
            order.Gt -> {
              // Valid range: start < end
              Model(
                ..model,
                end_date: Some(date),
                selection_state: Idle,
                hover_date: None,
              )
            }
            order.Lt -> {
              // Swap - clicked date is before start, so it becomes new start
              Model(
                ..model,
                start_date: Some(date),
                end_date: None,
                selection_state: SelectingEnd,
                hover_date: None,
              )
            }
            order.Eq -> {
              // Same date twice - toggle off
              Model(
                ..model,
                start_date: None,
                end_date: None,
                selection_state: Idle,
                hover_date: None,
              )
            }
          }
        }
        None -> {
          // Shouldn't happen, but handle gracefully
          Model(..model, start_date: Some(date), selection_state: SelectingEnd)
        }
      }
    }
    SelectingStart -> {
      // This state is used when user selects end date first (swapped)
      // Complete range
      case model.start_date {
        Some(start) -> {
          case date_utils.compare_dates(date, start) {
            order.Gt -> {
              Model(
                ..model,
                end_date: Some(date),
                selection_state: Idle,
                hover_date: None,
              )
            }
            order.Lt -> {
              // Swap - new date becomes start
              Model(
                ..model,
                start_date: Some(date),
                end_date: None,
                selection_state: SelectingEnd,
                hover_date: None,
              )
            }
            order.Eq -> {
              // Same date twice - toggle off
              Model(
                ..model,
                start_date: None,
                end_date: None,
                selection_state: Idle,
                hover_date: None,
              )
            }
          }
        }
        None -> model
      }
    }
  }
}

// ============================================================================
// Helpers - Date checks
// ============================================================================

pub fn is_disabled(model: Model, date: calendar.Date) -> Bool {
  let min_disabled = case model.min_date {
    Some(min) -> date_utils.compare_dates(date, min) == order.Lt
    None -> False
  }
  let max_disabled = case model.max_date {
    Some(max) -> date_utils.compare_dates(date, max) == order.Gt
    None -> False
  }
  min_disabled || max_disabled
}

pub fn is_in_range(model: Model, date: calendar.Date) -> Bool {
  case model.start_date, model.end_date {
    // Complete range
    Some(start), Some(end) -> date_utils.is_in_range(date, start, end)

    // Preview range (start selected, hovering)
    Some(start), None -> {
      case model.hover_date {
        Some(hover) -> {
          let #(range_start, range_end) = normalize_range(start, hover)
          date_utils.is_in_range(date, range_start, range_end)
        }
        None -> False
      }
    }

    None, _ -> False
  }
}

pub fn is_range_start(model: Model, date: calendar.Date) -> Bool {
  case model.start_date {
    Some(start) -> date_utils.is_same_date(start, date)
    None -> False
  }
}

pub fn is_range_end(model: Model, date: calendar.Date) -> Bool {
  case model.end_date {
    Some(end) -> date_utils.is_same_date(end, date)
    None -> False
  }
}

pub fn is_start_or_end(model: Model, date: calendar.Date) -> Bool {
  is_range_start(model, date) || is_range_end(model, date)
}

pub fn is_selected(model: Model, date: calendar.Date) -> Bool {
  case model.start_date, model.end_date {
    Some(start), Some(end) ->
      date_utils.is_same_date(date, start) || date_utils.is_same_date(date, end)
    Some(start), None -> date_utils.is_same_date(date, start)
    None, _ -> False
  }
}

pub fn is_focused(model: Model, date: calendar.Date) -> Bool {
  case model.focused_date {
    Some(focused) -> date_utils.is_same_date(focused, date)
    None -> False
  }
}

pub fn is_today(model: Model, date: calendar.Date) -> Bool {
  date_utils.is_same_date(model.today, date)
}

pub fn is_current_month(model: Model, date: calendar.Date) -> Bool {
  let calendar.Date(year, month, _) = model.visible_month
  let calendar.Date(date_year, date_month, _) = date
  year == date_year && month == date_month
}

pub fn is_current_month_2(model: Model, date: calendar.Date) -> Bool {
  let month_2 = visible_month_2(model)
  let calendar.Date(year, month, _) = month_2
  let calendar.Date(date_year, date_month, _) = date
  year == date_year && month == date_month
}

// ============================================================================
// Formatting
// ============================================================================

pub fn format_visible_month(model: Model) -> String {
  date_utils.format_month_year(model.visible_month)
}

pub fn format_visible_month_2(model: Model) -> String {
  date_utils.format_month_year(visible_month_2(model))
}

pub fn format_full_date(date: calendar.Date) -> String {
  let weekday_str = case date_utils.weekday(date) {
    date_utils.Sunday -> "Sunday"
    date_utils.Monday -> "Monday"
    date_utils.Tuesday -> "Tuesday"
    date_utils.Wednesday -> "Wednesday"
    date_utils.Thursday -> "Thursday"
    date_utils.Friday -> "Friday"
    date_utils.Saturday -> "Saturday"
  }
  let month_str = case date.month {
    calendar.January -> "January"
    calendar.February -> "February"
    calendar.March -> "March"
    calendar.April -> "April"
    calendar.May -> "May"
    calendar.June -> "June"
    calendar.July -> "July"
    calendar.August -> "August"
    calendar.September -> "September"
    calendar.October -> "October"
    calendar.November -> "November"
    calendar.December -> "December"
  }
  weekday_str
  <> ", "
  <> month_str
  <> " "
  <> int_to_string(date.day)
  <> ", "
  <> int_to_string(date.year)
}

// Simple int to string conversion (avoiding gleam/int import issues)
fn int_to_string(n: Int) -> String {
  case n {
    0 -> "0"
    1 -> "1"
    2 -> "2"
    3 -> "3"
    4 -> "4"
    5 -> "5"
    6 -> "6"
    7 -> "7"
    8 -> "8"
    9 -> "9"
    10 -> "10"
    11 -> "11"
    12 -> "12"
    13 -> "13"
    14 -> "14"
    15 -> "15"
    16 -> "16"
    17 -> "17"
    18 -> "18"
    19 -> "19"
    20 -> "20"
    21 -> "21"
    22 -> "22"
    23 -> "23"
    24 -> "24"
    25 -> "25"
    26 -> "26"
    27 -> "27"
    28 -> "28"
    29 -> "29"
    30 -> "30"
    31 -> "31"
    _ -> {
      // Fallback for years
      case n < 0 {
        True -> "-" <> int_to_string(-n)
        False -> {
          let digit = n % 10
          let rest = n / 10
          case rest == 0 {
            True -> int_to_string(digit)
            False -> int_to_string(rest) <> int_to_string(digit)
          }
        }
      }
    }
  }
}

// ============================================================================
// Calendar grid generation
// ============================================================================

pub fn generate_calendar(model: Model) -> List(List(Option(calendar.Date))) {
  date_utils.generate_calendar_grid(model.visible_month)
}

pub fn generate_calendar_2(model: Model) -> List(List(Option(calendar.Date))) {
  date_utils.generate_calendar_grid(visible_month_2(model))
}

pub fn visible_month_2(model: Model) -> calendar.Date {
  date_utils.add_months(model.visible_month, 1)
}

// ============================================================================
// Getters
// ============================================================================

pub fn get_start_date(model: Model) -> Option(calendar.Date) {
  model.start_date
}

pub fn get_end_date(model: Model) -> Option(calendar.Date) {
  model.end_date
}

pub fn get_focused_date(model: Model) -> Option(calendar.Date) {
  model.focused_date
}

pub fn is_open(model: Model) -> Bool {
  model.is_open
}

pub fn get_selection_state(model: Model) -> SelectionState {
  model.selection_state
}

pub fn get_min_date(model: Model) -> Option(calendar.Date) {
  model.min_date
}

pub fn get_max_date(model: Model) -> Option(calendar.Date) {
  model.max_date
}

// ============================================================================
// Presets
// ============================================================================

pub fn get_preset_range(
  preset: Preset,
  today: calendar.Date,
) -> #(calendar.Date, calendar.Date) {
  case preset {
    Today -> #(today, today)
    Yesterday -> {
      let yesterday = date_utils.add_days(today, -1)
      #(yesterday, yesterday)
    }
    Last7Days -> #(date_utils.add_days(today, -6), today)
    Last30Days -> #(date_utils.add_days(today, -29), today)
    ThisMonth -> {
      let first = date_utils.get_first_day_of_month(today)
      let last = date_utils.get_last_day_of_month(today)
      #(first, last)
    }
  }
}

pub fn select_preset(model: Model, preset: Preset) -> Model {
  let #(start, end) = get_preset_range(preset, model.today)
  Model(
    ..model,
    start_date: Some(start),
    end_date: Some(end),
    selection_state: Idle,
    hover_date: None,
    focused_date: Some(end),
  )
}

// ============================================================================
// Internal helpers
// ============================================================================

fn normalize_range(
  a: calendar.Date,
  b: calendar.Date,
) -> #(calendar.Date, calendar.Date) {
  case date_utils.compare_dates(a, b) {
    order.Lt -> #(a, b)
    order.Eq -> #(a, b)
    order.Gt -> #(b, a)
  }
}
