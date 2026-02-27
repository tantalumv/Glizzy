// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/keyboard.{
  type Key, ArrowDown, ArrowLeft, ArrowRight, ArrowUp, End, Home, PageDown,
  PageUp, decode_key,
}

pub type Variant {
  Default
  Muted
}

pub type Size {
  Small
  Medium
  Large
}

/// Messages for color wheel keyboard navigation
pub type Msg {
  Increase
  Decrease
  SetMin
  SetMax
  IncreaseLarge
  DecreaseLarge
}

pub fn color_wheel(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("relative rounded-full border border-input"),
      attribute("role", "slider"),
      attribute("aria-label", "Color wheel"),
      ..attributes
    ],
    children,
  )
}

pub fn thumb(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class(
        "absolute h-4 w-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow",
      ),
      ..attributes
    ],
    [],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background")
    Muted -> class("opacity-80")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("h-24 w-24")
    Medium -> class("h-32 w-32")
    Large -> class("h-40 w-40")
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for color wheel keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow Right/Up**: Increase hue value (rotate clockwise)
/// - **Arrow Left/Down**: Decrease hue value (rotate counter-clockwise)
/// - **Home**: Minimum value (0 degrees - red)
/// - **End**: Maximum value (360 degrees)
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
