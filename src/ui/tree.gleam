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

pub fn tree(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("overflow-auto rounded-md border border-input bg-background"),
      role("tree"),
      attribute("tabindex", "0"),
      attribute("aria-multiselectable", "false"),
      attribute("aria-activedescendant", ""),
      ..attributes
    ],
    children,
  )
}

pub fn tree_item(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      role("treeitem"),
      attribute("aria-selected", "false"),
      attribute("tabindex", "0"),
      ..attributes
    ],
    children,
  )
}

pub fn tree_item_content(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "flex items-center gap-1 py-1 px-2 rounded-sm text-sm cursor-pointer",
          "outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "focus:bg-accent focus:text-accent-foreground",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

pub fn tree_item_label(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.span([class("flex-1"), ..attributes], children)
}

pub fn tree_group(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("pl-4"), role("group"), ..attributes], children)
}

pub fn tree_node(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("flex items-center gap-1"), ..attributes], children)
}

pub fn tree_expand_button(
  is_expanded: Bool,
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.button(
    [
      class(
        "h-4 w-4 p-0 flex items-center justify-center rounded-sm hover:bg-accent transition-transform duration-200",
      ),
      attribute("type", "button"),
      attribute("aria-label", case is_expanded {
        True -> "Collapse"
        False -> "Expand"
      }),
      attribute("aria-expanded", case is_expanded {
        True -> "true"
        False -> "false"
      }),
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
    Small -> class(size_helpers.text_class(size_helpers.Small))
    Medium -> class(size_helpers.text_class(size_helpers.Medium))
    Large -> class(size_helpers.text_class(size_helpers.Large))
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

pub fn expanded(is_expanded: Bool) -> Attribute(a) {
  attribute("aria-expanded", case is_expanded {
    True -> "true"
    False -> "false"
  })
}
