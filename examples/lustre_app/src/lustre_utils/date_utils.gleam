import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/time/calendar

pub type Weekday {
  Sunday
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
}

pub fn days_in_month(year: Int, month: calendar.Month) -> Int {
  case month {
    calendar.January
    | calendar.March
    | calendar.May
    | calendar.July
    | calendar.August
    | calendar.October
    | calendar.December -> 31
    calendar.April | calendar.June | calendar.September | calendar.November ->
      30
    calendar.February -> {
      case calendar.is_leap_year(year) {
        True -> 29
        False -> 28
      }
    }
  }
}

pub fn add_days(date: calendar.Date, delta: Int) -> calendar.Date {
  let calendar.Date(year, month, day) = date
  let new_day = day + delta

  let max_day = days_in_month(year, month)

  case new_day {
    n if n > max_day -> {
      let next_month_date = calendar.Date(year, month, max_day)
      add_days(add_months(next_month_date, 1), n - max_day)
    }
    n if n < 1 -> {
      let prev_month_date = add_months(calendar.Date(year, month, 1), -1)
      let prev_month_max =
        days_in_month(prev_month_date.year, prev_month_date.month)
      add_days(prev_month_date, n + prev_month_max - 1)
    }
    _ -> calendar.Date(year, month, new_day)
  }
}

pub fn add_months(date: calendar.Date, delta: Int) -> calendar.Date {
  let calendar.Date(year, month, day) = date
  let month_int = calendar.month_to_int(month)

  let new_total = month_int + delta
  let new_year = case new_total > 0 {
    True -> year + { new_total - 1 } / 12
    False -> year - 1 + { new_total } / 12
  }

  let new_month_int = case new_total > 0 {
    True -> { new_total - 1 } % 12 + 1
    False -> {
      let m = new_total % 12
      case m == 0 {
        True -> 12
        False -> 12 + m
      }
    }
  }

  let new_month =
    calendar.month_from_int(new_month_int)
    |> result.unwrap(calendar.January)

  let max_day = days_in_month(new_year, new_month)
  let new_day = int.min(day, max_day)

  calendar.Date(new_year, new_month, new_day)
}

pub fn add_years(date: calendar.Date, delta: Int) -> calendar.Date {
  let calendar.Date(year, month, day) = date
  let new_year = year + delta

  let new_day = case month == calendar.February && day == 29 {
    True ->
      case calendar.is_leap_year(new_year) {
        True -> 29
        False -> 28
      }
    False -> day
  }

  calendar.Date(new_year, month, new_day)
}

fn zeller_h(date: calendar.Date) -> Int {
  let calendar.Date(year, month, day) = date
  let m = calendar.month_to_int(month)

  let adjusted_year = case m <= 2 {
    True -> year - 1
    False -> year
  }
  let adjusted_month = case m <= 2 {
    True -> m + 12
    False -> m
  }

  let k = adjusted_year % 100
  let j = adjusted_year / 100

  let h = day + { 13 * { adjusted_month + 1 } } / 5 + k + k / 4 + j / 4 - 2 * j
  let result = h % 7

  case result < 0 {
    True -> result + 7
    False -> result
  }
}

pub fn weekday_index(date: calendar.Date) -> Int {
  let h = zeller_h(date)
  { h + 6 } % 7
}

pub fn weekday(date: calendar.Date) -> Weekday {
  case weekday_index(date) {
    0 -> Sunday
    1 -> Monday
    2 -> Tuesday
    3 -> Wednesday
    4 -> Thursday
    5 -> Friday
    6 -> Saturday
    _ -> Sunday
  }
}

pub fn get_first_day_of_month(date: calendar.Date) -> calendar.Date {
  let calendar.Date(year, month, _) = date
  calendar.Date(year, month, 1)
}

pub fn get_last_day_of_month(date: calendar.Date) -> calendar.Date {
  let calendar.Date(year, month, _) = date
  let day = days_in_month(year, month)
  calendar.Date(year, month, day)
}

pub fn generate_calendar_grid(
  base_date: calendar.Date,
) -> List(List(Option(calendar.Date))) {
  let calendar.Date(year, month, _) = base_date
  let first_day = get_first_day_of_month(base_date)
  let first_weekday = weekday_index(first_day)
  let num_days = days_in_month(year, month)

  let cells =
    int.range(from: 0, to: 42, with: [], run: fn(acc, i) {
      let day_index = i - first_weekday + 1
      let cell = case day_index < 1 || day_index > num_days {
        True -> None
        False -> Some(calendar.Date(year, month, day_index))
      }
      [cell, ..acc]
    })
    |> list.reverse

  chunk_into_weeks(cells)
}

fn chunk_into_weeks(
  cells: List(Option(calendar.Date)),
) -> List(List(Option(calendar.Date))) {
  case cells {
    [] -> []
    _ -> {
      let week = cells |> list.take(7)
      let remaining = cells |> list.drop(7)
      [week, ..chunk_into_weeks(remaining)]
    }
  }
}

pub fn format_month_year(date: calendar.Date) -> String {
  let calendar.Date(year, month, _) = date
  calendar.month_to_string(month) <> " " <> int.to_string(year)
}

pub fn format_date_numeric(date: calendar.Date) -> String {
  let month_num = calendar.month_to_int(date.month)
  let month_str = case month_num {
    1 -> "01"
    2 -> "02"
    3 -> "03"
    4 -> "04"
    5 -> "05"
    6 -> "06"
    7 -> "07"
    8 -> "08"
    9 -> "09"
    10 -> "10"
    11 -> "11"
    12 -> "12"
    _ -> "01"
  }
  int.to_string(date.day) <> "-" <> month_str <> "-" <> int.to_string(date.year)
}

pub fn format_date_display(date: calendar.Date) -> String {
  calendar.month_to_string(date.month) <> " " <> int.to_string(date.day)
}

pub fn format_full_date_aria(date: calendar.Date) -> String {
  let weekday_str = case weekday(date) {
    Sunday -> "Sunday"
    Monday -> "Monday"
    Tuesday -> "Tuesday"
    Wednesday -> "Wednesday"
    Thursday -> "Thursday"
    Friday -> "Friday"
    Saturday -> "Saturday"
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
  <> int.to_string(date.day)
  <> ", "
  <> int.to_string(date.year)
}

pub fn is_same_date(one: calendar.Date, other: calendar.Date) -> Bool {
  calendar.naive_date_compare(one, other) == order.Eq
}

pub fn is_in_range(
  date: calendar.Date,
  start: calendar.Date,
  end: calendar.Date,
) -> Bool {
  let after_start = calendar.naive_date_compare(date, start) != order.Lt
  let before_end = calendar.naive_date_compare(date, end) != order.Gt
  after_start && before_end
}

pub fn compare_dates(a: calendar.Date, b: calendar.Date) -> order.Order {
  calendar.naive_date_compare(a, b)
}
