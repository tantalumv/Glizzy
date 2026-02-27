// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Click-outside detection for Lustre components
////
//// Provides effect-based subscriptions to detect clicks outside an element.
//// Use this for closing menus, popovers, dialogs, etc. when clicking outside.
////
//// ## Usage
////
//// ```gleam
//// import lustre/effect.{type Effect}
//// import lustre_utils/click_outside
////
//// type Model {
////   Model(menu_open: Bool, click_outside_subscription: String)
//// }
////
//// type Msg {
////   ClickOutside
////   ClickOutsideSubscribed(String)
//// }
////
//// fn init(_) -> #(Model, Effect(Msg)) {
////   #(
////     Model(menu_open: False, click_outside_subscription: ""),
////     click_outside.subscribe("menu-element", ClickOutside, ClickOutsideSubscribed),
////   )
//// }
////
//// // IMPORTANT: Clean up subscriptions when component unmounts
//// fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
////   case msg {
////     ClickOutside ->
////       #(Model(..model, menu_open: False), none())
////     ClickOutsideSubscribed(subscription_id) ->
////       #(Model(..model, click_outside_subscription: subscription_id), none())
////     // ... other messages
////   }
//// }
//// ```

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode as decode
import gleam/json
import gleam/result
import lustre/effect.{type Effect, after_paint}

// ============================================================================
// Types
// ============================================================================

pub type ClickOutsideEvent {
  ClickOutsideEvent(target_id: String)
}

// ============================================================================
// JSON Decoding
// ============================================================================

pub fn decode_click_outside_event(json_string: String) -> Result(ClickOutsideEvent, String) {
  // Parse JSON string to Dynamic
  let dynamic_value = json_string |> json.parse(using: decode.dynamic)

  case dynamic_value {
    Error(_) -> Error("Failed to parse JSON")
    Ok(value) -> decode_click_outside_event_from_dynamic(value)
  }
}

fn decode_click_outside_event_from_dynamic(value: Dynamic) -> Result(ClickOutsideEvent, String) {
  use type_val <- result.try(get_string_field(value, "type"))
  case type_val {
    "click_outside" -> decode_click_outside(value)
    t -> Error("Unknown click outside event type: " <> t)
  }
}

fn decode_click_outside(value: Dynamic) -> Result(ClickOutsideEvent, String) {
  use target_id <- result.try(get_string_field(value, "targetId"))
  Ok(ClickOutsideEvent(target_id: target_id))
}

fn get_string_field(value: Dynamic, field: String) -> Result(String, String) {
  value
  |> decode.run(decode.field(field, decode.string, decode.success))
  |> result.map_error(decode_errors_to_string)
}

fn decode_errors_to_string(errors: List(decode.DecodeError)) -> String {
  case errors {
    [e, ..] -> decode_error_to_string(e)
    [] -> "Unknown error"
  }
}

fn decode_error_to_string(e: decode.DecodeError) -> String {
  "Decode error: expected " <> e.expected <> ", found " <> e.found
}

// ============================================================================
// Subscriptions
// ============================================================================

/// Subscribe to click-outside detection for an element.
/// Takes an element ID and message constructors:
/// - `on_click_outside`: receives ClickOutsideEvent messages when clicking outside
/// - `on_subscribed`: receives the subscription ID for cleanup
///
/// Returns an effect that sets up the subscription AFTER the DOM is updated.
///
/// IMPORTANT: Call `unsubscribe` with the subscription ID
/// when your component unmounts to prevent memory leaks.
pub fn subscribe(
  element_id: String,
  on_click_outside: fn(ClickOutsideEvent) -> msg,
  on_subscribed: fn(String) -> msg,
) -> Effect(msg) {
  // Use after_paint to ensure the element exists in the DOM
  after_paint(fn(dispatch, _root) {
    // Create a wrapped dispatch that decodes JSON and forwards ClickOutsideEvents
    let wrapped_dispatch = fn(json_string: String) {
      case decode_click_outside_event(json_string) {
        Ok(event) -> dispatch(on_click_outside(event))
        Error(_error_msg) -> {
          // Silently ignore decode errors for click outside
          // This can happen when clicking inside (click_inside events)
          Nil
        }
      }
    }

    // Subscribe to click outside events
    let config_json = "{}"
    let subscription_id = subscribe_click_outside_js(element_id, wrapped_dispatch, config_json)

    // Notify parent of subscription ID for cleanup
    dispatch(on_subscribed(subscription_id))
  })
}

/// Unsubscribe from click-outside detection.
/// Returns an effect that cleans up the subscription.
pub fn unsubscribe(subscription_id: String) -> Effect(msg) {
  after_paint(fn(_, _) {
    unsubscribe_click_outside_js(subscription_id)
  })
}

// ============================================================================
// FFI Bindings
// ============================================================================

@external(javascript, "./interactions/interactions.ffi.mjs", "subscribeClickOutside")
fn subscribe_click_outside_js(
  element_id: String,
  dispatch: fn(String) -> Nil,
  config_json: String,
) -> String

@external(javascript, "./interactions/interactions.ffi.mjs", "unsubscribeClickOutside")
fn unsubscribe_click_outside_js(subscription_id: String) -> Nil

@external(javascript, "./interactions/interactions.ffi.mjs", "updateClickOutsideElement")
fn update_click_outside_element_js(subscription_id: String, new_element_id: String) -> Nil

// ============================================================================
// Helpers
// ============================================================================

/// Update the element ID for an existing subscription.
/// Useful when the tracked element changes (e.g., conditional rendering).
pub fn update_element(subscription_id: String, new_element_id: String) -> Effect(msg) {
  after_paint(fn(_, _) {
    update_click_outside_element_js(subscription_id, new_element_id)
  })
}
