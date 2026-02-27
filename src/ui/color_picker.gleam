// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class, role, type_}
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

/// Messages for color picker keyboard navigation
pub type Msg {
  HueIncrease
  HueDecrease
  SaturationIncrease
  SaturationDecrease
  LightnessIncrease
  LightnessDecrease
  HueMin
  HueMax
  SaturationMin
  SaturationMax
  LightnessMin
  LightnessMax
}

/// Color mode for keyboard navigation
pub type ColorMode {
  Hue
  Saturation
  Lightness
}

// ============================================================================
// Color Picker Component (Presentational - controlled by parent)
// ============================================================================

pub fn color_picker(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("grid gap-3 rounded-md border border-input bg-background p-3"),
      role("group"),
      attribute("aria-label", "Color picker"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background text-foreground")
    Muted -> class("bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("max-w-xs")
    Medium -> class("max-w-sm")
    Large -> class("max-w-md")
  }
}

pub fn value(val: String) -> Attribute(a) {
  attribute("value", val)
}

pub fn label(lbl: String) -> Attribute(a) {
  attribute("aria-label", lbl)
}

// ============================================================================
// Helper Components
// ============================================================================

pub fn swatch(color: String, attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class("h-10 w-10 rounded-md border border-border cursor-pointer"),
      attribute("style", "background-color: " <> color),
      ..attributes
    ],
    [],
  )
}

pub fn input(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      "flex h-10 flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-ring",
    ),
    type_("text"),
    ..attributes
  ])
}

pub fn hint(text: String) -> Element(a) {
  html.p([class("text-xs text-muted-foreground")], [html.text(text)])
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for color picker keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow Right/Up**: Increase current color value
/// - **Arrow Left/Down**: Decrease current color value
/// - **Home**: Minimum value (0)
/// - **End**: Maximum value (360 for hue, 100 for saturation/lightness)
/// - **PageUp**: Large increment (+10)
/// - **PageDown**: Large decrement (-10)
///
/// Follows WAI-ARIA [Slider](https://www.w3.org/WAI/ARIA/apg/patterns/slider/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent, mode: ColorMode) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case mode {
    Hue -> {
      case key {
        ArrowRight | ArrowUp -> Some(HueIncrease)
        ArrowLeft | ArrowDown -> Some(HueDecrease)
        Home -> Some(HueMin)
        End -> Some(HueMax)
        PageUp -> Some(HueIncrease)
        PageDown -> Some(HueDecrease)
        _ -> None
      }
    }
    Saturation -> {
      case key {
        ArrowRight | ArrowUp -> Some(SaturationIncrease)
        ArrowLeft | ArrowDown -> Some(SaturationDecrease)
        Home -> Some(SaturationMin)
        End -> Some(SaturationMax)
        PageUp -> Some(SaturationIncrease)
        PageDown -> Some(SaturationDecrease)
        _ -> None
      }
    }
    Lightness -> {
      case key {
        ArrowRight | ArrowUp -> Some(LightnessIncrease)
        ArrowLeft | ArrowDown -> Some(LightnessDecrease)
        Home -> Some(LightnessMin)
        End -> Some(LightnessMax)
        PageUp -> Some(LightnessIncrease)
        PageDown -> Some(LightnessDecrease)
        _ -> None
      }
    }
  }
}
