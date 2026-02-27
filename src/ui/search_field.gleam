// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, name, type_}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/keyboard.{
  type Key, ArrowDown, ArrowUp, End, Enter, Escape, Home, decode_key,
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

/// Messages for search field keyboard navigation
pub type Msg {
  Increment
  Decrement
  SetMin
  SetMax
  Clear
}

pub fn search_field(attributes: List(Attribute(a))) -> Element(a) {
  html.div([class("relative w-full")], [
    html.div(
      [
        class(
          "absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none",
        ),
      ],
      [
        html.div(
          [
            class(
              [
                "h-4 w-4",
                "border-2 border-current border-r-0 rounded-l",
                "translate-x-0.5",
              ]
              |> string.join(" "),
            ),
          ],
          [],
        ),
      ],
    ),
    html.input([
      class(
        [
          "flex h-10 w-full rounded-md border border-input bg-background pl-10 pr-4 py-2.5 text-sm",
          "placeholder:text-muted-foreground",
          css.focus_ring(),
          css.disabled(),
        ]
        |> string.join(" "),
      ),
      name(""),
      type_("search"),
      attribute("role", "searchbox"),
      ..attributes
    ]),
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
    Small -> class("h-8 pl-8 pr-2 text-xs")
    Medium -> class("h-10 pl-10 pr-3 text-sm")
    Large -> class("h-11 pl-11 pr-4 text-base")
  }
}

pub fn required() -> Attribute(a) {
  attribute("aria-required", "true")
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for search field keyboard navigation
///
/// ## Keyboard interactions:
/// - **ArrowUp**: Increment value (for numeric search)
/// - **ArrowDown**: Decrement value
/// - **Home**: Minimum value
/// - **End**: Maximum value
/// - **Escape**: Clear value
///
/// Follows WAI-ARIA [Searchbox](https://www.w3.org/WAI/ARIA/apg/patterns/searchbox/) pattern.
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
