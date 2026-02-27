// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{a, li, ol, span}
import ui/keyboard.{
  type Key, ArrowDown, ArrowLeft, ArrowRight, ArrowUp, End, Enter, Home,
  decode_key,
}
import ui/size as size_helpers

pub type Size {
  Small
  Medium
  Large
}

/// Messages for breadcrumbs keyboard navigation
pub type Msg {
  MoveNext
  MovePrev
  MoveFirst
  MoveLast
  Navigate(String)
}

pub fn breadcrumbs(
  attributes: List(Attribute(a)),
  separator: Element(a),
  children: List(Element(a)),
) -> Element(a) {
  ol(
    [
      class("flex items-center gap-1.5"),
      attribute("role", "navigation"),
      attribute("aria-label", "Breadcrumb"),
      ..attributes
    ],
    list.intersperse(children, separator),
  )
}

pub fn item(attributes: List(Attribute(a))) -> Element(a) {
  li([class("flex items-center gap-1.5"), ..attributes], [])
}

pub fn link(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  a(
    [
      class("transition-colors hover:text-foreground text-muted-foreground"),
      ..attributes
    ],
    children,
  )
}

pub fn separator() -> Element(a) {
  span([class("text-muted-foreground")], [text("/")])
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
  }
}

pub fn current() -> Attribute(a) {
  attribute("aria-current", "page")
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for breadcrumbs keyboard navigation
///
/// ## Keyboard interactions:
/// - **Arrow keys**: Navigate between breadcrumb items
/// - **Enter**: Navigate to breadcrumb link
/// - **Home**: First breadcrumb
/// - **End**: Last breadcrumb
///
/// Follows WAI-ARIA [Breadcrumb](https://www.w3.org/WAI/ARIA/apg/patterns/breadcrumb/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    ArrowRight | ArrowDown -> Some(MoveNext)
    ArrowLeft | ArrowUp -> Some(MovePrev)
    Home -> Some(MoveFirst)
    End -> Some(MoveLast)
    Enter -> Some(Navigate("current"))
    _ -> None
  }
}
