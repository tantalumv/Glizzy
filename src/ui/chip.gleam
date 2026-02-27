// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{div}
import ui/keyboard.{
  ArrowDown, ArrowLeft, ArrowRight, ArrowUp, Delete, End, Enter, Home, Space,
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

/// Messages for chip keyboard navigation
pub type Msg {
  MoveNext
  MovePrev
  MoveFirst
  MoveLast
  Remove
  Activate
}

pub fn chip(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      class(
        "inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-medium transition-colors",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> "bg-primary text-primary-foreground hover:bg-primary/80"
    Secondary -> "bg-secondary text-secondary-foreground hover:bg-secondary/80"
    Outline ->
      "border border-input bg-background hover:bg-accent hover:text-accent-foreground"
  }
  |> class
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.tag_class(size_helpers.Small))
    Medium -> class("px-3 py-1 text-sm")
    Large -> class(size_helpers.tag_class(size_helpers.Large))
  }
}

pub fn icon() -> Attribute(a) {
  class("h-4 w-4")
}

pub fn chip_group(
  label: String,
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [
      attribute("role", "group"),
      attribute("aria-label", label),
      class("flex flex-wrap gap-2"),
      ..attributes
    ],
    children,
  )
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for chip group keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow keys**: Navigate between chips
/// - **Delete**: Remove chip
/// - **Enter/Space**: Activate chip
/// - **Home**: First chip
/// - **End**: Last chip
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
    Enter | Space -> Some(Activate)
    _ -> None
  }
}
