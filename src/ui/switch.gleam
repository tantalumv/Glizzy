// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class, type_}
import lustre/element.{type Element}
import lustre/element/html.{div, input, label, span}
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
  // Build a switch component using the "checkbox hack" pattern
  // The input is positioned normally in the DOM but visually hidden
  // The visual switch is styled based on the input's :checked state
  html.div(
    [
      class("inline-flex items-center gap-2"),
    ],
    [
      // Wrapper for the switch control
      // The label wraps both the checkbox and visual span
      html.label(
        [
          class("relative inline-flex items-center cursor-pointer"),
        ],
        [
          // Native checkbox - visually hidden but remains focusable and clickable
          // Standard accessible switch pattern: absolute positioning, opacity 0, but full size
          input(list.append(
            [
              type_("checkbox"),
              attribute("role", "switch"),
              attribute("id", "switch-input"),
              attribute("tabindex", "0"),
              // Absolute positioning to fill label, opacity 0 but keep dimensions for focus
              class("peer"),
              attribute("style", "position:absolute;top:0;left:0;width:100%;height:100%;opacity:0.001;margin:0;padding:0;cursor:pointer"),
            ],
            attributes,
          )),
          // Visual switch track - styled based on checkbox state
          // pointer-events-none ensures clicks pass through to the checkbox
          html.span(
            [
              class(
                [
                  "peer-checked:bg-primary bg-input relative inline-flex h-6 w-11 shrink-0 rounded-full border-2 border-transparent transition-colors pointer-events-none",
                  css.focus_ring() <> " focus-visible:ring-offset-background",
                  css.disabled(),
                  "after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-background after:rounded-full after:h-5 after:w-5 after:transition-all",
                  "peer-checked:after:translate-x-full peer-checked:after:bg-primary-foreground rtl:peer-checked:after:-translate-x-full",
                ]
                |> string.join(" "),
              ),
            ],
            [],
          ),
        ],
      ),
      // Label content (visually displayed text)
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
