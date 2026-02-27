// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, type_}
import lustre/element.{type Element}
import lustre/element/html.{div, input, label}
import ui/css
import ui/keyboard.{type Key, Enter, Space, decode_key}

pub type Variant {
  Default
  Muted
}

pub type Size {
  Small
  Medium
  Large
}

/// Messages for switch keyboard navigation
pub type Msg {
  Toggle
}

pub fn switch(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  label(
    [
      class("inline-flex items-center gap-2 cursor-pointer"),
    ],
    [
      input([
        type_("checkbox"),
        class("sr-only peer"),
        attribute("role", "switch"),
        attribute(
          "style",
          "position:absolute;opacity:0;width:100%;height:100%;top:0;left:0;cursor:pointer;z-index:10",
        ),
        ..attributes
      ]),
      div(
        [
          class(
            [
              "peer-checked:bg-primary bg-input relative inline-flex h-6 w-11 shrink-0 rounded-full border-2 border-transparent transition-colors",
              css.focus_ring() <> " focus-visible:ring-offset-background",
              css.disabled(),
              "after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-background after:rounded-full after:h-5 after:w-5 after:transition-all after:pointer-events-none",
              "peer-checked:after:translate-x-full peer-checked:after:bg-primary-foreground rtl:peer-checked:after:-translate-x-full",
            ]
            |> string.join(" "),
          ),
        ],
        [],
      ),
      ..children
    ],
  )
}

pub fn variant(v: Variant) -> Attribute(a) {
  case v {
    Default -> class("bg-primary")
    Muted -> class("bg-muted")
  }
}

pub fn size(s: Size) -> Attribute(a) {
  case s {
    Small -> class("h-5 w-9 after:h-4 after:w-4")
    Medium -> class("h-6 w-11 after:h-5 after:w-5")
    Large -> class("h-7 w-[3.25rem] after:h-6 after:w-6")
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for switch keyboard navigation
///
/// ## Keyboard interactions:
/// - **Space**: Toggle state
///
/// Follows WAI-ARIA [Switch](https://www.w3.org/WAI/ARIA/apg/patterns/switch/) pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  let key = decode_key(key_event.key)

  case key {
    Space -> Some(Toggle)
    _ -> None
  }
}
