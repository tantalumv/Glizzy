//// Keyboard event decoding and view helpers for Glizzy components.
////
//// Provides a shared KeyEvent type with modifier keys and a helper
//// that decodes full DOM keyboard events for component keymaps.

// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{type Attribute}
import lustre/event

// ============================================================================
// Types
// ============================================================================

/// A decoded keyboard event with modifier key state.
pub type KeyEvent {
  KeyEvent(key: String, shift: Bool, ctrl: Bool, meta: Bool, alt: Bool)
}

// ============================================================================
// Key Type for Pattern Matching
// ============================================================================

/// A normalized key type for easier pattern matching in keymaps.
pub type Key {
  Space
  Enter
  Escape
  Tab
  Shift
  Control
  Alt
  Meta
  ArrowUp
  ArrowDown
  ArrowLeft
  ArrowRight
  Home
  End
  PageUp
  PageDown
  Delete
  Backspace
  F1
  F2
  F3
  F4
  F5
  F6
  F7
  F8
  F9
  F10
  F11
  F12
  Character(String)
  Unknown
}

/// Decode a key string from a KeyEvent into a normalized Key type.
pub fn decode_key(key_string: String) -> Key {
  case key_string {
    " " -> Space
    "Enter" -> Enter
    "Escape" -> Escape
    "Tab" -> Tab
    "Shift" -> Shift
    "Control" -> Control
    "Alt" -> Alt
    "Meta" -> Meta
    "ArrowUp" -> ArrowUp
    "ArrowDown" -> ArrowDown
    "ArrowLeft" -> ArrowLeft
    "ArrowRight" -> ArrowRight
    "Home" -> Home
    "End" -> End
    "PageUp" -> PageUp
    "PageDown" -> PageDown
    "Delete" -> Delete
    "Backspace" -> Backspace
    "F1" -> F1
    "F2" -> F2
    "F3" -> F3
    "F4" -> F4
    "F5" -> F5
    "F6" -> F6
    "F7" -> F7
    "F8" -> F8
    "F9" -> F9
    "F10" -> F10
    "F11" -> F11
    "F12" -> F12
    _ -> Character(key_string)
  }
}

// ============================================================================
// Navigation Helpers for Roving Tabindex
// ============================================================================

/// Calculate the next index in a circular list.
pub fn next_index(current: Int, item_count: Int, wrap: Bool) -> Int {
  case item_count {
    0 -> 0
    _ -> {
      let next = current + 1
      case next >= item_count {
        True if wrap -> 0
        True -> current
        False -> next
      }
    }
  }
}

/// Calculate the previous index in a circular list.
pub fn prev_index(current: Int, item_count: Int, wrap: Bool) -> Int {
  case item_count {
    0 -> 0
    _ -> {
      case current <= 0 {
        True if wrap -> item_count - 1
        True -> current
        False -> current - 1
      }
    }
  }
}

/// Get the first index (always 0).
pub fn first_index(item_count: Int) -> Int {
  case item_count {
    0 -> 0
    _ -> 0
  }
}

/// Get the last index.
pub fn last_index(item_count: Int) -> Int {
  case item_count {
    0 -> 0
    _ -> item_count - 1
  }
}

// ============================================================================
// Type-Ahead Helper
// ============================================================================

/// Default timeout for type-ahead buffer in milliseconds.
pub const default_typeahead_timeout_ms = 500

/// Update type-ahead buffer with new character.
pub fn update_typeahead_buffer(
  current_buffer: String,
  last_keypress_time: Int,
  current_time: Int,
  new_char: String,
  timeout_ms: Int,
) -> #(String, Bool) {
  let timeout_expired = current_time - last_keypress_time > timeout_ms

  case timeout_expired {
    True -> #(new_char, True)
    False -> #(current_buffer <> new_char, False)
  }
}

/// Find the next item that starts with the given buffer string.
pub fn typeahead_match(items: List(String), current: Int, buffer: String) -> Int {
  let normalized_buffer = string.lowercase(buffer)
  let items_from_next = items |> list.drop(current + 1)
  let items_wrapped = items |> list.take(current + 1)

  case
    find_matching_buffer_index(items_from_next, normalized_buffer, current + 1)
  {
    Some(index) -> index
    None ->
      find_matching_buffer_index(items_wrapped, normalized_buffer, 0)
      |> option.unwrap(current)
  }
}

fn find_matching_buffer_index(
  items: List(String),
  buffer: String,
  offset: Int,
) -> Option(Int) {
  case items {
    [] -> None
    [item, ..rest] -> {
      case string.starts_with(string.lowercase(item), buffer) {
        True -> Some(offset)
        False -> find_matching_buffer_index(rest, buffer, offset + 1)
      }
    }
  }
}

/// Find the next item that starts with the given character.
pub fn type_ahead_match(items: List(String), current: Int, char: String) -> Int {
  let normalized_char = string.lowercase(char)
  let items_from_next = items |> list.drop(current + 1)
  let items_wrapped = items |> list.take(current + 1)

  case find_matching_index(items_from_next, normalized_char, current + 1) {
    Some(index) -> index
    None ->
      find_matching_index(items_wrapped, normalized_char, 0)
      |> option.unwrap(current)
  }
}

fn find_matching_index(
  items: List(String),
  char: String,
  offset: Int,
) -> Option(Int) {
  case items {
    [] -> None
    [item, ..rest] -> {
      case string.starts_with(string.lowercase(item), char) {
        True -> Some(offset)
        False -> find_matching_index(rest, char, offset + 1)
      }
    }
  }
}

// ============================================================================
// Key Classification Helpers
// ============================================================================

/// Check if a key is a navigation key.
pub fn is_navigation_key(key: Key) -> Bool {
  case key {
    ArrowUp
    | ArrowDown
    | ArrowLeft
    | ArrowRight
    | Home
    | End
    | PageUp
    | PageDown -> True
    _ -> False
  }
}

/// Check if a key is an activation key.
pub fn is_activation_key(key: Key) -> Bool {
  case key {
    Enter | Space -> True
    _ -> False
  }
}

/// Check if a key is a character key.
pub fn is_character_key(key: Key) -> Bool {
  case key {
    Character(_) -> True
    _ -> False
  }
}

// ============================================================================
// View Helpers
// ============================================================================

/// Attach a keydown handler that decodes the full KeyEvent with modifier keys.
pub fn on_keydown(handler: fn(KeyEvent) -> msg) -> Attribute(msg) {
  event.on("keydown", {
    use key <- decode.field("key", decode.string)
    use shift <- decode.field("shiftKey", decode.bool)
    use ctrl <- decode.field("ctrlKey", decode.bool)
    use meta <- decode.field("metaKey", decode.bool)
    use alt <- decode.field("altKey", decode.bool)
    decode.success(handler(KeyEvent(key:, shift:, ctrl:, meta:, alt:)))
  })
}

/// Attach a keydown handler with preventDefault for all dispatched keys.
pub fn on_keydown_prevent(handler: fn(KeyEvent) -> msg) -> Attribute(msg) {
  event.prevent_default(on_keydown(handler))
}
