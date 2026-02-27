// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Focus helpers for Lustre components
////
//// Provides effect-based focus management for keyboard navigation and focus trapping.
////
//// ## Usage
////
//// ```gleam
//// import lustre/effect.{type Effect}
//// import lustre_utils/interactions/focus
////
//// type Msg {
////   FocusMenuItem(String)
////   FocusScopeCreated(String)
//// }
////
//// fn focus_menu_item(item_id: String) -> Effect(Msg) {
////   focus.focus_by_id(item_id)
//// }
////
//// fn create_focus_scope(container_id: String) -> Effect(Msg) {
////   focus.create_scope(container_id, FocusScopeCreated)
//// }
//// ```

import lustre/effect.{type Effect, after_paint, from}

/// Focus an element by its ID using effect.
/// Returns an effect that focuses the element after render.
pub fn focus_by_id(element_id: String) -> Effect(msg) {
  from(fn(_dispatch) {
    focus_element_js(element_id)
  })
}

/// Create a focus scope for focus trap management.
/// Returns an effect that creates the scope and dispatches the scope ID.
pub fn create_scope(
  container_id: String,
  on_created: fn(String) -> msg,
) -> Effect(msg) {
  from(fn(dispatch) {
    let scope_id = create_focus_scope_js(container_id)
    dispatch(on_created(scope_id))
  })
}

/// Destroy a focus scope and clean up resources.
pub fn destroy_scope(scope_id: String) -> Effect(msg) {
  from(fn(_) {
    destroy_focus_scope_js(scope_id)
  })
}

/// Focus the first focusable element within the scope.
pub fn focus_first(scope_id: String) -> Effect(msg) {
  after_paint(fn(_, _) {
    focus_scope_focus_first_js(scope_id)
  })
}

/// Focus the last focusable element within the scope.
pub fn focus_last(scope_id: String) -> Effect(msg) {
  after_paint(fn(_, _) {
    focus_scope_focus_last_js(scope_id)
  })
}

/// Enable or disable focus trapping within the scope.
pub fn trap_focus(scope_id: String, enabled: Bool) -> Effect(msg) {
  after_paint(fn(_, _) {
    focus_scope_trap_focus_js(scope_id, enabled)
  })
}

/// Enable focus trap on a container element by ID.
pub fn enable_trap(container_id: String) -> Effect(msg) {
  after_paint(fn(_, _) {
    enable_focus_trap_js(container_id)
  })
}

/// Disable focus trap on a container element by ID.
pub fn disable_trap(container_id: String) -> Effect(msg) {
  after_paint(fn(_, _) {
    disable_focus_trap_js(container_id)
  })
}

/// Get the ID of the currently focused element.
/// Returns an effect that dispatches the focused element ID.
pub fn get_focused_id(on_result: fn(String) -> msg) -> Effect(msg) {
  from(fn(dispatch) {
    let focused_id = get_focused_element_id_js()
    dispatch(on_result(focused_id))
  })
}

// ============================================================================
// FFI Bindings
// ============================================================================

@external(javascript, "./interactions.ffi.mjs", "createFocusScope")
fn create_focus_scope_js(container_id: String) -> String

@external(javascript, "./interactions.ffi.mjs", "destroyFocusScope")
fn destroy_focus_scope_js(scope_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusScopeFocusFirst")
fn focus_scope_focus_first_js(scope_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusScopeFocusLast")
fn focus_scope_focus_last_js(scope_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusScopeTrapFocus")
fn focus_scope_trap_focus_js(scope_id: String, enabled: Bool) -> Nil

@external(javascript, "./interactions.ffi.mjs", "enableFocusTrap")
fn enable_focus_trap_js(container_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "disableFocusTrap")
fn disable_focus_trap_js(container_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusElementById")
fn focus_element_js(element_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "getFocusedElementId")
fn get_focused_element_id_js() -> String
