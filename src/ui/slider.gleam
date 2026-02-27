// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role, type_}
import lustre/element.{type Element}
import lustre/element/html.{input}
import ui/css
import ui/keyboard
import ui/size as size_helpers

pub type Variant {
  Default
  Muted
}

pub type Size {
  Small
  Medium
  Large
}

pub fn slider(attributes: List(Attribute(a))) -> Element(a) {
  input([
    role("slider"),
    class(
      [
        "w-full cursor-pointer appearance-none bg-transparent",
        // Thumb styling - WebKit
        "[&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:relative [&::-webkit-slider-thumb]:-mt-0.5",
        "[&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary",
        "[&::-webkit-slider-thumb]:transition-colors [&::-webkit-slider-thumb]:focus:outline-none [&::-webkit-slider-thumb]:focus:ring-2 [&::-webkit-slider-thumb]:focus:ring-ring [&::-webkit-slider-thumb]:focus:ring-offset-2",
        // Thumb styling - Mozilla
        "[&::-moz-range-thumb]:appearance-none [&::-moz-range-thumb]:h-4 [&::-moz-range-thumb]:w-4 [&::-moz-range-thumb]:rounded-full [&::-moz-range-thumb]:bg-primary [&::-moz-range-thumb]:border-0",
        "[&::-moz-range-thumb]:transition-colors [&::-moz-range-thumb]:focus:outline-none [&::-moz-range-thumb]:focus:ring-2 [&::-moz-range-thumb]:focus:ring-ring [&::-moz-range-thumb]:focus:ring-offset-2",
        // Track styling - WebKit
        "[&::-webkit-slider-runnable-track]:h-2 [&::-webkit-slider-runnable-track]:rounded-full [&::-webkit-slider-runnable-track]:bg-input",
        "[&::-webkit-slider-runnable-track]:transition-colors",
        // Track styling - Mozilla
        "[&::-moz-range-track]:h-2 [&::-moz-range-track]:rounded-full [&::-moz-range-track]:bg-input",
        "[&::-moz-range-track]:transition-colors",
        // Focus states
        css.focus_ring(),
        // Disabled states
        css.disabled(),
        // Vertical alignment
        "align-middle",
      ]
      |> string.join(" "),
    ),
    type_("range"),
    ..attributes
  ])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-primary")
    Muted -> class("bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.track_class(size_helpers.Small))
    Medium -> class(size_helpers.track_class(size_helpers.Medium))
    Large -> class(size_helpers.track_class(size_helpers.Large))
  }
}

pub fn thumb_size(s: Size) -> Attribute(a) {
  case s {
    Small ->
      class(
        "[&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:w-3 [&::-moz-range-thumb]:h-3 [&::-moz-range-thumb]:w-3",
      )
    Medium ->
      class(
        "[&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:w-4 [&::-moz-range-thumb]:h-4 [&::-moz-range-thumb]:w-4",
      )
    Large ->
      class(
        "[&::-webkit-slider-thumb]:h-5 [&::-webkit-slider-thumb]:w-5 [&::-moz-range-thumb]:h-5 [&::-moz-range-thumb]:w-5",
      )
  }
}

pub fn min(value: Int) -> Attribute(a) {
  attribute("min", int.to_string(value))
}

pub fn max(value: Int) -> Attribute(a) {
  attribute("max", int.to_string(value))
}

pub fn value(value: Int) -> Attribute(a) {
  attribute("value", int.to_string(value))
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_valuenow(value: Int) -> Attribute(a) {
  attribute("aria-valuenow", int.to_string(value))
}

pub fn aria_valuemin(value: Int) -> Attribute(a) {
  attribute("aria-valuemin", int.to_string(value))
}

pub fn aria_valuemax(value: Int) -> Attribute(a) {
  attribute("aria-valuemax", int.to_string(value))
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for slider component.
pub type Msg {
  /// Decrease value (ArrowLeft or ArrowDown)
  Decrease
  /// Increase value (ArrowRight or ArrowUp)
  Increase
  /// Set to minimum value (Home)
  SetMin
  /// Set to maximum value (End)
  SetMax
  /// Increase value by larger step (PageUp)
  PageIncrease
  /// Decrease value by larger step (PageDown)
  PageDecrease
}

/// Keymap for slider keyboard navigation.
/// Follows WAI-ARIA slider pattern:
/// - ArrowLeft/ArrowDown: Decrease value
/// - ArrowRight/ArrowUp: Increase value
/// - Home: Set to minimum value
/// - End: Set to maximum value
/// - PageUp: Increase by larger step (optional)
/// - PageDown: Decrease by larger step (optional)
pub fn keymap(
  key_event: keyboard.KeyEvent,
  _orientation: Orientation,
) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.Home -> Some(SetMin)
    keyboard.End -> Some(SetMax)
    keyboard.PageUp -> Some(PageIncrease)
    keyboard.PageDown -> Some(PageDecrease)
    keyboard.ArrowLeft | keyboard.ArrowDown -> Some(Decrease)
    keyboard.ArrowRight | keyboard.ArrowUp -> Some(Increase)
    _ -> None
  }
}

/// Slider orientation.
pub type Orientation {
  Horizontal
  Vertical
}

/// Set slider orientation.
pub fn orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> attribute("aria-orientation", "horizontal")
    Vertical -> attribute("aria-orientation", "vertical")
  }
}
