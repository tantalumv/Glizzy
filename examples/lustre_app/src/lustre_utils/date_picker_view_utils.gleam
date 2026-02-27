import gleam/time/calendar
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre_utils/date_picker as dp_utils
import lustre_utils/date_picker_view as dp_view
import lustre_utils/date_range_picker as drp_utils
import lustre_utils/date_range_picker_view as drp_view
import lustre_utils/date_utils

pub fn format_date(date: calendar.Date) -> String {
  date_utils.format_date_numeric(date)
}

pub fn format_date_display(date: calendar.Date) -> String {
  date_utils.format_date_display(date)
}

pub fn render_calendar_grid(
  dp_model: dp_utils.Model,
  to_msg: fn(dp_utils.Msg) -> msg,
  week_constructor: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  day_constructor: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
) -> Element(msg) {
  dp_view.render_calendar_grid(
    dp_model,
    to_msg,
    week_constructor,
    day_constructor,
  )
}

pub fn render_date_range_calendar_grid(
  drp_model: drp_utils.Model,
  to_msg: fn(drp_utils.Msg) -> msg,
  is_second_month: Bool,
  week_constructor: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  day_constructor: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
) -> Element(msg) {
  drp_view.render_calendar_grid(
    drp_model,
    to_msg,
    week_constructor,
    day_constructor,
    is_second_month,
  )
}
