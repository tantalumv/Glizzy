// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/keyboard.{
  ArrowDown, ArrowUp, Character, End, Enter, Escape, Home, Space, decode_key,
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

/// Messages for autocomplete keyboard navigation
pub type Msg {
  Open
  Close
  MoveNext
  MovePrev
  Select
  MoveFirst
  MoveLast
  TypeAhead(String)
}

pub fn autocomplete(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("relative"),
      attribute("role", "combobox"),
      attribute("aria-autocomplete", "list"),
      attribute("aria-expanded", "false"),
      ..attributes
    ],
    children,
  )
}

pub fn input(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      [
        "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
        "focus:outline-none " <> css.focus_ring(),
      ]
      |> string.join(" "),
    ),
    attribute("type", "text"),
    ..attributes
  ])
}

pub fn list(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.ul(
    [
      class(
        "absolute left-0 top-full z-50 mt-1 max-h-60 w-full overflow-auto rounded-md border bg-popover p-1",
      ),
      attribute("role", "listbox"),
      ..attributes
    ],
    children,
  )
}

pub fn item(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.li(
    [
      class(
        "cursor-default select-none rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground",
      ),
      attribute("role", "option"),
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
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for autocomplete keyboard navigation
///
/// ## Keyboard interactions:
/// - **ArrowDown**: Open dropdown and move to next option
/// - **ArrowUp**: Open dropdown and move to previous option
/// - **Enter**: Select current option
/// - **Escape**: Close dropdown
/// - **Home**: Move to first option
/// - **End**: Move to last option
/// - **Type-ahead**: Filter options by typing
///
/// Follows WAI-ARIA [Combobox](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent, is_open: Bool) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case is_open {
    False -> {
      case key {
        ArrowDown | ArrowUp -> Some(Open)
        _ -> None
      }
    }
    True -> {
      case key {
        ArrowDown -> Some(MoveNext)
        ArrowUp -> Some(MovePrev)
        Enter | Space -> Some(Select)
        Escape -> Some(Close)
        Home -> Some(MoveFirst)
        End -> Some(MoveLast)
        Character(char) -> {
          case string.length(char) == 1 {
            True -> Some(TypeAhead(char))
            False -> None
          }
        }
        _ -> None
      }
    }
  }
}
