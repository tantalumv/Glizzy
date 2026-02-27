import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/time/calendar
import lustre_utils/date_utils
import lustre_utils/keyboard

pub type Model {
  Model(
    value: Option(calendar.Date),
    is_open: Bool,
    visible_month: calendar.Date,
    today: calendar.Date,
    focused_date: Option(calendar.Date),
    // Multi-char type-ahead for day input (e.g., "15" for 15th)
    typeahead_buffer: String,
    typeahead_timeout: Int,
  )
}

pub type Msg {
  ToggleOpen
  Open
  Close
  SelectDate(calendar.Date)
  NavigatePreviousMonth
  NavigateNextMonth
  NavigatePreviousYear
  NavigateNextYear
  GoToToday
  FocusPreviousDay
  FocusNextDay
  FocusPreviousWeek
  FocusNextWeek
  SelectFocusedDate
  TypeAhead(String)
  NoOp
}

pub fn init(today: calendar.Date) -> Model {
  Model(
    value: None,
    is_open: False,
    visible_month: date_utils.get_first_day_of_month(today),
    today: today,
    focused_date: None,
    typeahead_buffer: "",
    typeahead_timeout: 0,
  )
}

pub fn update(model: Model, msg: Msg, current_time: Int) -> Model {
  case msg {
    ToggleOpen -> {
      let new_is_open = !model.is_open
      // When opening, ensure visible month shows the selected date if one exists
      case new_is_open {
        True -> {
          case model.value {
            Some(selected_date) -> {
              let selected_month =
                date_utils.get_first_day_of_month(selected_date)
              Model(..model, is_open: True, visible_month: selected_month)
            }
            None -> Model(..model, is_open: True)
          }
        }
        False -> Model(..model, is_open: False)
      }
    }
    Open -> Model(..model, is_open: True)
    Close -> Model(..model, is_open: False)
    SelectDate(date) ->
      Model(
        ..model,
        value: Some(date),
        is_open: False,
        focused_date: Some(date),
        typeahead_buffer: "",
      )
    NavigatePreviousMonth -> {
      let new_month = date_utils.add_months(model.visible_month, -1)
      Model(..model, visible_month: new_month, typeahead_buffer: "")
    }
    NavigateNextMonth -> {
      let new_month = date_utils.add_months(model.visible_month, 1)
      Model(..model, visible_month: new_month, typeahead_buffer: "")
    }
    NavigatePreviousYear -> {
      let new_month = date_utils.add_years(model.visible_month, -1)
      Model(..model, visible_month: new_month, typeahead_buffer: "")
    }
    NavigateNextYear -> {
      let new_month = date_utils.add_years(model.visible_month, 1)
      Model(..model, visible_month: new_month, typeahead_buffer: "")
    }
    GoToToday ->
      Model(
        ..model,
        visible_month: date_utils.get_first_day_of_month(model.today),
        focused_date: Some(model.today),
        typeahead_buffer: "",
      )
    FocusPreviousDay -> focus_day(model, -1) |> clear_typeahead
    FocusNextDay -> focus_day(model, 1) |> clear_typeahead
    FocusPreviousWeek -> focus_day(model, -7) |> clear_typeahead
    FocusNextWeek -> focus_day(model, 7) |> clear_typeahead
    SelectFocusedDate ->
      case model.focused_date {
        Some(date) ->
          Model(
            ..model,
            value: Some(date),
            is_open: False,
            typeahead_buffer: "",
          )
        None -> model
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
          case day >= 1 {
            True -> {
              let base_date = calendar.Date(year, month, 1)
              let target_date = date_utils.add_days(base_date, day - 1)
              Model(
                ..model,
                focused_date: Some(target_date),
                typeahead_buffer: new_buffer,
                typeahead_timeout: current_time,
              )
            }
            False ->
              Model(
                ..model,
                typeahead_buffer: new_buffer,
                typeahead_timeout: current_time,
              )
          }
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
  }
}

fn clear_typeahead(model: Model) -> Model {
  Model(..model, typeahead_buffer: "")
}

fn focus_day(model: Model, days: Int) -> Model {
  let start_date = case model.focused_date {
    Some(date) -> date
    None -> model.today
  }
  let new_date = date_utils.add_days(start_date, days)
  Model(
    ..model,
    focused_date: Some(new_date),
    visible_month: date_utils.get_first_day_of_month(new_date),
  )
}

pub fn is_selected(model: Model, date: calendar.Date) -> Bool {
  case model.value {
    Some(selected) -> date_utils.is_same_date(selected, date)
    None -> False
  }
}

pub fn is_today(model: Model, date: calendar.Date) -> Bool {
  date_utils.is_same_date(model.today, date)
}

pub fn is_focused(model: Model, date: calendar.Date) -> Bool {
  case model.focused_date {
    Some(focused) -> date_utils.is_same_date(focused, date)
    None -> False
  }
}

pub fn is_current_month(model: Model, date: calendar.Date) -> Bool {
  let calendar.Date(year, month, _) = model.visible_month
  let calendar.Date(date_year, date_month, _) = date
  year == date_year && month == date_month
}

pub fn format_visible_month(model: Model) -> String {
  date_utils.format_month_year(model.visible_month)
}

pub fn generate_calendar(model: Model) -> List(List(Option(calendar.Date))) {
  date_utils.generate_calendar_grid(model.visible_month)
}

pub fn get_value(model: Model) -> Option(calendar.Date) {
  model.value
}

pub fn is_open(model: Model) -> Bool {
  model.is_open
}

/// Get the element ID for a day button.
pub fn day_element_id(date: calendar.Date) -> String {
  let calendar.Date(year, month, day) = date
  let month_int = case month {
    calendar.January -> 1
    calendar.February -> 2
    calendar.March -> 3
    calendar.April -> 4
    calendar.May -> 5
    calendar.June -> 6
    calendar.July -> 7
    calendar.August -> 8
    calendar.September -> 9
    calendar.October -> 10
    calendar.November -> 11
    calendar.December -> 12
  }
  "date-"
  <> int.to_string(year)
  <> "-"
  <> int.to_string(month_int)
  <> "-"
  <> int.to_string(day)
}

/// Keymap for date picker calendar.
/// Follows WAI-ARIA date picker pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowLeft if !key_event.ctrl -> Some(FocusPreviousDay)
    keyboard.ArrowRight if !key_event.ctrl -> Some(FocusNextDay)
    keyboard.ArrowUp if !key_event.ctrl -> Some(FocusPreviousWeek)
    keyboard.ArrowDown if !key_event.ctrl -> Some(FocusNextWeek)
    keyboard.PageUp if !key_event.ctrl -> Some(NavigatePreviousMonth)
    keyboard.PageDown if !key_event.ctrl -> Some(NavigateNextMonth)
    keyboard.PageUp if key_event.ctrl -> Some(NavigatePreviousYear)
    keyboard.PageDown if key_event.ctrl -> Some(NavigateNextYear)
    keyboard.Enter | keyboard.Space -> Some(SelectFocusedDate)
    keyboard.Escape -> Some(Close)
    keyboard.Character(c) -> {
      case is_digit(c) {
        True -> Some(TypeAhead(c))
        False -> None
      }
    }
    _ -> None
  }
}

fn is_digit(c: String) -> Bool {
  c == "0"
  || c == "1"
  || c == "2"
  || c == "3"
  || c == "4"
  || c == "5"
  || c == "6"
  || c == "7"
  || c == "8"
  || c == "9"
}
