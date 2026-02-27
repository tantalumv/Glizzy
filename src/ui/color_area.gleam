// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html
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

/// Messages for color area keyboard navigation
pub type Msg {
  SaturationIncrease
  SaturationDecrease
  LightnessIncrease
  LightnessDecrease
  SaturationMin
  SaturationMax
  LightnessMin
  LightnessMax
  SaturationIncreaseLarge
  SaturationDecreaseLarge
  LightnessIncreaseLarge
  LightnessDecreaseLarge
}

// ============================================================================
// Color Area Component (Presentational - controlled by parent)
// ============================================================================

pub fn color_area(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        "relative rounded-md border border-input overflow-hidden cursor-crosshair",
      ),
      role("application"),
      attribute("aria-label", "Color area"),
      attribute("tabindex", "0"),
      ..attributes
    ],
    [gradient_overlays(), ..children],
  )
}

pub fn background(hue: Float) -> Attribute(a) {
  attribute(
    "style",
    "background-color: hsl(" <> float.to_string(hue) <> ", 100%, 50%)",
  )
}

pub fn thumb(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class(
        "absolute h-4 w-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow-lg",
      ),
      ..attributes
    ],
    [],
  )
}

pub fn gradient_overlays() -> Element(a) {
  html.div(
    [
      class("absolute inset-0"),
      attribute(
        "style",
        "background: linear-gradient(to right, #ffffff, transparent), linear-gradient(to top, #000000, transparent)",
      ),
    ],
    [],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input")
    Muted -> class("opacity-80")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("h-32 w-32")
    Medium -> class("h-40 w-40")
    Large -> class("h-48 w-48")
  }
}

pub fn hue(h: Float) -> Attribute(a) {
  attribute("data-hue", float.to_string(h))
}

pub fn saturation(s: Float) -> Attribute(a) {
  attribute("data-saturation", float.to_string(s))
}

pub fn lightness(l: Float) -> Attribute(a) {
  attribute("data-lightness", float.to_string(l))
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

// ============================================================================
// Helper Functions
// ============================================================================

pub fn hsl_to_hex(h: Float, s: Float, l: Float) -> String {
  let s_norm = s /. 100.0
  let l_norm = l /. 100.0
  let h_norm = h /. 360.0

  // Helper to get absolute value of float
  let float_abs = fn(x: Float) {
    case x <. 0.0 {
      True -> 0.0 -. x
      False -> x
    }
  }

  // Helper for float modulo
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

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for color area keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow Right**: Increase saturation
/// - **Arrow Left**: Decrease saturation
/// - **Arrow Up**: Increase lightness
/// - **Arrow Down**: Decrease lightness
/// - **Home**: Minimum saturation (0)
/// - **End**: Maximum saturation (100)
/// - **PageUp**: Large saturation increment (+10)
/// - **PageDown**: Large saturation decrement (-10)
///
/// Follows WAI-ARIA [Slider](https://www.w3.org/WAI/ARIA/apg/patterns/slider/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    ArrowRight -> Some(SaturationIncrease)
    ArrowLeft -> Some(SaturationDecrease)
    ArrowUp -> Some(LightnessIncrease)
    ArrowDown -> Some(LightnessDecrease)
    Home -> Some(SaturationMin)
    End -> Some(SaturationMax)
    PageUp -> Some(SaturationIncreaseLarge)
    PageDown -> Some(SaturationDecreaseLarge)
    _ -> None
  }
}
