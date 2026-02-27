// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Move interaction helpers for Lustre components
////
//// Provides effect-based subscriptions for pointer move interactions.
//// Use these helpers to wire up drag interactions for color sliders and areas.
////
//// ## Usage
////
//// ```gleam
//// import lustre/effect.{type Effect}
//// import lustre_utils/interactions.{type MoveEvent}
//// import lustre_utils/interactions/move
////
//// type Model {
////   Model(hue: Float, slider_subscription: String)
//// }
////
//// type Msg {
////   SliderMove(MoveEvent)
////   SliderSubscribed(String)
////   SliderCleanup
//// }
////
//// fn init(_) -> #(Model, Effect(Msg)) {
////   #(
////     Model(0.0, ""),
////     move.subscribe_color_slider("slider-track", SliderMove, SliderSubscribed),
////   )
//// }
////
//// // IMPORTANT: Clean up subscriptions when component unmounts
//// fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
////   case msg {
////     SliderSubscribed(subscription_id) ->
////       #(Model(..model, slider_subscription: subscription_id), none())
////     SliderCleanup ->
////       #(model, move.unsubscribe_color_slider(model.slider_subscription))
////     // ... other messages
////   }
//// }
//// ```

import lustre/effect.{type Effect, from}
import lustre_utils/interactions.{type MoveEvent, decode_move_event}
import lustre_utils/interactions/ffi.{subscribe_move, unsubscribe_move}

// ============================================================================
// Color Slider Subscription
// ============================================================================

/// Subscribe to move events for a color slider track.
/// Takes an element ID and message constructors:
/// - `on_move`: receives MoveEvent messages while dragging
/// - `on_subscribed`: receives the subscription ID for cleanup
/// - `on_error`: receives error messages if JSON decoding fails
///
/// Returns an effect that sets up the subscription.
///
/// IMPORTANT: Call `unsubscribe_color_slider` with the subscription ID
/// when your component unmounts to prevent memory leaks.
pub fn subscribe_color_slider(
  element_id: String,
  on_move: fn(MoveEvent) -> msg,
  on_subscribed: fn(String) -> msg,
  on_error: fn(String) -> msg,
) -> Effect(msg) {
  from(fn(dispatch) {
    // Create a wrapped dispatch that decodes JSON and forwards MoveEvents
    let wrapped_dispatch = fn(json_string: String) {
      case decode_move_event(json_string) {
        Ok(move_event) -> dispatch(on_move(move_event))
        Error(error_msg) -> dispatch(on_error(error_msg))
      }
    }

    // Subscribe to move events
    let subscription_id = subscribe_move(element_id, wrapped_dispatch)

    // Notify parent of subscription ID for cleanup
    dispatch(on_subscribed(subscription_id))
  })
}

/// Unsubscribe from move events for a color slider.
/// Returns an effect that cleans up the subscription.
pub fn unsubscribe_color_slider(subscription_id: String) -> Effect(msg) {
  from(fn(_) {
    unsubscribe_move(subscription_id)
  })
}

// ============================================================================
// Color Area Subscription
// ============================================================================

/// Subscribe to move events for a color area.
/// Takes an element ID and message constructors:
/// - `on_move`: receives MoveEvent messages while dragging
/// - `on_subscribed`: receives the subscription ID for cleanup
/// - `on_error`: receives error messages if JSON decoding fails
///
/// Returns an effect that sets up the subscription.
///
/// IMPORTANT: Call `unsubscribe_color_area` with the subscription ID
/// when your component unmounts to prevent memory leaks.
pub fn subscribe_color_area(
  element_id: String,
  on_move: fn(MoveEvent) -> msg,
  on_subscribed: fn(String) -> msg,
  on_error: fn(String) -> msg,
) -> Effect(msg) {
  from(fn(dispatch) {
    // Create a wrapped dispatch that decodes JSON and forwards MoveEvents
    let wrapped_dispatch = fn(json_string: String) {
      case decode_move_event(json_string) {
        Ok(move_event) -> dispatch(on_move(move_event))
        Error(error_msg) -> dispatch(on_error(error_msg))
      }
    }

    // Subscribe to move events
    let subscription_id = subscribe_move(element_id, wrapped_dispatch)

    // Notify parent of subscription ID for cleanup
    dispatch(on_subscribed(subscription_id))
  })
}

/// Unsubscribe from move events for a color area.
/// Returns an effect that cleans up the subscription.
pub fn unsubscribe_color_area(subscription_id: String) -> Effect(msg) {
  from(fn(_) {
    unsubscribe_move(subscription_id)
  })
}

// ============================================================================
// Generic Subscription
// ============================================================================

/// Generic subscribe to move events for any element.
/// Takes an element ID and message constructors:
/// - `on_move`: receives MoveEvent messages
/// - `on_error`: receives error messages if JSON decoding fails
///
/// Returns an effect that sets up the subscription.
///
/// IMPORTANT: Call `unsubscribe_move` with the subscription ID
/// when your component unmounts to prevent memory leaks.
pub fn subscribe(
  element_id: String,
  on_move: fn(MoveEvent) -> msg,
  on_error: fn(String) -> msg,
) -> Effect(msg) {
  from(fn(dispatch) {
    // Create a wrapped dispatch that decodes JSON and forwards MoveEvents
    let wrapped_dispatch = fn(json_string: String) {
      case decode_move_event(json_string) {
        Ok(move_event) -> dispatch(on_move(move_event))
        Error(error_msg) -> dispatch(on_error(error_msg))
      }
    }

    // Subscribe to move events (ignore subscription ID for generic case)
    let _subscription_id = subscribe_move(element_id, wrapped_dispatch)
    Nil
  })
}
