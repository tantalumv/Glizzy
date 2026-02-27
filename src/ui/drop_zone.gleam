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

/// Drop zone component with optional file input for click-to-browse.
/// 
/// When `input_attributes` is provided, clicking the drop zone will trigger
/// the file browser. When `input_attributes` is `None`, the drop zone is
/// visual-only (for drag-and-drop only).
/// 
/// ## Example
/// 
/// ```gleam
/// // With click-to-browse
/// drop_zone.drop_zone(
///   [drop_zone.input_attributes([file_trigger.input([attribute("accept", ".png,.jpg")])])],
///   [text("Drop files here or click to browse")]
/// )
/// 
/// // Visual-only (drag-and-drop only)
/// drop_zone.drop_zone(
///   [],
///   [text("Drop files here")]
/// )
/// ```
pub fn drop_zone(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class(
        [
          "rounded-md border-2 border-dashed border-input bg-background p-6 text-center",
          css.focus_ring(),
        ]
        |> string.join(" "),
      ),
      attribute("role", "button"),
      attribute("tabindex", "0"),
      attribute("aria-label", "Drop files here or click to browse"),
      ..attributes
    ],
    children,
  )
}

/// Wraps drop zone children with a label element to enable click-to-browse.
/// The label wraps the content and contains a hidden file input.
/// 
/// ## Parameters
/// - `input_attributes`: Attributes for the hidden file input (e.g., accept, multiple)
/// - `children`: The drop zone content
/// 
/// ## Example
/// 
/// ```gleam
/// drop_zone.drop_zone_with_input(
///   [file_trigger.input([attribute("accept", ".png,.jpg"), attribute("multiple", "true")])],
///   [
///     text("📁"),
///     p([], [text("Drop files here or click to browse")])
///   ]
/// )
/// ```
pub fn drop_zone_with_input(
  input_attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.label(
    [
      class("cursor-pointer"),
      attribute("role", "button"),
      attribute("tabindex", "0"),
      attribute("aria-label", "Drop files here or click to browse"),
    ],
    [
      html.input([
        class("sr-only"),
        attribute("type", "file"),
        ..input_attributes
      ]),
      ..children
    ],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-background")
    Muted -> class("bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class(size_helpers.text_class(size_helpers.Small) <> " p-4")
    Medium -> class(size_helpers.text_class(size_helpers.Medium) <> " p-6")
    Large -> class(size_helpers.text_class(size_helpers.Large) <> " p-8")
  }
}

pub type DropEffect {
  Copy
  Move
  Link
  Execute
  None
}

pub fn aria_dropeffect(effect: DropEffect) -> Attribute(a) {
  let value = case effect {
    Copy -> "copy"
    Move -> "move"
    Link -> "link"
    Execute -> "execute"
    None -> "none"
  }
  attribute("aria-dropeffect", value)
}

pub fn aria_label(label: String) -> Attribute(a) {
  attribute("aria-label", label)
}

pub fn aria_describedby(id: String) -> Attribute(a) {
  attribute("aria-describedby", id)
}
