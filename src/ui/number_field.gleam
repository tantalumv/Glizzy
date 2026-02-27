// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, class, name, type_}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/keyboard.{
  type Key, ArrowDown, ArrowUp, End, Enter, Escape, Home, decode_key,
}
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

/// Messages for number field keyboard navigation
pub type Msg {
  Increment
  Decrement
  SetMin
  SetMax
  Clear
}

pub fn input(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      [
        "flex h-10 w-full rounded-md border border-input bg-background px-4 py-2.5 text-sm",
        "file:border-0 file:bg-transparent file:text-sm file:font-medium",
        "placeholder:text-muted-foreground",
        css.focus_ring(),
        css.disabled(),
      ]
      |> string.join(" "),
    ),
    name(""),
    type_("text"),
    ..attributes
  ])
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input bg-background")
    Muted -> class("border-input bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.input_class(size_helpers.Small))
    Medium -> class(size_helpers.input_class(size_helpers.Medium))
    Large -> class(size_helpers.input_class(size_helpers.Large))
  }
}

pub fn file() -> Attribute(a) {
  class(
    "file:mr-4 file:py-1 file:px-4 file:rounded-full file:border-0 file:text-xs file:font-semibold file:bg-primary file:text-primary-foreground hover:file:bg-primary/90",
  )
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for number field keyboard navigation
///
/// ## Keyboard interactions:
/// - **ArrowUp**: Increment value
/// - **ArrowDown**: Decrement value
/// - **Home**: Minimum value
/// - **End**: Maximum value
/// - **Escape**: Clear value
///
/// Follows WAI-ARIA [Spinbutton](https://www.w3.org/WAI/ARIA/apg/patterns/spinbutton/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    ArrowUp -> Some(Increment)
    ArrowDown -> Some(Decrement)
    Home -> Some(SetMin)
    End -> Some(SetMax)
    Escape -> Some(Clear)
    _ -> None
  }
}
