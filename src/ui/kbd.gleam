// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{abbr}
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

pub fn kbd(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.kbd(
    [
      class(
        [
          "relative inline-flex h-6 select-none items-center justify-center",
          "rounded border bg-background px-2 font-mono text-xs font-semibold",
          "ring-2 ring-ring ring-offset-background",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input")
    Muted -> class("border-transparent bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small) <> " h-5")
    Medium -> class(size_helpers.text_class(size_helpers.Medium) <> " h-6")
    Large -> class(size_helpers.text_class(size_helpers.Large) <> " h-7")
  }
}

fn title(t: String) -> Attribute(a) {
  attribute("title", t)
}

pub fn command() -> Element(a) {
  abbr([title("Command")], [text("⌘")])
}

pub fn shift() -> Element(a) {
  abbr([title("Shift")], [text("⇧")])
}

pub fn ctrl() -> Element(a) {
  abbr([title("Control")], [text("⌃")])
}

pub fn option() -> Element(a) {
  abbr([title("Option")], [text("⌥")])
}

pub fn enter() -> Element(a) {
  abbr([title("Enter")], [text("↵")])
}

pub fn escape() -> Element(a) {
  abbr([title("Escape")], [text("⎋")])
}

pub fn tab() -> Element(a) {
  abbr([title("Tab")], [text("⇥")])
}

pub fn capslock() -> Element(a) {
  abbr([title("Caps Lock")], [text("⇪")])
}

pub fn delete() -> Element(a) {
  abbr([title("Delete")], [text("⌫")])
}

pub fn arrow_up() -> Element(a) {
  abbr([title("Arrow Up")], [text("↑")])
}

pub fn arrow_down() -> Element(a) {
  abbr([title("Arrow Down")], [text("↓")])
}

pub fn arrow_left() -> Element(a) {
  abbr([title("Arrow Left")], [text("←")])
}

pub fn arrow_right() -> Element(a) {
  abbr([title("Arrow Right")], [text("→")])
}
