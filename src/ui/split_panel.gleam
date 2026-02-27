// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html.{button, div, text}
import ui/css
import ui/keyboard.{
  type Key, ArrowDown, ArrowLeft, ArrowRight, ArrowUp, End, Home, decode_key,
}
import ui/size.{type Size, Large, Medium, Small}

pub type Orientation {
  Horizontal
  Vertical
}

/// Split panel container with adjustable divider
pub fn split_panel(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      class("flex overflow-hidden rounded-md border border-input"),
      role("region"),
      attribute("aria-label", "Split panel"),
      ..attributes
    ],
    children,
  )
}

/// Left or top pane with percentage-based size
pub fn pane_a(
  attributes: List(Attribute(a)),
  size_percent: Int,
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      class("overflow-auto"),
      attribute("style", "flex: " <> int.to_string(size_percent) <> " 0 0;"),
      ..attributes
    ],
    children,
  )
}

/// Right or bottom pane (fills remaining space)
pub fn pane_b(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div([class("overflow-auto flex-1"), ..attributes], children)
}

/// Adjustable divider with click controls
/// Pass on_click handlers for the decrease/increase buttons via attributes
pub fn adjustable_divider(
  attributes: List(Attribute(a)),
  position: Int,
) -> Element(a) {
  div(
    [
      class(
        [
          "relative flex items-center justify-center w-4",
          "bg-muted/50 hover:bg-primary/20",
          "transition-colors cursor-col-resize",
        ]
        |> string.join(" "),
      ),
      attribute("role", "separator"),
      attribute("aria-label", "Adjustable divider"),
      attribute("aria-valuenow", int.to_string(position)),
      attribute("aria-valuemin", "10"),
      attribute("aria-valuemax", "90"),
      attribute("tabindex", "0"),
      ..attributes
    ],
    [
      // Decrease button (make left panel smaller) - arrow pointing left
      button(
        [
          class(
            [
              "absolute left-0 -translate-x-1/2 h-6 w-6 rounded-full bg-background border border-border",
              "flex items-center justify-center",
              "hover:bg-primary hover:text-primary-foreground",
              css.focus_ring(),
              "shadow-sm",
              "text-xs font-bold",
            ]
            |> string.join(" "),
          ),
          attribute("type", "button"),
          attribute("aria-label", "Decrease left panel size"),
          attribute("data-action", "decrease"),
          attribute("data-split-action", "decrease"),
          attribute("tabindex", "-1"),
        ],
        [text("◀")],
      ),
      // Position indicator
      div(
        [
          class("text-[10px] text-muted-foreground font-mono select-none"),
        ],
        [text(int.to_string(position) <> "%")],
      ),
      // Increase button (make left panel larger) - arrow pointing right
      button(
        [
          class(
            [
              "absolute right-0 translate-x-1/2 h-6 w-6 rounded-full bg-background border border-border",
              "flex items-center justify-center",
              "hover:bg-primary hover:text-primary-foreground",
              css.focus_ring(),
              "shadow-sm",
              "text-xs font-bold",
            ]
            |> string.join(" "),
          ),
          attribute("type", "button"),
          attribute("aria-label", "Increase left panel size"),
          attribute("data-action", "increase"),
          attribute("data-split-action", "increase"),
          attribute("tabindex", "-1"),
        ],
        [text("▶")],
      ),
    ],
  )
}

/// Helper to create click handler for split panel adjustment
/// Use with event delegation on the parent container
pub fn on_split_click(current_position: Int, step: Int) -> fn(String) -> Int {
  fn(action: String) -> Int {
    case action {
      "decrease" | "ArrowLeft" -> {
        let new_pos = current_position - step
        case new_pos < 10 {
          True -> 10
          False -> new_pos
        }
      }
      "increase" | "ArrowRight" -> {
        let new_pos = current_position + step
        case new_pos > 90 {
          True -> 90
          False -> new_pos
        }
      }
      _ -> current_position
    }
  }
}

/// Simple divider handle (visual only, for future drag implementation)
pub fn divider_handle(attributes: List(Attribute(a))) -> Element(a) {
  div(
    [
      class(
        [
          "w-1 h-full cursor-col-resize",
          "bg-border hover:bg-primary/50",
          "transition-colors",
        ]
        |> string.join(" "),
      ),
      attribute("role", "separator"),
      ..attributes
    ],
    [],
  )
}

/// Orientation attribute
pub fn orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> attribute("data-orientation", "horizontal")
    Vertical -> attribute("data-orientation", "vertical")
  }
}

/// Size attribute (height for horizontal splits)
pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("h-48")
    Medium -> class("h-64")
    Large -> class("h-96")
  }
}

/// Keyboard handler helper - returns message for key events
/// Use in your app's keydown handler
pub fn handle_key_position(key: String, current_position: Int, step: Int) -> Int {
  let min_pos = 10
  let max_pos = 90

  case key {
    "ArrowLeft" | "ArrowUp" -> {
      let new_pos = current_position - step
      case new_pos < min_pos {
        True -> min_pos
        False -> new_pos
      }
    }
    "ArrowRight" | "ArrowDown" -> {
      let new_pos = current_position + step
      case new_pos > max_pos {
        True -> max_pos
        False -> new_pos
      }
    }
    _ -> current_position
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Messages for split panel keyboard navigation
pub type Msg {
  Decrease
  Increase
  Reset
  SetMin
  SetMax
}

/// Keymap for split panel keyboard navigation
///
/// ## Keyboard interactions:
/// - **ArrowLeft/ArrowUp**: Decrease panel size (horizontal/vertical split)
/// - **ArrowRight/ArrowDown**: Increase panel size
/// - **Home**: Reset to default size (50%)
/// - **End**: Maximize current panel (90% or 10%)
///
/// Follows WAI-ARIA [Separator](https://www.w3.org/WAI/ARIA/apg/patterns/separator/) pattern.
pub fn keymap(
  key_event: keyboard.KeyEvent,
  orientation: Orientation,
) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case orientation {
    Horizontal -> {
      case key {
        ArrowLeft -> Some(Decrease)
        ArrowRight -> Some(Increase)
        Home -> Some(Reset)
        End -> Some(SetMax)
        _ -> None
      }
    }
    Vertical -> {
      case key {
        ArrowUp -> Some(Decrease)
        ArrowDown -> Some(Increase)
        Home -> Some(Reset)
        End -> Some(SetMax)
        _ -> None
      }
    }
  }
}
