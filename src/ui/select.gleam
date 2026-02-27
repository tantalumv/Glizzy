// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, value}
import lustre/element.{type Element}
import lustre/element/html.{
  div, optgroup, option as html_option, select as html_select,
}
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

pub fn select(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div([class("relative")], [
    html_select(
      [
        class(
          [
            "flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm",
            "placeholder:text-muted-foreground",
            "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
            css.disabled(),
            "[&>span]:line-clamp-1",
          ]
          |> string.join(" "),
        ),
        ..attributes
      ],
      children,
    ),
    div(
      [
        class(
          "pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 flex flex-col gap-0.5",
        ),
      ],
      [],
    ),
  ])
}

pub fn option(
  attributes: List(Attribute(a)),
  label: String,
  option_value: String,
) -> Element(a) {
  html_option(
    [
      class(
        "py-2 px-3 hover:bg-accent hover:text-accent-foreground cursor-pointer",
      ),
      value(option_value),
      ..attributes
    ],
    label,
  )
}

pub fn option_group(
  attributes: List(Attribute(a)),
  label: String,
  children: List(Element(a)),
) -> Element(a) {
  optgroup(
    [
      class("font-semibold text-muted-foreground"),
      attribute("label", label),
      ..attributes
    ],
    children,
  )
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

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for custom select dropdown component.
/// Note: Native HTML select handles keyboard natively.
/// These messages are for custom select implementations.
pub type Msg {
  /// Open the dropdown (Enter, Space, or ArrowDown)
  Open
  /// Close the dropdown (Escape)
  Close
  /// Move to next option (ArrowDown)
  MoveNext
  /// Move to previous option (ArrowUp)
  MovePrev
  /// Move to first option (Home)
  MoveFirst
  /// Move to last option (End)
  MoveLast
  /// Select the currently highlighted option (Enter)
  Select
  /// Type-ahead search (Character keys)
  TypeAhead(String)
}

/// Keymap for custom select dropdown keyboard navigation.
/// Follows WAI-ARIA select pattern:
/// - Enter/Space/ArrowDown: Open dropdown
/// - Escape: Close dropdown
/// - ArrowDown: Move to next option
/// - ArrowUp: Move to previous option
/// - Home: Move to first option
/// - End: Move to last option
/// - Enter: Select highlighted option
/// - Character: Type-ahead search
pub fn keymap(key_event: keyboard.KeyEvent, is_open: Bool) -> Option(Msg) {
  case is_open {
    False -> {
      // When closed, only open keys work
      case keyboard.decode_key(key_event.key) {
        keyboard.Enter | keyboard.Space | keyboard.ArrowDown -> Some(Open)
        keyboard.Character(c) -> Some(TypeAhead(c))
        _ -> option.None
      }
    }
    True -> {
      // When open, navigation keys work
      case keyboard.decode_key(key_event.key) {
        keyboard.Escape -> Some(Close)
        keyboard.ArrowDown -> Some(MoveNext)
        keyboard.ArrowUp -> Some(MovePrev)
        keyboard.Home -> Some(MoveFirst)
        keyboard.End -> Some(MoveLast)
        keyboard.Enter -> Some(Select)
        keyboard.Character(c) -> Some(TypeAhead(c))
        _ -> option.None
      }
    }
  }
}

/// Get the element ID for a select option at the given index.
pub fn option_element_id(index: Int) -> String {
  "select-option-" <> int.to_string(index)
}

/// Attribute to indicate expanded state.
pub fn aria_expanded(expanded: Bool) -> Attribute(a) {
  attribute("aria-expanded", case expanded {
    True -> "true"
    False -> "false"
  })
}

/// Attribute to indicate the currently active descendant.
pub fn aria_activedescendant(id: String) -> Attribute(a) {
  attribute("aria-activedescendant", id)
}
