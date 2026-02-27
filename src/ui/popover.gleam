//// Popover component with focus trap support.
////
//// Popovers can be modal (focus trapped) or non-modal using `non_modal()`.
////
//// ## Usage with Focus Trap (Modal Popover)
////
//// ```gleam
//// import glizzy/ui/popover
//// import glizzy/ui/focus
//// import lustre/effect.{type Effect, batch}
////
//// type Model {
////   Model(is_open: Bool, focus_scope_id: String)
//// }
////
//// type Msg {
////   Open
////   Close
////   FocusScopeCreated(String)
//// }
////
//// // In init:
//// fn init() -> #(Model, Effect(Msg)) {
////   #(
////     Model(is_open: False, focus_scope_id: ""),
////     focus.create_scope("popover-content", FocusScopeCreated),
////   )
//// }
////
//// // In update:
//// fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
////   case msg {
////     Open -> #(
////       Model(..model, is_open: True),
////       batch([
////         focus.trap_focus(model.focus_scope_id, True),
////         focus.focus_first(model.focus_scope_id),
////       ])
////     )
////     Close -> #(
////       Model(..model, is_open: False),
////       focus.trap_focus(model.focus_scope_id, False)
////     )
////     FocusScopeCreated(scope_id) -> #(
////       Model(..model, focus_scope_id: scope_id),
////       effect.none()
////     )
////   }
//// }
////
//// // In view (modal popover):
//// fn view(model: Model) {
////   popover.popover([], [
////     popover.underlay([]),
////     popover.content([
////       attribute("id", "popover-content"),
////       attribute("data-state", case model.is_open {
////         True -> "open"
////         False -> "closed"
////       }),
////     ], [
////       // ... popover content
////     ])
////   ])
//// }
////
//// // In view (non-modal popover - no focus trap):
//// fn view(model: Model) {
////   popover.popover([
////     popover.non_modal(),
////   ], [
////     popover.content([], [
////       // ... popover content (no focus trap)
////     ])
////   ])
//// }
//// ```

// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
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

pub type Placement {
  Top
  Bottom
  Left
  Right
  Start
  End
}

pub fn popover(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([class("fixed inset-0 z-50"), ..attributes], children)
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
      attribute("aria-haspopup", "dialog"),
      ..attributes
    ],
    children,
  )
}

pub fn underlay(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class("fixed inset-0 bg-black/30"),
      attribute("data-popover-underlay", "true"),
      attribute("aria-hidden", "true"),
      ..attributes
    ],
    [],
  )
}

pub fn content(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "absolute z-50 min-w-[12rem] rounded-md border border-border bg-popover p-3 text-popover-foreground shadow-md",
          "outline-none",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        ]
        |> string.join(" "),
      ),
      attribute("role", "dialog"),
      attribute("tabindex", "-1"),
      attribute("data-popover-content", "true"),
      ..attributes
    ],
    children,
  )
}

pub fn arrow(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class(
        "absolute -top-1 left-4 h-2 w-2 rotate-45 border-l border-t border-border bg-popover",
      ),
      attribute("data-popover-arrow", "true"),
      ..attributes
    ],
    [],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-popover text-popover-foreground")
    Muted -> class("bg-muted text-muted-foreground")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small ->
      class(size_helpers.container_class(size_helpers.Small) <> " p-2 text-xs")
    Medium ->
      class(size_helpers.container_class(size_helpers.Medium) <> " p-3 text-sm")
    Large ->
      class(
        size_helpers.container_class(size_helpers.Large) <> " p-4 text-base",
      )
  }
}

pub fn placement(p: Placement) -> Attribute(a) {
  case p {
    Top -> attribute("data-placement", "top")
    Bottom -> attribute("data-placement", "bottom")
    Left -> attribute("data-placement", "left")
    Right -> attribute("data-placement", "right")
    Start -> attribute("data-placement", "start")
    End -> attribute("data-placement", "end")
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

pub fn non_modal() -> Attribute(a) {
  attribute("data-non-modal", "true")
}
