// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute, attribute, class}
import lustre/element.{type Element}
import lustre/element/html
import ui/css
import ui/keyboard
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

pub type MenuTrigger {
  Input
  Focus
  Manual
}

pub fn combobox(attributes: List(Attribute(a))) -> Element(a) {
  html.div([class("relative")], [
    html.input([
      class(
        [
          "flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
          css.disabled(),
        ]
        |> string.join(" "),
      ),
      attribute("type", "text"),
      attribute("role", "combobox"),
      attribute("aria-autocomplete", "list"),
      attribute("aria-expanded", "false"),
      attribute("aria-haspopup", "listbox"),
      attribute("aria-controls", "combobox-list"),
      attribute("autocomplete", "off"),
      attribute("data-combobox-input", "true"),
      ..attributes
    ]),
    html.button(
      [
        class(
          [
            "absolute right-1 top-1/2 -translate-y-1/2",
            "inline-flex items-center justify-center",
            "h-8 w-8",
            "text-muted-foreground",
          ]
          |> string.join(" "),
        ),
        attribute("type", "button"),
        attribute("tabindex", "-1"),
        attribute("aria-label", "Toggle menu"),
        attribute("data-combobox-trigger", "true"),
      ],
      [
        chevron_icon([]),
      ],
    ),
  ])
}

pub fn input_field(attributes: List(Attribute(a))) -> Element(a) {
  html.input([
    class(
      [
        "flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm",
        "placeholder:text-muted-foreground",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
        css.disabled(),
      ]
      |> string.join(" "),
    ),
    attribute("type", "text"),
    attribute("role", "combobox"),
    attribute("aria-autocomplete", "list"),
    attribute("aria-expanded", "false"),
    attribute("aria-haspopup", "listbox"),
    attribute("autocomplete", "off"),
    ..attributes
  ])
}

pub fn listbox(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.ul(
    [
      class(
        [
          "absolute top-full left-0 z-50 mt-1 w-full",
          "max-h-60 overflow-auto",
          "border bg-background rounded-md shadow-lg p-1",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        ]
        |> string.join(" "),
      ),
      attribute("role", "listbox"),
      attribute("id", "combobox-list"),
      attribute("aria-label", "Options"),
      ..attributes
    ],
    children,
  )
}

pub fn option(
  attributes: List(Attribute(a)),
  label: String,
  option_value: String,
) -> Element(a) {
  html.li(
    [
      class(
        [
          "relative flex items-center cursor-pointer select-none py-2 px-3 text-sm rounded-sm",
          "outline-none",
          "hover:bg-accent hover:text-accent-foreground",
          "data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground",
          "data-[selected]:bg-primary data-[selected]:text-primary-foreground",
          "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        ]
        |> string.join(" "),
      ),
      attribute("role", "option"),
      attribute("data-value", option_value),
      attribute("aria-selected", "false"),
      ..attributes
    ],
    [html.text(label)],
  )
}

pub fn option_group(
  attributes: List(Attribute(a)),
  label: String,
  children: List(Element(a)),
) -> Element(a) {
  html.div(
    [
      class("py-1.5 px-2"),
      attribute("role", "group"),
      attribute("data-group", "true"),
      ..attributes
    ],
    [
      html.div(
        [
          class("px-2 py-1.5 text-xs font-semibold text-muted-foreground"),
        ],
        [html.text(label)],
      ),
      html.ul([class("space-y-0.5")], children),
    ],
  )
}

pub fn empty_state(attributes: List(Attribute(a))) -> Element(a) {
  html.div(
    [
      class("py-6 text-center text-sm text-muted-foreground"),
      attribute("data-combobox-empty", "true"),
      ..attributes
    ],
    [],
  )
}

pub fn chevron_icon(_attributes: List(Attribute(a))) -> Element(a) {
  html.i(
    [class("ri ri-arrow-down-s-line h-4 w-4"), attribute("aria-hidden", "true")],
    [],
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
    Small -> class(size_helpers.input_class(size_helpers.Small))
    Medium -> class(size_helpers.input_class(size_helpers.Medium))
    Large -> class(size_helpers.input_class(size_helpers.Large))
  }
}

pub fn menu_trigger(mt: MenuTrigger) -> Attribute(a) {
  case mt {
    Input -> attribute("data-menu-trigger", "input")
    Focus -> attribute("data-menu-trigger", "focus")
    Manual -> attribute("data-menu-trigger", "manual")
  }
}

pub fn required() -> Attribute(a) {
  attribute("aria-required", "true")
}

pub fn disabled() -> Attribute(a) {
  attribute("aria-disabled", "true")
}

pub fn invalid() -> Attribute(a) {
  attribute("aria-invalid", "true")
}

pub fn placeholder(placeholder: String) -> Attribute(a) {
  attribute("placeholder", placeholder)
}

pub fn value(val: String) -> Attribute(a) {
  attribute("value", val)
}

pub fn allows_custom_value() -> Attribute(a) {
  attribute("data-allows-custom-value", "true")
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keyboard messages for combobox component.
pub type Msg {
  /// Open the dropdown (ArrowDown, ArrowUp, Alt+ArrowDown, Alt+ArrowUp)
  Open
  /// Close the dropdown (Escape)
  Close
  /// Move to next option (ArrowDown)
  MoveNext
  /// Move to previous option (ArrowUp)
  MovePrev
  /// Move to first option (Home)
  MoveFirst
  /// Move to last option (End)
  MoveLast
  /// Select the currently highlighted option (Enter)
  Select
  /// Type-ahead search (Character keys)
  TypeAhead(String)
  /// Select and close (Enter)
  SelectAndClose
  /// Clear the input (Escape when open)
  Clear
}

/// Keymap for combobox keyboard navigation.
/// Follows WAI-ARIA combobox pattern:
/// - ArrowDown/ArrowUp: Open dropdown and navigate
/// - Alt+ArrowDown/Alt+ArrowUp: Open dropdown
/// - Escape: Close dropdown
/// - Enter: Select highlighted option
/// - Character: Type-ahead search and filter
pub fn keymap(key_event: keyboard.KeyEvent, is_open: Bool) -> Option(Msg) {
  case is_open {
    False -> {
      // When closed, only open keys work
      case keyboard.decode_key(key_event.key) {
        keyboard.ArrowDown | keyboard.ArrowUp -> Some(Open)
        keyboard.Character(c) -> Some(TypeAhead(c))
        _ -> None
      }
    }
    True -> {
      // When open, navigation keys work
      case keyboard.decode_key(key_event.key) {
        keyboard.Escape -> Some(Close)
        keyboard.ArrowDown -> Some(MoveNext)
        keyboard.ArrowUp -> Some(MovePrev)
        keyboard.Home -> Some(MoveFirst)
        keyboard.End -> Some(MoveLast)
        keyboard.Enter -> Some(SelectAndClose)
        keyboard.Character(c) -> Some(TypeAhead(c))
        _ -> None
      }
    }
  }
}

/// Get the element ID for a combobox option at the given index.
pub fn option_element_id(index: Int) -> String {
  "combobox-option-" <> int.to_string(index)
}

/// Get the element ID for the combobox input.
pub fn input_element_id() -> String {
  "combobox-input"
}

/// Get the element ID for the combobox listbox.
pub fn listbox_element_id() -> String {
  "combobox-listbox"
}

/// Attribute to indicate expanded state.
pub fn aria_expanded(expanded: Bool) -> Attribute(a) {
  attribute("aria-expanded", case expanded {
    True -> "true"
    False -> "false"
  })
}

/// Attribute to indicate the currently active descendant.
pub fn aria_activedescendant(id: String) -> Attribute(a) {
  attribute("aria-activedescendant", id)
}

/// Attribute to indicate controls relationship.
pub fn aria_controls(id: String) -> Attribute(a) {
  attribute("aria-controls", id)
}
