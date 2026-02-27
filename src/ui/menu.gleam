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

pub fn menu(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        "overflow-auto rounded-md border border-input bg-popover text-popover-foreground",
      ),
      role("menu"),
      attribute("aria-orientation", "vertical"),
      attribute("tabindex", "-1"),
      ..attributes
    ],
    [html.ul([class("list-none p-1 m-0")], children)],
  )
}

pub fn trigger(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        [
          "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors",
          css.focus_ring(),
          "disabled:pointer-events-none " <> css.disabled(),
          "bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2",
        ]
        |> string.join(" "),
      ),
      attribute("type", "button"),
      attribute("aria-haspopup", "menu"),
      ..attributes
    ],
    children,
  )
}

pub fn menu_section(
  attributes: List(Attribute(a)),
  heading: String,
  children: List(Element(a)),
) -> Element(a) {
  html.li([role("presentation"), ..attributes], [
    html.div(
      [
        class(
          "px-2 py-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground",
        ),
        role("presentation"),
      ],
      [html.text(heading)],
    ),
    html.ul(
      [
        class("list-none p-0 m-0"),
        role("group"),
        attribute("aria-label", heading),
      ],
      children,
    ),
  ])
}

pub fn menu_item(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.li(
    [
      class(
        [
          "relative flex w-full cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:bg-accent focus:text-accent-foreground",
          "data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50",
        ]
        |> string.join(" "),
      ),
      role("menuitem"),
      attribute("tabindex", "-1"),
      ..attributes
    ],
    children,
  )
}

pub fn menu_item_checkbox(
  attributes: List(Attribute(a)),
  checked: Bool,
  children: List(Element(a)),
) -> Element(a) {
  html.li(
    [
      class(
        [
          "relative flex w-full cursor-default select-none items-center rounded-sm pl-8 pr-2 py-1.5 text-sm outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:bg-accent focus:text-accent-foreground",
        ]
        |> string.join(" "),
      ),
      role("menuitemcheckbox"),
      attribute("aria-checked", case checked {
        True -> "true"
        False -> "false"
      }),
      attribute("tabindex", "-1"),
      ..attributes
    ],
    children,
  )
}

pub fn menu_item_radio(
  attributes: List(Attribute(a)),
  checked: Bool,
  children: List(Element(a)),
) -> Element(a) {
  html.li(
    [
      class(
        [
          "relative flex w-full cursor-default select-none items-center rounded-sm pl-8 pr-2 py-1.5 text-sm outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:bg-accent focus:text-accent-foreground",
        ]
        |> string.join(" "),
      ),
      role("menuitemradio"),
      attribute("aria-checked", case checked {
        True -> "true"
        False -> "false"
      }),
      attribute("tabindex", "-1"),
      ..attributes
    ],
    children,
  )
}

pub fn separator(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [class("-mx-1 my-1 h-px bg-border"), role("separator"), ..attributes],
    [],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("border-input bg-popover text-popover-foreground")
    Muted -> class("border-input bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small ->
      class("min-w-[10rem] " <> size_helpers.text_class(size_helpers.Small))
    Medium ->
      class("min-w-[12rem] " <> size_helpers.text_class(size_helpers.Medium))
    Large ->
      class("min-w-[14rem] " <> size_helpers.text_class(size_helpers.Large))
  }
}

pub fn selection_mode(m: SelectionMode) -> Attribute(a) {
  case m {
    None -> attribute("aria-multiselectable", "false")
    Single -> attribute("aria-multiselectable", "false")
    Multiple -> attribute("aria-multiselectable", "true")
  }
}

pub fn expanded(expanded: Bool) -> Attribute(a) {
  case expanded {
    True -> attribute("aria-expanded", "true")
    False -> attribute("aria-expanded", "false")
  }
}

pub fn controls(id: String) -> Attribute(a) {
  attribute("aria-controls", id)
}
