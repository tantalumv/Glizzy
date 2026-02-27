// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role, type_}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/keyboard.{
  type Key, ArrowDown, ArrowLeft, ArrowRight, ArrowUp, End, Home, PageDown,
  PageUp, decode_key,
}
import ui/size.{type Size, Large, Medium, Small}

// ============================================================================
// Types
// ============================================================================

pub type Variant {
  Default
  Muted
}

/// Messages for color slider keyboard navigation
pub type Msg {
  Increase
  Decrease
  SetMin
  SetMax
  IncreaseLarge
  DecreaseLarge
}

// ============================================================================
// Color Slider Component (Presentational - controlled by parent)
// ============================================================================

pub fn color_slider(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("relative w-full rounded-full"), ..attributes], children)
}

pub fn track(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class("h-2 w-full rounded-full"),
      attribute(
        "style",
        "background: linear-gradient(to right, #ff0000, #ffff00, #00ff00, #00ffff, #0000ff, #ff00ff, #ff0000)",
      ),
      ..attributes
    ],
    [],
  )
}

pub fn thumb(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class(
        "absolute top-1/2 h-4 w-4 -translate-y-1/2 rounded-full border-2 border-white shadow",
      ),
      ..attributes
    ],
    [],
  )
}

pub fn slider_input(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    role("slider"),
    class(
      [
        "w-full cursor-pointer appearance-none bg-transparent",
        "[&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:relative [&::-webkit-slider-thumb]:-mt-0.5",
        "[&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-white [&::-webkit-slider-thumb]:border-2 [&::-webkit-slider-thumb]:border-white [&::-webkit-slider-thumb]:shadow",
        "[&::-webkit-slider-thumb]:transition-colors [&::-webkit-slider-thumb]:focus:outline-none [&::-webkit-slider-thumb]:focus:ring-2 [&::-webkit-slider-thumb]:focus:ring-ring [&::-webkit-slider-thumb]:focus:ring-offset-2",
        "[&::-moz-range-thumb]:appearance-none [&::-moz-range-thumb]:h-4 [&::-moz-range-thumb]:w-4 [&::-moz-range-thumb]:rounded-full [&::-moz-range-thumb]:bg-white [&::-moz-range-thumb]:border-2 [&::-moz-range-thumb]:border-white [&::-moz-range-thumb]:shadow",
        "[&::-moz-range-thumb]:transition-colors [&::-moz-range-thumb]:focus:outline-none [&::-moz-range-thumb]:focus:ring-2 [&::-moz-range-thumb]:focus:ring-ring [&::-moz-range-thumb]:focus:ring-offset-2",
        "[&::-webkit-slider-runnable-track]:h-2 [&::-webkit-slider-runnable-track]:rounded-full [&::-webkit-slider-runnable-track]:bg-transparent",
        "[&::-webkit-slider-runnable-track]:transition-colors",
        "[&::-moz-range-track]:h-2 [&::-moz-range-track]:rounded-full [&::-moz-range-track]:bg-transparent",
        "[&::-moz-range-track]:transition-colors",
        css.focus_ring(),
        css.disabled(),
        "align-middle",
      ]
      |> string.join(" "),
    ),
    type_("range"),
    attribute("min", "0"),
    attribute("max", "360"),
    ..attributes
  ])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-muted")
    Muted -> class("opacity-80")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("h-1")
    Medium -> class("h-2")
    Large -> class("h-3")
  }
}

pub fn value(hue: Float) -> Attribute(a) {
  attribute("data-value", float.to_string(hue))
}

pub fn min(hue: Float) -> Attribute(a) {
  attribute("aria-valuemin", float.to_string(hue))
}

pub fn max(hue: Float) -> Attribute(a) {
  attribute("aria-valuemax", float.to_string(hue))
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_valuenow(hue: Float) -> Attribute(a) {
  attribute("aria-valuenow", float.to_string(hue))
}

// ============================================================================
// Helper Functions
// ============================================================================

pub fn hsl_to_hex(h: Float, s: Float, l: Float) -> String {
  let s_norm = s /. 100.0
  let l_norm = l /. 100.0
  let h_norm = h /. 360.0

  let float_abs = fn(x: Float) {
    case x <. 0.0 {
      True -> 0.0 -. x
      False -> x
    }
  }

  let float_mod = fn(a: Float, b: Float) {
    a -. { int.to_float(float.truncate(a /. b)) } *. b
  }

  let c = { 1.0 -. float_abs(2.0 *. l_norm -. 1.0) } *. s_norm
  let x = c *. { 1.0 -. float_abs(float_mod(h_norm *. 2.0, 2.0) -. 1.0) }
  let m = l_norm -. c /. 2.0

  let rgb = case h_norm {
    h if h <. 1.0 /. 6.0 -> #(c +. m, x +. m, 0.0 +. m)
    h if h <. 2.0 /. 6.0 -> #(x +. m, c +. m, 0.0 +. m)
    h if h <. 3.0 /. 6.0 -> #(0.0 +. m, c +. m, x +. m)
    h if h <. 4.0 /. 6.0 -> #(0.0 +. m, x +. m, c +. m)
    h if h <. 5.0 /. 6.0 -> #(x +. m, 0.0 +. m, c +. m)
    _ -> #(c +. m, 0.0 +. m, x +. m)
  }

  let r_int = float.round(rgb.0 *. 255.0) |> int.max(0) |> int.min(255)
  let g_int = float.round(rgb.1 *. 255.0) |> int.max(0) |> int.min(255)
  let b_int = float.round(rgb.2 *. 255.0) |> int.max(0) |> int.min(255)

  "#" <> to_hex_digit(r_int) <> to_hex_digit(g_int) <> to_hex_digit(b_int)
}

fn to_hex_digit(n: Int) -> String {
  let hex = "0123456789abcdef"
  string.slice(hex, n / 16, 1) <> string.slice(hex, n % 16, 1)
}

pub fn thumb_position(hue: Float) -> String {
  "left: calc(" <> float.to_string(hue /. 3.6) <> "% - 8px)"
}

pub fn thumb_color(hue: Float) -> Attribute(a) {
  attribute(
    "style",
    "background-color: hsl(" <> float.to_string(hue) <> ", 100%, 50%)",
  )
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for color slider keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow Right/Up**: Increase hue value
/// - **Arrow Left/Down**: Decrease hue value
/// - **Home**: Minimum value (0)
/// - **End**: Maximum value (360)
/// - **PageUp**: Large increment (+10)
/// - **PageDown**: Large decrement (-10)
///
/// Follows WAI-ARIA [Slider](https://www.w3.org/WAI/ARIA/apg/patterns/slider/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    ArrowRight | ArrowUp -> Some(Increase)
    ArrowLeft | ArrowDown -> Some(Decrease)
    Home -> Some(SetMin)
    End -> Some(SetMax)
    PageUp -> Some(IncreaseLarge)
    PageDown -> Some(DecreaseLarge)
    _ -> None
  }
}
