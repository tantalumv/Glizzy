// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/size as size_helpers

pub type Variant {
  Default
  Bordered
  Pill
}

pub type Size {
  Small
  Medium
  Large
}

pub type Orientation {
  Horizontal
  Vertical
}

pub type KeyboardActivation {
  Automatic
  Manual
}

pub fn tabs(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("flex flex-col gap-2"), ..attributes], children)
}

pub fn tab_list(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "flex border-b border-border gap-1",
        ]
        |> string.join(" "),
      ),
      role("tablist"),
      attribute("aria-orientation", "horizontal"),
      ..attributes
    ],
    children,
  )
}

pub fn tab(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  // Build base attributes without defaults that would conflict with user attrs
  // User must provide: aria-selected, tabindex via tab_selected() and explicit attribute
  html.button(
    [
      class(
        [
          "inline-flex items-center justify-center whitespace-nowrap px-4 py-2",
          "text-sm font-medium transition-colors",
          css.focus_ring(),
          "disabled:pointer-events-none " <> css.disabled(),
          "border-b-2 border-transparent",
          "hover:border-border hover:bg-muted hover:text-muted-foreground",
          "focus:bg-muted focus:text-muted-foreground",
        ]
        |> string.join(" "),
      ),
      role("tab"),
      // Default aria-disabled="false" - this can stay as it's rarely overridden
      attribute("aria-disabled", "false"),
      // NOTE: aria-selected and tabindex must be provided by the user
      // via tab_selected() and attribute("tabindex", ...) respectively
      ..attributes
    ],
    children,
  )
}

pub fn tab_panel(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "mt-2 focus-visible:outline-none",
        ]
        |> string.join(" "),
      ),
      role("tabpanel"),
      attribute("tabindex", "0"),
      ..attributes
    ],
    children,
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("")
    Bordered -> class("rounded-md border border-border p-1")
    Pill -> class("rounded-lg bg-muted p-1")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small) <> " px-3 py-1")
    Medium ->
      class(size_helpers.text_class(size_helpers.Medium) <> " px-4 py-2")
    Large -> class(size_helpers.text_class(size_helpers.Large) <> " px-5 py-3")
  }
}

pub fn orientation(o: Orientation) -> Attribute(a) {
  case o {
    Horizontal -> attribute("aria-orientation", "horizontal")
    Vertical -> attribute("aria-orientation", "vertical")
  }
}

pub fn keyboard_activation(k: KeyboardActivation) -> Attribute(a) {
  case k {
    Automatic -> attribute("data-keyboard-activation", "automatic")
    Manual -> attribute("data-keyboard-activation", "manual")
  }
}

pub fn tab_disabled(disabled: Bool) -> Attribute(a) {
  case disabled {
    True -> attribute("aria-disabled", "true")
    False -> attribute("aria-disabled", "false")
  }
}

pub fn tab_selected(selected: Bool) -> Attribute(a) {
  case selected {
    True -> attribute("aria-selected", "true")
    False -> attribute("aria-selected", "false")
  }
}
