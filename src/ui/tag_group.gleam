// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html
import ui/keyboard.{
  ArrowDown, ArrowLeft, ArrowRight, ArrowUp, Delete, End, Enter, Home,
  decode_key,
}
import ui/size as size_helpers

pub type Variant {
  Default
  Secondary
  Outline
}

pub type Size {
  Small
  Medium
  Large
}

pub type SelectionMode {
  None
  Single
  Multiple
}

/// Messages for tag group keyboard navigation
pub type Msg {
  MoveNext
  MovePrev
  MoveFirst
  MoveLast
  Remove
  Edit
  Activate
}

pub fn tag_group(
  attributes: List(Attribute(a)),
  label: String,
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("flex flex-col gap-1.5"),
      role("group"),
      attribute("aria-label", label),
      ..attributes
    ],
    [
      html.div([class("text-sm font-medium")], [html.text(label)]),
      html.div(
        [
          class("flex flex-wrap gap-2"),
        ],
        children,
      ),
    ],
  )
}

pub fn tag(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "inline-flex items-center gap-1 rounded-full text-sm font-medium transition-colors",
        ]
        |> string.join(" "),
      ),
      attribute("tabindex", "0"),
      ..attributes
    ],
    children,
  )
}

pub fn tag_with_remove(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "inline-flex items-center gap-1 rounded-full text-sm font-medium transition-colors",
        ]
        |> string.join(" "),
      ),
      attribute("tabindex", "0"),
      ..attributes
    ],
    [
      html.div(
        [
          class("flex-1"),
        ],
        children,
      ),
      html.button(
        [
          class(
            "ml-1 h-4 w-4 rounded-full opacity-50 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring",
          ),
          attribute("aria-label", "Remove"),
          attribute("type", "button"),
        ],
        [
          html.span([class("sr-only")], [html.text("×")]),
        ],
      ),
    ],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default ->
      "bg-primary text-primary-foreground hover:bg-primary/80"
      |> class
    Secondary ->
      "bg-secondary text-secondary-foreground hover:bg-secondary/80"
      |> class
    Outline ->
      "border border-input bg-background hover:bg-accent hover:text-accent-foreground"
      |> class
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.tag_class(size_helpers.Small))
    Medium -> class("px-3 py-1 text-sm")
    Large -> class(size_helpers.tag_class(size_helpers.Large))
  }
}

pub fn selection_mode(m: SelectionMode) -> Attribute(a) {
  case m {
    None -> attribute("aria-multiselectable", "false")
    Single -> attribute("aria-multiselectable", "false")
    Multiple -> attribute("aria-multiselectable", "true")
  }
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for tag group keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow keys**: Navigate between tags
/// - **Delete**: Remove tag
/// - **Enter**: Edit/activate tag
/// - **Home**: First tag
/// - **End**: Last tag
///
/// Follows WAI-ARIA [Tag Group](https://www.w3.org/WAI/ARIA/apg/patterns/tag-group/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    ArrowRight | ArrowDown -> Some(MoveNext)
    ArrowLeft | ArrowUp -> Some(MovePrev)
    Home -> Some(MoveFirst)
    End -> Some(MoveLast)
    Delete -> Some(Remove)
    Enter -> Some(Edit)
    _ -> option.None
  }
}
