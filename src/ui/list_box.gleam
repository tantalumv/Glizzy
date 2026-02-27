// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class, role}
import lustre/element.{type Element}
import lustre/element/html
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

pub type SelectionMode {
  None
  Single
  Multiple
}

pub fn list_box(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("overflow-auto rounded-md border border-input bg-background"),
      role("listbox"),
      attribute("tabindex", "0"),
      attribute("aria-activedescendant", ""),
      ..attributes
    ],
    children,
  )
}

pub fn list_box_section(
  attributes: List(Attribute(a)),
  heading: String,
  children: List(Element(a)),
) -> Element(a) {
  html.div([role("presentation"), ..attributes], [
    html.div(
      [
        class("px-2 py-1.5 text-sm font-semibold text-foreground"),
        role("group"),
      ],
      [html.text(heading)],
    ),
    ..children
  ])
}

pub fn list_box_option(
  attributes: List(Attribute(a)),
  label: String,
  option_value: String,
) -> Element(a) {
  html.div(
    [
      class(
        [
          "relative flex w-full cursor-pointer select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm",
          "outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:bg-accent focus:text-accent-foreground",
        ]
        |> string.join(" "),
      ),
      role("option"),
      attribute("tabindex", "-1"),
      attribute("aria-selected", "false"),
      attribute("data-value", option_value),
      ..attributes
    ],
    [
      html.div(
        [
          class("absolute left-2 flex h-3.5 w-3.5 items-center justify-center"),
        ],
        [],
      ),
      html.div([class("flex-1")], [html.text(label)]),
    ],
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
    Small ->
      class("min-h-[150px] " <> size_helpers.text_class(size_helpers.Small))
    Medium ->
      class("min-h-[200px] " <> size_helpers.text_class(size_helpers.Medium))
    Large ->
      class("min-h-[250px] " <> size_helpers.text_class(size_helpers.Large))
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

pub fn activedescendant(id: String) -> Attribute(a) {
  attribute("aria-activedescendant", id)
}
