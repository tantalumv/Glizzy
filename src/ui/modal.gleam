//// Modal component with focus trap support.
////
//// ## Usage with Focus Trap
////
//// ```gleam
//// import glizzy/ui/modal
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
////     focus.create_scope("modal-content", FocusScopeCreated),
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
//// // In view:
//// fn view(model: Model) {
////   modal.modal([
////     attribute("id", "modal-container"),
////   ], [
////     modal.underlay([]),
////     modal.content([
////       attribute("id", "modal-content"),
////       attribute("data-state", case model.is_open {
////         True -> "open"
////         False -> "closed"
////       }),
////     ], [
////       // ... modal content
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

pub fn modal(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("fixed inset-0 z-50 flex items-center justify-center"),
      attribute("role", "dialog"),
      attribute("aria-modal", "true"),
      ..attributes
    ],
    children,
  )
}

pub fn underlay(attributes: List(Attribute(a))) -> Element(a) {
  html.div([class("fixed inset-0 bg-black/70 z-40"), ..attributes], [])
}

pub fn content(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "relative z-50 w-full rounded-md border bg-background p-6 shadow-lg",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
        ]
        |> string.join(" "),
      ),
      attribute("role", "document"),
      ..attributes
    ],
    children,
  )
}

pub fn title(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.h2(
    [
      class(
        "text-lg font-semibold leading-none tracking-tight text-foreground mb-2",
      ),
      attribute("id", "modal-title"),
      ..attributes
    ],
    children,
  )
}

pub fn description(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.p(
    [
      class("text-sm text-muted-foreground mt-2"),
      attribute("id", "modal-description"),
      ..attributes
    ],
    children,
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

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_describedby(id: String) -> Attribute(a) {
  attribute("aria-describedby", id)
}

pub fn aria_labelledby(id: String) -> Attribute(a) {
  attribute("aria-labelledby", id)
}
