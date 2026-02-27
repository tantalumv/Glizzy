// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html.{button, div, h2, i, p}
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

pub fn dialog(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(attributes, children)
}

pub fn trigger(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  button(
    [
      class(
        [
          "inline-flex items-center justify-center whitespace-nowrap",
          "rounded-md text-sm font-medium transition-colors",
          css.focus_ring(),
          "disabled:pointer-events-none " <> css.disabled(),
          "bg-primary text-primary-foreground hover:bg-primary/90",
          "h-10 px-4 py-2",
        ]
        |> string.join(" "),
      ),
      ..attributes
    ],
    children,
  )
}

/// Dialog content with optional ID for focus scope management.
///
/// Provide an `id` attribute to enable focus trapping with `ui/focus`.
///
/// ## Example
///
/// ```gleam
/// dialog.content([
///   attribute("id", "my-dialog"),
///   attribute("data-state", "open"),
/// ], [
///   dialog.title([], [text("Title")]),
///   // ... dialog content
/// ])
/// ```
pub fn content(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  div(
    [class("fixed inset-0 z-50 flex items-center justify-center"), ..attributes],
    [
      // Backdrop overlay
      div(
        [
          class(
            [
              "fixed inset-0 bg-black/80",
              "data-[state=open]:animate-in data-[state=closed]:animate-out",
              "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
            ]
            |> string.join(" "),
          ),
          attribute("data-dialog-overlay", "true"),
        ],
        [],
      ),
      // Dialog panel
      div(
        [
          class(
            [
              "relative z-50 grid w-full max-w-lg gap-4",
              "border bg-background p-6 shadow-lg",
              "rounded-lg",
              "data-[state=open]:animate-in data-[state=closed]:animate-out",
              "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
              "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
              "data-[state=closed]:slide-out-to-left-1/2",
              "data-[state=closed]:slide-out-to-top-[48%]",
              "data-[state=open]:slide-in-from-left-1/2",
              "data-[state=open]:slide-in-from-top-[48%]",
            ]
            |> string.join(" "),
          ),
          attribute("role", "dialog"),
          attribute("aria-modal", "true"),
          attribute("aria-labelledby", "dialog-title"),
          attribute("data-dialog-content", "true"),
          ..attributes
        ],
        children,
      ),
    ],
  )
}

pub fn title(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  h2(
    [
      class(
        [
          "text-lg font-semibold leading-none tracking-tight",
          "text-foreground",
        ]
        |> string.join(" "),
      ),
      attribute("id", "dialog-title"),
      attribute("data-dialog-title", "true"),
      ..attributes
    ],
    children,
  )
}

pub fn description(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  p(
    [
      class(
        [
          "text-sm text-muted-foreground",
          "mt-2",
        ]
        |> string.join(" "),
      ),
      attribute("data-dialog-description", "true"),
      ..attributes
    ],
    children,
  )
}

pub fn close(attributes: List(Attribute(a))) -> Element(a) {
  button(
    [
      class(
        [
          "absolute right-4 top-4",
          "rounded-sm opacity-70 transition-opacity",
          "hover:opacity-100",
          css.focus_ring(),
          "disabled:pointer-events-none",
          "inline-flex items-center justify-center",
          "h-8 w-8",
        ]
        |> string.join(" "),
      ),
      attribute("data-dialog-close", "true"),
      attribute("aria-label", "Close"),
      ..attributes
    ],
    [
      i(
        [class("ri ri-close-line h-4 w-4"), attribute("aria-hidden", "true")],
        [],
      ),
    ],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background text-foreground")
    Muted -> class("bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.container_class(size_helpers.Small))
    Medium -> class(size_helpers.container_class(size_helpers.Medium))
    Large -> class(size_helpers.container_class(size_helpers.Large))
  }
}
